import 'package:flutter/material.dart';
import '../Services/edu_service.dart';
import '../Services/tile_service.dart';

Widget buildTile(String tile) {
  late Widget? a;

  if (tile == '电费') {
    a = buildElectricity();
  }

  if (tile == '校车') {
    a = buildBus();
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
                children: [
                  Text(
                    '当前电费',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${snapshot.data ?? '...'} 元',
                    style: TextStyle(
                        fontSize: 18,
                        color: snapshot.data! <= 10 ? Colors.redAccent : null),
                  ),
                ]),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}

Widget buildBus() {
  return FutureBuilder(
      future: EduService.getBus(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasData) {
          final busData = snapshot.data!.records;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '今日校车',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (busData.isNotEmpty)
                            Expanded(
                              child: ListView.builder(
                                  itemCount: busData.length,
                                  itemBuilder: (context, index) {
                                    final bus = busData[index];
                                    return GestureDetector(
                                      child: Card(
                                        margin: EdgeInsets.all(8),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      bus.departureStation,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      bus.runTime,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                    Text(bus.description,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Divider(
                                                      thickness: 1,
                                                    ),
                                                    Text(bus.arrivalStationTime,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ])),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                    Text(
                                                      bus.arrivalStation,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      bus.totalTime,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ]))
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          else
                            Center(
                                child: Text(
                                  '今天没有车了',
                                  style: TextStyle(fontSize: 20),
                                )),
                        ],
                      ))
                ]),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}
