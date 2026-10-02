import '../data/models.dart';
import 'constants.dart';

/// 全部用本地公式计算，不依赖网络/AI。
/// 公式：Mifflin-St Jeor（目前营养学界常用且误差较小）。
class NutritionCalculator {
  static const formulaVersion = 'mifflin-v1';

  static NutritionTarget compute(Profile p) {
    final heightM = p.heightCm / 100.0;
    final bmi = heightM <= 0 ? 0.0 : p.weightKg / (heightM * heightM);

    final double bmr;
    if (p.gender == Gender.female) {
      bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age - 161;
    } else {
      bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + 5;
    }

    final tdee = bmr * ActivityLevel.factor(p.activityLevel);
    final targetCalories = tdee * Goal.factor(p.goal);

    // 三大营养素供能比：蛋白 25% / 碳水 45% / 脂肪 30%
    final proteinG = targetCalories * 0.25 / 4.0;
    final carbsG = targetCalories * 0.45 / 4.0;
    final fatG = targetCalories * 0.30 / 9.0;

    return NutritionTarget(
      profileId: p.id ?? 1,
      bmi: _round(bmi, 1),
      bmr: _round(bmr, 0),
      tdee: _round(tdee, 0),
      targetCalories: _round(targetCalories, 0),
      proteinG: _round(proteinG, 0),
      carbsG: _round(carbsG, 0),
      fatG: _round(fatG, 0),
      breakfastCal: _round(targetCalories * MealType.calorieRatio(MealType.breakfast), 0),
      lunchCal: _round(targetCalories * MealType.calorieRatio(MealType.lunch), 0),
      dinnerCal: _round(targetCalories * MealType.calorieRatio(MealType.dinner), 0),
      formulaVersion: formulaVersion,
      calculatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static double _round(double v, int digits) {
    final f = _pow10(digits);
    return (v * f).roundToDouble() / f;
  }

  static double _pow10(int n) {
    var r = 1.0;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  /// 校验输入范围
  static String? validateAge(int? v) {
    if (v == null) return '请输入年龄';
    if (v < 1 || v > 120) return '年龄需在 1-120';
    return null;
  }

  static String? validateHeight(double? v) {
    if (v == null) return '请输入身高';
    if (v < 80 || v > 250) return '身高需在 80-250cm';
    return null;
  }

  static String? validateWeight(double? v) {
    if (v == null) return '请输入体重';
    if (v < 20 || v > 300) return '体重需在 20-300kg';
    return null;
  }

  static String bmiLabel(double bmi) {
    if (bmi <= 0) return '';
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏重';
    return '肥胖';
  }
}
