/// 全局常量与枚举字符串。
/// 所有分类值统一使用英文存储，展示时再转成中文，避免数据库里混入中文分类。

class Gender {
  static const male = 'male';
  static const female = 'female';

  static String label(String v) => v == female ? '女' : '男';
}

class Goal {
  static const lose = 'lose';
  static const gain = 'gain';
  static const maintain = 'maintain';

  static String label(String v) {
    switch (v) {
      case lose:
        return '减脂';
      case gain:
        return '增肌';
      default:
        return '维持';
    }
  }

  /// 目标热量系数
  static double factor(String v) {
    switch (v) {
      case lose:
        return 0.80;
      case gain:
        return 1.10;
      default:
        return 1.00;
    }
  }
}

class ActivityLevel {
  static const sedentary = 'sedentary';
  static const light = 'light';
  static const moderate = 'moderate';
  static const active = 'active';
  static const veryActive = 'very_active';

  static const List<String> all = [sedentary, light, moderate, active, veryActive];

  static String label(String v) {
    switch (v) {
      case sedentary:
        return '久坐（几乎不运动）';
      case light:
        return '轻度（每周1-3次）';
      case moderate:
        return '中度（每周3-5次）';
      case active:
        return '活跃（每周6-7次）';
      case veryActive:
        return '非常活跃（体力劳动/2次训练）';
      default:
        return '轻度（每周1-3次）';
    }
  }

  /// TDEE 活动系数
  static double factor(String v) {
    switch (v) {
      case sedentary:
        return 1.2;
      case light:
        return 1.375;
      case moderate:
        return 1.55;
      case active:
        return 1.725;
      case veryActive:
        return 1.9;
      default:
        return 1.375;
    }
  }
}

class MealType {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';

  static const List<String> order = [breakfast, lunch, dinner];

  static int sortOrder(String v) => order.indexOf(v);

  static String label(String v) {
    switch (v) {
      case breakfast:
        return '早餐';
      case lunch:
        return '午餐';
      case dinner:
        return '晚餐';
      default:
        return '加餐';
    }
  }

  /// 三餐热量分配
  static double calorieRatio(String v) {
    switch (v) {
      case breakfast:
        return 0.30;
      case lunch:
        return 0.40;
      case dinner:
        return 0.30;
      default:
        return 0.0;
    }
  }
}

class EvidenceLevel {
  static const strong = 'strong';
  static const medium = 'medium';
  static const weak = 'weak';
  static const folk = 'folk';
  static const insufficient = 'insufficient';

  static String label(String v) {
    switch (v) {
      case strong:
        return '证据：强';
      case medium:
        return '证据：中';
      case weak:
        return '证据：弱';
      case folk:
        return '民间说法';
      default:
        return '证据不足';
    }
  }
}

class AppDefaults {
  static const appName = '健康食谱';
  static const disclaimer = '本页内容为一般健康信息，不构成医疗建议，不能替代医生或注册营养师的诊断与处方。';
}
