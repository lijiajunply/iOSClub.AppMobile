import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/widgets/club_card.dart';

import '../stores/payment_store.dart';
import '../services/payment_analyzer.dart';
import '../widgets/club_app_bar.dart';
import '../widgets/platform_dialog.dart';

class PaymentPage extends StatelessWidget {
  final PaymentStore controller = Get.put(PaymentStore());

  PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildContent()),
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          Obx(
            () => controller.num.value.isEmpty
                ? _buildBindCardPrompt()
                : _buildRecentTransactionsSection(),
          ),
          _buildSettingsSection()
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _buildStatCard(
        '余额',
        controller.totalRecharge.value,
        Icons.monetization_on_outlined,
        Colors.green,
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
            child: Hero(tag: '饭卡', child: Icon(icon, color: color, size: 24)),
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
    final amount = record.amount;
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
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text(
                  '绑定饭卡卡号',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  // 显示设置对话框让用户输入卡号
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSettingDialog(Get.context!);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    if (controller.num.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClubCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('添加到首页'),
                  subtitle: Text('在首页显示饭卡磁贴'),
                  trailing: CupertinoSwitch(
                    value: controller.isShowTile.value,
                    onChanged: (value) => controller.toggleTileShow(value),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showSettingDialog(BuildContext context) async {
    final result = await PlatformDialog.showInputDialog(
      context,
      title: '设置饭卡卡号',
      hintText: '请输入饭卡卡号',
    );

    if (result != null) {
      if (result.isEmpty) {
        if (context.mounted) {
          PlatformDialog.showConfirmDialog(
            context,
            title: '提示',
            content: '请输入饭卡卡号',
            confirmText: '确定',
            cancelText: '',
          );
        }
        return;
      }
      
      await controller.setPayment(result);
    }
  }
}
