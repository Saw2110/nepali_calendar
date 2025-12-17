import 'package:flutter/material.dart';

import '../src.dart';

class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final bool isDimmed;
  final Widget Function(CalendarCellData<T>)? cellBuilder;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    required this.event,
    required this.onDaySelected,
    required this.calendarStyle,
    this.isDimmed = false,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the current date is today
    final isToday = CalendarUtils.isToday(date.toDateTime());
    // Check if the current date is the selected date
    final isSelected = _isSelectedDate(date);
    // Check if the current date is a holiday
    final isHoliday = event?.isHoliday ?? false;
    // Check if the current date is a weekend
    final isWeekend = _isWeekend(date.weekday);

    // If custom cellBuilder is provided, use it
    if (cellBuilder != null) {
      final cellData = CalendarCellData<T>(
        date: date,
        day: day,
        isToday: isToday,
        isSelected: isSelected,
        isDimmed: isDimmed,
        isWeekend: isWeekend,
        event: event,
        onTap: () => onDaySelected(date),
        style: calendarStyle,
      );
      return cellBuilder!(cellData);
    }

    // Default cell implementation
    // Note: Borders are handled by the grid container, not individual cells
    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Set the background color of the cell based on today and selected state
          color: _getCellColor(isToday, isSelected),
          // Rounded corners only when borders are disabled
          borderRadius: calendarStyle.effectiveConfig.showBorder
              ? null
              : BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                // Display the day in English or Nepali based on the calendar style
                calendarStyle.effectiveConfig.language == Language.english
                    ? "$day"
                    : NepaliNumberConverter.englishToNepali(day.toString()),
                style: calendarStyle.cellsStyle.dayStyle.copyWith(
                  // Set the text color based on today, selected, and weekday
                  color: _getCellTextColor(isToday, isSelected, date.weekday),
                ),
              ),
            ),
            // Show the English date if the calendar style specifies to show it
            if (calendarStyle.effectiveConfig.showEnglishDate)
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
    // Dimmed cells should never have background highlighting
    if (isDimmed) return Colors.transparent;
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
    if (isDimmed) {
      // Dimmed cells: show dimmed weekend color for weekends, grey for regular days
      if (_isWeekend(weekday)) {
        return calendarStyle.cellsStyle.weekDayColor.withValues(alpha: 0.4);
      }
      return Colors.grey.withValues(alpha: 0.4);
    }
    if (isToday && isSelected) return Colors.white;
    // if (isSelected) return Colors.white; // Commented out for now
    if (isToday) return Colors.white;
    if (_isWeekend(weekday)) return calendarStyle.cellsStyle.weekDayColor;
    return Colors.black;
  }

  // Method to get the event indicator color based on holiday, today, and weekday
  // Priority: Dimmed > Today > Event Type (Holiday/Regular) > Weekend
  Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
    // Dimmed cells should have dimmed event indicators
    if (isDimmed) return Colors.grey.withValues(alpha: 0.4);
    // Today's events always show white for visibility on colored background
    if (isToday) return Colors.white;
    // Event type takes priority: holidays show weekend color, regular events show dot color
    if (isHoliday) return calendarStyle.cellsStyle.weekDayColor;
    // Regular events show their designated color regardless of weekend
    // This allows users to distinguish event types even on weekends
    return calendarStyle.cellsStyle.dotColor;
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int weekday) {
    return WeekUtils.isWeekend(
      weekday,
      calendarStyle.effectiveConfig.weekendType,
    );
  }

  // Method to check if the current date is the selected date
  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
