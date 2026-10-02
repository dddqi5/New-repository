import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// 键值设置：API Key、主题、搜索提供方等。
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  static const kDeepSeekKey = 'deepseek_api_key';
  static const kSearchProvider = 'search_api_provider';
  static const kSearchKey = 'search_api_key';
  static const kRecipeProvider = 'recipe_api_provider';
  static const kRecipeKey = 'recipe_api_key';
  static const kThemeMode = 'theme_mode';
  static const kLastPlanDate = 'last_meal_plan_date';

  Future<String?> get(String key) async {
    final db = await _db.database;
    final rows = await db
        .query('app_setting', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value']?.toString();
  }

  Future<void> set(String key, String? value) async {
    final db = await _db.database;
    await db.insert(
      'app_setting',
      {'key': key, 'value': value ?? ''},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('app_setting');
    final map = <String, String>{};
    for (final r in rows) {
      map[r['key'].toString()] = (r['value'] ?? '').toString();
    }
    return map;
  }
}
