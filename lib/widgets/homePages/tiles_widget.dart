import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../Services/tile_service.dart';
import '../tile_widget.dart';

class TilesWidget extends StatelessWidget {
  const TilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: TileService.getTiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '磁贴',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: GridView.custom(
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      pattern: [
                        // 动态生成模式
                        for (int i = 0;
                        i < (snapshot.data!.length / 2).floor();
                        i++)
                          const QuiltedGridTile(1, 1),
                        // 如果是奇数个元素，添加一个占满整行的元素
                        if (snapshot.data!.length % 2 == 1)
                          const QuiltedGridTile(1, 2),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                          (context, index) => buildTile(snapshot.data![index]),
                      childCount: snapshot.data!.length,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  ),
                )
              ],
            );
          }

          return SizedBox();
        });
  }
}