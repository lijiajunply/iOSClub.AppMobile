import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelperPage extends StatefulWidget {
  const HelperPage({super.key});

  @override
  State<HelperPage> createState() => _HelperPageState();
}

class _HelperPageState extends State<HelperPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _tabs = [
    '功能介绍',
    '使用说明',
    '注意事项',
    '平台适配',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();

    // 监听 TabController 变化
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '帮助',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: [
          _buildFeaturesPage(),
          _buildInstructionsPage(),
          _buildNotesPage(),
          _buildPlatformPage(),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主要功能模块',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            '首页',
            '信息中心，展示个人信息、课程、待办事项和考试安排。',
          ),
          _buildFeatureItem(
            '课程表',
            '管理周课程安排，支持切换校区和设置提醒。',
          ),
          _buildFeatureItem(
            '成绩查询',
            '查看学期成绩单、绩点计算和分析。',
          ),
          _buildFeatureItem(
            '个人资料',
            '展示学号、姓名、学院等个人信息。',
          ),
          _buildFeatureItem(
            '校园巴士',
            '查看校区间班车时刻表和路线信息。',
          ),
          _buildFeatureItem(
            '成员管理',
            '社团成员可查看信息和项目进度。',
          ),
          _buildFeatureItem(
            '培养方案',
            '显示专业培养计划和学分要求。',
          ),
          _buildFeatureItem(
            '电费查询',
            '查看宿舍电量和用电历史记录。',
          ),
          _buildFeatureItem(
            '饭卡消费',
            '查看饭卡余额和消费明细。',
          ),
          _buildFeatureItem(
            '校园网',
            '查看网络流量使用情况和统计。',
          ),
          _buildFeatureItem(
            '常用链接',
            '收集教务系统等常用工具链接。',
          ),
          _buildFeatureItem(
            '设置',
            '自定义应用偏好和账户管理。',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用说明',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _buildInstructionItem(
            '登录与账户',
            '首次使用需登录教务系统账户，社团成员可使用 iMember 账户。',
          ),
          _buildInstructionItem(
            '课程管理',
            '进入课程表查看当周课程，左右滑动切换周次，点击课程查看详情。',
          ),
          _buildInstructionItem(
            '日程提醒',
            '在设置中开启课程提醒，应用会发送通知提醒。',
          ),
          _buildInstructionItem(
            '数据同步',
            '应用自动同步教务系统数据，需要网络连接。',
          ),
          _buildInstructionItem(
            '小组件',
            '在桌面长按添加应用小组件（支持部分平台）。',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '注意事项',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _buildNoteItem('部分功能需要连接校园网才能正常使用。'),
          _buildNoteItem('请保持应用更新以获得最新功能和修复。'),
          _buildNoteItem('数据不准确时，请检查是否正确登录教务系统。'),
          _buildNoteItem('遇到问题可通过设置页面进行反馈。'),
        ],
      ),
    );
  }

  Widget _buildPlatformPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '平台适配',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            'iOS Club App 是一款跨平台应用，支持：',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ...[
            'iOS（iPhone、iPad）',
            'Android',
            'Windows',
            'macOS',
            'Linux',
          ].map((platform) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(CupertinoIcons.checkmark_circle, size: 18),
                    ),
                    Text(platform,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Text(
            '不同平台界面略有差异，但核心功能保持一致。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
