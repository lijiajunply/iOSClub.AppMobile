import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/InfoModel.dart';
import 'package:ios_club_app/Services/DataService.dart';
import 'package:ios_club_app/Services/EduService.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _obscureText = true;
  bool _isLoading = true;
  late bool? _isBoth;
  late final TabController _tabController;
  late List<InfoModel> _info;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    final iosName = prefs.getString('iosName');

    final dataService = DataService();
    final a = await dataService.getInfoList();
    setState(() {
      _isLoggedIn = username != null &&
          password != null &&
          username.isNotEmpty &&
          password.isNotEmpty;
      _username = username ?? '';
      _isLoading = false;
      _info = a;
      if (iosName == null || iosName.isNotEmpty) {
        _isBoth = false;
      } else {
        _username = iosName;
        if (_isLoggedIn) _isBoth = true;
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

    final edu = EduService();
    var result = false;

    for (var i = 0; i < 3; i++) {
      result = await edu.loginFromData(
        _usernameController.text,
        _passwordController.text,
      );
      if (result) break;
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在重试')),
      );
    }

    if (!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败，请检查用户名和密码')),
      );

      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);

    setState(() {
      _isLoggedIn = true;
      _username = _usernameController.text;
      _isLoading = false;
    });

    _usernameController.clear();
    _passwordController.clear();
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
    final width = MediaQuery.of(context).size.width;
    var a = width / 5;
    if (width > 600) {
      a = width / 7;
    }
    return Scaffold(
      body: Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: a),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/icon.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      text: '教务系统',
                    ),
                    Tab(
                      text: 'iMember',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon: const Icon(Icons.person_outline),
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
                    fillColor: Colors.grey[100],
                    prefixIcon: const Icon(Icons.lock_outline),
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
                const SizedBox(height: 16),
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
            )),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 247, 247, 0.6),
            ),
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
                        //const SizedBox(height: 8),
                        Text(
                          _isBoth == null
                              ? 'iMember'
                              : _isBoth!
                                  ? 'iMember & 教务系统账号'
                                  : '教务系统账号',
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
                  label: const Text('退出登录'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _info.length,
                  itemBuilder: (context, index) =>
                      StudyCreditCard(data: _info[index])))
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
