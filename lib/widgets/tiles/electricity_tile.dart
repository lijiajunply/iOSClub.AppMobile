import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../club_card.dart';
import '../../stores/electricity_store.dart';

class ElectricityTile extends StatelessWidget {
  const ElectricityTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ElectricityStore controller = Get.find<ElectricityStore>();
    
    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/Electricity'),
          borderRadius: BorderRadius.circular(20),
          child: Obx(() {
            if (controller.hasData.value) {
              final amount = controller.electricity.value;
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
                          child: Hero(
                              tag: '电费',
                              child: Icon(
                                CupertinoIcons.bolt_fill,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.red : Colors.blue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          }),
        ),
      ),
    );
  }
}