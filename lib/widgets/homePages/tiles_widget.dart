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
                        for (int i = 0; i < snapshot.data!.length; i++)
                          // 可以根据索引或数据内容决定瓦片大小
                          i == snapshot.data!.length - 1 &&
                                  snapshot.data!.length % 2 == 1
                              ? const QuiltedGridTile(1, 2) // 最后一个元素且为奇数时占满整行
                              : const QuiltedGridTile(1, 1), // 其他情况占一个格子
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          buildTile(snapshot.data![index], context),
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
