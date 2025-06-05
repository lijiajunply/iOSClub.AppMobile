import 'package:flutter/material.dart';
import 'package:ios_club_app/Services/club_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/LinkModel.dart';
import '../widgets/BlurWidget.dart';
import '../widgets/icon_font.dart';

class LinkPage extends StatelessWidget {
  const LinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('建大导航'),
        flexibleSpace: BlurWidget(child: SizedBox.expand()),
      ),
      body: FutureBuilder(
          future: ClubService.getLinks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                // 请求失败，显示错误
                return Text("Error: ${snapshot.error}");
              } else {
                // 请求成功，显示数据
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final categoryList = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ScoreBuilder(
                          categoryList: categoryList,
                        ),
                      );
                    });
              }
            } else {
              // 请求未结束，显示loading
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
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
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              categoryList.name,
              style: const TextStyle(fontSize: 24),
            ),
            GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 6 : 3,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryList.links.length,
                itemBuilder: (context, index) {
                  final linkList = categoryList.links[index];
                  return RawMaterialButton(
                    onPressed: () async {
                      await _launchURL(linkList.url);
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder(
                              future: IconUtil.getIconFont(linkList),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? snapshot.data!
                                    : const SizedBox();
                              }),
                          Text(
                            linkList.name,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
