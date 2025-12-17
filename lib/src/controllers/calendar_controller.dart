import 'package:flutter/material.dart';

import '../models/nepali_date_time.dart';

/// Callback type for handling date selection changes.
typedef SelectedDateCallback = void Function(
  NepaliDateTime date, {
  required bool runCallback,
  required bool animate,
});

/// Abstract base class for calendar controllers.
///
/// This provides a common interface for managing calendar state and navigation
/// across different calendar implementations (vertical, horizontal, etc.).
///
/// Controllers are independent and manage their own state, communicating with
/// widgets through callbacks. This ensures proper separation of concerns.
///
/// Controllers should be disposed when no longer needed to prevent memory leaks.
abstract class CalendarController extends ChangeNotifier {
  /// Whether this controller is currently initialized.
  bool get isInitialized;

  /// The currently selected date in the calendar.
  ///
  /// Returns null if the controller is not initialized.
  NepaliDateTime? get selectedDate;

  /// Jump to a specific date in the calendar.
  ///
  /// Parameters:
  /// - [date]: The date to jump to
  /// - [isProgrammatic]: Whether this is a programmatic change (default: true)
  /// - [animate]: Whether to animate the transition (default: true)
  /// - [runCallback]: Whether to trigger the onDateChanged callback (default: false)
  void jumpToDate(
    NepaliDateTime date, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  });

  /// Jump to today's date in the calendar.
  ///
  /// Convenience method that calls [jumpToDate] with the current date.
  void jumpToToday({bool animate = true}) {
    jumpToDate(NepaliDateTime.now(), animate: animate);
  }

  /// Navigate to the next month.
  void nextMonth({bool animate = true});

  /// Navigate to the previous month.
  void previousMonth({bool animate = true});
}
