import '../core/constants.dart';
import '../data/models.dart';
import 'api_services.dart';

/// 联网生成每日食谱。
/// 流程：搜索权威来源 → 交给 DeepSeek 按 JSON 结构整理 → 解析为模型。
/// 任何一步失败都返回 null，由上层回退到示例数据。
class MealPlanService {
  MealPlanService({
    required this.search,
    required this.llm,
  });

  final SearchService search;
  final DeepSeekService llm;

  Future<DailyMealPlan?> generate({
    required String date,
    required Profile profile,
    required NutritionTarget target,
    required ApiConfig cfg,
  }) async {
    if (!cfg.hasLlm) return null;

    final allergyText =
        profile.allergies.isEmpty ? '无' : profile.allergies.join('、');
    final query =
        '${profile.dietPreference} 一日三餐 健康食谱 ${Goal.label(profile.goal)} '
        '中国居民膳食指南 权威';

    final hits = await search.search(query, cfg);
    final context = hits.isEmpty
        ? '（本次未取到搜索结果，请仅依据权威来源知识作答，并如实标注来源）'
        : hits
            .take(6)
            .map((h) => '- ${h.title} | ${h.publisher} | ${h.url}')
            .join('\n');

    const system = '''
你是一名严谨的营养食谱助手。要求：
1. 只输出一个 JSON 对象，不要输出任何解释文字、不要用 Markdown 代码块。
2. 营养知识必须来自权威来源（WHO、中国居民膳食指南、NIH、USDA、Harvard、Mayo Clinic、CDC、NHS）。
3. 绝不输出"有毒/中毒/相克"等无来源结论。
4. 三餐热量比例：早餐30%、午餐40%、晚餐30%（可微调）。
5. 尊重用户的过敏忌口与饮食偏好。
6. 每道菜给出 source_url 与 retrieved_date。
JSON 结构：
{"meals":[
  {"type":"breakfast","dishes":[
    {"name":"菜名","calories":0,"protein":0,"carbs":0,"fat":0,
     "ingredients":[{"name":"食材","amount":100,"unit":"g"}],
     "steps":["步骤1","步骤2"],
     "source_url":"https://...","retrieved_date":"YYYY-MM-DD"}
  ]},
  {"type":"lunch","dishes":[]},
  {"type":"dinner","dishes":[]}
]}
''';

    final user = '''
用户档案：${profile.gender == Gender.female ? '女' : '男'}，${profile.age}岁，
身高${profile.heightCm}cm，体重${profile.weightKg}kg，目标${Goal.label(profile.goal)}，
活动量${ActivityLevel.label(profile.activityLevel)}，饮食偏好${profile.dietPreference}，
过敏忌口：$allergyText。
每日目标热量 ${target.targetCalories.round()} kcal；
早餐约 ${target.breakfastCal.round()} kcal，午餐约 ${target.lunchCal.round()} kcal，晚餐约 ${target.dinnerCal.round()} kcal；
蛋白 ${target.proteinG.round()}g，碳水 ${target.carbsG.round()}g，脂肪 ${target.fatG.round()}g。
日期：$date。
搜索结果（可作为来源参考）：
$context
请生成当天三餐食谱，只输出 JSON。
''';

    final data = await llm.jsonChat(system: system, user: user, cfg: cfg);
    if (data == null) return null;

    final mealsJson = data['meals'];
    if (mealsJson is! List) return null;

    final meals = <Meal>[];
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;

    for (final raw in mealsJson) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final type = (map['type'] ?? 'breakfast').toString();
      final dishesJson = map['dishes'];
      final dishes = <Dish>[];
      double mealCal = 0, mealP = 0, mealC = 0, mealF = 0;

      if (dishesJson is List) {
        for (final d in dishesJson) {
          if (d is! Map) continue;
          final dm = Map<String, dynamic>.from(d);
          final dish = _parseDish(dm);
          dishes.add(dish);
          mealCal += dish.calories;
          mealP += dish.proteinG;
          mealC += dish.carbsG;
          mealF += dish.fatG;
        }
      }
      if (dishes.isEmpty) continue;

      totalCal += mealCal;
      totalP += mealP;
      totalC += mealC;
      totalF += mealF;

      meals.add(Meal(
        mealType: type,
        sortOrder: MealType.sortOrder(type),
        calories: mealCal,
        proteinG: mealP,
        carbsG: mealC,
        fatG: mealF,
        dishes: dishes,
      ));
    }

    if (meals.isEmpty) return null;
    meals.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final sourceNote = hits.isEmpty
        ? 'DeepSeek 生成（未取得搜索来源）'
        : 'DeepSeek 生成，来源：${hits.take(3).map((h) => h.publisher.isEmpty ? h.title : h.publisher).join('、')}';

    return DailyMealPlan(
      planDate: date,
      goal: profile.goal,
      targetCalories: target.targetCalories,
      totalCalories: totalCal,
      totalProteinG: totalP,
      totalCarbsG: totalC,
      totalFatG: totalF,
      status: 'ready',
      generatedAt: DateTime.now().millisecondsSinceEpoch,
      sourceNote: sourceNote,
      meals: meals,
    );
  }

  Dish _parseDish(Map<String, dynamic> dm) {
    final ingredientsJson = dm['ingredients'];
    final ingredients = <DishIngredient>[];
    if (ingredientsJson is List) {
      for (final i in ingredientsJson) {
        if (i is! Map) continue;
        final im = Map<String, dynamic>.from(i);
        ingredients.add(DishIngredient(
          ingredientName: (im['name'] ?? '').toString(),
          amount: _num(im['amount']),
          unit: im['unit']?.toString(),
        ));
      }
    }

    final stepsJson = dm['steps'];
    final steps = <String>[];
    if (stepsJson is List) {
      steps.addAll(stepsJson.map((e) => e.toString()));
    }

    return Dish(
      name: (dm['name'] ?? '').toString(),
      calories: _num(dm['calories']) ?? 0,
      proteinG: _num(dm['protein']) ?? 0,
      carbsG: _num(dm['carbs']) ?? 0,
      fatG: _num(dm['fat']) ?? 0,
      steps: steps,
      sourceUrl: dm['source_url']?.toString(),
      retrievedDate: dm['retrieved_date']?.toString(),
      ingredients: ingredients,
    );
  }

  double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
