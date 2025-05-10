import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/tile_service.dart';
import '../pages/electricity_chart.dart';

Widget buildTile(String tile) {
  late Widget? a;

  if (tile == '电费') {
    a = buildElectricity();
  }

  a ??= Container();

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: a,
  );
}

Widget buildElectricity() {
  return FutureBuilder(
      future: TileService.getTextAfterKeyword(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '当前电费',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${snapshot.data ?? '...'} 元',
                    style: TextStyle(
                        fontSize: 18,
                        color: snapshot.data! <= 20 ? Colors.redAccent : null),
                  ),
                  Wrap(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            var url = prefs.getString('electricity_url') ?? '';
                            url = url.replaceAll('wxAccount', 'wxCharge');
                            await TileService.openInWeChat(url);
                          },
                          child: Text('充值')),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ElectricityChart()));
                          },
                          child: Text('查看详情'))
                    ],
                  )
                ]),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}
