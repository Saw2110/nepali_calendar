import 'package:flutter/material.dart';

import '../src.dart';

class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(T? event)? checkIsHoliday;
  final void Function(NepaliDateTime) onDaySelected;
  final NepaliCalenderStyle calendarStyle;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    required this.onDaySelected,
    this.checkIsHoliday,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = NepaliDateTime(year: year, month: month);
    final weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
    final daysCountInMonth = _getDaysInMonth(year, month);

    final gridItems = _buildEmptyPadding(weekdayOfFirstDay);
    gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) => gridItems[index],
    );
  }

  List<Widget> _buildEmptyPadding(int weekdayOfFirstDay) {
    return weekdayOfFirstDay == 7
        ? []
        : List.generate(weekdayOfFirstDay, (_) => const EmptyCell());
  }

  List<Widget> _buildMonthDays(int year, int month, int daysCountInMonth) {
    return List.generate(daysCountInMonth, (index) {
      final day = index + 1;
      final date = NepaliDateTime(year: year, month: month, day: day);
      final event = _getEventForDate(date);

      return CalendarCell<T>(
        day: day,
        date: date,
        selectedDate: selectedDate,
        event: event,
        checkIsHoliday: checkIsHoliday,
        onDaySelected: onDaySelected,
        calendarStyle: calendarStyle,
      );
    });
  }

  CalendarEvent<T>? _getEventForDate(NepaliDateTime date) {
    if (eventList == null) return null;
    try {
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

  int _getDaysInMonth(int year, int month) {
    return CalendarUtils.nepaliYears[year]![month];
  }

  int _normalizeWeekday(int weekday) {
    return weekday - 1;
  }
}
