import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/Services/data_service.dart';
import 'package:ios_club_app/Services/edu_service.dart';
import 'package:ios_club_app/widgets/ClubCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../PageModels/CourseColorManager.dart';
import '../Services/club_service.dart';
import '../stores/prefs_keys.dart';
import '../stores/settings_store.dart';
import '../stores/user_store.dart';
import '../widgets/study_credit_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserStore userStore = UserStore.to;
  final SettingsStore settingsStore = SettingsStore.to;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = true;
  bool _isLoginMember = false;
  bool _isOnlyLoginMember = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = false;
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
      await prefs.setString(PrefsKeys.MEMBER_DATA, _usernameController.text);
      await prefs.setString(PrefsKeys.MEMBER_JWT, _passwordController.text);
    } else {
      await prefs.setString(PrefsKeys.USERNAME, _usernameController.text);
      await prefs.setString(PrefsKeys.PASSWORD, _passwordController.text);
    }

    if (_isLoginMember) {
      await prefs.setString(PrefsKeys.MEMBER_DATA, _nameController.text);
      await prefs.setString(PrefsKeys.MEMBER_JWT, _usernameController.text);
    }
    
    // 退出游客模式
    await prefs.setBool(PrefsKeys.IS_UPDATE_CLUB, false);
    await settingsStore.setIsUpdateToClub(false);

    setState(() {
      _isLoading = false;
      _isOnlyLoginMember = false;
      _isLoginMember = false;
    });

    _usernameController.clear();
    _passwordController.clear();

    if (_isLoginMember) {
      _nameController.clear();
    }
  }
  
  Future<void> _enterGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_UPDATE_CLUB, true);
    await settingsStore.setIsUpdateToClub(true);
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.USERNAME);
    await prefs.remove(PrefsKeys.PASSWORD);
    await prefs.remove(PrefsKeys.MEMBER_DATA);
    await prefs.remove(PrefsKeys.MEMBER_JWT);
    
    await userStore.logout();
  }

  Future<void> _enterLoginMode() async {
    setState(() {
      _isLoading = false;
    });
    
    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
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
        body: (userStore.isLogin || settingsStore.isUpdateToClub) ? _buildProfileContent() : _buildLoginForm());
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
        child: Column(
      children: [
        if (_isOnlyLoginMember)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isOnlyLoginMember = false;
                          _passwordController.clear();
                        });
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 8),
                  const Text(
                    '登录社团账号',
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              )),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon.webp',
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
                    hintText: _isOnlyLoginMember ? '学号' : '统一身份认证密码',
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
                                  'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form'))) {
                                await launchUrl(
                                    Uri.parse(
                                        'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form'),
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
                const SizedBox(height: 16),
                // 游客模式按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _enterGuestMode,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '游客模式',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ))
      ],
    ));
  }

  List<ProfileButtonItem> get profileButtonItems {
    // 游客模式下仅限制培养方案功能
    if (settingsStore.isUpdateToClub) {
      return [
        ProfileButtonItem(
            icon: CupertinoIcons.link_circle, title: '建大导航', route: '/Link'),
        ProfileButtonItem(icon: Icons.settings, title: '设置/关于', route: '/About'),
        ProfileButtonItem(
            title: '校车', icon: Icons.directions_bus_rounded, route: '/SchoolBus'),
        ProfileButtonItem(
            icon: Icons.apple,
            title: '登录社团iMember',
            onPressed: () {
              setState(() {
                _isOnlyLoginMember = true;
              });
            }),
        ProfileButtonItem(
            icon: CupertinoIcons.bolt_fill, title: '电费', route: '/Electricity'),
        ProfileButtonItem(
            icon: Icons.toc, 
            title: '培养方案', 
            onPressed: () {
              // 游客模式下提示需要登录
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('此功能需要登录后使用')),
              );
            }),
        ProfileButtonItem(
            icon: Icons.monetization_on_outlined, title: '饭卡', route: '/Payment'),
        ProfileButtonItem(icon: Icons.wifi_outlined, title: '校园网', route: '/Net'),
      ];
    }
    
    return [
      ProfileButtonItem(
          icon: CupertinoIcons.link_circle, title: '建大导航', route: '/Link'),
      ProfileButtonItem(icon: Icons.settings, title: '设置/关于', route: '/About'),
      ProfileButtonItem(
          title: '校车', icon: Icons.directions_bus_rounded, route: '/SchoolBus'),
      ProfileButtonItem(
          icon: Icons.apple,
          title: userStore.isLogin ? '社团详情' : '登录社团iMember',
          onPressed: () {
            if (!userStore.isLogin) {
              setState(() {
                _isOnlyLoginMember = true;
              });
            } else {
              Navigator.pushNamed(context, '/iMember');
            }
          }),
      ProfileButtonItem(
          icon: CupertinoIcons.bolt_fill, title: '电费', route: '/Electricity'),
      ProfileButtonItem(icon: Icons.toc, title: '培养方案', route: '/Program'),
      ProfileButtonItem(
          icon: Icons.monetization_on_outlined, title: '饭卡', route: '/Payment'),
      ProfileButtonItem(icon: Icons.wifi_outlined, title: '校园网', route: '/Net'),
    ];
  }

  Widget _buildProfileContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

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
                    const Image(
                      width: 48,
                      height: 48,
                      image: AssetImage('assets/icon.webp'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userStore.userData?.studentId ?? '未登录',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          settingsStore.isUpdateToClub 
                            ? '游客模式' 
                            : userStore.isLogin ? 'iMember账号' : '教务系统账号',
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
                if (settingsStore.isUpdateToClub)
                  IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: _enterLoginMode,
                  )
                else if (!settingsStore.isUpdateToClub && userStore.isLogin)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
              ],
            ),
          ),
          ClubCard(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 6 : 3,
                  ),
                  itemBuilder: (context, index) {
                    return Center(
                      child: profileButtonItems[index].build(),
                    );
                  },
                  itemCount: profileButtonItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                )),
          ),
          const SizedBox(height: 16),
          if (!settingsStore.isUpdateToClub)
            FutureBuilder(
                future: DataService.getInfoList(),
                builder: (context, snapshot) => snapshot.hasData
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) =>
                            StudyCreditCard(data: snapshot.data![index]))
                    : const CircularProgressIndicator()),
          if (settingsStore.isUpdateToClub)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '您当前处于游客模式，部分功能受限。登录后可享受完整功能。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
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

class ProfileButtonItem {
  final String title;
  final IconData icon;
  String route = '';
  Function? onPressed;

  ProfileButtonItem(
      {required this.title,
      required this.icon,
      this.route = '',
      this.onPressed});

  Widget build() {
    return Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                    tag: title,
                    child: Icon(icon,
                        size: 32,
                        color: CourseColorManager.generateSoftColor(icon,
                            isDark: true))),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                )
              ],
            ),
          ),
          onTap: () {
            if (route.isEmpty) {
              onPressed?.call();
            } else {
              Get.toNamed(route);
            }
          },
        ));
  }
}