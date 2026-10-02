import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';

/// 记录页：饮食热量记录 + 体重记录与趋势。
class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  String _date = AppDate.todayKey();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: AppDate.parseKey(_date),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = AppDate.toKey(picked));
    }
  }

  void _shiftDate(int days) {
    final d = AppDate.parseKey(_date).add(Duration(days: days));
    setState(() => _date = AppDate.toKey(d));
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(nutritionTargetProvider);
    final recordsAsync = ref.watch(foodRecordsProvider(_date));

    return Scaffold(
      appBar: AppBar(title: const Text('记录')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodSheet(),
        icon: const Icon(Icons.add),
        label: const Text('添加饮食'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dateRow(),
          const SizedBox(height: 12),
          recordsAsync.when(
            loading: () => const SkeletonBox(height: 120),
            error: (e, _) => Text('加载失败：$e'),
            data: (records) => _summary(records, target),
          ),
          const SizedBox(height: 16),
          Text('饮食明细', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          recordsAsync.when(
            loading: () => const SkeletonBox(height: 60),
            error: (e, _) => const SizedBox.shrink(),
            data: (records) => records.isEmpty
                ? _emptyLine('当天暂无饮食记录')
                : Column(
                    children: records
                        .map((r) => _foodTile(r))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('体重记录',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _showAddBodyDialog,
                icon: const Icon(Icons.add),
                label: const Text('记录体重'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _bodySection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _dateRow() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _shiftDate(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: TextButton(
              onPressed: _pickDate,
              child: Text(AppDate.displayKey(_date)),
            ),
          ),
          IconButton(
            onPressed: () => _shiftDate(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _summary(List<FoodRecord> records, NutritionTarget? target) {
    double cal = 0, p = 0, c = 0, f = 0;
    for (final r in records) {
      cal += r.calories;
      p += r.proteinG;
      c += r.carbsG;
      f += r.fatG;
    }
    final total = p * 4 + c * 4 + f * 9;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('已摄入',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(
                target == null
                    ? NumFormat.cal(cal)
                    : '${cal.round()} / ${target.targetCalories.round()} kcal',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MacroBar(
            proteinPercent: total <= 0 ? 0 : p * 4 / total,
            carbsPercent: total <= 0 ? 0 : c * 4 / total,
            fatPercent: total <= 0 ? 0 : f * 9 / total,
          ),
        ],
      ),
    );
  }

  Widget _foodTile(FoodRecord r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.foodName,
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    '${MealType.label(r.mealType)} · 蛋白${r.proteinG.round()}g 碳水${r.carbsG.round()}g 脂肪${r.fatG.round()}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(NumFormat.cal(r.calories),
                style: Theme.of(context).textTheme.bodyMedium),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await ref
                    .read(recordRepositoryProvider)
                    .deleteFoodRecord(r.id!);
                ref.invalidate(foodRecordsProvider(_date));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  Widget _bodySection() {
    final async = ref.watch(bodyRecordsProvider);
    return async.when(
      loading: () => const SkeletonBox(height: 140),
      error: (e, _) => Text('加载失败：$e'),
      data: (records) {
        if (records.isEmpty) return _emptyLine('暂无体重记录');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: SizedBox(
                height: 180,
                child: records.length < 2
                    ? Center(
                        child: Text('至少两条记录后显示趋势',
                            style: Theme.of(context).textTheme.bodySmall),
                      )
                    : _chart(records),
              ),
            ),
            const SizedBox(height: 8),
            ...records.reversed.take(5).map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: Text('${r.weightKg} kg'),
                  subtitle: Text(AppDate.displayKey(r.recordDate)),
                  trailing: r.bodyFatPercent == null
                      ? null
                      : Text('体脂 ${r.bodyFatPercent}%'),
                )),
          ],
        );
      },
    );
  }

  Widget _chart(List<BodyRecord> records) {
    final spots = <FlSpot>[];
    for (var i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].weightKg));
    }
    final color = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFoodSheet() {
    final nameC = TextEditingController();
    final calC = TextEditingController();
    final pC = TextEditingController(text: '0');
    final cC = TextEditingController(text: '0');
    final fC = TextEditingController(text: '0');
    String meal = MealType.breakfast;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('添加饮食记录',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: '食物名称'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: meal,
                decoration: const InputDecoration(labelText: '餐次'),
                items: MealType.order
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(MealType.label(e)),
                        ))
                    .toList(),
                onChanged: (v) => setS(() => meal = v ?? meal),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(labelText: '热量 kcal'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _miniNumField(pC, '蛋白质 g')),
                const SizedBox(width: 8),
                Expanded(child: _miniNumField(cC, '碳水 g')),
                const SizedBox(width: 8),
                Expanded(child: _miniNumField(fC, '脂肪 g')),
              ]),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  if (nameC.text.trim().isEmpty) return;
                  await ref.read(recordRepositoryProvider).addFoodRecord(
                        FoodRecord(
                          recordDate: _date,
                          mealType: meal,
                          foodName: nameC.text.trim(),
                          calories: double.tryParse(calC.text) ?? 0,
                          proteinG: double.tryParse(pC.text) ?? 0,
                          carbsG: double.tryParse(cC.text) ?? 0,
                          fatG: double.tryParse(fC.text) ?? 0,
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                        ),
                      );
                  ref.invalidate(foodRecordsProvider(_date));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _miniNumField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(labelText: label),
    );
  }

  void _showAddBodyDialog() {
    final weightC = TextEditingController();
    final fatC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记录体重'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(labelText: '体重 kg'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fatC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: const InputDecoration(labelText: '体脂率 %（可选）'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final w = double.tryParse(weightC.text);
              if (w == null) return;
              await ref.read(recordRepositoryProvider).saveBodyRecord(
                    BodyRecord(
                      recordDate: _date,
                      weightKg: w,
                      bodyFatPercent: double.tryParse(fatC.text),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
              ref.invalidate(bodyRecordsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
