import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/nutrition_calculator.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import 'common.dart';

/// 个人档案表单，被「首次引导页」和「我的」页共用。
class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.onSkip,
    this.skipLabel,
    this.initial,
  });

  final String submitLabel;
  final Future<void> Function(Profile profile) onSubmit;
  final VoidCallback? onSkip;
  final String? skipLabel;
  final Profile? initial;

  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _bodyFat;
  late final TextEditingController _targetWeight;
  late final TextEditingController _diet;
  late final TextEditingController _allergies;
  late final TextEditingController _medical;

  String _gender = Gender.male;
  String _goal = Goal.maintain;
  String _activity = ActivityLevel.light;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial ?? Profile();
    _age = TextEditingController(text: p.age.toString());
    _height = TextEditingController(text: _fmt(p.heightCm));
    _weight = TextEditingController(text: _fmt(p.weightKg));
    _bodyFat = TextEditingController(
        text: p.bodyFatPercent == null ? '' : _fmt(p.bodyFatPercent!));
    _targetWeight = TextEditingController(
        text: p.targetWeightKg == null ? '' : _fmt(p.targetWeightKg!));
    _diet = TextEditingController(text: p.dietPreference);
    _allergies = TextEditingController(text: p.allergies.join('、'));
    _medical = TextEditingController(text: p.medicalNotes ?? '');
    _gender = p.gender;
    _goal = p.goal;
    _activity = p.activityLevel;
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _bodyFat.dispose();
    _targetWeight.dispose();
    _diet.dispose();
    _allergies.dispose();
    _medical.dispose();
    super.dispose();
  }

  int? get _ageValue => int.tryParse(_age.text.trim());
  double? get _heightValue => double.tryParse(_height.text.trim());
  double? get _weightValue => double.tryParse(_weight.text.trim());

  String? get _ageError => NutritionCalculator.validateAge(_ageValue);
  String? get _heightError => NutritionCalculator.validateHeight(_heightValue);
  String? get _weightError => NutritionCalculator.validateWeight(_weightValue);

  bool get _valid =>
      _ageError == null && _heightError == null && _weightError == null;

  Profile _buildProfile() {
    return Profile(
      id: widget.initial?.id,
      age: _ageValue ?? 30,
      gender: _gender,
      heightCm: _heightValue ?? 175,
      weightKg: _weightValue ?? 70,
      bodyFatPercent: double.tryParse(_bodyFat.text.trim()),
      targetWeightKg: double.tryParse(_targetWeight.text.trim()),
      goal: _goal,
      activityLevel: _activity,
      dietPreference:
          _diet.text.trim().isEmpty ? '中餐' : _diet.text.trim(),
      allergies: _allergies.text
          .split(RegExp(r'[、,，\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      medicalNotes:
          _medical.text.trim().isEmpty ? null : _medical.text.trim(),
      isComplete: true,
      createdAt: widget.initial?.createdAt,
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先修正标红的输入项')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSubmit(_buildProfile());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = NutritionCalculator.compute(_buildProfile());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BlockTitle('基本信息'),
              _numberField(
                controller: _age,
                label: '年龄',
                suffix: '岁',
                error: _ageError,
                integer: true,
              ),
              const SizedBox(height: 12),
              Text('性别', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: Gender.male,
                      label: Text('男'),
                      icon: Icon(Icons.male)),
                  ButtonSegment(
                      value: Gender.female,
                      label: Text('女'),
                      icon: Icon(Icons.female)),
                ],
                selected: {_gender},
                onSelectionChanged: (s) => setState(() => _gender = s.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _height,
                      label: '身高',
                      suffix: 'cm',
                      error: _heightError,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _weight,
                      label: '体重',
                      suffix: 'kg',
                      error: _weightError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _bodyFat,
                      label: '体脂率（可选）',
                      suffix: '%',
                      error: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _targetWeight,
                      label: '目标体重（可选）',
                      suffix: 'kg',
                      error: null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BlockTitle('目标与活动'),
              Text('目标', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: Goal.lose, label: Text('减脂')),
                  ButtonSegment(value: Goal.maintain, label: Text('维持')),
                  ButtonSegment(value: Goal.gain, label: Text('增肌')),
                ],
                selected: {_goal},
                onSelectionChanged: (s) => setState(() => _goal = s.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _activity,
                decoration: const InputDecoration(labelText: '活动量'),
                items: ActivityLevel.all
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(ActivityLevel.label(e)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _activity = v ?? _activity),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BlockTitle('饮食与健康'),
              TextField(
                controller: _diet,
                decoration: const InputDecoration(labelText: '饮食偏好'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _allergies,
                decoration: const InputDecoration(
                  labelText: '过敏忌口',
                  hintText: '用顿号分隔，如：花生、虾',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medical,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '疾病用药（可选）',
                  hintText: '如：高血压，服 XX 药',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('实时营养目标', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _MetricGrid(target: target),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitLabel),
        ),
        if (widget.onSkip != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onSkip,
            child: Text(widget.skipLabel ?? '以后再说'),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? error,
    bool integer = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        if (integer)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        errorText: error,
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

class BlockTitle extends StatelessWidget {
  const BlockTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.target});
  final NutritionTarget target;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      MetricTile(
        label: 'BMI',
        value: NumFormat.one(target.bmi),
        hint: NutritionCalculator.bmiLabel(target.bmi),
      ),
      MetricTile(label: 'BMR', value: target.bmr.round().toString(), unit: 'kcal'),
      MetricTile(label: 'TDEE', value: target.tdee.round().toString(), unit: 'kcal'),
      MetricTile(
        label: '每日目标',
        value: target.targetCalories.round().toString(),
        unit: 'kcal',
      ),
      MetricTile(label: '蛋白质', value: target.proteinG.round().toString(), unit: 'g'),
      MetricTile(label: '碳水', value: target.carbsG.round().toString(), unit: 'g'),
      MetricTile(label: '脂肪', value: target.fatG.round().toString(), unit: 'g'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((w) => SizedBox(width: (MediaQuery.of(context).size.width - 48) / 2, child: w))
          .toList(),
    );
  }
}
