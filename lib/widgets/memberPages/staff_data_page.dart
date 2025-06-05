import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/club_service.dart';
import 'package:ios_club_app/models/MemberModel.dart';

import '../BlurWidget.dart';

class StaffDataPage extends StatefulWidget {
  const StaffDataPage({super.key});

  @override
  State<StaffDataPage> createState() => _StaffDataPageState();
}

class _StaffDataPageState extends State<StaffDataPage> {
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

    final data = await ClubService.getStaffsByPage(_pageNum, _pageSize);

    setState(() {
      _members = data.data;
      _totalPages = data.totalPages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成员数据'),
        flexibleSpace: BlurWidget(child: SizedBox.expand()),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        isLoading
            ? const Center(
                child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return buildMemberCard(member);
                },
              ),
        PaginationWidget(
            currentPage: _pageNum,
            totalPages: _totalPages,
            pageSize: _pageSize,
            onPageChanged: (page) {
              setState(() {
                _pageNum = page;
              });
              _getMembers();
            },
            onPageSizeChanged: (pageSize) {
              setState(() {
                _pageSize = pageSize;
              });
              _getMembers();
            }),
        const SizedBox(height: 16),
      ])),
    );
  }

  Widget buildMemberCard(MemberModel model) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  ListTile(
                    title: Text(model.userName),
                    subtitle: Text(model.identity),
                  ),
                  ListTile(
                    title: const Text('专业班级'),
                    subtitle: Text(model.className),
                  ),
                  ListTile(
                    title: const Text('学号'),
                    subtitle: Text(model.userId),
                  ),
                  ListTile(
                    title: const Text('学院'),
                    subtitle: Text(model.academy),
                  ),
                  ListTile(
                    title: const Text('政治面貌'),
                    subtitle: Text(model.politicalLandscape),
                  ),
                  ListTile(
                    title: const Text('性别'),
                    subtitle: Text(model.gender),
                  ),
                  ListTile(
                    title: const Text('手机号'),
                    subtitle: Text(model.phoneNum),
                  ),
                ]))));
  }
}

typedef IntCallback = void Function(int value);

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    this.pageSizeOptions = const [10, 20, 50],
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (currentPage == 0 || totalPages == 0 || pageSizeOptions.isEmpty) {
      return const SizedBox();
    }

    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(36, 36),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    List<Widget> buildPageButtons() {
      List<Widget> buttons = [];

      final pageAdd = isTablet ? 3 : 0;

      void addPageButton(int page) {
        buttons.add(
          OutlinedButton(
            style: buttonStyle.copyWith(
              side: WidgetStateProperty.all(BorderSide(
                  color: page == currentPage ? Colors.blue : Colors.grey)),
              backgroundColor: WidgetStateProperty.all(page == currentPage
                  ? Colors.blue.withValues(alpha: 220)
                  : null),
            ),
            onPressed: page == currentPage ? null : () => onPageChanged(page),
            child: Text(
              page.toString(),
              style: TextStyle(
                color: page == currentPage ? Colors.blue : Colors.black,
                fontWeight: page == currentPage ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      }

      // Always show first page
      addPageButton(1);

      // Show left ellipsis if needed
      int leftThreshold = currentPage - pageAdd;
      int rightThreshold = currentPage + pageAdd;

      if (leftThreshold > 2) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      } else {
        // show pages between 2 and currentPage-3 or up to currentPage-1
        for (var i = 2; i < currentPage; i++) {
          if (i < leftThreshold || leftThreshold <= 2) {
            addPageButton(i);
          }
        }
      }

      // Show pages around current page
      for (var i = currentPage; i <= totalPages && i <= rightThreshold; i++) {
        if (i != 1 && i != totalPages) {
          addPageButton(i);
        }
      }

      // Show right ellipsis if needed
      if (rightThreshold < totalPages - 1) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      } else {
        // show pages from rightThreshold + 1 to totalPages - 1
        for (var i = rightThreshold + 1; i < totalPages; i++) {
          addPageButton(i);
        }
      }

      // Always show last page if more than 1
      if (totalPages > 1) {
        addPageButton(totalPages);
      }

      return buttons;
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          OutlinedButton(
            style: buttonStyle,
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            child: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 6),

          // Page Number Buttons
          ...buildPageButtons()
              .expand((w) => [w, const SizedBox(width: 8)])
              .toList()
            ..removeLast(),

          const SizedBox(width: 6),

          // Next Button
          OutlinedButton(
            style: buttonStyle,
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            child: const Icon(Icons.chevron_right),
          ),

          const SizedBox(width: 24),

          // Page Size Dropdown
          if (isTablet)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: pageSize,
                  items: pageSizeOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text('$e / page')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null && v != pageSize) {
                      onPageSizeChanged(v);
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
