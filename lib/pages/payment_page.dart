// payment_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/widgets/club_card.dart';

import '../controllers/payment_controller.dart';
import '../services/turnover_analyzer.dart';
import '../widgets/club_app_bar.dart';

class PaymentPage extends StatelessWidget {
  final PaymentController controller = Get.put(PaymentController());

  PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ClubAppBar(
      title: '饭卡余额',
      actions: [
        _buildRefreshButton(),
        _buildSettingButton(context),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: controller.loadData,
    );
  }

  Widget _buildSettingButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => _showSettingDialog(context),
    );
  }

  Widget _buildBody() {
    return _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          Obx(
            () => controller.totalRecharge.value == 0
                ? _buildBindCardPrompt()
                : _buildRecentTransactionsSection(),
          )
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '统计信息',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            '余额',
            controller.totalRecharge.value,
            CupertinoIcons.money_dollar,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.totalRecharge.value == 0
                    ? const Text(
                        '暂无数据',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        '¥${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recentRecords =
        controller.records.where((r) => r.turnoverType == '消费').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近消费',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (recentRecords.isEmpty)
            const Center(
              child: Text(
                '暂无消费记录',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          else
            ClubCard(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentRecords.length.clamp(0, 5),
                  itemBuilder: (context, index) =>
                      _buildTransactionItem(recentRecords[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PaymentModel record) {
    final isRecharge = record.turnoverType == '充值';
    final amount = record.tranamt;
    final date = record.datetimeStr;
    final description = record.resume;

    return ListTile(
      title: Text(
        description.trim(),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        date,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Text(
        '${isRecharge ? '+' : '-'}${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBindCardPrompt() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ClubCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '暂无饭卡数据',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请先绑定饭卡卡号以查看余额和消费记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 显示设置对话框让用户输入卡号
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSettingDialog(Get.context!);
                  });
                },
                child: const Text('绑定饭卡卡号'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSettingDialog(BuildContext context) async {
    final controller = Get.find<PaymentController>();
    final TextEditingController textController =
        TextEditingController(text: controller.num.value);

    await showDialog(
      context: context,
      builder: (contextDialog) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('设置饭卡卡号'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: '请输入饭卡卡号',
                  filled: true,
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.numbers,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,19}')),
                ],
              ),
              if (controller.num.value.isNotEmpty)
                ListTile(
                  title: Text('是否显示饭卡磁贴'),
                  trailing: Obx(() => Switch(
                        value: controller.isShowTile.value,
                        onChanged: (value) => controller.toggleTileShow(value),
                      )),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final cardNumber = textController.text.trim();
                if (cardNumber.isEmpty) {
                  ScaffoldMessenger.of(contextDialog).showSnackBar(
                    const SnackBar(content: Text('请输入饭卡卡号')),
                  );
                  return;
                }
                await controller.setPayment(cardNumber);
                if (contextDialog.mounted) {
                  Navigator.pop(contextDialog);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
}
