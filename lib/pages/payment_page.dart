import 'package:flutter/material.dart';
import 'package:ios_club_app/services/turnover_analyzer.dart';
import 'dart:math' as math;

import 'package:ios_club_app/widgets/ClubAppBar.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  late List<PaymentModel> records;

  double totalRecharge = 0;
  String num = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    num = await TurnoverAnalyzer.getPayment();

    if (num.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '请先绑定饭卡';
      });
      return;
    }

    final recordsResult = await TurnoverAnalyzer.fetchData(num);
    if (recordsResult.payments.isNotEmpty) {
      setState(() {
        records = recordsResult.payments;
        totalRecharge = recordsResult.total;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '数据加载失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ClubAppBar(
      title: '饭卡余额',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // 饭卡数额设置，拿个弹窗
            showDialog(
              context: context,
              builder: (contextDialog) {
                final controller = TextEditingController(text: num);
                return AlertDialog(
                  title: const Text('设置饭卡卡号'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '请输入饭卡卡号',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(contextDialog).pop();
                      },
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await TurnoverAnalyzer.setPayment(controller.text);
                        if (contextDialog.mounted){
                          Navigator.of(contextDialog).pop();
                        }
                        _loadData();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                );
              }
            );
          },
        )
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '重新加载',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计信息
          _buildStatisticsSection(),

          // 最近交易
          _buildRecentTransactionsSection(),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
              '余额', totalRecharge, Icons.add_circle_outline, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
                Text(
                  '¥${(amount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recentRecords = records.where((r) => r.turnoverType == '消费').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近消费',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recentRecords.isEmpty)
            const Center(
              child: Text(
                '暂无消费记录',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(recentRecords.length, 5),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = recentRecords[index];
                return _buildTransactionItem(record);
              },
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
        '${isRecharge ? '+' : '-'}${(amount).toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
