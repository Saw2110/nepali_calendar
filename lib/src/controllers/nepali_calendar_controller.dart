import 'package:flutter/material.dart';

import '../models/nepali_date_time.dart';
import 'calendar_controller.dart';

/// Controller for managing the state and navigation of [NepaliCalendar].
///
/// This controller is independent of the widget and manages its own state.
/// It communicates with the widget through callbacks, ensuring proper
/// separation of concerns.
///
/// Example:
/// ```dart
/// final controller = NepaliCalendarController();
///
/// NepaliCalendar(
///   controller: controller,
/// )
///
/// // Later, jump to a specific date
/// controller.jumpToDate(NepaliDateTime(year: 2081, month: 9, day: 15));
///
/// // Or jump to today
/// controller.jumpToToday();
///
/// // Don't forget to dispose
/// controller.dispose();
/// ```
class NepaliCalendarController extends CalendarController {
  NepaliDateTime? _selectedDate;
  SelectedDateCallback? _selectedDateCallback;

  @override
  bool get isInitialized => _selectedDateCallback != null;

  @override
  NepaliDateTime? get selectedDate => _selectedDate;

  /// Internal setter for updating selected date from widget.
  /// Should only be called by the calendar widget.
  set selectedDate(NepaliDateTime? value) {
    _selectedDate = value;
    notifyListeners();
  }

  /// Initialize the controller with the widget's callback and initial date.
  ///
  /// This is called internally by the calendar widget and should not
  /// be called directly by users.
  void init({
    required SelectedDateCallback selectedDateCallback,
    required NepaliDateTime initialDate,
  }) {
    _selectedDateCallback = selectedDateCallback;
    _selectedDate = initialDate;
    notifyListeners();
  }

  @override
  void jumpToDate(
    NepaliDateTime date, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  }) {
    if (!isInitialized) {
      debugPrint(
        'NepaliCalendarController: Cannot jump to date - controller is not initialized',
      );
      return;
    }

    _selectedDate = date;

    if (isProgrammatic && _selectedDateCallback != null) {
      _selectedDateCallback!(
        date,
        runCallback: runCallback,
        animate: animate,
      );
    }

    notifyListeners();
  }

  @override
  void nextMonth({bool animate = true}) {
    if (!isInitialized || _selectedDate == null) {
      debugPrint(
        'NepaliCalendarController: Cannot navigate - controller is not initialized',
      );
      return;
    }

    final currentDate = _selectedDate!;
    final nextMonth = currentDate.month == 12
        ? NepaliDateTime(year: currentDate.year + 1)
        : NepaliDateTime(
            year: currentDate.year,
            month: currentDate.month + 1,
          );

    jumpToDate(nextMonth, animate: animate);
  }

  @override
  void previousMonth({bool animate = true}) {
    if (!isInitialized || _selectedDate == null) {
      debugPrint(
        'NepaliCalendarController: Cannot navigate - controller is not initialized',
      );
      return;
    }

    final currentDate = _selectedDate!;
    final prevMonth = currentDate.month == 1
        ? NepaliDateTime(year: currentDate.year - 1, month: 12)
        : NepaliDateTime(
            year: currentDate.year,
            month: currentDate.month - 1,
          );

    jumpToDate(prevMonth, animate: animate);
  }

  @override
  void dispose() {
    _selectedDateCallback = null;
    super.dispose();
  }
}
