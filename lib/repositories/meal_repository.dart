import '../models/meal_entry.dart';

/// Contract for all meal persistence backends.
///
/// Screens import and depend on this interface only — never on a concrete
/// implementation. This isolates all storage technology decisions behind
/// this boundary, allowing SQLite → Firebase migration with zero screen
/// changes.
abstract class MealRepository {
  /// Persists [entry]. Replaces any existing record with the same ID.
  Future<void> saveEntry(MealEntry entry);

  /// Returns all entries logged on [date], ordered newest-first.
  Future<List<MealEntry>> getEntriesForDay(DateTime date);

  /// Returns all entries in the range [[start], [end]), ordered newest-first.
  ///
  /// [start] is inclusive, [end] is exclusive.
  /// Intended for weekly and monthly analytics summaries.
  Future<List<MealEntry>> getEntriesForDateRange(
    DateTime start,
    DateTime end,
  );

  /// Returns the [limit] most-recently logged entries across all dates.
  ///
  /// Intended for a Home screen "recent meals" panel in a future milestone.
  Future<List<MealEntry>> getRecentEntries({int limit = 20});

  /// Permanently removes the entry with [id].
  ///
  /// No-op if [id] does not exist.
  Future<void> deleteEntry(String id);

  /// Overwrites the stored entry with the same ID as [entry].
  ///
  /// No-op if the ID does not exist.
  Future<void> updateEntry(MealEntry entry);
}