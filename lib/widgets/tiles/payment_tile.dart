import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/payment_store.dart';
import '../club_card.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentStore>();
    
    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Obx(() {
            if (!controller.isLoading.value && controller.totalRecharge.value != 0) {
              final amount = controller.totalRecharge.value;
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
                          child: const Hero(
                              tag: '饭卡',
                              child: Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.orange,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.red : Colors.orange,
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
          onTap: () {
            Get.toNamed('/Payment');
          },
        ),
      ),
    );
  }
}