import 'package:flutter/material.dart';
import 'package:ios_club_app/Models/InfoModel.dart';

class StudyCreditCard extends StatelessWidget {
  final InfoModel data;

  const StudyCreditCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              _buildHeader(context),
              const SizedBox(height: 12),

              // 总学分部分
              _buildMainCreditCard(context),

              const SizedBox(height: 16),

              // 分项标题
              _buildSubtitle(context),
              const SizedBox(height: 8),

              // 分项学分列表
              ...data.other.asMap().entries.map((entry) {
                return _buildCreditItem(
                  context: context,
                  title: entry.value.name,
                  actual: entry.value.actual,
                  full: entry.value.full,
                  delay: entry.key * 100,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.school_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.type,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '学分概览',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCreditCard(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        data.total.full > 0 ? data.total.actual / data.total.full : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.total.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                "${data.total.actual.toStringAsFixed(1)} / ${data.total.full.toStringAsFixed(1)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress, theme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 进度条
          _buildProgressBar(context, progress),

          const SizedBox(height: 8),

          // 进度文字
          Text(
            '完成度: ${(progress * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "分项学分",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditItem({
    required BuildContext context,
    required String title,
    required double actual,
    required double full,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final progress = full > 0 ? actual / full : 0.0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "${actual.toStringAsFixed(1)} / ${full.toStringAsFixed(1)}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(progress, theme),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(context, progress * value),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: clampedProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(clampedProgress, theme),
                      _getProgressColor(clampedProgress, theme)
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: clampedProgress > 0
                      ? [
                          BoxShadow(
                            color: _getProgressColor(clampedProgress, theme)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 1.0) {
      return Colors.green.shade600;
    } else if (progress >= 0.8) {
      return Colors.blue.shade600;
    } else if (progress >= 0.5) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }
}
