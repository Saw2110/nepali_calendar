import 'package:flutter/material.dart';

import '../models/nepali_date_time.dart';
import '../utils/calendar_layout.dart';
import '../utils/calendar_utils.dart';
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
    // The calendar calls this while it is being built. Notifying right away
    // would make a listener above it -- a ListenableBuilder showing the
    // selected date, say -- call setState during build, which throws. Tell
    // listeners once the frame is done instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  bool _disposed = false;

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

    // isInitialized above guarantees the callback.
    if (isProgrammatic) {
      _selectedDateCallback!(
        date,
        runCallback: runCallback,
        animate: animate,
      );
    }

    notifyListeners();
  }

  @override
  void nextMonth({bool animate = true}) => _shift(1, animate: animate);

  @override
  void previousMonth({bool animate = true}) => _shift(-1, animate: animate);

  /// Jumps to the 1st of the month [delta] away. Does nothing when not
  /// attached, or when that month is past either end of the calendar data.
  void _shift(int delta, {required bool animate}) {
    final current = _selectedDate;
    if (!isInitialized || current == null) {
      debugPrint(
        'NepaliCalendarController: Cannot navigate - controller is not initialized',
      );
      return;
    }

    final (year, month) = shiftMonth(current.year, current.month, delta);
    if (!CalendarUtils.nepaliYears.containsKey(year)) {
      debugPrint(
        'NepaliCalendarController: Cannot navigate - already at the '
        '${delta > 0 ? 'last' : 'first'} supported month',
      );
      return;
    }

    jumpToDate(NepaliDateTime(year: year, month: month), animate: animate);
  }

  @override
  void dispose() {
    _disposed = true;
    _selectedDateCallback = null;
    super.dispose();
  }
}
