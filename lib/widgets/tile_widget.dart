import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/edu_service.dart';
import '../Services/tile_service.dart';
import '../services/turnover_analyzer.dart';
import 'ClubCard.dart';

Widget buildTile(String tile, BuildContext context) {
  Widget? content;

  if (tile == '电费') {
    content = buildElectricity(context);
  }

  if (tile == '校车') {
    content = buildBus(context);
  }

  if (tile == '饭卡') {
    content = buildPayment(context);
  }

  content ??= Container();

  return ClubCard(
    child: content,
  );
}

Widget buildElectricity(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => Get.toNamed('/Electricity'),
      borderRadius: BorderRadius.circular(20),
      child: FutureBuilder(
        future: TileService.getTextAfterKeyword(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final amount = snapshot.data ?? 0.0;
            final isLow = amount <= 10;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLow
                      ? [
                          Colors.red.withValues(alpha: 0.1),
                          Colors.orange.withValues(alpha: 0.05)
                        ]
                      : [
                          Colors.blue.withValues(alpha: 0.1),
                          Colors.indigo.withValues(alpha: 0.05)
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLow
                              ? Colors.red.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Hero(tag: '电费', child: Icon(
                          Icons.electric_bolt_rounded,
                          color: isLow ? Colors.red : Colors.blue,
                          size: 24,
                        )),
                      ),
                      const Spacer(),
                      if (isLow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '余额不足',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '当前电费',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isLow ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    ),
  );
}

Widget buildBus(BuildContext context) {
  return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () => Get.toNamed('/SchoolBus'),
          borderRadius: BorderRadius.circular(20),
          child: FutureBuilder(
            future: EduService.getBus(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final busData = snapshot.data!.total;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.withValues(alpha: 0.1),
                        Colors.teal.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$busData班次',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '今日校车',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (busData > 0)
                        Text(
                          '今日有$busData个班次',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      else
                        const Text(
                          '今天没有班次',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          )));
}

Widget buildPayment(BuildContext context) {
  return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder(
          future: TurnoverAnalyzer.getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final amount = snapshot.data?.total ?? 0.0;
              final isLow = amount <= 10;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isLow
                        ? [
                            Colors.red.withValues(alpha: 0.1),
                            Colors.orange.withValues(alpha: 0.05)
                          ]
                        : [
                            Colors.yellow.withValues(alpha: 0.1),
                            Colors.green.withValues(alpha: 0.05)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLow
                                ? Colors.red.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.monetization_on_outlined,
                            color: isLow ? Colors.red : Colors.orange,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        if (isLow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '余额不足',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '当前余额',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.red : Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        onTap: () {
          Get.toNamed('/Payment');
        },
      ));
}
