import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/services/net_service.dart';
import 'package:ios_club_app/widgets/club_card.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';
import '../widgets/club_app_bar.dart';

class NetPage extends StatelessWidget {
  const NetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(
        title: '校园网数据统计',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: NetService.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingWidget();
          }

          if (snapshot.hasError) {
            return _ErrorWidget(error: snapshot.error.toString());
          }

          if (snapshot.hasData) {
            return _DataContent(data: snapshot.data!);
          }

          return const _EmptyWidget();
        },
      ),
    );
  }
}

class _DataContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DataContent({required this.data});

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';

    try {
      double value = double.parse(bytes.toString());
      const units = ['B', 'KB', 'MB', 'GB', 'TB'];
      int unitIndex = 0;

      while (value >= 1000 && unitIndex < units.length - 1) {
        value /= 1000;
        unitIndex++;
      }

      return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
    } catch (e) {
      return bytes.toString();
    }
  }

  String timeFormat(int s) {
    int m = s ~/ 60;
    int sRemainder = s % 60;

    int h = m ~/ 60;
    int mRemainder = m % 60;

    int d = h ~/ 24;
    int hRemainder = h % 24;

    return "$d天$hRemainder小时$mRemainder分$sRemainder秒";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 主卡片 - 流量使用情况
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _MainCard(
                    usedBytes: _formatBytes(data['sum_bytes']),
                    rawBytes: "已使用 ${timeFormat(data['sum_seconds'])}",
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 详细信息卡片
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      _InfoCard(
                        icon: Icons.person,
                        iconColor: Colors.red,
                        title: '用户名',
                        value: data['user_name'] ?? '未知',
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        icon: Icons.wifi,
                        iconColor: Colors.blue,
                        title: 'IP 地址',
                        value: data['online_ip'] ?? '未知',
                        onTap: () =>
                            _copyToClipboard(context, data['online_ip']),
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        icon: Icons.devices,
                        iconColor: Colors.green,
                        title: '产品套餐',
                        value: data['products_name'] ?? '未知',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null) return;

    Clipboard.setData(ClipboardData(text: text));
    showClubSnackBar(context, const Text('已复制到剪贴板'));
  }
}

class _MainCard extends StatelessWidget {
  final String usedBytes;
  final String rawBytes;

  const _MainCard({
    required this.usedBytes,
    required this.rawBytes,
  });

  @override
  Widget build(BuildContext context) {
    return ClubCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.data_usage,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '已用流量',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              usedBytes,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rawBytes,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClubCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.copy,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            '正在加载数据...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const NetPage()),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
