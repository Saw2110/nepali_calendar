import 'package:flutter/services.dart';

/// How firmly the calendar answers a tap on a date.
///
/// Haptics are hardware, and the same value feels different on every phone.
/// This enum names the intent and leaves the rendering to the platform, which
/// is the only thing that knows what its motor can do.
///
/// ```dart
/// NepaliCalendar(
///   calendarStyle: const NepaliCalendarStyle(
///     config: CalendarConfig(hapticFeedback: CalendarHaptics.medium),
///   ),
/// )
/// ```
///
/// ## What each one maps to
///
/// | Value       | Android                  | iOS                              |
/// | ----------- | ------------------------ | -------------------------------- |
/// | [none]      | nothing                  | nothing                          |
/// | [selection] | `CLOCK_TICK`             | `UISelectionFeedbackGenerator`   |
/// | [light]     | `VIRTUAL_KEY`            | impact, light                    |
/// | [medium]    | `KEYBOARD_TAP`           | impact, medium                   |
/// | [heavy]     | `CONTEXT_CLICK`          | impact, heavy                    |
///
/// Desktop and web have no haptic hardware, so every value is a no-op there --
/// including on the iOS Simulator, which has no Taptic Engine. A physical
/// device is the only place any of this can be felt.
///
/// Android additionally gates all of them behind the system's touch-feedback
/// setting. If a user has turned that off, nothing here will reach them, and
/// that is the correct behaviour rather than something to work around.
enum CalendarHaptics {
  /// No feedback.
  none,

  /// The lightest tick the platform offers.
  ///
  /// Intended for a value scrubbing past discrete steps -- a picker wheel
  /// turning -- rather than for a tap. On Android this is `CLOCK_TICK`, which
  /// many devices render so faintly it cannot be felt at all, and some do not
  /// render it. Prefer [light] for a date cell unless you specifically want
  /// this.
  selection,

  /// A crisp tap, the same one the system keyboard uses for a keypress.
  ///
  /// The default, and the right answer for selecting a date: it is a discrete,
  /// deliberate action, and this is the feedback a user already associates
  /// with one. Reliably felt on Android, where it maps to `VIRTUAL_KEY`.
  light,

  /// A firmer tap, for a calendar where selecting a date is a weightier action.
  medium,

  /// The firmest tap. Noticeable enough to be tiring if every date fires it.
  ///
  /// On Android this needs API 23 or above; below that it does nothing.
  heavy;

  /// Whether this value produces any feedback at all.
  bool get isEnabled => this != CalendarHaptics.none;

  /// Fires this feedback.
  ///
  /// Safe to call anywhere: [none] returns without touching the platform, and
  /// a platform with no haptic hardware ignores the rest. Exposed so a custom
  /// `cellBuilder` can match the built-in cells.
  ///
  /// The returned future completes when the platform has acknowledged the
  /// call. Tapping a date does not await it -- the tick is an aside to the
  /// selection, not a step in it.
  Future<void> perform() {
    switch (this) {
      case CalendarHaptics.none:
        return Future<void>.value();
      case CalendarHaptics.selection:
        return HapticFeedback.selectionClick();
      case CalendarHaptics.light:
        return HapticFeedback.lightImpact();
      case CalendarHaptics.medium:
        return HapticFeedback.mediumImpact();
      case CalendarHaptics.heavy:
        return HapticFeedback.heavyImpact();
    }
  }
}
