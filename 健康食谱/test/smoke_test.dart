import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_recipe/core/nutrition_calculator.dart';
import 'package:healthy_recipe/data/models.dart';

void main() {
  test('默认示例档案的 BMI / BMR / TDEE 计算', () {
    final p = Profile(
      age: 30,
      gender: 'male',
      heightCm: 175,
      weightKg: 70,
      goal: 'maintain',
      activityLevel: 'light',
    );
    final t = NutritionCalculator.compute(p);
    expect(t.bmi, closeTo(22.9, 0.2));
    expect(t.bmr, closeTo(1649, 1));
    expect(t.tdee, closeTo(2267, 2));
    expect(t.targetCalories, closeTo(t.tdee, 0.001));
  });

  test('输入范围校验', () {
    expect(NutritionCalculator.validateAge(0), isNotNull);
    expect(NutritionCalculator.validateAge(30), isNull);
    expect(NutritionCalculator.validateHeight(300), isNotNull);
    expect(NutritionCalculator.validateWeight(10), isNotNull);
  });
}
