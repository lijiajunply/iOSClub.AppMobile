import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/net/edu_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/pageModels/course_color_manager.dart';
import 'package:ios_club_app/net/club_service.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/stores/user_store.dart';
import 'package:ios_club_app/widgets/study_credit_card.dart';

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
  bool _showLoginForm = false; // 新增状态，控制是否显示登录表单
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 检查是否已有登录信息
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(PrefsKeys.USERNAME);
    final iosName = prefs.getString(PrefsKeys.CLUB_NAME);

    if (userStore.isLogin && username != null) {
      _username = username;
    }
    if (userStore.isLoginMember && iosName != null) {
      _username = iosName;
    }

    if (!userStore.isLogin && !userStore.isLoginMember) {
      // 没有登录信息，进入游客模式
      await _enterGuestMode();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showClubSnackBar(
        context,
        const Text('用户名和密码不能为空'),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool eduLoginSuccess = true;
    bool clubLoginSuccess = true;

    // 登录教务系统账号
    if (!_isOnlyLoginMember) {
      eduLoginSuccess = await _loginToEduSystem();
    }

    // 登录社团账号
    if (_isOnlyLoginMember || _isLoginMember) {
      clubLoginSuccess = await _loginToClub();
    }

    // 检查登录结果
    if (!eduLoginSuccess || !clubLoginSuccess) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 保存登录信息
    await _saveLoginInfo();

    // 更新UI状态
    setState(() {
      _isLoading = false;
      _isOnlyLoginMember = false;
      _showLoginForm = false;
    });

    // 清空输入框
    _usernameController.clear();
    _passwordController.clear();
    if (_isLoginMember) {
      _nameController.clear();
    }
  }

  /// 登录教务系统
  Future<bool> _loginToEduSystem() async {
    bool result = false;
    for (var i = 0; i < 3; i++) {
      result = await EduService.loginFromData(
        _usernameController.text,
        _passwordController.text,
      );
      if (result) break;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('正在重试'),
        );
      }
    }

    if (!result && mounted) {
      showClubSnackBar(
        context,
        const Text('登录失败，请检查用户名和密码'),
      );
    }

    if (result) {
      setState(() {
        _username = _usernameController.text;
      });
    }

    return result;
  }

  /// 登录社团账号
  Future<bool> _loginToClub() async {
    // 验证输入
    if (_isOnlyLoginMember && _usernameController.text.isEmpty) {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('登录社团账号时姓名不能为空'),
        );
      }
      return false;
    }

    if (_isLoginMember && _nameController.text.isEmpty) {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('登录社团账号时姓名不能为空'),
        );
      }
      return false;
    }

    bool result = false;
    if (_isOnlyLoginMember) {
      // 仅登录社团账号：用户名(姓名)和密码(学号)
      result = await ClubService.loginMember(
        _usernameController.text,
        _passwordController.text,
      );
    } else if (_isLoginMember) {
      // 同时登录两个账号：姓名和学号
      result = await ClubService.loginMember(
        _nameController.text,
        _usernameController.text,
      );
    }

    if (!result && mounted) {
      showClubSnackBar(
        context,
        const Text('社团账号登陆失败'),
      );
    }

    if (result) {
      setState(() {
        _username = _isOnlyLoginMember
            ? _usernameController.text
            : _nameController.text;
      });
    }

    return result;
  }

  /// 保存登录信息
  Future<void> _saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (_isOnlyLoginMember) {
      // 仅登录社团账号
      await prefs.setString(PrefsKeys.CLUB_NAME, _usernameController.text);
      await prefs.setString(PrefsKeys.CLUB_ID, _passwordController.text);
      userStore.setLoginMember();
    } else if (!_isOnlyLoginMember && !_isLoginMember) {
      // 仅登录教务系统
      await prefs.setString(PrefsKeys.USERNAME, _usernameController.text);
      await prefs.setString(PrefsKeys.PASSWORD, _passwordController.text);
      final userDataString = prefs.getString(PrefsKeys.USER_DATA);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        userStore.setUserData(UserData.fromJson(userData));
      }
    }

    // 同时登录两个账号的情况
    if (_isLoginMember) {
      await prefs.setString(PrefsKeys.CLUB_NAME, _nameController.text);
      await prefs.setString(PrefsKeys.CLUB_ID, _passwordController.text);
      userStore.setLoginMember();
    }
  }

  Future<void> _enterGuestMode() async {
    // 更新 UserStore 状态
    await userStore.logout();

    setState(() {
      _isLoading = false;
      _showLoginForm = false; // 确保隐藏登录表单
    });
  }

  Future<void> _enterLoginMode() async {
    setState(() {
      _isLoading = false;
      _showLoginForm = true; // 显示登录表单
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

    // 根据状态决定显示登录表单还是用户信息界面
    if (_showLoginForm) {
      return Scaffold(
        body: _buildLoginForm(),
      );
    } else {
      return Scaffold(
        body: Obx(() => _buildProfileContent()),
      );
    }
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
        child: Column(
      children: [
        if (_isOnlyLoginMember)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isOnlyLoginMember = false;
                          _passwordController.clear();
                          _showLoginForm = false; // 添加这行代码来隐藏登录表单
                        });
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const Text(
                    '登录社团账号',
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              )),
        if (!_isOnlyLoginMember)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMember = false;
                            _nameController.clear();
                            _showLoginForm = false; // 添加这行代码来隐藏登录表单
                          });
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      '登录教务系统账号',
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ])),
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
                        if (!userStore.isLoginMember)
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
                        SizedBox(
                          width: 1,
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
              ],
            ))
      ],
    ));
  }

  List<ProfileButtonItem> get profileButtonItems {
    return [
      ProfileButtonItem(
          icon: CupertinoIcons.link_circle, title: '建大导航', route: '/Link'),
      ProfileButtonItem(icon: Icons.settings, title: '设置/关于', route: '/About'),
      ProfileButtonItem(
          title: '校车', icon: Icons.directions_bus_rounded, route: '/SchoolBus'),
      ProfileButtonItem(
          icon: Icons.apple,
          title: userStore.isLoginMember ? '社团详情' : '登录社团iMember',
          onPressed: () {
            if (!userStore.isLoginMember) {
              setState(() {
                _isOnlyLoginMember = true;
                _showLoginForm = true;
              });
            } else {
              Navigator.pushNamed(context, '/iMember');
            }
          }),
      if (!kIsWeb)
        ProfileButtonItem(
            icon: CupertinoIcons.bolt_fill, title: '电费', route: '/Electricity'),
      if (userStore.isLogin)
        ProfileButtonItem(icon: Icons.toc, title: '培养方案', route: '/Program'),
      ProfileButtonItem(
          icon: Icons.monetization_on_outlined, title: '饭卡', route: '/Payment'),
      if (!kIsWeb)
        ProfileButtonItem(
            icon: Icons.wifi_outlined, title: '校园网', route: '/Net'),
      if (!userStore.isLogin)
        ProfileButtonItem(
            icon: Icons.login,
            title: '登录教务系统',
            onPressed: () {
              setState(() {
                _isLoading = true;
                _showLoginForm = true;
              });
              _enterLoginMode();
            }),
      ProfileButtonItem(
          icon: Icons.help_outline, title: '帮助', route: '/Helper'),
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
                          _username.isNotEmpty ? _username : '未登录',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          userStore.isLogin && userStore.isLoginMember
                              ? '教务系统账号 & iMember账号'
                              : userStore.isLogin
                                  ? '教务系统账号'
                                  : userStore.isLoginMember
                                      ? 'iMember账号'
                                      : '游客',
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
          if (userStore.isLogin) const SizedBox(height: 16),
          if (userStore.isLogin)
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
                        color: CourseColorManager.generateSoftColor(title,
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
