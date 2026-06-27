import 'package:flutter/foundation.dart';

/// Aggregated nutrition totals for a single calendar day.
///
/// Produced by [NutritionAggregator] from a list of [MealEntry] objects.
/// This class performs no calculation itself — it is a pure data holder,
/// keeping aggregation logic isolated and unit-testable in one place.
///
/// [calorieGoal] and [proteinGoalG] are optional and unused until a future
/// Goals milestone exists. Keeping them here now means the summary card
/// can be built once and simply gain progress bars later, with no changes
/// to its data contract.
@immutable
class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.totalFiberG,
    required this.mealCount,
    this.calorieGoal,
    this.proteinGoalG,
  });

  /// The calendar day this summary represents (time component should be
  /// normalised to midnight by whoever constructs this — see aggregator).
  final DateTime date;

  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final double totalFiberG;

  /// Number of meals that contributed to this summary.
  final int mealCount;

  /// Daily calorie target, if a Goals feature has set one. Null otherwise.
  final double? calorieGoal;

  /// Daily protein target in grams, if set. Null otherwise.
  final double? proteinGoalG;

  /// Returns an empty, zeroed-out summary for [date].
  ///
  /// Use this instead of a nullable `DailyNutritionSummary?` when no meals
  /// have been logged yet — callers can render it directly without
  /// null-checking the whole object first.
  factory DailyNutritionSummary.empty(DateTime date) => DailyNutritionSummary(
        date: date,
        totalCalories: 0,
        totalProteinG: 0,
        totalCarbsG: 0,
        totalFatG: 0,
        totalFiberG: 0,
        mealCount: 0,
      );

  /// True if at least one meal has been logged for [date].
  bool get hasMeals => mealCount > 0;

  /// Progress toward [calorieGoal] as a fraction (1.0 = goal met).
  /// Returns null if no goal has been set, so the UI can distinguish
  /// "no goal" from "0% progress".
  double? get calorieProgress {
    final goal = calorieGoal;
    if (goal == null || goal <= 0) return null;
    return totalCalories / goal;
  }

  /// Progress toward [proteinGoalG] as a fraction. Null if no goal is set.
  double? get proteinProgress {
    final goal = proteinGoalG;
    if (goal == null || goal <= 0) return null;
    return totalProteinG / goal;
  }

  /// Returns a copy with goal values attached, leaving all totals
  /// untouched. Intended for use once a Goals feature exists — the
  /// aggregator produces totals, a separate goals service attaches targets.
  DailyNutritionSummary copyWith({
    double? calorieGoal,
    double? proteinGoalG,
  }) =>
      DailyNutritionSummary(
        date: date,
        totalCalories: totalCalories,
        totalProteinG: totalProteinG,
        totalCarbsG: totalCarbsG,
        totalFatG: totalFatG,
        totalFiberG: totalFiberG,
        mealCount: mealCount,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        proteinGoalG: proteinGoalG ?? this.proteinGoalG,
      );

  @override
  String toString() =>
      'DailyNutritionSummary(date: ${date.toIso8601String().split('T').first}, '
      'meals: $mealCount, calories: ${totalCalories.toStringAsFixed(0)})';
}