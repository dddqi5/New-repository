import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme.dart';

/// 通用卡片：圆角 16、无阴影、可点击。
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.padding),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 指标小块（BMI/BMR/TDEE 等）
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.hint,
  });

  final String label;
  final String value;
  final String unit;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
              children: [
                TextSpan(text: value),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (hint != null && hint!.isNotEmpty)
            Text(hint!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// 蛋白/碳水/脂肪 占比条
class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    this.showLegend = true,
  });

  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final bool showLegend;

  static const _proteinColor = Color(0xFF2E7D32);
  static const _carbsColor = Color(0xFF1565C0);
  static const _fatColor = Color(0xFFEF6C00);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                    flex: _flex(proteinPercent),
                    child: Container(color: _proteinColor)),
                Expanded(
                    flex: _flex(carbsPercent), child: Container(color: _carbsColor)),
                Expanded(
                    flex: _flex(fatPercent), child: Container(color: _fatColor)),
              ],
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _legend(context, _proteinColor, '蛋白', proteinPercent),
              _legend(context, _carbsColor, '碳水', carbsPercent),
              _legend(context, _fatColor, '脂肪', fatPercent),
            ],
          ),
        ],
      ],
    );
  }

  int _flex(double v) => (v * 1000).round().clamp(1, 1000);

  Widget _legend(BuildContext context, Color color, String label, double v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label ${(v * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// 骨架屏块
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 8,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerLow,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// 首页餐卡片骨架
class MealCardSkeleton extends StatelessWidget {
  const MealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 20, width: 80),
          SizedBox(height: 12),
          SkeletonBox(height: 120),
          SizedBox(height: 12),
          SkeletonBox(height: 16, width: 160),
          SizedBox(height: 8),
          SkeletonBox(height: 8),
        ],
      ),
    );
  }
}

class EvidenceChip extends StatelessWidget {
  const EvidenceChip({super.key, required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: c, fontWeight: FontWeight.w600)),
    );
  }
}

/// 带小标题的区块
class Block extends StatelessWidget {
  const Block({super.key, required this.title, required this.child, this.compact = false});
  final String title;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: compact ? 6 : 8),
        child,
      ],
    );
  }
}

class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, this.color});
  final List<String> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('暂无',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant));
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color ?? scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
