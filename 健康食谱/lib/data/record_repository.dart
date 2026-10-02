import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'models.dart';

/// 饮食记录、体重记录、搜索历史。
class RecordRepository {
  RecordRepository(this._db);
  final AppDatabase _db;

  // ---- 饮食记录 ----
  Future<List<FoodRecord>> foodRecordsByDate(String date) async {
    final db = await _db.database;
    final rows = await db.query('food_record',
        where: 'record_date = ?', whereArgs: [date], orderBy: 'created_at DESC');
    return rows.map(FoodRecord.fromMap).toList();
  }

  Future<void> addFoodRecord(FoodRecord r) async {
    final db = await _db.database;
    await db.insert('food_record', r.toMap()..remove('id'));
  }

  Future<void> deleteFoodRecord(int id) async {
    final db = await _db.database;
    await db.delete('food_record', where: 'id = ?', whereArgs: [id]);
  }

  // ---- 体重记录 ----
  Future<List<BodyRecord>> bodyRecords() async {
    final db = await _db.database;
    final rows = await db
        .query('body_record', orderBy: 'record_date ASC');
    return rows.map(BodyRecord.fromMap).toList();
  }

  Future<void> saveBodyRecord(BodyRecord r) async {
    final db = await _db.database;
    await db.insert('body_record', r.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---- 搜索历史 ----
  Future<List<SearchHistoryItem>> searchHistory({int limit = 20}) async {
    final db = await _db.database;
    final rows = await db.query('search_history',
        orderBy: 'created_at DESC', limit: limit);
    return rows.map(SearchHistoryItem.fromMap).toList();
  }

  Future<void> addSearchHistory(String query, String type) async {
    final db = await _db.database;
    await db.insert('search_history', {
      'query': query,
      'query_type': type,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> clearSearchHistory() async {
    final db = await _db.database;
    await db.delete('search_history');
  }
}
