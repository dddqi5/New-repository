import 'app_database.dart';
import 'models.dart';

/// 每日食谱读写。保存时事务化写入 计划 -> 餐 -> 菜 -> 用料 四层结构。
class MealPlanRepository {
  MealPlanRepository(this._db);
  final AppDatabase _db;

  Future<DailyMealPlan?> getPlan(String date) async {
    final db = await _db.database;
    final planRows = await db.query('daily_meal_plan',
        where: 'plan_date = ?', whereArgs: [date], limit: 1);
    if (planRows.isEmpty) return null;

    final plan = DailyMealPlan.fromMap(planRows.first);
    final mealRows = await db.query('meal',
        where: 'plan_id = ?', whereArgs: [plan.id], orderBy: 'sort_order ASC');

    final meals = <Meal>[];
    for (final mr in mealRows) {
      final mealMeta = Meal.fromMap(mr);
      final dishRows = await db.query('dish',
          where: 'meal_id = ?', whereArgs: [mealMeta.id], orderBy: 'id ASC');
      final dishes = <Dish>[];
      for (final dr in dishRows) {
        final dishMeta = Dish.fromMap(dr);
        final ingRows = await db.query('dish_ingredient',
            where: 'dish_id = ?', whereArgs: [dishMeta.id], orderBy: 'id ASC');
        final ings = ingRows.map(DishIngredient.fromMap).toList();
        dishes.add(Dish.fromMap(dr, ingredients: ings));
      }
      meals.add(Meal.fromMap(mr, dishes: dishes));
    }
    return DailyMealPlan.fromMap(planRows.first, meals: meals);
  }

  Future<void> savePlan(DailyMealPlan plan) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('daily_meal_plan',
          where: 'plan_date = ?', whereArgs: [plan.planDate]);

      final planId = await txn.insert('daily_meal_plan', plan.toMap());

      for (final meal in plan.meals) {
        final mealMap = meal.toMap();
        mealMap.remove('id');
        mealMap['plan_id'] = planId;
        final mealId = await txn.insert('meal', mealMap);

        for (final dish in meal.dishes) {
          final dishMap = dish.toMap();
          dishMap.remove('id');
          dishMap['meal_id'] = mealId;
          final dishId = await txn.insert('dish', dishMap);

          for (final ing in dish.ingredients) {
            final ingMap = ing.toMap();
            ingMap.remove('id');
            ingMap['dish_id'] = dishId;
            await txn.insert('dish_ingredient', ingMap);
          }
        }
      }
    });
  }

  Future<void> deletePlan(String date) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final rows = await txn.query('daily_meal_plan',
          columns: ['id'], where: 'plan_date = ?', whereArgs: [date]);
      for (final r in rows) {
        final pid = r['id'];
        final mealRows = await txn.query('meal',
            columns: ['id'], where: 'plan_id = ?', whereArgs: [pid]);
        for (final m in mealRows) {
          final mid = m['id'];
          final dishRows = await txn.query('dish',
              columns: ['id'], where: 'meal_id = ?', whereArgs: [mid]);
          for (final d in dishRows) {
            await txn.delete('dish_ingredient',
                where: 'dish_id = ?', whereArgs: [d['id']]);
          }
          await txn.delete('dish', where: 'meal_id = ?', whereArgs: [mid]);
        }
        await txn.delete('meal', where: 'plan_id = ?', whereArgs: [pid]);
      }
      await txn.delete('daily_meal_plan',
          where: 'plan_date = ?', whereArgs: [date]);
    });
  }

  /// 档案变更时清空全部食谱缓存，强制重新生成。
  Future<void> deleteAllPlans() async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('dish_ingredient');
      await txn.delete('dish');
      await txn.delete('meal');
      await txn.delete('daily_meal_plan');
    });
  }
}
