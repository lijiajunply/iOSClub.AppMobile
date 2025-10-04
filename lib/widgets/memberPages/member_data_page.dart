import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/club_service.dart';
import 'package:ios_club_app/models/member_model.dart';
import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/widgets/club_card.dart';

class MemberDataPage extends StatefulWidget {
  const MemberDataPage({super.key});

  @override
  State<MemberDataPage> createState() => _MemberDataPageState();
}

class _MemberDataPageState extends State<MemberDataPage> {
  int _pageNum = 1;
  int _pageSize = 10;
  int _totalPages = 0;

  bool isLoading = true;

  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  Future<void> _getMembers() async {
    setState(() {
      isLoading = true;
    });

    final data = await ClubService.getMembersByPage(_pageNum, _pageSize);

    setState(() {
      _members = data.data;
      _totalPages = data.totalPages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(title: '成员数据'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = _members[index];
                    return _buildMemberCard(member);
                  },
                  childCount: _members.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPaginationWidget(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(MemberModel model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClubCard(
        child: Column(
          children: [
            // 头部信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemBlue.withOpacity(0.05),
                    CupertinoColors.systemBlue.withOpacity(0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemBlue,
                          CupertinoColors.activeBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        model.userName.isNotEmpty ? model.userName[0] : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            model.identity,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 详细信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: CupertinoIcons.book,
                    title: '专业班级',
                    value: model.className,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.number,
                    title: '学号',
                    value: model.userId,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.building_2_fill,
                    title: '学院',
                    value: model.academy,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.flag,
                    title: '政治面貌',
                    value: model.politicalLandscape,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.person,
                    title: '性别',
                    value: model.gender,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.phone,
                    title: '手机号',
                    value: model.phoneNum,
                    isPhone: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          if (isPhone)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // 处理电话点击
              },
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator.withOpacity(0.3),
    );
  }

  Widget _buildPaginationWidget() {
    return ClubCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 上一页按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pageNum > 1
                  ? () {
                      setState(() {
                        _pageNum--;
                      });
                      _getMembers();
                    }
                  : null,
              child: SizedBox(
                width: 36,
                height: 36,
                child: const Icon(
                  CupertinoIcons.chevron_left,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 页码显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_pageNum / $_totalPages',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 下一页按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _pageNum < _totalPages
                  ? () {
                      setState(() {
                        _pageNum++;
                      });
                      _getMembers();
                    }
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // 每页数量选择
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _showPageSizePicker();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '$_pageSize 条/页',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPageSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        int selectedIndex = [10, 20, 50].indexOf(_pageSize);
        if (selectedIndex == -1) selectedIndex = 0;

        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '每页显示数量',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '完成',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 选择器
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  physics: const FixedExtentScrollPhysics(),
                  controller:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    final options = [10, 20, 50];
                    setState(() {
                      _pageSize = options[index];
                      _pageNum = 1;
                    });
                    _getMembers();
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 3,
                    builder: (context, index) {
                      final options = [10, 20, 50];
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${options[index]} 条/页',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
