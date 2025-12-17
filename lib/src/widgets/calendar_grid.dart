import 'package:flutter/material.dart';

import '../src.dart';

class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(CalendarCellData<T>)? cellBuilder;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    required this.onDaySelected,
    required this.calendarStyle,
    this.cellBuilder,
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
    final gridItems = _buildCalendarGrid(weekdayOfFirstDay, daysCountInMonth);

    final gridView = GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 columns for 7 days in a week
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
  List<Widget> _buildCalendarGrid(int weekdayOfFirstDay, int daysCountInMonth) {
    final gridItems = <Widget>[];

    // Add previous month days
    if (weekdayOfFirstDay > 0) {
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final daysInPrevMonth = _getDaysInMonth(prevYear, prevMonth);

      for (int i = weekdayOfFirstDay - 1; i >= 0; i--) {
        final day = daysInPrevMonth - i;
        final date = NepaliDateTime(year: prevYear, month: prevMonth, day: day);
        final event = _getEventForDate(date);

        gridItems.add(
          CalendarCell<T>(
            day: day,
            date: date,
            selectedDate: selectedDate,
            event: event,
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
      final event = _getEventForDate(date);

      gridItems.add(
        CalendarCell<T>(
          day: day,
          date: date,
          selectedDate: selectedDate,
          event: event,
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
        final event = _getEventForDate(date);

        gridItems.add(
          CalendarCell<T>(
            day: day,
            date: date,
            selectedDate: selectedDate,
            event: event,
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

  // Method to get the event for a specific date
  CalendarEvent<T>? _getEventForDate(NepaliDateTime date) {
    if (eventList == null) return null; // Return null if no events are provided
    try {
      // Find the event that matches the given date
      return eventList!.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: child,
    );
  }
}
