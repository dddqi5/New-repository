import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_page.dart';

/// 首页 · 今日食谱
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.onGoToProfile});
  final VoidCallback onGoToProfile;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  String _today = AppDate.todayKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 回到前台时重新读取系统当天日期，必要时刷新当日食谱（应对跨天）。
    if (state == AppLifecycleState.resumed) {
      final now = AppDate.todayKey();
      if (now != _today) {
        setState(() => _today = now);
      }
      ref.invalidate(mealPlanProvider(_today));
    }
  }

  Future<void> _forceRefresh() async {
    await ref.read(mealPlanRepositoryProvider).deletePlan(_today);
    ref.invalidate(mealPlanProvider(_today));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今日食谱'),
            Text(AppDate.displayKey(_today),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '重新生成',
            onPressed: _forceRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ref.watch(profileProvider).when(
            loading: () => _skeleton(),
            error: (e, _) => _error('$e'),
            data: (profile) {
              if (profile == null || !profile.isComplete) {
                return _needProfile();
              }
              return _plan();
            },
          ),
    );
  }

  Widget _plan() {
    return ref.watch(mealPlanProvider(_today)).when(
          loading: () => _skeleton(),
          error: (e, _) {
            if (e is ProfileIncompleteException) {
              return _needProfile();
            }
            return _error('$e', onRetry: _forceRefresh);
          },
          data: (plan) => RefreshIndicator(
            onRefresh: _forceRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summary(plan),
                const SizedBox(height: 12),
                ...plan.meals.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MealCard(
                        meal: m,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MealDetailPage(plan: plan, meal: m),
                          ),
                        ),
                      ),
                    )),
                if (plan.sourceNote.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '数据来源：${plan.sourceNote}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
  }

  Widget _summary(DailyMealPlan plan) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('今日合计',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${plan.totalCalories.round()} / ${plan.targetCalories.round()} kcal',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MacroBar(
            proteinPercent: plan.proteinPercent,
            carbsPercent: plan.carbsPercent,
            fatPercent: plan.fatPercent,
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        MealCardSkeleton(),
        SizedBox(height: 16),
        MealCardSkeleton(),
        SizedBox(height: 16),
        MealCardSkeleton(),
      ],
    );
  }

  Widget _needProfile() {
    return EmptyState(
      icon: Icons.person_outline,
      title: '请先完善个人档案',
      subtitle: '填写年龄、身高、体重、目标后，才能生成今日食谱。',
      action: FilledButton.icon(
        onPressed: widget.onGoToProfile,
        icon: const Icon(Icons.edit),
        label: const Text('去填写档案'),
      ),
    );
  }

  Widget _error(String message, {VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: '加载失败',
      subtitle: message,
      action: onRetry == null
          ? FilledButton(onPressed: _forceRefresh, child: const Text('重试'))
          : FilledButton(onPressed: onRetry, child: const Text('重试')),
    );
  }
}
