import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Low-level SQLite access layer for NutriLens.
///
/// Responsibilities:
///   - Maintain a single database connection (singleton).
///   - Define schema and versioned migrations.
///   - Expose table-agnostic CRUD operations.
///
/// This class intentionally has zero knowledge of app models.
/// All [MealEntry] ↔ map translation belongs in the repository layer,
/// keeping this class reusable for any future table.
class DatabaseHelper {
  // ── Singleton ─────────────────────────────────────────────────────────────

  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  // ── Constants ─────────────────────────────────────────────────────────────

  static const String _dbName = 'nutrilens.db';
  static const int _dbVersion = 1;

  /// Imported by repositories via [DatabaseHelper.mealTable].
  /// Never hard-coded inside a repository to avoid typo-driven bugs.
  static const String mealTable = 'meals';

  // ── Connection ────────────────────────────────────────────────────────────

  /// The Future is cached rather than the Database itself.
  /// This prevents a race condition where two concurrent callers both
  /// see `_dbFuture == null` and both invoke [_initDatabase] independently.
  Future<Database>? _dbFuture;

  Future<Database> get database {
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Schema ────────────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $mealTable (
        id            TEXT  PRIMARY KEY,
        food_name     TEXT  NOT NULL,
        weight_grams  REAL  NOT NULL,
        calories      REAL  NOT NULL,
        protein_g     REAL  NOT NULL,
        carbs_g       REAL  NOT NULL,
        fat_g         REAL  NOT NULL,
        fiber_g       REAL  NOT NULL DEFAULT 0,
        image_path    TEXT,
        logged_at     TEXT  NOT NULL,
        meal_type     TEXT  NOT NULL DEFAULT 'snack'
      )
    ''');
  }

  /// Migration hook for future schema versions.
  ///
  /// Pattern for every new version:
  /// ```dart
  /// if (oldVersion < 2) {
  ///   await db.execute('ALTER TABLE $mealTable ADD COLUMN ...');
  /// }
  /// ```
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // No migrations yet — reserved for future milestones.
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Inserts [row] into [table].
  ///
  /// [ConflictAlgorithm.replace] acts as an upsert, which is safe because
  /// [MealEntry] IDs are unique millisecond timestamps.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns rows from [table] matching [where] / [whereArgs],
  /// ordered by [orderBy], capped at [limit].
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Updates rows in [table] matching [where]. Returns rows affected.
  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, row, where: where, whereArgs: whereArgs);
  }

  /// Deletes rows from [table] matching [where]. Returns rows deleted.
  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Closes the connection and resets the cached Future.
  /// Primarily useful in integration tests; rarely called in production.
  Future<void> close() async {
    final db = await _dbFuture;
    _dbFuture = null;
    await db?.close();
  }
}