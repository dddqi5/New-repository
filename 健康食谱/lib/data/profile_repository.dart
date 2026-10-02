import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'models.dart';

/// 个人档案与营养目标。档案固定只有 id=1 一行，作为唯一数据源。
class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  Future<Profile?> getProfile() async {
    final db = await _db.database;
    final rows = await db.query('profile', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return Profile.fromMap(rows.first);
  }

  Future<void> saveProfile(Profile p) async {
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = p.toMap();
    map['id'] = 1;
    map['created_at'] = p.createdAt ?? now;
    map['updated_at'] = now;
    await db.insert('profile', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<NutritionTarget?> getTarget() async {
    final db = await _db.database;
    final rows = await db.query('nutrition_target',
        where: 'profile_id = 1', orderBy: 'calculated_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return NutritionTarget.fromMap(rows.first);
  }

  Future<void> saveTarget(NutritionTarget t) async {
    final db = await _db.database;
    await db.delete('nutrition_target', where: 'profile_id = 1');
    await db.insert('nutrition_target', t.toMap());
  }
}
