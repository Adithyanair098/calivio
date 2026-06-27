import '../models/daily_nutrition_summary.dart';
import '../models/meal_entry.dart';
import '../repositories/meal_repository.dart';

/// Converts logged [MealEntry] records into a [DailyNutritionSummary].
///
/// This class contains the only place in the app where "today's totals"
/// are calculated. Keeping it separate from both [MealRepository] (data
/// access) and any screen (presentation) means:
///
/// - The repository stays a thin data-access layer with no business rules.
/// - The math can be unit-tested with plain [MealEntry] lists — no
///   database, no async setup, no mocking required.
/// - Future features (weekly summaries, goal tracking, analytics charts)
///   can reuse [summarize] without duplicating the sum logic.
class NutritionAggregator {
  const NutritionAggregator({required MealRepository repository})
      : _repository = repository;

  final MealRepository _repository;

  /// Fetches all entries logged on [date] and returns their aggregated
  /// totals as a [DailyNutritionSummary].
  ///
  /// This is the method screens call directly. It performs I/O via the
  /// injected [MealRepository] — for a pure, testable version of just the
  /// math, see [summarize].
  Future<DailyNutritionSummary> getSummaryForDay(DateTime date) async {
    final entries = await _repository.getEntriesForDay(date);
    return summarize(entries, date);
  }

  /// Aggregates [entries] into a single [DailyNutritionSummary] for [date].
  ///
  /// Pure function — no database access, no side effects. [date] is
  /// normalised to midnight so the resulting summary always represents
  /// a whole calendar day regardless of the time component passed in.
  ///
  /// Returns [DailyNutritionSummary.empty] if [entries] is empty, so
  /// callers never need a null check for "no meals today".
  DailyNutritionSummary summarize(List<MealEntry> entries, DateTime date) {
    final normalisedDate = DateTime(date.year, date.month, date.day);

    if (entries.isEmpty) {
      return DailyNutritionSummary.empty(normalisedDate);
    }

    var totalCalories = 0.0;
    var totalProteinG = 0.0;
    var totalCarbsG = 0.0;
    var totalFatG = 0.0;
    var totalFiberG = 0.0;

    for (final entry in entries) {
      totalCalories += entry.calories;
      totalProteinG += entry.proteinG;
      totalCarbsG += entry.carbsG;
      totalFatG += entry.fatG;
      totalFiberG += entry.fiberG;
    }

    return DailyNutritionSummary(
      date: normalisedDate,
      totalCalories: totalCalories,
      totalProteinG: totalProteinG,
      totalCarbsG: totalCarbsG,
      totalFatG: totalFatG,
      totalFiberG: totalFiberG,
      mealCount: entries.length,
    );
  }
}