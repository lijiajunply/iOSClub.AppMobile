import 'package:flutter/material.dart';
import 'package:ios_club_app/services/turnover_analyzer.dart';
import 'dart:math' as math;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  final TurnoverAnalyzer analyzer = TurnoverAnalyzer('');

  int totalRecharge = 0;
  int totalConsume = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final success = await analyzer.fetchData();
      if (success) {
        setState(() {
          totalRecharge = analyzer.records
              .where((r) => r.turnoverType == '充值')
              .map((r) => r.tranamt)
              .fold(0, (sum, amt) => sum + amt);

          totalConsume = analyzer.records
              .where((r) => r.turnoverType == '消费')
              .map((r) => r.tranamt)
              .fold(0, (sum, amt) => sum + amt);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '数据加载失败';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载数据时出错: $e';
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        '饭卡余额',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
        strokeWidth: 3,
      ),
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
    final balance = totalRecharge - totalConsume;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 饭卡卡片
          _buildCard(balance),

          const SizedBox(height: 24),

          // 统计信息
          _buildStatisticsSection(),

          const SizedBox(height: 24),

          // 最近交易
          _buildRecentTransactionsSection(),
        ],
      ),
    );
  }

  Widget _buildCard(int balance) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF007AFF),
            const Color(0xFF0A84FF),
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '饭卡余额',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${(balance / 100).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardInfoItem('充值总额', totalRecharge),
              _buildCardInfoItem('消费总额', totalConsume),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoItem(String title, int amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${(amount / 100).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
              '总充值', totalRecharge, Icons.add_circle_outline, Colors.green),
          const SizedBox(height: 12),
          _buildStatCard(
              '总消费', totalConsume, Icons.remove_circle_outline, Colors.red),
          const SizedBox(height: 12),
          _buildStatCard('余额', totalRecharge - totalConsume,
              Icons.account_balance_wallet, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int amount, IconData icon, Color color) {
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
                  '¥${(amount / 100).toStringAsFixed(2)}',
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
    final recentRecords =
        analyzer.records.where((r) => r.turnoverType == '消费').toList()
          ..sort((a, b) => b.datetime.compareTo(a.datetime))
          ..take(5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isRecharge
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isRecharge ? Icons.add : Icons.remove,
          color: isRecharge ? Colors.green : Colors.red,
          size: 24,
        ),
      ),
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
        '${isRecharge ? '+' : '-'}¥${(amount / 100).toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isRecharge ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
