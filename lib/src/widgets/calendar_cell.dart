import 'package:flutter/material.dart';

import '../src.dart';

class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    required this.event,
    required this.onDaySelected,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the current date is today
    final isToday = CalendarUtils.isToday(date.toDateTime());
    // Check if the current date is the selected date
    final isSelected = _isSelectedDate(date);
    // Check if the current date is a holiday
    final isHoliday = event?.isHoliday ?? false;

    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Set the background color of the cell based on today and selected state
          color: _getCellColor(isToday, isSelected),
          // Add a border if the calendar style specifies to show borders
          border: calendarStyle.showBorder
              ? Border.all(
                  color: _getCellColor(isToday, isSelected)
                      .withValues(alpha: 0.05),
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                // Display the day in English or Nepali based on the calendar style
                calendarStyle.language == Language.english
                    ? "$day"
                    : NepaliNumberConverter.englishToNepali(day.toString()),
                style: calendarStyle.cellsStyle.dayStyle.copyWith(
                  // Set the text color based on today, selected, and weekday
                  color: _getCellTextColor(isToday, isSelected, date.weekday),
                ),
              ),
            ),
            // Show the English date if the calendar style specifies to show it
            if (calendarStyle.showEnglishDate)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "${date.toDateTime().day}",
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCellTextColor(
                        isToday,
                        isSelected,
                        date.weekday,
                      ),
                    ),
                  ),
                ),
              ),
            // Show an event indicator if there is an event
            if (event != null)
              Positioned(
                bottom: 5.0,
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color: _getEventColor(isHoliday, isToday, date.weekday),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method to get the cell background color based on today and selected state
  Color _getCellColor(bool isToday, bool isSelected) {
    if (isToday && isSelected) return calendarStyle.cellsStyle.todayColor;
    if (isSelected) {
      return calendarStyle.cellsStyle.selectedColor.withValues(
        alpha: 0.2,
      );
    }
    if (isToday) return calendarStyle.cellsStyle.todayColor;
    return Colors.transparent;
  }

  // Method to get the cell text color based on today, selected, and weekday
  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    if (isToday && isSelected) return Colors.white;
    // if (isSelected) return Colors.white; // Commented out for now
    if (isToday) return Colors.white;
    if (weekday == 7) return calendarStyle.cellsStyle.weekDayColor;
    return Colors.black;
  }

  // Method to get the event indicator color based on holiday, today, and weekday
  Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
    if (weekday == 7) return calendarStyle.cellsStyle.weekDayColor;
    if (isToday) return Colors.white;
    if (isHoliday) return calendarStyle.cellsStyle.weekDayColor;
    return calendarStyle.cellsStyle.dotColor;
  }

  // Method to check if the current date is the selected date
  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
