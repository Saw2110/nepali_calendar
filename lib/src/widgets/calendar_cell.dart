import 'package:flutter/material.dart';

import '../src.dart';

class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final bool Function(T? event)? checkIsHoliday;
  final void Function(NepaliDateTime) onDaySelected;
  final NepaliCalenderStyle calendarStyle;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    required this.event,
    required this.onDaySelected,
    required this.calendarStyle,
    this.checkIsHoliday,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelected = _isSelectedDate(date);
    final isHoliday =
        event?.events != null ? checkIsHoliday?.call(event?.events) : false;

    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _getCellColor(isToday, isSelected),
          border: Border.all(
            color: _getCellColor(isToday, isSelected).withValues(alpha: 0.05),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                "$day",
                style: calendarStyle.dayTextStyle?.copyWith(
                      color:
                          _getCellTextColor(isToday, isSelected, date.weekday),
                    ) ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          _getCellTextColor(isToday, isSelected, date.weekday),
                    ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "${date.toDateTime().day}",
                  style: TextStyle(
                    fontSize: 10,
                    color: _getCellTextColor(isToday, isSelected, date.weekday),
                  ),
                ),
              ),
            ),
            if (event != null)
              Positioned(
                bottom: 5.0,
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color:
                      _getEventColor(isHoliday ?? false, isToday, date.weekday),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor(bool isToday, bool isSelected) {
    if (isToday && isSelected) return calendarStyle.todayColor!;
    if (isSelected) return calendarStyle.selectedDateColor!;
    if (isToday) return calendarStyle.todayColor!;
    return Colors.transparent;
  }

  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    if (isToday && isSelected) return calendarStyle.todayTextColor!;
    if (isSelected) return calendarStyle.selectedTextColor!;
    if (isToday) return calendarStyle.todayTextColor!;
    if (weekday == 7) return calendarStyle.weekendColor!;
    return calendarStyle.defaultTextColor!;
  }

  Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
    if (weekday == 7) return calendarStyle.weekendColor!;
    if (isToday) return calendarStyle.todayTextColor!;
    if (isHoliday) return calendarStyle.holidayColor!;
    return calendarStyle.eventColor!;
  }

  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
