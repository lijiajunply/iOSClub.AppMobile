import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/club_service.dart';
import 'package:ios_club_app/widgets/ClubCard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/LinkModel.dart';
import '../widgets/ClubAppBar.dart';
import '../widgets/icon_font.dart';

class LinkPage extends StatelessWidget {
  const LinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(
        title: '建大导航',
      ),
      body: FutureBuilder(
        future: ClubService.getLinks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "加载失败",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final categoryList = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ScoreBuilder(
                      categoryList: categoryList,
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "加载中...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ScoreBuilder extends StatelessWidget {
  final CategoryModel categoryList;

  const ScoreBuilder({super.key, required this.categoryList});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ClubCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标题
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    categoryList.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // 链接网格
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 6 : 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryList.links.length,
              itemBuilder: (context, index) {
                final linkList = categoryList.links[index];
                return _LinkItem(
                  link: linkList,
                  onTap: () => _launchURL(linkList.url),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 单独的链接项组件
class _LinkItem extends StatelessWidget {
  final dynamic link;
  final VoidCallback onTap;

  const _LinkItem({
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标
              FutureBuilder(
                future: IconUtil.getIconFont(link),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return IconTheme(
                      data: const IconThemeData(
                        size: 24,
                      ),
                      child: snapshot.data!,
                    );
                  }
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // 名称
              Text(
                link.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
