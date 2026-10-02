import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// 本地 SQLite 数据库（sqflite），版本 1。
/// 说明：为降低云端打包风险、避免代码生成步骤，本项目选用成熟的 sqflite
/// 直接编写 SQL，而非常用但需要 build_runner 的 Drift/Isar。
/// 表结构完全遵循 docs/数据表设计.md。
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'healthy_recipe.db';
  static const _version = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 首版无升级；后续新增字段时在此按 oldVersion 增量迁移。
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        body_fat_percent REAL,
        target_weight_kg REAL,
        goal TEXT NOT NULL,
        activity_level TEXT NOT NULL,
        diet_preference TEXT NOT NULL,
        allergies TEXT NOT NULL DEFAULT '[]',
        medical_notes TEXT,
        is_complete INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE nutrition_target (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        bmi REAL, bmr REAL, tdee REAL, target_calories REAL,
        protein_g REAL, carbs_g REAL, fat_g REAL,
        breakfast_cal REAL, lunch_cal REAL, dinner_cal REAL,
        formula_version TEXT, calculated_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE daily_meal_plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_date TEXT NOT NULL UNIQUE,
        goal TEXT, target_calories REAL,
        total_calories REAL, total_protein_g REAL,
        total_carbs_g REAL, total_fat_g REAL,
        status TEXT, generated_at INTEGER, source_note TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE meal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        sort_order INTEGER,
        calories REAL, protein_g REAL, carbs_g REAL, fat_g REAL,
        cover_image_url TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE dish (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        image_url TEXT,
        calories REAL, protein_g REAL, carbs_g REAL, fat_g REAL,
        steps TEXT, source_url TEXT, retrieved_date TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE dish_ingredient (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dish_id INTEGER NOT NULL,
        ingredient_id INTEGER,
        ingredient_name TEXT NOT NULL,
        amount REAL, unit TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE ingredient (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        name_en TEXT, image_url TEXT,
        evidence_level TEXT,
        benefits TEXT, pairings TEXT,
        cautions_evidence TEXT, cautions_folk TEXT,
        possible_effects TEXT, drug_interactions TEXT,
        disclaimer TEXT, fetched_at INTEGER, expire_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE ingredient_nutrient (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER NOT NULL UNIQUE,
        calories_kcal REAL, protein_g REAL, carbs_g REAL, fat_g REAL,
        fiber_g REAL, sodium_mg REAL, calcium_mg REAL, iron_mg REAL,
        vitamins_json TEXT, per INTEGER DEFAULT 100
      )
    ''');

    batch.execute('''
      CREATE TABLE ingredient_source (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER NOT NULL,
        title TEXT, url TEXT, publisher TEXT,
        retrieved_date TEXT, evidence_level TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE food_record (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        record_date TEXT NOT NULL,
        meal_type TEXT, food_name TEXT,
        amount_g REAL, calories REAL, protein_g REAL,
        carbs_g REAL, fat_g REAL, note TEXT, created_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE body_record (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        record_date TEXT NOT NULL UNIQUE,
        weight_kg REAL, body_fat_percent REAL, note TEXT, created_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL, query_type TEXT, created_at INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE app_setting (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    batch.execute('CREATE INDEX idx_meal_plan ON meal(plan_id)');
    batch.execute('CREATE INDEX idx_dish_meal ON dish(meal_id)');
    batch.execute('CREATE INDEX idx_dish_ingredient ON dish_ingredient(dish_id)');
    batch.execute('CREATE INDEX idx_source_ingredient ON ingredient_source(ingredient_id)');
    batch.execute('CREATE INDEX idx_food_date ON food_record(record_date)');
    batch.execute('CREATE INDEX idx_body_date ON body_record(record_date)');

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
