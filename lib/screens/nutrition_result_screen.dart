import 'dart:io';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_info.dart';
import '../repositories/meal_repository.dart';

class NutritionResultScreen extends StatefulWidget {
  final File imageFile;
  final String confirmedFoodName;
  final double weightG;
  final NutritionInfo nutritionPer100g;

  /// Abstract repository — never coupled to a concrete implementation.
  /// Callers pass [LocalMealRepository] today; [FirebaseMealRepository]
  /// in a future milestone with zero changes to this screen.
  final MealRepository repository;

  const NutritionResultScreen({
    super.key,
    required this.imageFile,
    required this.confirmedFoodName,
    required this.weightG,
    required this.nutritionPer100g,
    required this.repository,
  });

  @override
  State<NutritionResultScreen> createState() => _NutritionResultScreenState();
}

class _NutritionResultScreenState extends State<NutritionResultScreen> {
  /// True while the async save is in-flight; disables both action buttons.
  bool _isSaving = false;

  /// Meal type chosen by the user before saving; defaults to snack.
  MealType _selectedMealType = MealType.snack;

  // ── Save logic ────────────────────────────────────────────────────────────

  Future<void> _saveMeal() async {
    setState(() => _isSaving = true);

    try {
      // Scale nutrition from per-100 g to the user's actual weight.
      final scaled = widget.nutritionPer100g.scaledTo(widget.weightG);

      final entry = MealEntry.create(
        foodName: widget.confirmedFoodName,
        weightGrams: widget.weightG,
        calories: scaled.calories,
        proteinG: scaled.proteinG,
        carbsG: scaled.carbsG,
        fatG: scaled.fatG,
        fiberG: scaled.fiberG,
        imagePath: widget.imageFile.path,
        mealType: _selectedMealType,
      );

      await widget.repository.saveEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal saved!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Return to the root screen after a successful save.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save meal. Please try again.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scaled = widget.nutritionPer100g.scaledTo(widget.weightG);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Result')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Food Image ─────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // ── Food Name + Weight Badge ───────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.confirmedFoodName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _WeightBadge(weightG: widget.weightG),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'AI-estimated values · Exact USDA data added in next update',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // ── Calories Card ──────────────────────────────────────────
              _CalorieCard(calories: scaled.calories),
              const SizedBox(height: 14),

              // ── Macros Row ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MacroCard(
                      label: 'Protein',
                      value: scaled.proteinG,
                      color: const Color(0xFF1565C0),
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MacroCard(
                      label: 'Carbs',
                      value: scaled.carbsG,
                      color: const Color(0xFFF57F17),
                      icon: Icons.grain_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MacroCard(
                      label: 'Fat',
                      value: scaled.fatG,
                      color: const Color(0xFFC62828),
                      icon: Icons.water_drop_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Fiber Card ─────────────────────────────────────────────
              _FiberRow(fiberG: scaled.fiberG),
              const SizedBox(height: 28),

              // ── Meal Type Selector ─────────────────────────────────────
              _MealTypeSelector(
                selected: _selectedMealType,
                onChanged: (type) =>
                    setState(() => _selectedMealType = type),
              ),
              const SizedBox(height: 24),

              // ── Actions ────────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMeal,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Meal'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                // Disabled while saving to prevent navigation mid-write.
                onPressed: _isSaving
                    ? null
                    : () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Discard & Start Over'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private Sub-Widgets
// ═══════════════════════════════════════════════════════════════════════════

/// Segmented control for choosing the meal type before saving.
class _MealTypeSelector extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  const _MealTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<MealType>(
          segments: MealType.values
              .map(
                (type) => ButtonSegment<MealType>(
                  value: type,
                  label: Text('${type.emoji} ${type.displayName}'),
                ),
              )
              .toList(),
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

class _WeightBadge extends StatelessWidget {
  final double weightG;
  const _WeightBadge({required this.weightG});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${weightG.toStringAsFixed(0)} g',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CalorieCard extends StatelessWidget {
  final double calories;
  const _CalorieCard({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Calories',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(1)} g',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiberRow extends StatelessWidget {
  final double fiberG;
  const _FiberRow({required this.fiberG});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.grass_rounded,
              color: AppTheme.primaryLight, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Dietary Fiber',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            '${fiberG.toStringAsFixed(1)} g',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}