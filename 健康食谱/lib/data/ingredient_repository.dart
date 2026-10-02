import 'app_database.dart';
import 'models.dart';

/// 食材缓存读写（含营养素与来源）。
class IngredientRepository {
  IngredientRepository(this._db);
  final AppDatabase _db;

  Future<Ingredient?> getByName(String name) async {
    final db = await _db.database;
    final rows = await db.query('ingredient',
        where: 'name = ?', whereArgs: [name], limit: 1);
    if (rows.isEmpty) return null;

    final ingredient = Ingredient.fromMap(rows.first);
    final id = ingredient.id;

    final nRows = await db.query('ingredient_nutrient',
        where: 'ingredient_id = ?', whereArgs: [id], limit: 1);
    final nutrient =
        nRows.isEmpty ? null : IngredientNutrient.fromMap(nRows.first);

    final sRows = await db.query('ingredient_source',
        where: 'ingredient_id = ?', whereArgs: [id], orderBy: 'id ASC');
    final sources = sRows.map(IngredientSource.fromMap).toList();

    return Ingredient.fromMap(rows.first, nutrient: nutrient, sources: sources);
  }

  Future<void> saveIngredient(Ingredient ing) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final existing = await txn.query('ingredient',
          columns: ['id'], where: 'name = ?', whereArgs: [ing.name], limit: 1);
      int ingredientId;
      final map = ing.toMap()..remove('id');
      if (existing.isNotEmpty) {
        ingredientId = existing.first['id'] as int;
        await txn.update('ingredient', map,
            where: 'id = ?', whereArgs: [ingredientId]);
        await txn.delete('ingredient_nutrient',
            where: 'ingredient_id = ?', whereArgs: [ingredientId]);
        await txn.delete('ingredient_source',
            where: 'ingredient_id = ?', whereArgs: [ingredientId]);
      } else {
        ingredientId = await txn.insert('ingredient', map);
      }

      if (ing.nutrient != null) {
        final nm = ing.nutrient!.toMap()
          ..remove('id')
          ..['ingredient_id'] = ingredientId;
        await txn.insert('ingredient_nutrient', nm);
      }

      for (final s in ing.sources) {
        final sm = s.toMap()
          ..remove('id')
          ..['ingredient_id'] = ingredientId;
        await txn.insert('ingredient_source', sm);
      }
    });
  }
}
