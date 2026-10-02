import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/nutrition_calculator.dart';
import '../data/app_database.dart';
import '../data/ingredient_repository.dart';
import '../data/meal_plan_repository.dart';
import '../data/models.dart';
import '../data/profile_repository.dart';
import '../data/record_repository.dart';
import '../data/settings_repository.dart';
import '../services/api_services.dart';
import '../services/ingredient_service.dart';
import '../services/meal_plan_service.dart';
import '../services/sample_data.dart';

/// 档案不完整时用这个异常，首页据此显示引导。
class ProfileIncompleteException implements Exception {
  const ProfileIncompleteException();
}

// ---------------------------------------------------------------------------
// 基础设施
// ---------------------------------------------------------------------------
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 40),
  ));
});

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository(ref.read(databaseProvider)));
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.read(databaseProvider)));
final mealPlanRepositoryProvider =
    Provider<MealPlanRepository>((ref) => MealPlanRepository(ref.read(databaseProvider)));
final ingredientRepositoryProvider =
    Provider<IngredientRepository>((ref) => IngredientRepository(ref.read(databaseProvider)));
final recordRepositoryProvider =
    Provider<RecordRepository>((ref) => RecordRepository(ref.read(databaseProvider)));

final searchServiceProvider =
    Provider<SearchService>((ref) => SearchService(ref.read(dioProvider)));
final deepSeekServiceProvider =
    Provider<DeepSeekService>((ref) => DeepSeekService(ref.read(dioProvider)));
final mealPlanServiceProvider = Provider<MealPlanService>((ref) => MealPlanService(
      search: ref.read(searchServiceProvider),
      llm: ref.read(deepSeekServiceProvider),
    ));
final ingredientServiceProvider = Provider<IngredientService>((ref) => IngredientService(
      search: ref.read(searchServiceProvider),
      llm: ref.read(deepSeekServiceProvider),
    ));

// ---------------------------------------------------------------------------
// API 配置
// ---------------------------------------------------------------------------
class ApiConfigNotifier extends StateNotifier<ApiConfig> {
  ApiConfigNotifier(this._repo) : super(const ApiConfig()) {
    load();
  }
  final SettingsRepository _repo;

  Future<void> load() async {
    state = ApiConfig(
      deepseekKey: await _repo.get(SettingsRepository.kDeepSeekKey) ?? '',
      searchProvider:
          await _repo.get(SettingsRepository.kSearchProvider) ?? 'brave',
      searchKey: await _repo.get(SettingsRepository.kSearchKey) ?? '',
      recipeProvider:
          await _repo.get(SettingsRepository.kRecipeProvider) ?? 'spoonacular',
      recipeKey: await _repo.get(SettingsRepository.kRecipeKey) ?? '',
    );
  }

  Future<void> save(ApiConfig cfg) async {
    await _repo.set(SettingsRepository.kDeepSeekKey, cfg.deepseekKey);
    await _repo.set(SettingsRepository.kSearchProvider, cfg.searchProvider);
    await _repo.set(SettingsRepository.kSearchKey, cfg.searchKey);
    await _repo.set(SettingsRepository.kRecipeProvider, cfg.recipeProvider);
    await _repo.set(SettingsRepository.kRecipeKey, cfg.recipeKey);
    state = cfg;
  }
}

final apiConfigProvider =
    StateNotifierProvider<ApiConfigNotifier, ApiConfig>((ref) {
  return ApiConfigNotifier(ref.read(settingsRepositoryProvider));
});

// ---------------------------------------------------------------------------
// 档案
// ---------------------------------------------------------------------------
class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() {
    return ref.read(profileRepositoryProvider).getProfile();
  }

  Future<void> save(Profile p) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final planRepo = ref.read(mealPlanRepositoryProvider);

    final complete = p.copyWith(isComplete: true);
    await profileRepo.saveProfile(complete);
    await profileRepo.saveTarget(NutritionCalculator.compute(complete));
    // 档案是唯一数据源：变更后清空今日食谱缓存，强制联网重新生成。
    await planRepo.deleteAllPlans();

    state = AsyncData(complete);
    ref.invalidate(mealPlanProvider);
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, Profile?>(ProfileNotifier.new);

/// 已加载的档案（加载中/失败时为 null）。
final profileValueProvider = Provider<Profile?>((ref) {
  return ref.watch(profileProvider).valueOrNull;
});

/// 由档案实时算出的营养目标。
final nutritionTargetProvider = Provider<NutritionTarget?>((ref) {
  final p = ref.watch(profileValueProvider);
  if (p == null || !p.isComplete) return null;
  return NutritionCalculator.compute(p);
});

// ---------------------------------------------------------------------------
// 今日食谱
// ---------------------------------------------------------------------------
final mealPlanProvider =
    FutureProvider.family<DailyMealPlan, String>((ref, date) async {
  final profile = ref.watch(profileValueProvider);
  if (profile == null || !profile.isComplete) {
    throw const ProfileIncompleteException();
  }

  final repo = ref.read(mealPlanRepositoryProvider);
  final cached = await repo.getPlan(date);
  if (cached != null && cached.status == 'ready' && cached.meals.isNotEmpty) {
    return cached;
  }

  final target = NutritionCalculator.compute(profile);
  final cfg = ref.watch(apiConfigProvider);
  final service = ref.read(mealPlanServiceProvider);

  final generated = await service.generate(
    date: date,
    profile: profile,
    target: target,
    cfg: cfg,
  );
  final plan = generated ?? SampleData.buildPlan(date, target, profile);

  await repo.savePlan(plan);
  return plan;
});

// ---------------------------------------------------------------------------
// 食材
// ---------------------------------------------------------------------------
final ingredientProvider =
    FutureProvider.family<Ingredient, String>((ref, name) async {
  final repo = ref.read(ingredientRepositoryProvider);
  final cfg = ref.watch(apiConfigProvider);

  final cached = await repo.getByName(name);
  if (cached != null && !cached.isExpired) return cached;

  final service = ref.read(ingredientServiceProvider);
  final fetched = await service.fetch(name, cfg);
  final result =
      fetched ?? SampleData.ingredient(name) ?? SampleData.generic(name);

  await repo.saveIngredient(result);
  return result;
});

// ---------------------------------------------------------------------------
// 记录
// ---------------------------------------------------------------------------
final foodRecordsProvider =
    FutureProvider.family<List<FoodRecord>, String>((ref, date) async {
  return ref.read(recordRepositoryProvider).foodRecordsByDate(date);
});

final bodyRecordsProvider = FutureProvider<List<BodyRecord>>((ref) async {
  return ref.read(recordRepositoryProvider).bodyRecords();
});

// ---------------------------------------------------------------------------
// 主题
// ---------------------------------------------------------------------------
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._repo) : super(ThemeMode.system) {
    load();
  }
  final SettingsRepository _repo;

  Future<void> load() async {
    final v = await _repo.get(SettingsRepository.kThemeMode);
    state = _parse(v);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _repo.set(SettingsRepository.kThemeMode, mode.name);
  }

  ThemeMode _parse(String? v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(settingsRepositoryProvider));
});
