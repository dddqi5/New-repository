import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import 'common.dart';

/// 全局食材详情 Bottom Sheet，从任意位置点击食材调用。
Future<void> showIngredientSheet(
  BuildContext context,
  WidgetRef ref,
  String name,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) =>
          _IngredientBody(name: name, controller: controller),
    ),
  );
}

class _IngredientBody extends ConsumerWidget {
  const _IngredientBody({required this.name, required this.controller});
  final String name;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ingredientProvider(name));
    return async.when(
      loading: () => _loading(context),
      error: (e, _) => _error(context, ref),
      data: (ing) => _content(context, ing),
    );
  }

  Widget _loading(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonBox(height: 150),
        SizedBox(height: 16),
        SkeletonBox(height: 20, width: 120),
        SizedBox(height: 12),
        SkeletonBox(height: 14),
        SizedBox(height: 8),
        SkeletonBox(height: 14),
        SizedBox(height: 8),
        SkeletonBox(height: 14),
        SizedBox(height: 24),
        SkeletonBox(height: 120),
      ],
    );
  }

  Widget _error(BuildContext context, WidgetRef ref) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        EmptyState(
          icon: Icons.wifi_off,
          title: '获取失败',
          subtitle: '请检查网络后重试',
          action: FilledButton(
            onPressed: () => ref.invalidate(ingredientProvider(name)),
            child: const Text('重试'),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, Ingredient ing) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // 1. 名称 + 图片
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 88,
                height: 88,
                child: (ing.imageUrl != null && ing.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: ing.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imgPlaceholder(scheme),
                        errorWidget: (_, __, ___) => _imgPlaceholder(scheme),
                      )
                    : _imgPlaceholder(scheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ing.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (ing.nameEn != null && ing.nameEn!.isNotEmpty)
                    Text(ing.nameEn!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  EvidenceChip(
                    label: EvidenceLevel.label(ing.evidenceLevel),
                    color: _evidenceColor(ing.evidenceLevel, scheme),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. 营养优势
        Block(title: '营养优势', child: BulletList(items: ing.benefits)),
        const SizedBox(height: 20),

        // 3. 关键营养素（每 100g）
        Block(
          title: '关键营养素（每 100g）',
          child: _nutrientGrid(context, ing.nutrient),
        ),
        const SizedBox(height: 20),

        // 4. 推荐搭配
        Block(title: '推荐搭配', child: BulletList(items: ing.pairings)),
        const SizedBox(height: 20),

        // 5. 注意搭配
        Block(
          title: '注意搭配',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('有科学证据',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              BulletList(items: ing.cautionsEvidence),
              const SizedBox(height: 12),
              Text('证据不足 / 民间说法',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              BulletList(items: ing.cautionsFolk, color: scheme.outline),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 6. 可能后果
        Block(
          title: '可能后果（仅有来源内容）',
          child: BulletList(items: ing.possibleEffects, color: scheme.tertiary),
        ),
        const SizedBox(height: 20),

        // 7. 药物交互
        if (ing.drugInteractions.isNotEmpty) ...[
          Block(
            title: '药物交互（已联网查证）',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BulletList(
                  items: ing.drugInteractions, color: scheme.error),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 9. 来源链接 + 检索日期
        Block(
          title: '来源与检索日期',
          child: ing.sources.isEmpty
              ? Text('暂无来源',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant))
              : Column(
                  children: ing.sources
                      .map((s) => InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _open(s.url),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.link,
                                      size: 18, color: scheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(s.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        Text(
                                          '${s.publisher ?? ''} · 检索于 ${s.retrievedDate}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 20),

        // 10. 免责声明
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: scheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ing.disclaimer.isEmpty
                      ? AppDefaults.disclaimer
                      : ing.disclaimer,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imgPlaceholder(ColorScheme scheme) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined, color: scheme.outline),
      );

  Color _evidenceColor(String level, ColorScheme scheme) {
    switch (level) {
      case EvidenceLevel.strong:
        return const Color(0xFF2E7D32);
      case EvidenceLevel.medium:
        return const Color(0xFF1565C0);
      case EvidenceLevel.weak:
        return const Color(0xFFEF6C00);
      default:
        return scheme.outline;
    }
  }

  Widget _nutrientGrid(BuildContext context, IngredientNutrient? n) {
    if (n == null) {
      return Text('暂无数据',
          style: Theme.of(context).textTheme.bodyMedium);
    }
    final rows = <List<String>>[
      ['热量', _v(n.caloriesKcal, 'kcal')],
      ['蛋白质', _v(n.proteinG, 'g')],
      ['碳水', _v(n.carbsG, 'g')],
      ['脂肪', _v(n.fatG, 'g')],
      ['纤维', _v(n.fiberG, 'g')],
      ['钠', _v(n.sodiumMg, 'mg')],
      ['钙', _v(n.calciumMg, 'mg')],
      ['铁', _v(n.ironMg, 'mg')],
    ];
    for (final e in n.vitamins.entries) {
      rows.add([e.key, e.value.toString()]);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rows
          .where((r) => r[1] != '—')
          .map((r) => Container(
                width: 148,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r[0],
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(r[1],
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  String _v(double? v, String unit) =>
      v == null ? '—' : '${_trim(v)} $unit';

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
