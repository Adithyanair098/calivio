import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/daily_nutrition_summary.dart';

/// Displays one day's aggregated nutrition totals.
///
/// Purely presentational — receives a [DailyNutritionSummary] and renders
/// it. Contains no database access, no aggregation math, and no knowledge
/// of where the summary came from. This separation means the widget can be
/// reused unchanged for "yesterday" cards, weekly summaries, or test
/// harnesses that pass in a hand-built [DailyNutritionSummary].
///
/// Goal progress bars appear automatically once [DailyNutritionSummary]
/// carries non-null [DailyNutritionSummary.calorieGoal] /
/// [DailyNutritionSummary.proteinGoalG] values from a future Goals
/// feature — no changes to this widget are required at that point.
class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key, required this.summary});

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: summary.hasMeals
            ? _buildContent(context, textTheme, colorScheme)
            : _buildEmptyState(textTheme),
      ),
    );
  }

  // ── Populated state ─────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Summary", style: textTheme.titleMedium),
            Text(
              '${summary.mealCount} meal${summary.mealCount == 1 ? '' : 's'}',
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCalorieRow(textTheme, colorScheme),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildProteinStat(textTheme, colorScheme)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlainStat(
                textTheme,
                label: 'Carbs',
                grams: summary.totalCarbsG,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPlainStat(
                textTheme,
                label: 'Fat',
                grams: summary.totalFatG,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Calorie total, with a progress bar if [DailyNutritionSummary.calorieGoal]
  /// has been set. Falls back to a plain number when no goal exists yet.
  Widget _buildCalorieRow(TextTheme textTheme, ColorScheme colorScheme) {
    final progress = summary.calorieProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              summary.totalCalories.toStringAsFixed(0),
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              summary.calorieGoal != null
                  ? 'of ${summary.calorieGoal!.toStringAsFixed(0)} kcal'
                  : 'kcal',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: AppTheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  /// Protein stat with an inline progress bar when a goal exists.
  Widget _buildProteinStat(TextTheme textTheme, ColorScheme colorScheme) {
    final progress = summary.proteinProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Protein', style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        )),
        const SizedBox(height: 4),
        Text(
          '${summary.totalProteinG.toStringAsFixed(0)}g'
          '${summary.proteinGoalG != null ? ' / ${summary.proteinGoalG!.toStringAsFixed(0)}g' : ''}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ],
    );
  }

  /// A macro stat with no goal support (carbs, fat) — just label + value.
  Widget _buildPlainStat(
    TextTheme textTheme, {
    required String label,
    required double grams,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        )),
        const SizedBox(height: 4),
        Text(
          '${grams.toStringAsFixed(0)}g',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text("Today's Summary", style: textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'No meals logged yet today — snap a photo to get started.',
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}