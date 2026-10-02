import '../core/constants.dart';
import '../data/models.dart';

/// 离线示例数据。
/// 未配置任何 API Key 时，App 用这些内置数据先跑通界面与流程；
/// 配置 Key 后会改为联网检索（见 meal_plan_service / ingredient_service）。
class SampleData {
  static const retrievedDate = '2026-10-02';

  // -------------------------------------------------------------------------
  // 示例食谱
  // -------------------------------------------------------------------------
  static DailyMealPlan buildPlan(
    String date,
    NutritionTarget target,
    Profile profile,
  ) {
    final meals = <Meal>[
      Meal(
        mealType: MealType.breakfast,
        sortOrder: 0,
        calories: target.breakfastCal,
        proteinG: target.proteinG * 0.30,
        carbsG: target.carbsG * 0.30,
        fatG: target.fatG * 0.30,
        dishes: [
          Dish(
            name: '牛奶燕麦粥',
            calories: target.breakfastCal * 0.55,
            proteinG: target.proteinG * 0.15,
            carbsG: target.carbsG * 0.22,
            fatG: target.fatG * 0.10,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://www.hsph.harvard.edu/nutritionsource/',
            steps: const [
              '燕麦片 40g 加牛奶 250ml，小火煮 3 分钟。',
              '关火后加入少量坚果碎，搅拌即可。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '燕麦', amount: 40, unit: 'g'),
              DishIngredient(ingredientName: '牛奶', amount: 250, unit: 'ml'),
            ],
          ),
          Dish(
            name: '水煮蛋',
            calories: target.breakfastCal * 0.45,
            proteinG: target.proteinG * 0.15,
            carbsG: target.carbsG * 0.08,
            fatG: target.fatG * 0.20,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://fdc.nal.usda.gov/',
            steps: const [
              '鸡蛋冷水下锅，水开后煮 7 分钟。',
              '过凉水后剥壳即可。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '鸡蛋', amount: 1, unit: '个'),
            ],
          ),
        ],
      ),
      Meal(
        mealType: MealType.lunch,
        sortOrder: 1,
        calories: target.lunchCal,
        proteinG: target.proteinG * 0.40,
        carbsG: target.carbsG * 0.45,
        fatG: target.fatG * 0.35,
        dishes: [
          Dish(
            name: '鸡胸肉炒时蔬',
            calories: target.lunchCal * 0.55,
            proteinG: target.proteinG * 0.30,
            carbsG: target.carbsG * 0.15,
            fatG: target.fatG * 0.15,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://fdc.nal.usda.gov/',
            steps: const [
              '鸡胸肉切片，用少量盐、黑胡椒腌 10 分钟。',
              '西兰花焯水 1 分钟捞出。',
              '热锅少油，先炒鸡肉至变色，再下西兰花翻炒 2 分钟。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '鸡胸肉', amount: 120, unit: 'g'),
              DishIngredient(ingredientName: '西兰花', amount: 150, unit: 'g'),
            ],
          ),
          Dish(
            name: '糙米饭',
            calories: target.lunchCal * 0.45,
            proteinG: target.proteinG * 0.10,
            carbsG: target.carbsG * 0.30,
            fatG: target.fatG * 0.20,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://www.hsph.harvard.edu/nutritionsource/',
            steps: const [
              '糙米提前浸泡 2 小时。',
              '米水比 1:1.5，电饭锅煮熟即可。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '糙米', amount: 80, unit: 'g'),
            ],
          ),
        ],
      ),
      Meal(
        mealType: MealType.dinner,
        sortOrder: 2,
        calories: target.dinnerCal,
        proteinG: target.proteinG * 0.30,
        carbsG: target.carbsG * 0.25,
        fatG: target.fatG * 0.35,
        dishes: [
          Dish(
            name: '清蒸三文鱼',
            calories: target.dinnerCal * 0.50,
            proteinG: target.proteinG * 0.25,
            carbsG: target.carbsG * 0.05,
            fatG: target.fatG * 0.22,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://www.mayoclinic.org/',
            steps: const [
              '三文鱼用姜片、少量料酒腌制 10 分钟。',
              '水开后上锅蒸 8 分钟，出锅淋少量生抽。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '三文鱼', amount: 120, unit: 'g'),
            ],
          ),
          Dish(
            name: '番茄豆腐汤',
            calories: target.dinnerCal * 0.30,
            proteinG: target.proteinG * 0.05,
            carbsG: target.carbsG * 0.12,
            fatG: target.fatG * 0.08,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://ods.od.nih.gov/',
            steps: const [
              '番茄切块炒出汁，加水煮开。',
              '下嫩豆腐块煮 3 分钟，加少许盐调味。',
            ],
            ingredients: [
              DishIngredient(ingredientName: '番茄', amount: 150, unit: 'g'),
              DishIngredient(ingredientName: '豆腐', amount: 100, unit: 'g'),
            ],
          ),
          Dish(
            name: '白米饭',
            calories: target.dinnerCal * 0.20,
            proteinG: target.proteinG * 0.0,
            carbsG: target.carbsG * 0.08,
            fatG: target.fatG * 0.05,
            retrievedDate: retrievedDate,
            sourceUrl: 'https://fdc.nal.usda.gov/',
            steps: const ['大米淘洗后按 1:1.2 加水煮熟。'],
            ingredients: [
              DishIngredient(ingredientName: '大米', amount: 60, unit: 'g'),
            ],
          ),
        ],
      ),
    ];

    return DailyMealPlan(
      planDate: date,
      goal: profile.goal,
      targetCalories: target.targetCalories,
      totalCalories: target.targetCalories,
      totalProteinG: target.proteinG,
      totalCarbsG: target.carbsG,
      totalFatG: target.fatG,
      status: 'ready',
      generatedAt: DateTime.now().millisecondsSinceEpoch,
      sourceNote: '示例数据（未配置 API Key，联网后自动替换）',
      meals: meals,
    );
  }

