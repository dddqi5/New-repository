import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../widgets/common.dart';
import '../widgets/ingredient_sheet.dart';

/// 餐详情页：食材清单、每道菜做法、营养数据、来源链接。
class MealDetailPage extends ConsumerWidget {
  const MealDetailPage({super.key, required this.plan, required this.meal});
  final DailyMealPlan plan;
  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(MealType.label(meal.mealType))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('合计',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(NumFormat.cal(meal.calories),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                MacroBar(
                  proteinPercent: _p(meal.proteinG * 4),
                  carbsPercent: _p(meal.carbsG * 4),
                  fatPercent: _p(meal.fatG * 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...meal.dishes.map((d) => _dish(context, ref, d)),
        ],
      ),
    );
  }

  double _p(double energy) {
    final total = meal.proteinG * 4 + meal.carbsG * 4 + meal.fatG * 9;
    if (total <= 0) return 0;
    return energy / total;
  }

  Widget _dish(BuildContext context, WidgetRef ref, Dish dish) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dish.imageUrl != null && dish.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: dish.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (dish.imageUrl != null && dish.imageUrl!.isNotEmpty)
              const SizedBox(height: 12),
            Text(dish.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _nutri(context, '热量', NumFormat.cal(dish.calories)),
                _nutri(context, '蛋白', NumFormat.grams(dish.proteinG)),
                _nutri(context, '碳水', NumFormat.grams(dish.carbsG)),
                _nutri(context, '脂肪', NumFormat.grams(dish.fatG)),
              ],
            ),
            if (dish.ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              Block(
                title: '食材（点击查看详情）',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: dish.ingredients
                      .map((i) => ActionChip(
                            avatar: const Icon(Icons.search, size: 16),
                            label: Text(_ingredientLabel(i)),
                            onPressed: () => showIngredientSheet(
                                context, ref, i.ingredientName),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (dish.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Block(
                title: '做法',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < dish.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Text('${i + 1}',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(dish.steps[i],
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (dish.sourceUrl != null && dish.sourceUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _open(dish.sourceUrl!),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '来源：${dish.sourceUrl}  检索于 ${dish.retrievedDate ?? '-'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _ingredientLabel(DishIngredient i) {
    if (i.amount == null) return i.ingredientName;
    final amount = i.amount == i.amount!.roundToDouble()
        ? i.amount!.toStringAsFixed(0)
        : i.amount!.toStringAsFixed(1);
    return '${i.ingredientName} $amount${i.unit ?? ''}';
  }

  Widget _nutri(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
