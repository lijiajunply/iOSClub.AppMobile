import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:ios_club_app/Services/EduService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Services/ClubService.dart';
import '../Widgets/StudyCreditCard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool _isLoggedIn = false;
  String _username = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = true;
  bool _isLoginMember = false;
  bool _isOnlyLoginMember = false;

  /// true为 都登录状态，false为教务系统登录状态
  late bool _isBoth = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    final iosName = prefs.getString('club_name');

    setState(() {
      _isLoggedIn = username != null &&
          password != null &&
          username.isNotEmpty &&
          password.isNotEmpty;

      _username = username ?? '';
      _isLoading = false;

      if (iosName == null || iosName.isEmpty) {
        _isBoth = false;
      } else {
        _username = iosName;
        _isBoth = true;
      }
    });
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名和密码不能为空')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = false;

    // 登录教务系统账号
    if (!_isOnlyLoginMember) {
      for (var i = 0; i < 3; i++) {
        result = await EduService.loginFromData(
          _usernameController.text,
          _passwordController.text,
        );
        if (result) break;
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('正在重试')),
          );
        }
      }

      if (!result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录失败，请检查用户名和密码')),
          );
        }

        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        return;
      }
    }

    // 登录社团账号
    if (_isOnlyLoginMember || _isLoginMember) {
      if ((_nameController.text.isEmpty && _isOnlyLoginMember) &&
          (_isLoginMember && _usernameController.text.isEmpty) &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录社团账号时姓名不能为空')),
        );
      } else {
        if (_isOnlyLoginMember) {
          result = await ClubService.loginMember(
            _usernameController.text,
            _passwordController.text,
          );
        } else if (_isLoginMember) {
          result = await ClubService.loginMember(
            _nameController.text,
            _usernameController.text,
          );
        }
      }
    }

    if (!result) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('社团账号登陆失败')),
        );
      }

      if (_isOnlyLoginMember == true) {
        _isOnlyLoginMember = false;
      }
      if (_isLoginMember == true) {
        _isLoginMember = false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (_isOnlyLoginMember) {
      await prefs.setString('club_name', _usernameController.text);
      await prefs.setString('club_id', _passwordController.text);
    } else {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    }

    if (_isLoginMember) {
      await prefs.setString('club_name', _nameController.text);
      await prefs.setString('club_id', _usernameController.text);
    }

    setState(() {
      _isLoggedIn = true;
      _username = _usernameController.text;
      _isLoading = false;
      _isBoth = _isOnlyLoginMember || _isLoginMember;
    });

    _usernameController.clear();
    _passwordController.clear();

    if (_isLoginMember) {
      _nameController.clear();
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _isLoggedIn = false;
      _username = '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        body: _isLoggedIn ? _buildProfileContent() : _buildLoginForm());
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/icon.png',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800] // 暗色模式下的背景
                        : Colors.grey[100],
                    prefixIcon: Icon(Icons.person_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300] // 暗色模式下的图标颜色
                            : Colors.grey[700] // 亮色模式下的图标颜色
                        ),
                    hintText: _isOnlyLoginMember ? '姓名' : '学号',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 密码输入框
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800] // 暗色模式下的背景
                        : Colors.grey[100],
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300] // 暗色模式下的图标颜色
                            : Colors.grey[700] // 亮色模式下的图标颜色
                        ),
                    hintText: _isOnlyLoginMember ? '学号' : '教务系统密码',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_isLoginMember) const SizedBox(height: 16),
                if (_isLoginMember)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // 暗色模式下的背景
                          : Colors.grey[100],
                      prefixIcon: Icon(Icons.person_outline,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300] // 暗色模式下的图标颜色
                              : Colors.grey[700] // 亮色模式下的图标颜色
                          ),
                      hintText: '姓名（登录社团账号时必填）',
                      //李嘉俊
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!_isOnlyLoginMember)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isLoginMember,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _isLoginMember = value;
                                });
                              },
                            ),
                            const Text('登录社团账号'),
                          ],
                        ),
                        TextButton(
                            onPressed: () async {
                              if (await canLaunchUrl(Uri.parse(
                                  'https://swjw.xauat.edu.cn/security-center//password-reset/identity-check-form'))) {
                                await launchUrl(
                                    Uri.parse(
                                        'https://swjw.xauat.edu.cn/security-center//password-reset/identity-check-form'),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text('忘记密码?'))
                      ]),
                if (!_isOnlyLoginMember) const SizedBox(height: 16),
                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/icon.png'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _isBoth ? 'iMember账号' : '教务系统账号',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _logout,
                  label: const Text(
                    '退出登录',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RawMaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/Todo');
                              },
                              child: const Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.square_list,
                                    size: 32,
                                  ),
                                  Text(
                                    '待办事务',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ],
                              )),
                          RawMaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/Link');
                              },
                              child: const Column(
                                children: [
                                  Icon(CupertinoIcons.link_circle, size: 32),
                                  Text(
                                    '建大导航',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ],
                              )),
                          RawMaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/About');
                              },
                              child: const Column(
                                children: [
                                  Icon(Icons.info_outline, size: 32),
                                  Text(
                                    '设置/关于',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RawMaterialButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/SchoolBus');
                                },
                                child: const Column(children: [
                                  Icon(Icons.directions_bus_rounded, size: 32),
                                  Text(
                                    '校车',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  )
                                ])),
                            RawMaterialButton(
                                onPressed: () {
                                  if (!_isBoth) {
                                    setState(() {
                                      _isLoggedIn = false;
                                      _isOnlyLoginMember = true;
                                    });
                                  } else {
                                    Navigator.pushNamed(context, '/iMember');
                                  }
                                },
                                child: Column(children: [
                                  const Icon(Icons.apple, size: 32),
                                  Text(
                                    _isBoth ? '社团详情' : '登录社团iMember',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  )
                                ])),
                            RawMaterialButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/Other');
                                },
                                child: const Column(children: [
                                  Icon(Icons.apps, size: 32),
                                  Text(
                                    '其他',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  )
                                ])),
                          ])
                    ])),
              )),
          FutureBuilder(
              future: DataService.getInfoList(),
              builder: (context, snapshot) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) =>
                              StudyCreditCard(data: snapshot.data![index]))
                      : const CircularProgressIndicator())),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