  // -------------------------------------------------------------------------
  // 示例食材
  // -------------------------------------------------------------------------
  static Ingredient? ingredient(String name) {
    switch (name) {
      case '鸡蛋':
        return _egg();
      case '燕麦':
        return _oats();
      case '鸡胸肉':
        return _chicken();
      case '西兰花':
        return _broccoli();
      case '三文鱼':
        return _salmon();
      case '番茄':
        return _tomato();
      case '牛奶':
        return _milk();
      case '豆腐':
        return _tofu();
      default:
        return null;
    }
  }

  static Ingredient _base({
    required String name,
    String? nameEn,
    String? imageUrl,
    required String evidence,
    required List<String> benefits,
    required List<String> pairings,
    required List<String> cautionsEvidence,
    required List<String> cautionsFolk,
    required List<String> possibleEffects,
    required List<String> drugInteractions,
    required IngredientNutrient nutrient,
    required List<IngredientSource> sources,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Ingredient(
      name: name,
      nameEn: nameEn,
      imageUrl: imageUrl,
      evidenceLevel: evidence,
      benefits: benefits,
      pairings: pairings,
      cautionsEvidence: cautionsEvidence,
      cautionsFolk: cautionsFolk,
      possibleEffects: possibleEffects,
      drugInteractions: drugInteractions,
      disclaimer: AppDefaults.disclaimer,
      fetchedAt: now,
      expireAt: now + const Duration(days: 30).inMilliseconds,
      nutrient: nutrient,
      sources: sources,
    );
  }

  static List<IngredientSource> _src(
          List<List<String>> rows) =>
      rows
          .map((r) => IngredientSource(
                title: r[0],
                url: r[1],
                publisher: r[2],
                retrievedDate: retrievedDate,
                evidenceLevel: r.length > 3 ? r[3] : EvidenceLevel.strong,
              ))
          .toList();

  static Ingredient _egg() => _base(
        name: '鸡蛋',
        nameEn: 'Egg',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '优质蛋白：氨基酸组成接近人体需要，利用率高。',
          '含胆碱，参与神经与大脑功能。',
          '含叶黄素/玉米黄质，与眼部黄斑健康相关。',
          '含维生素 D、B12 与硒。',
        ],
        pairings: const ['搭配全麦面包补充膳食纤维', '搭配番茄补充维生素 C 与番茄红素'],
        cautionsEvidence: const [
          '健康人群每天 1 个鸡蛋一般不影响血脂；高胆固醇人群应遵医嘱控制总量。',
        ],
        cautionsFolk: const [
          '「鸡蛋与豆浆相克」无可靠证据，正常同食无碍。',
        ],
        possibleEffects: const [
          '对鸡蛋过敏者可能出现皮疹、消化道不适等过敏反应（Mayo Clinic）。',
        ],
        drugInteractions: const [],
        nutrient: IngredientNutrient(
          caloriesKcal: 143,
          proteinG: 12.6,
          carbsG: 0.7,
          fatG: 9.5,
          fiberG: 0,
          sodiumMg: 142,
          calciumMg: 56,
          ironMg: 1.8,
          vitamins: const {'维生素D_ug': 2.0, '维生素B12_ug': 1.1, '胆碱_mg': 294},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Egg, whole, raw', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['Mayo Clinic - Egg allergy', 'https://www.mayoclinic.org/diseases-conditions/egg-allergy/symptoms-causes/syc-20372115', 'Mayo Clinic', EvidenceLevel.strong],
        ]),
      );

  static Ingredient _oats() => _base(
        name: '燕麦',
        nameEn: 'Oats',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '富含 β-葡聚糖（可溶性膳食纤维），有助降低 LDL 胆固醇。',
          '饱腹感强，有助体重管理。',
          '升糖相对平缓。',
        ],
        pairings: const ['搭配牛奶/无糖酸奶补充蛋白与钙', '搭配坚果补充不饱和脂肪'],
        cautionsEvidence: const [
          '对麸质敏感者应选择标注「无麸质」的燕麦。',
        ],
        cautionsFolk: const ['无特殊民间禁忌。'],
        possibleEffects: const [
          '突然大量摄入膳食纤维可能引起腹胀、排气增多。',
        ],
        drugInteractions: const [],
        nutrient: IngredientNutrient(
          caloriesKcal: 389,
          proteinG: 16.9,
          carbsG: 66.3,
          fatG: 6.9,
          fiberG: 10.6,
          sodiumMg: 2,
          calciumMg: 54,
          ironMg: 4.7,
          vitamins: const {'维生素B1_mg': 0.76, '镁_mg': 177},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Oats', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['Harvard Nutrition Source - Oats', 'https://www.hsph.harvard.edu/nutritionsource/food-features/oats/', 'Harvard', EvidenceLevel.strong],
        ]),
      );

  static Ingredient _chicken() => _base(
        name: '鸡胸肉',
        nameEn: 'Chicken breast',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '高蛋白低脂，有助肌肉维持与修复。',
          '含维生素 B6、烟酸。',
          '热量密度低，利于体重管理。',
        ],
        pairings: const ['搭配西兰花等深色蔬菜', '搭配糙米做主食'],
        cautionsEvidence: const [
          '必须彻底加热至中心熟透，避免沙门氏菌等食源性感染（CDC）。',
        ],
        cautionsFolk: const ['无特殊民间禁忌。'],
        possibleEffects: const [
          '未熟透可能引起食源性胃肠炎（CDC）。',
        ],
        drugInteractions: const [],
        nutrient: IngredientNutrient(
          caloriesKcal: 165,
          proteinG: 31.0,
          carbsG: 0,
          fatG: 3.6,
          fiberG: 0,
          sodiumMg: 74,
          calciumMg: 15,
          ironMg: 1.0,
          vitamins: const {'烟酸_mg': 14.8, '维生素B6_mg': 0.9},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Chicken breast', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['CDC - Chicken and Food Poisoning', 'https://www.cdc.gov/foodborne-outbreaks/', 'CDC', EvidenceLevel.strong],
        ]),
      );

  static Ingredient _broccoli() => _base(
        name: '西兰花',
        nameEn: 'Broccoli',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '富含维生素 C、维生素 K 与叶酸。',
          '含萝卜硫素等植物化学物。',
          '膳食纤维丰富，有益肠道健康。',
        ],
        pairings: const ['搭配瘦肉补充蛋白', '搭配番茄增加抗氧化物质'],
        cautionsEvidence: const [
          '服用华法林等抗凝药者，维生素 K 摄入应保持稳定并咨询医生。',
        ],
        cautionsFolk: const ['「十字花科致甲状腺肿」在日常正常食用量下证据不足，甲功异常者遵医嘱。'],
        possibleEffects: const ['大量生食可能引起腹胀。'],
        drugInteractions: const ['维生素 K 可能影响华法林等抗凝药效果（NHS）。'],
        nutrient: IngredientNutrient(
          caloriesKcal: 34,
          proteinG: 2.8,
          carbsG: 6.6,
          fatG: 0.4,
          fiberG: 2.6,
          sodiumMg: 33,
          calciumMg: 47,
          ironMg: 0.7,
          vitamins: const {'维生素C_mg': 89.2, '维生素K_ug': 101.6, '叶酸_ug': 63},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Broccoli', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['NHS - Vitamin K', 'https://www.nhs.uk/conditions/vitamins-and-minerals/vitamin-k/', 'NHS', EvidenceLevel.strong],
        ]),
      );

  static Ingredient _salmon() => _base(
        name: '三文鱼',
        nameEn: 'Salmon',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '富含 EPA/DHA（Omega-3 脂肪酸），与心血管健康相关。',
          '优质蛋白来源。',
          '含维生素 D。',
        ],
        pairings: const ['搭配深色蔬菜', '搭配全谷物主食'],
        cautionsEvidence: const [
          '孕妇、备孕及哺乳期人群应注意汞暴露与来源，选择正规渠道并控制频次（FDA/EPA）。',
        ],
        cautionsFolk: const ['无特殊民间禁忌。'],
        possibleEffects: const ['鱼类过敏者可能出现过敏反应。'],
        drugInteractions: const [],
        nutrient: IngredientNutrient(
          caloriesKcal: 208,
          proteinG: 20.4,
          carbsG: 0,
          fatG: 13.4,
          fiberG: 0,
          sodiumMg: 59,
          calciumMg: 9,
          ironMg: 0.3,
          vitamins: const {'维生素D_ug': 11, '维生素B12_ug': 3.2, 'DHA_mg': 1100},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Salmon', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['FDA - Advice about Eating Fish', 'https://www.fda.gov/food/consumers/advice-about-eating-fish', 'FDA', EvidenceLevel.strong],
        ]),
      );

  static Ingredient _tomato() => _base(
        name: '番茄',
        nameEn: 'Tomato',
        evidence: EvidenceLevel.medium,
        benefits: const [
          '富含番茄红素，加热并配少量油脂更利于吸收。',
          '提供维生素 C、钾。',
          '热量低，适合体重管理。',
        ],
        pairings: const ['搭配少量橄榄油', '搭配鸡蛋'],
        cautionsEvidence: const ['胃食管反流人群可能对酸性食物敏感，需个体观察。'],
        cautionsFolk: const ['「番茄与黄瓜相克」证据不足。'],
        possibleEffects: const ['部分人空腹大量食用后胃部不适。'],
        drugInteractions: const [],
        nutrient: IngredientNutrient(
          caloriesKcal: 18,
          proteinG: 0.9,
          carbsG: 3.9,
          fatG: 0.2,
          fiberG: 1.2,
          sodiumMg: 5,
          calciumMg: 10,
          ironMg: 0.3,
          vitamins: const {'维生素C_mg': 13.7, '钾_mg': 237, '番茄红素_mg': 2.6},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Tomato', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['Harvard Nutrition Source - Tomatoes', 'https://www.hsph.harvard.edu/nutritionsource/food-features/tomatoes/', 'Harvard', EvidenceLevel.medium],
        ]),
      );

  static Ingredient _milk() => _base(
        name: '牛奶',
        nameEn: 'Milk',
        evidence: EvidenceLevel.strong,
        benefits: const [
          '钙与优质蛋白来源，有益骨骼健康。',
          '含维生素 B2、B12。',
        ],
        pairings: const ['搭配燕麦', '搭配水果'],
        cautionsEvidence: const [
          '乳糖不耐受者可能出现腹胀、腹泻，可选择低乳糖产品（NIH）。',
        ],
        cautionsFolk: const ['无特殊民间禁忌。'],
        possibleEffects: const ['乳糖不耐受或牛奶蛋白过敏者出现不适。'],
        drugInteractions: const ['牛奶中的钙可能影响部分抗生素（如四环素类）吸收，建议间隔服用（NIH）。'],
        nutrient: IngredientNutrient(
          caloriesKcal: 61,
          proteinG: 3.2,
          carbsG: 4.8,
          fatG: 3.3,
          fiberG: 0,
          sodiumMg: 43,
          calciumMg: 113,
          ironMg: 0.03,
          vitamins: const {'维生素B2_mg': 0.17, '维生素B12_ug': 0.45, '维生素D_ug': 1.3},
        ),
        sources: _src(const [
          ['NIH ODS - Calcium', 'https://ods.od.nih.gov/factsheets/Calcium-Consumer/', 'NIH', EvidenceLevel.strong],
          ['USDA FoodData Central - Milk', 'https://fdc.nal.usda.gov/', 'USDA'],
        ]),
      );

  static Ingredient _tofu() => _base(
        name: '豆腐',
        nameEn: 'Tofu',
        evidence: EvidenceLevel.medium,
        benefits: const [
          '植物优质蛋白来源。',
          '含钙（视凝固剂而定）与铁。',
          '饱和脂肪低。',
        ],
        pairings: const ['搭配番茄', '搭配深色蔬菜'],
        cautionsEvidence: const ['甲状腺功能异常并服药者，大豆制品摄入应咨询医生。'],
        cautionsFolk: const ['「豆腐与菠菜相克」证据不足；同食影响草酸/钙吸收的程度有限，正常食用无碍。'],
        possibleEffects: const ['大豆过敏者可能出现过敏反应。'],
        drugInteractions: const ['左甲状腺素等药物建议与豆制品间隔服用（Mayo Clinic）。'],
        nutrient: IngredientNutrient(
          caloriesKcal: 76,
          proteinG: 8.1,
          carbsG: 1.9,
          fatG: 4.8,
          fiberG: 0.3,
          sodiumMg: 7,
          calciumMg: 350,
          ironMg: 5.4,
          vitamins: const {'钙_mg': 350, '镁_mg': 30},
        ),
        sources: _src(const [
          ['USDA FoodData Central - Tofu', 'https://fdc.nal.usda.gov/', 'USDA'],
          ['Mayo Clinic - Levothyroxine', 'https://www.mayoclinic.org/drugs-supplements/levothyroxine-oral-route/description/drg-20072133', 'Mayo Clinic', EvidenceLevel.medium],
        ]),
      );

  /// 未收录且未配置 API Key 时的占位结果。
  static Ingredient generic(String name) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Ingredient(
      name: name,
      evidenceLevel: EvidenceLevel.insufficient,
      benefits: const ['尚未联网检索。配置 API Key 后会自动搜索权威来源并生成。'],
      disclaimer: AppDefaults.disclaimer,
      fetchedAt: now,
      expireAt: now + const Duration(days: 1).inMilliseconds,
    );
  }
}
