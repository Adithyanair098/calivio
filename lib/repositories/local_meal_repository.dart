import '../database/database_helper.dart';
import '../models/meal_entry.dart';
import '../services/meal_events.dart';
import 'meal_repository.dart';

/// SQLite-backed implementation of [MealRepository].
///
/// ── Injecting DatabaseHelper ───────────────────────────────────────────────
/// [db] defaults to [DatabaseHelper.instance] so production callers need no
/// arguments. Tests pass a mock instance for full isolation.
///
/// ── Date range queries ─────────────────────────────────────────────────────
/// Entries are stored with [logged_at] as ISO-8601 local-time text, e.g.
/// "2024-01-15T14:23:00.000". SQLite's lexicographic ordering of ISO-8601
/// strings is numerically correct, so >= / < comparisons work as expected.
///
/// INVARIANT: [MealEntry.create] must always use local time (DateTime.now()).
/// Switching to UTC would silently break all date-range WHERE clauses.
///
/// ── Change notifications ────────────────────────────────────────────────────
/// Every mutating method notifies [MealEvents.instance] after the write
/// succeeds. This is what allows screens outside this repository's
/// immediate call chain (e.g. HomeScreen, living in a different bottom-nav
/// tab) to know meal data changed and refresh themselves.
///
/// ── Firebase migration ─────────────────────────────────────────────────────
/// Create [FirebaseMealRepository] that implements [MealRepository] and
/// update the binding in main.dart. This class remains untouched.
/// IMPORTANT: the new implementation must also call
/// [MealEvents.notifyMealsChanged] after each mutation, or dependent
/// screens will stop refreshing.
class LocalMealRepository implements MealRepository {
  LocalMealRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> saveEntry(MealEntry entry) async {
    await _db.insert(DatabaseHelper.mealTable, entry.toMap());
    MealEvents.instance.notifyMealsChanged();
  }

  @override
  Future<void> updateEntry(MealEntry entry) async {
    await _db.update(
      DatabaseHelper.mealTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    MealEvents.instance.notifyMealsChanged();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _db.delete(
      DatabaseHelper.mealTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    MealEvents.instance.notifyMealsChanged();
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<MealEntry>> getEntriesForDay(DateTime date) async {
    // Construct precise midnight boundaries for the requested calendar day.
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _queryRange(start: start, end: end);
  }

  @override
  Future<List<MealEntry>> getEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _queryRange(start: start, end: end);
  }

  @override
  Future<List<MealEntry>> getRecentEntries({int limit = 20}) async {
    final rows = await _db.query(
      DatabaseHelper.mealTable,
      orderBy: 'logged_at DESC',
      limit: limit,
    );
    return _toEntries(rows);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Shared query used by [getEntriesForDay] and [getEntriesForDateRange].
  ///
  /// [start] is inclusive, [end] is exclusive — consistent with Dart's
  /// own DateTime range conventions.
  Future<List<MealEntry>> _queryRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _db.query(
      DatabaseHelper.mealTable,
      where: 'logged_at >= ? AND logged_at < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'logged_at DESC',
    );
    return _toEntries(rows);
  }

  /// Converts raw database rows into typed [MealEntry] objects.
  List<MealEntry> _toEntries(List<Map<String, dynamic>> rows) =>
      rows.map(MealEntry.fromMap).toList();
}