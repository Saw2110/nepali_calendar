import 'package:flutter/foundation.dart';

import '../src.dart';

/// A flexible controller for managing calendar state across different calendar types.
///
/// This controller can be used with various calendar widgets.
///
/// Example usage:
/// ```dart
/// final controller = NepaliCalendarController();
///
/// // Listen to date changes
/// controller.addListener(() {
///   print('Selected date: ${controller.selectedDate}');
/// });
///
/// // Use with calendar widget
/// NepaliCalendar(
///   controller: controller,
/// )
///
/// // Programmatically control the calendar
/// controller.jumpToDate(NepaliDateTime(year: 2081, month: 5, day: 15));
/// controller.jumpToToday();
/// ```
class NepaliCalendarController extends ChangeNotifier {
  /// The currently selected date.
  NepaliDateTime _selectedDate;

  /// The currently displayed/focused date (may differ from selected in some views).
  NepaliDateTime _focusedDate;

  /// Callback for when the view needs to animate to a specific page.
  void Function(int pageIndex, {bool animate})? _onPageChangeRequested;

  /// Creates a [NepaliCalendarController] with optional initial values.
  ///
  /// [initialDate] - The initial selected date. Defaults to today.
  NepaliCalendarController({
    NepaliDateTime? initialDate,
  })  : _selectedDate = initialDate ?? NepaliDateTime.now(),
        _focusedDate = initialDate ?? NepaliDateTime.now();

  // ============== Getters ==============

  /// The currently selected date.
  NepaliDateTime get selectedDate => _selectedDate;

  /// The currently focused/displayed date.
  NepaliDateTime get focusedDate => _focusedDate;

  // ============== Actions ==============

  /// Selects a specific date.
  void selectDate(NepaliDateTime date) {
    if (!_isSameDate(_selectedDate, date)) {
      _selectedDate = date;
      _focusedDate = date;
      notifyListeners();
    }
  }

  /// Jumps to a specific date.
  ///
  /// This will update the focused date and request the view to navigate
  /// to show this date.
  void jumpToDate(NepaliDateTime date, {bool animate = true}) {
    _focusedDate = date;
    _selectedDate = date;

    // Calculate page index for month-based views
    final pageIndex =
        ((date.year - CalendarUtils.calenderyearStart) * 12) + date.month - 1;

    _onPageChangeRequested?.call(pageIndex, animate: animate);
    notifyListeners();
  }

  /// Jumps to today's date.
  void jumpToToday({bool animate = true}) {
    jumpToDate(NepaliDateTime.now(), animate: animate);
  }

  /// Jumps to a specific month.
  void jumpToMonth(int year, int month, {bool animate = true}) {
    _focusedDate = NepaliDateTime(year: year, month: month, day: 1);

    final pageIndex =
        ((year - CalendarUtils.calenderyearStart) * 12) + month - 1;

    _onPageChangeRequested?.call(pageIndex, animate: animate);
    notifyListeners();
  }

  /// Navigates to the previous month.
  void previousMonth({bool animate = true}) {
    int year = _focusedDate.year;
    int month = _focusedDate.month - 1;

    if (month < 1) {
      month = 12;
      year--;
    }

    jumpToMonth(year, month, animate: animate);
  }

  /// Navigates to the next month.
  void nextMonth({bool animate = true}) {
    int year = _focusedDate.year;
    int month = _focusedDate.month + 1;

    if (month > 12) {
      month = 1;
      year++;
    }

    jumpToMonth(year, month, animate: animate);
  }

  /// Checks if a date is selected.
  bool isDateSelected(NepaliDateTime date) {
    return _isSameDate(_selectedDate, date);
  }

  // ============== Internal Methods ==============

  /// Called by widgets to register for page change requests.
  void attachPageController(
    void Function(int pageIndex, {bool animate}) onPageChange,
  ) {
    _onPageChangeRequested = onPageChange;
  }

  /// Called by widgets to unregister.
  void detachPageController() {
    _onPageChangeRequested = null;
  }

  /// Updates the focused date without triggering navigation.
  /// Used by widgets when the user manually navigates.
  void updateFocusedDate(NepaliDateTime date) {
    if (!_isSameDate(_focusedDate, date)) {
      _focusedDate = date;
      notifyListeners();
    }
  }

  /// Updates the selected date from widget interaction.
  void updateSelectedDate(NepaliDateTime date) {
    selectDate(date);
  }

  // ============== Utility Methods ==============

  bool _isSameDate(NepaliDateTime date1, NepaliDateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void dispose() {
    _onPageChangeRequested = null;
    super.dispose();
  }
}
