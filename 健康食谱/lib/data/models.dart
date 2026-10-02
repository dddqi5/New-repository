import 'dart:convert';

/// 所有数据模型。数据库通过 sqflite 存储，模型负责 Map <-> 对象 转换。
/// 复杂结构（数组/对象）统一以 JSON 字符串存进 TEXT 字段。

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

double? _asNullableDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

double _asDouble(dynamic v, [double fallback = 0]) =>
    _asNullableDouble(v) ?? fallback;

List<String> _asStringList(dynamic v) {
  if (v == null) return const [];
  if (v is List) return v.map((e) => e.toString()).toList();
  final s = v.toString().trim();
  if (s.isEmpty) return const [];
  try {
    final decoded = jsonDecode(s);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
  } catch (_) {}
  return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

// ---------------------------------------------------------------------------
// 个人档案
// ---------------------------------------------------------------------------
class Profile {
  int? id;
  int age;
  String gender;
  double heightCm;
  double weightKg;
  double? bodyFatPercent;
  double? targetWeightKg;
  String goal;
  String activityLevel;
  String dietPreference;
  List<String> allergies;
  String? medicalNotes;
  bool isComplete;
  int? createdAt;
  int? updatedAt;

  Profile({
    this.id,
    this.age = 30,
    this.gender = 'male',
    this.heightCm = 175,
    this.weightKg = 70,
    this.bodyFatPercent,
    this.targetWeightKg,
    this.goal = 'maintain',
    this.activityLevel = 'light',
    this.dietPreference = '中餐',
    this.allergies = const [],
    this.medicalNotes,
    this.isComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  Profile copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? bodyFatPercent,
    bool clearBodyFat = false,
    double? targetWeightKg,
    bool clearTargetWeight = false,
    String? goal,
    String? activityLevel,
    String? dietPreference,
    List<String>? allergies,
    String? medicalNotes,
    bool? isComplete,
    int? createdAt,
    int? updatedAt,
  }) {
    return Profile(
      id: id,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: clearBodyFat ? null : (bodyFatPercent ?? this.bodyFatPercent),
      targetWeightKg:
          clearTargetWeight ? null : (targetWeightKg ?? this.targetWeightKg),
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietPreference: dietPreference ?? this.dietPreference,
      allergies: allergies ?? this.allergies,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'body_fat_percent': bodyFatPercent,
        'target_weight_kg': targetWeightKg,
        'goal': goal,
        'activity_level': activityLevel,
        'diet_preference': dietPreference,
        'allergies': jsonEncode(allergies),
        'medical_notes': medicalNotes,
        'is_complete': isComplete ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] == null ? null : _asInt(m['id']),
        age: _asInt(m['age'], 30),
        gender: (m['gender'] ?? 'male').toString(),
        heightCm: _asDouble(m['height_cm'], 175),
        weightKg: _asDouble(m['weight_kg'], 70),
        bodyFatPercent: _asNullableDouble(m['body_fat_percent']),
        targetWeightKg: _asNullableDouble(m['target_weight_kg']),
        goal: (m['goal'] ?? 'maintain').toString(),
        activityLevel: (m['activity_level'] ?? 'light').toString(),
        dietPreference: (m['diet_preference'] ?? '中餐').toString(),
        allergies: _asStringList(m['allergies']),
        medicalNotes: m['medical_notes']?.toString(),
        isComplete: _asInt(m['is_complete']) == 1,
        createdAt: m['created_at'] == null ? null : _asInt(m['created_at']),
        updatedAt: m['updated_at'] == null ? null : _asInt(m['updated_at']),
      );
}

/// 营养目标（本地公式计算结果）
class NutritionTarget {
  int? id;
  int profileId;
  double bmi;
  double bmr;
  double tdee;
  double targetCalories;
  double proteinG;
  double carbsG;
  double fatG;
  double breakfastCal;
  double lunchCal;
  double dinnerCal;
  String formulaVersion;
  int calculatedAt;

  NutritionTarget({
    this.id,
    this.profileId = 1,
    this.bmi = 0,
    this.bmr = 0,
    this.tdee = 0,
    this.targetCalories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.breakfastCal = 0,
    this.lunchCal = 0,
    this.dinnerCal = 0,
    this.formulaVersion = 'mifflin-v1',
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'profile_id': profileId,
        'bmi': bmi,
        'bmr': bmr,
        'tdee': tdee,
        'target_calories': targetCalories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'breakfast_cal': breakfastCal,
        'lunch_cal': lunchCal,
        'dinner_cal': dinnerCal,
        'formula_version': formulaVersion,
        'calculated_at': calculatedAt,
      };

  factory NutritionTarget.fromMap(Map<String, dynamic> m) => NutritionTarget(
        id: m['id'] == null ? null : _asInt(m['id']),
        profileId: _asInt(m['profile_id'], 1),
        bmi: _asDouble(m['bmi']),
        bmr: _asDouble(m['bmr']),
        tdee: _asDouble(m['tdee']),
        targetCalories: _asDouble(m['target_calories']),
        proteinG: _asDouble(m['protein_g']),
        carbsG: _asDouble(m['carbs_g']),
        fatG: _asDouble(m['fat_g']),
        breakfastCal: _asDouble(m['breakfast_cal']),
        lunchCal: _asDouble(m['lunch_cal']),
        dinnerCal: _asDouble(m['dinner_cal']),
        formulaVersion: (m['formula_version'] ?? 'mifflin-v1').toString(),
        calculatedAt: _asInt(m['calculated_at']),
      );
}

// ---------------------------------------------------------------------------
// 食谱
// ---------------------------------------------------------------------------
class DailyMealPlan {
  int? id;
  String planDate; // YYYY-MM-DD
  String goal;
  double targetCalories;
  double totalCalories;
  double totalProteinG;
  double totalCarbsG;
  double totalFatG;
  String status; // generating / ready / failed
  int generatedAt;
  String sourceNote;
  List<Meal> meals;

  DailyMealPlan({
    this.id,
    required this.planDate,
    this.goal = 'maintain',
    this.targetCalories = 0,
    this.totalCalories = 0,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
    this.status = 'ready',
    required this.generatedAt,
    this.sourceNote = '',
    this.meals = const [],
  });

  double get totalMacroGrams => totalProteinG + totalCarbsG + totalFatG;

  /// 蛋白/碳水/脂肪 占比（按热量：蛋白4、碳水4、脂肪9）
  double get proteinPercent => _percent(totalProteinG, 4);
  double get carbsPercent => _percent(totalCarbsG, 4);
  double get fatPercent => _percent(totalFatG, 9);

  double _percent(double grams, double kcalPerGram) {
    final total =
        totalProteinG * 4 + totalCarbsG * 4 + totalFatG * 9;
    if (total <= 0) return 0;
    return (grams * kcalPerGram) / total;
  }

  Meal? mealOf(String type) {
    for (final m in meals) {
      if (m.mealType == type) return m;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'plan_date': planDate,
        'goal': goal,
        'target_calories': targetCalories,
        'total_calories': totalCalories,
        'total_protein_g': totalProteinG,
        'total_carbs_g': totalCarbsG,
        'total_fat_g': totalFatG,
        'status': status,
        'generated_at': generatedAt,
        'source_note': sourceNote,
      };

  factory DailyMealPlan.fromMap(Map<String, dynamic> m,
          {List<Meal> meals = const []}) =>
      DailyMealPlan(
        id: m['id'] == null ? null : _asInt(m['id']),
        planDate: (m['plan_date'] ?? '').toString(),
        goal: (m['goal'] ?? 'maintain').toString(),
        targetCalories: _asDouble(m['target_calories']),
        totalCalories: _asDouble(m['total_calories']),
        totalProteinG: _asDouble(m['total_protein_g']),
        totalCarbsG: _asDouble(m['total_carbs_g']),
        totalFatG: _asDouble(m['total_fat_g']),
        status: (m['status'] ?? 'ready').toString(),
        generatedAt: _asInt(m['generated_at']),
        sourceNote: (m['source_note'] ?? '').toString(),
        meals: meals,
      );
}

class Meal {
  int? id;
  int? planId;
  String mealType;
  int sortOrder;
  double calories;
  double proteinG;
  double carbsG;
  double fatG;
  String? coverImageUrl;
  List<Dish> dishes;

  Meal({
    this.id,
    this.planId,
    required this.mealType,
    this.sortOrder = 0,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.coverImageUrl,
    this.dishes = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'plan_id': planId,
        'meal_type': mealType,
        'sort_order': sortOrder,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'cover_image_url': coverImageUrl,
      };

  factory Meal.fromMap(Map<String, dynamic> m, {List<Dish> dishes = const []}) =>
      Meal(
        id: m['id'] == null ? null : _asInt(m['id']),
        planId: m['plan_id'] == null ? null : _asInt(m['plan_id']),
        mealType: (m['meal_type'] ?? 'breakfast').toString(),
        sortOrder: _asInt(m['sort_order']),
        calories: _asDouble(m['calories']),
        proteinG: _asDouble(m['protein_g']),
        carbsG: _asDouble(m['carbs_g']),
        fatG: _asDouble(m['fat_g']),
        coverImageUrl: m['cover_image_url']?.toString(),
        dishes: dishes,
      );
}

class Dish {
  int? id;
  int? mealId;
  String name;
  String? imageUrl;
  double calories;
  double proteinG;
  double carbsG;
  double fatG;
  List<String> steps;
  String? sourceUrl;
  String? retrievedDate;
  List<DishIngredient> ingredients;

  Dish({
    this.id,
    this.mealId,
    required this.name,
    this.imageUrl,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.steps = const [],
    this.sourceUrl,
    this.retrievedDate,
    this.ingredients = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'meal_id': mealId,
        'name': name,
        'image_url': imageUrl,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'steps': jsonEncode(steps),
        'source_url': sourceUrl,
        'retrieved_date': retrievedDate,
      };

  factory Dish.fromMap(Map<String, dynamic> m,
          {List<DishIngredient> ingredients = const []}) =>
      Dish(
        id: m['id'] == null ? null : _asInt(m['id']),
        mealId: m['meal_id'] == null ? null : _asInt(m['meal_id']),
        name: (m['name'] ?? '').toString(),
        imageUrl: m['image_url']?.toString(),
        calories: _asDouble(m['calories']),
        proteinG: _asDouble(m['protein_g']),
        carbsG: _asDouble(m['carbs_g']),
        fatG: _asDouble(m['fat_g']),
        steps: _asStringList(m['steps']),
        sourceUrl: m['source_url']?.toString(),
        retrievedDate: m['retrieved_date']?.toString(),
        ingredients: ingredients,
      );
}

class DishIngredient {
  int? id;
  int? dishId;
  int? ingredientId;
  String ingredientName;
  double? amount;
  String? unit;

  DishIngredient({
    this.id,
    this.dishId,
    this.ingredientId,
    required this.ingredientName,
    this.amount,
    this.unit,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dish_id': dishId,
        'ingredient_id': ingredientId,
        'ingredient_name': ingredientName,
        'amount': amount,
        'unit': unit,
      };

  factory DishIngredient.fromMap(Map<String, dynamic> m) => DishIngredient(
        id: m['id'] == null ? null : _asInt(m['id']),
        dishId: m['dish_id'] == null ? null : _asInt(m['dish_id']),
        ingredientId:
            m['ingredient_id'] == null ? null : _asInt(m['ingredient_id']),
        ingredientName: (m['ingredient_name'] ?? '').toString(),
        amount: _asNullableDouble(m['amount']),
        unit: m['unit']?.toString(),
      );
}

// ---------------------------------------------------------------------------
// 食材
// ---------------------------------------------------------------------------
class Ingredient {
  int? id;
  String name;
  String? nameEn;
  String? imageUrl;
  String evidenceLevel;
  List<String> benefits;
  List<String> pairings;
  List<String> cautionsEvidence;
  List<String> cautionsFolk;
  List<String> possibleEffects;
  List<String> drugInteractions;
  String disclaimer;
  int fetchedAt;
  int expireAt;
  IngredientNutrient? nutrient;
  List<IngredientSource> sources;

  Ingredient({
    this.id,
    required this.name,
    this.nameEn,
    this.imageUrl,
    this.evidenceLevel = 'insufficient',
    this.benefits = const [],
    this.pairings = const [],
    this.cautionsEvidence = const [],
    this.cautionsFolk = const [],
    this.possibleEffects = const [],
    this.drugInteractions = const [],
    this.disclaimer = '',
    required this.fetchedAt,
    required this.expireAt,
    this.nutrient,
    this.sources = const [],
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expireAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'image_url': imageUrl,
        'evidence_level': evidenceLevel,
        'benefits': jsonEncode(benefits),
        'pairings': jsonEncode(pairings),
        'cautions_evidence': jsonEncode(cautionsEvidence),
        'cautions_folk': jsonEncode(cautionsFolk),
        'possible_effects': jsonEncode(possibleEffects),
        'drug_interactions': jsonEncode(drugInteractions),
        'disclaimer': disclaimer,
        'fetched_at': fetchedAt,
        'expire_at': expireAt,
      };

  factory Ingredient.fromMap(Map<String, dynamic> m,
          {IngredientNutrient? nutrient, List<IngredientSource> sources = const []}) =>
      Ingredient(
        id: m['id'] == null ? null : _asInt(m['id']),
        name: (m['name'] ?? '').toString(),
        nameEn: m['name_en']?.toString(),
        imageUrl: m['image_url']?.toString(),
        evidenceLevel: (m['evidence_level'] ?? 'insufficient').toString(),
        benefits: _asStringList(m['benefits']),
        pairings: _asStringList(m['pairings']),
        cautionsEvidence: _asStringList(m['cautions_evidence']),
        cautionsFolk: _asStringList(m['cautions_folk']),
        possibleEffects: _asStringList(m['possible_effects']),
        drugInteractions: _asStringList(m['drug_interactions']),
        disclaimer: (m['disclaimer'] ?? '').toString(),
        fetchedAt: _asInt(m['fetched_at']),
        expireAt: _asInt(m['expire_at']),
        nutrient: nutrient,
        sources: sources,
      );
}

class IngredientNutrient {
  int? id;
  int? ingredientId;
  double? caloriesKcal;
  double? proteinG;
  double? carbsG;
  double? fatG;
  double? fiberG;
  double? sodiumMg;
  double? calciumMg;
  double? ironMg;
  Map<String, dynamic> vitamins;
  int per;

  IngredientNutrient({
    this.id,
    this.ingredientId,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.sodiumMg,
    this.calciumMg,
    this.ironMg,
    this.vitamins = const {},
    this.per = 100,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ingredient_id': ingredientId,
        'calories_kcal': caloriesKcal,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sodium_mg': sodiumMg,
        'calcium_mg': calciumMg,
        'iron_mg': ironMg,
        'vitamins_json': jsonEncode(vitamins),
        'per': per,
      };

  factory IngredientNutrient.fromMap(Map<String, dynamic> m) {
    Map<String, dynamic> vit = {};
    final raw = m['vitamins_json'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw.toString());
        if (decoded is Map) vit = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return IngredientNutrient(
      id: m['id'] == null ? null : _asInt(m['id']),
      ingredientId:
          m['ingredient_id'] == null ? null : _asInt(m['ingredient_id']),
      caloriesKcal: _asNullableDouble(m['calories_kcal']),
      proteinG: _asNullableDouble(m['protein_g']),
      carbsG: _asNullableDouble(m['carbs_g']),
      fatG: _asNullableDouble(m['fat_g']),
      fiberG: _asNullableDouble(m['fiber_g']),
      sodiumMg: _asNullableDouble(m['sodium_mg']),
      calciumMg: _asNullableDouble(m['calcium_mg']),
      ironMg: _asNullableDouble(m['iron_mg']),
      vitamins: vit,
      per: _asInt(m['per'], 100),
    );
  }
}

class IngredientSource {
  int? id;
  int? ingredientId;
  String title;
  String url;
  String? publisher;
  String retrievedDate;
  String evidenceLevel;

  IngredientSource({
    this.id,
    this.ingredientId,
    required this.title,
    required this.url,
    this.publisher,
    required this.retrievedDate,
    this.evidenceLevel = 'medium',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ingredient_id': ingredientId,
        'title': title,
        'url': url,
        'publisher': publisher,
        'retrieved_date': retrievedDate,
        'evidence_level': evidenceLevel,
      };

  factory IngredientSource.fromMap(Map<String, dynamic> m) => IngredientSource(
        id: m['id'] == null ? null : _asInt(m['id']),
        ingredientId:
            m['ingredient_id'] == null ? null : _asInt(m['ingredient_id']),
        title: (m['title'] ?? '').toString(),
        url: (m['url'] ?? '').toString(),
        publisher: m['publisher']?.toString(),
        retrievedDate: (m['retrieved_date'] ?? '').toString(),
        evidenceLevel: (m['evidence_level'] ?? 'medium').toString(),
      );
}

// ---------------------------------------------------------------------------
// 记录
// ---------------------------------------------------------------------------
class FoodRecord {
  int? id;
  int profileId;
  String recordDate;
  String mealType;
  String foodName;
  double? amountG;
  double calories;
  double proteinG;
  double carbsG;
  double fatG;
  String? note;
  int createdAt;

  FoodRecord({
    this.id,
    this.profileId = 1,
    required this.recordDate,
    required this.mealType,
    required this.foodName,
    this.amountG,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'profile_id': profileId,
        'record_date': recordDate,
        'meal_type': mealType,
        'food_name': foodName,
        'amount_g': amountG,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'note': note,
        'created_at': createdAt,
      };

  factory FoodRecord.fromMap(Map<String, dynamic> m) => FoodRecord(
        id: m['id'] == null ? null : _asInt(m['id']),
        profileId: _asInt(m['profile_id'], 1),
        recordDate: (m['record_date'] ?? '').toString(),
        mealType: (m['meal_type'] ?? 'breakfast').toString(),
        foodName: (m['food_name'] ?? '').toString(),
        amountG: _asNullableDouble(m['amount_g']),
        calories: _asDouble(m['calories']),
        proteinG: _asDouble(m['protein_g']),
        carbsG: _asDouble(m['carbs_g']),
        fatG: _asDouble(m['fat_g']),
        note: m['note']?.toString(),
        createdAt: _asInt(m['created_at']),
      );
}

class BodyRecord {
  int? id;
  int profileId;
  String recordDate;
  double weightKg;
  double? bodyFatPercent;
  String? note;
  int createdAt;

  BodyRecord({
    this.id,
    this.profileId = 1,
    required this.recordDate,
    required this.weightKg,
    this.bodyFatPercent,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'profile_id': profileId,
        'record_date': recordDate,
        'weight_kg': weightKg,
        'body_fat_percent': bodyFatPercent,
        'note': note,
        'created_at': createdAt,
      };

  factory BodyRecord.fromMap(Map<String, dynamic> m) => BodyRecord(
        id: m['id'] == null ? null : _asInt(m['id']),
        profileId: _asInt(m['profile_id'], 1),
        recordDate: (m['record_date'] ?? '').toString(),
        weightKg: _asDouble(m['weight_kg']),
        bodyFatPercent: _asNullableDouble(m['body_fat_percent']),
        note: m['note']?.toString(),
        createdAt: _asInt(m['created_at']),
      );
}

class SearchHistoryItem {
  int? id;
  String query;
  String queryType;
  int createdAt;

  SearchHistoryItem({
    this.id,
    required this.query,
    this.queryType = 'ingredient',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'query': query,
        'query_type': queryType,
        'created_at': createdAt,
      };

  factory SearchHistoryItem.fromMap(Map<String, dynamic> m) => SearchHistoryItem(
        id: m['id'] == null ? null : _asInt(m['id']),
        query: (m['query'] ?? '').toString(),
        queryType: (m['query_type'] ?? 'ingredient').toString(),
        createdAt: _asInt(m['created_at']),
      );
}
