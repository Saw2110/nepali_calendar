import 'package:flutter/material.dart';

import '../src.dart';

class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    required this.onDaySelected,
    required this.calendarStyle,
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

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 columns for 7 days in a week
      ),
      itemCount: 42, // Always show 6 rows
      itemBuilder: (context, index) => gridItems[index],
    );
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
    // weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday (from NepaliDateTime)
    // Convert to 0-based: 0=Sunday, 1=Monday, ..., 6=Saturday
    final dayIndex = weekday == 7 ? 0 : weekday;

    switch (calendarStyle.weekStartType) {
      case WeekStartType.sunday:
        // Week starts on Sunday, so Sunday=0, Monday=1, etc.
        return dayIndex;
      case WeekStartType.monday:
        // Week starts on Monday, so Monday=0, Tuesday=1, ..., Sunday=6
        return dayIndex == 0 ? 6 : dayIndex - 1;
    }
  }
}
