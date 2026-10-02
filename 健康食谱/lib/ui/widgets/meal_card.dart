import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import 'common.dart';

/// 首页餐卡片
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, this.onTap});

  final Meal meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = MealType.label(meal.mealType);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: _cover(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(NumFormat.cal(meal.calories),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                MacroBar(
                  proteinPercent: _p(meal.proteinG * 4, meal),
                  carbsPercent: _p(meal.carbsG * 4, meal),
                  fatPercent: _p(meal.fatG * 9, meal),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meal.dishes
                      .map((d) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(d.name,
                                style: Theme.of(context).textTheme.bodySmall),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _p(double energy, Meal meal) {
    final total = meal.proteinG * 4 + meal.carbsG * 4 + meal.fatG * 9;
    if (total <= 0) return 0;
    return energy / total;
  }

  Widget _cover(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = meal.coverImageUrl ??
        (meal.dishes.isNotEmpty ? meal.dishes.first.imageUrl : null);
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(scheme),
        errorWidget: (_, __, ___) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.primaryContainer.withOpacity(0.5),
      child: Center(
        child: Icon(Icons.restaurant_menu,
            size: 40, color: scheme.onPrimaryContainer.withOpacity(0.7)),
      ),
    );
  }
}
