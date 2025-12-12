import 'package:flutter/material.dart';

import '../src.dart';

class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final OnDateSelected onDaySelected;
  final CalendarTheme calendarStyle;

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
    // Normalize the weekday of the first day (0-based index)
    final weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
    // Get the total number of days in the month
    final daysCountInMonth = _getDaysInMonth(year, month);

    // Build the grid items starting with empty padding for the first week
    final gridItems = _buildEmptyPadding(weekdayOfFirstDay);
    // Add the days of the month to the grid items
    gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

    // Get spacing from theme
    final spacing = calendarStyle.spacing;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 columns for 7 days in a week
        mainAxisSpacing: spacing.cellVerticalSpacing,
        crossAxisSpacing: spacing.cellHorizontalSpacing,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) => gridItems[index],
    );
  }

  // Method to build empty padding cells for the first week
  List<Widget> _buildEmptyPadding(int weekdayOfFirstDay) {
    return weekdayOfFirstDay == 7
        ? [] // No padding needed if the first day is Sunday
        : List.generate(weekdayOfFirstDay, (_) => const EmptyCell());
  }

  // Method to build the list of days in the month
  List<Widget> _buildMonthDays(int year, int month, int daysCountInMonth) {
    return List.generate(daysCountInMonth, (index) {
      final day = index + 1; // Day starts from 1
      final date = NepaliDateTime(year: year, month: month, day: day);
      // Get the event for the current date, if any
      final event = _getEventForDate(date);

      return CalendarCell<T>(
        day: day,
        date: date,
        selectedDate: selectedDate,
        event: event,
        onDaySelected: onDaySelected,
        calendarStyle: calendarStyle,
      );
    });
  }

  // Method to get the event for a specific date
  CalendarEvent<T>? _getEventForDate(NepaliDateTime date) {
    if (eventList == null) return null;
    try {
      return eventList!.firstWhere(
        (e) =>
            e.eventDate.year == date.year &&
            e.eventDate.month == date.month &&
            e.eventDate.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Method to get the number of days in a specific month and year
  int _getDaysInMonth(int year, int month) {
    return CalendarUtils.nepaliYears[year]![month];
  }

  // Method to normalize the weekday to a 0-based index
  int _normalizeWeekday(int weekday) {
    return weekday - 1;
  }
}
