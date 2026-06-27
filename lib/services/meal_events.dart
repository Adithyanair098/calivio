import 'dart:async';

/// Broadcasts a notification whenever meal data changes (save, update, or
/// delete), regardless of which screen or tab performed the mutation.
///
/// ── Why this exists ──────────────────────────────────────────────────────
/// [HomeScreen] lives in a sibling tab inside a bottom-nav [IndexedStack]
/// and is never rebuilt or re-initialised when the user switches tabs.
/// The Add Meal flow never navigates back to HomeScreen directly, so there
/// is no `Navigator` callback to hang a refresh on. This event bus is the
/// bridge across that tab boundary.
///
/// ── Why a standalone singleton, not a `MealRepository` stream ───────────
/// Adding `Stream<void> get changes` directly to [MealRepository] was
/// considered and rejected for now: it would only work reliably if every
/// screen is guaranteed to hold the exact same repository *instance*, and
/// it would force every future [MealRepository] implementation (Firebase
/// included) to carry stream-management code for what is really an
/// app-wide UI concern, not a storage concern. A single shared emitter
/// avoids the instance-sharing assumption and matches the singleton
/// pattern this codebase already uses for [DatabaseHelper].
///
/// ── Usage ─────────────────────────────────────────────────────────────────
/// [LocalMealRepository] calls [notifyMealsChanged] after every successful
/// save, update, or delete. Screens that depend on aggregated meal data —
/// the dashboard today, analytics screens later — listen via [changes].
///
/// IMPORTANT: if a future `FirebaseMealRepository` is added, it must also
/// call [notifyMealsChanged] after its mutating operations, or dependent
/// screens will silently stop refreshing.
class MealEvents {
  MealEvents._();

  static final MealEvents instance = MealEvents._();

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  /// Emits once per meal mutation (save, update, or delete).
  Stream<void> get changes => _controller.stream;

  /// Call after any successful saveEntry / updateEntry / deleteEntry.
  void notifyMealsChanged() => _controller.add(null);
}