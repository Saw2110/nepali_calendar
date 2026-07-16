// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';

/// The grid is an implementation detail of [NepaliCalendar]. Use
/// [NepaliCalendar] or [NepaliYearCalendar], and `CalendarBuilder` to
/// customise them.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;

  /// The events to mark on the grid.
  ///
  /// Prefer passing a prebuilt [eventIndex]: this list is re-indexed on every
  /// build, whereas an index can be built once and reused across months.
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList].
  ///
  /// When null, one is built from [eventList] on each build. [NepaliCalendar]
  /// supplies this so the index is built once per event-list change rather
  /// than once per month page.
  final CalendarEventIndex<T>? eventIndex;

  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(CalendarCellData<T>)? cellBuilder;

  /// Width-to-height ratio of each day cell.
  ///
  /// Defaults to 1.0 (square cells), which is what every version up to 0.0.7
  /// used unconditionally. [NepaliCalendar] now passes a ratio greater than 1
  /// on wide viewports so that cells grow sideways rather than making the
  /// calendar as tall as the viewport is wide.
  final double cellAspectRatio;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    this.eventIndex,
    required this.onDaySelected,
    required this.calendarStyle,
    this.cellBuilder,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Get the first day of the month
    final firstDayOfMonth = NepaliDateTime(year: year, month: month);
    // Normalize the weekday of the first day based on week start type
    final weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
    // Get the total number of days in the month
    final daysCountInMonth = _getDaysInMonth(year, month);

    // Build the grid items with 6 rows (42 cells)
    final gridItems =
        _buildCalendarGrid(weekdayOfFirstDay, daysCountInMonth, _index);

    final gridView = GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 columns for 7 days in a week
        childAspectRatio: cellAspectRatio,
      ),
      itemCount: 42, // Always show 6 rows
      itemBuilder: (context, index) {
        // Wrap each cell with table-style borders (right + bottom)
        if (calendarStyle.effectiveConfig.showBorder) {
          return _wrapWithTableBorder(gridItems[index]);
        }
        return gridItems[index];
      },
    );

    // Don't add top/left border here - CalendarMonthView will handle it
    return gridView;
  }

  // Method to build the complete calendar grid with 6 rows
  List<Widget> _buildCalendarGrid(
    int weekdayOfFirstDay,
    int daysCountInMonth,
    CalendarEventIndex<T> index,
  ) {
    final gridItems = <Widget>[];

    // Add previous month days
    if (weekdayOfFirstDay > 0) {
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final daysInPrevMonth = _getDaysInMonth(prevYear, prevMonth);

      for (int i = weekdayOfFirstDay - 1; i >= 0; i--) {
        final day = daysInPrevMonth - i;
        final date = NepaliDateTime(year: prevYear, month: prevMonth, day: day);
        final events = index.eventsOn(date);

        gridItems.add(
          CalendarCell<T>(
            day: day,
            date: date,
            selectedDate: selectedDate,
            events: events,
            onDaySelected: onDaySelected,
            calendarStyle: calendarStyle,
            isDimmed: true,
            cellBuilder: cellBuilder,
          ),
        );
      }
    }

    // Add current month days
    for (int day = 1; day <= daysCountInMonth; day++) {
      final date = NepaliDateTime(year: year, month: month, day: day);
      final events = index.eventsOn(date);

      gridItems.add(
        CalendarCell<T>(
          day: day,
          date: date,
          selectedDate: selectedDate,
          events: events,
          onDaySelected: onDaySelected,
          calendarStyle: calendarStyle,
          cellBuilder: cellBuilder,
        ),
      );
    }

    // Add next month days to fill up to 42 cells (6 rows)
    final remainingCells = 42 - gridItems.length;
    if (remainingCells > 0) {
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;

      for (int day = 1; day <= remainingCells; day++) {
        final date = NepaliDateTime(year: nextYear, month: nextMonth, day: day);
        final events = index.eventsOn(date);

        gridItems.add(
          CalendarCell<T>(
            day: day,
            date: date,
            selectedDate: selectedDate,
            events: events,
            onDaySelected: onDaySelected,
            calendarStyle: calendarStyle,
            isDimmed: true,
            cellBuilder: cellBuilder,
          ),
        );
      }
    }

    return gridItems;
  }

  /// The index to look events up in.
  ///
  /// Uses the prebuilt [eventIndex] when given; otherwise builds one from
  /// [eventList] so callers constructing a [CalendarGrid] directly still work.
  CalendarEventIndex<T> get _index =>
      eventIndex ?? CalendarEventIndex<T>.fromList(eventList);

  // Method to get the number of days in a specific month and year
  int _getDaysInMonth(int year, int month) {
    return CalendarUtils.nepaliYears[year]![month];
  }

  // Method to normalize the weekday to a 0-based index based on week start type
  int _normalizeWeekday(int weekday) {
    // weekday is already in 0-based format: 0=Sunday, 1=Monday, ..., 6=Saturday
    switch (calendarStyle.effectiveConfig.weekStartType) {
      case WeekStartType.sunday:
        // Week starts on Sunday, so Sunday=0, Monday=1, etc.
        return weekday;
      case WeekStartType.monday:
        // Week starts on Monday, so Monday=0, Tuesday=1, ..., Sunday=6
        return weekday == 0 ? 6 : weekday - 1;
    }
  }

  /// Wraps a cell with table-style borders (right and bottom only).
  /// This creates a clean grid pattern when combined with the container's
  /// top and left borders.
  Widget _wrapWithTableBorder(Widget child) {
    final borderColor =
        calendarStyle.cellsStyle.borderColor.withValues(alpha: 0.3);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: child,
    );
  }
}
