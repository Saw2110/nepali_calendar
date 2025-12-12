import 'package:flutter/material.dart';

import '../src.dart';

/// Widget for displaying a single calendar day cell.
class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final OnDateSelected onDaySelected;
  final CalendarTheme calendarStyle;

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
    final cellTheme = calendarStyle.cellTheme;

    // Check various states
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelected = _isSelectedDate(date);
    final isHoliday = event?.isHoliday ?? false;
    final isWeekend = date.weekday == 7; // Saturday
    final hasEvent = event != null;

    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: Container(
        decoration: _getCellDecoration(
          isToday: isToday,
          isSelected: isSelected,
          isWeekend: isWeekend,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main date text
            Center(
              child: Text(
                calendarStyle.locale == CalendarLocale.english
                    ? "$day"
                    : NepaliNumberConverter.englishToNepali(day.toString()),
                style: _getTextStyle(
                  isToday: isToday,
                  isSelected: isSelected,
                  isWeekend: isWeekend,
                  hasEvent: hasEvent,
                ),
              ),
            ),

            // English date display
            if (cellTheme.showEnglishDate)
              Positioned(
                right: 2,
                bottom: 2,
                child: Text(
                  "${date.toDateTime().day}",
                  style: TextStyle(
                    fontSize: 10,
                    color: cellTheme.englishDateColor,
                  ),
                ),
              ),

            // Event indicator
            if (hasEvent)
              Positioned(
                bottom: 2,
                child: Container(
                  width: cellTheme.eventIndicatorSize,
                  height: cellTheme.eventIndicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getEventColor(
                      isHoliday: isHoliday,
                      isToday: isToday,
                      isWeekend: isWeekend,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Gets the decoration for the cell based on state.
  BoxDecoration _getCellDecoration({
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
  }) {
    final cellTheme = calendarStyle.cellTheme;

    // Determine background color
    Color backgroundColor = Colors.transparent;

    if (isToday) {
      backgroundColor = cellTheme.todayBackgroundColor;
    } else if (isSelected) {
      backgroundColor = cellTheme.selectionColor.withValues(alpha: 0.2);
    } else if (isWeekend && cellTheme.weekendBackgroundColor != null) {
      backgroundColor = cellTheme.weekendBackgroundColor!;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: cellTheme.showBorder ? cellTheme.cellBorder : null,
      borderRadius: _getBorderRadius(),
    );
  }

  /// Gets the border radius based on the cell shape.
  BorderRadius _getBorderRadius() {
    final cellTheme = calendarStyle.cellTheme;

    switch (cellTheme.shape) {
      case CellShape.circle:
        return BorderRadius.circular(100);
      case CellShape.roundedSquare:
        return BorderRadius.circular(cellTheme.borderRadius ?? 8.0);
      case CellShape.square:
        return BorderRadius.zero;
    }
  }

  /// Gets the text style for the cell based on state.
  TextStyle _getTextStyle({
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
    required bool hasEvent,
  }) {
    final cellTheme = calendarStyle.cellTheme;

    // Today
    if (isToday) {
      return cellTheme.todayTextStyle ??
          cellTheme.defaultTextStyle.copyWith(
            color: cellTheme.todayTextColor ?? Colors.white,
          );
    }

    // Selected
    if (isSelected) {
      return cellTheme.selectedTextStyle ??
          cellTheme.defaultTextStyle.copyWith(
            color: cellTheme.selectedTextColor ?? cellTheme.selectionColor,
          );
    }

    // Weekend
    if (isWeekend) {
      return cellTheme.weekendTextStyle ??
          cellTheme.defaultTextStyle.copyWith(
            color: cellTheme.weekendTextColor,
          );
    }

    // Has event
    if (hasEvent && cellTheme.eventDateTextStyle != null) {
      return cellTheme.eventDateTextStyle!;
    }

    // Default
    return cellTheme.defaultTextStyle;
  }

  /// Gets the event indicator color.
  Color _getEventColor({
    required bool isHoliday,
    required bool isToday,
    required bool isWeekend,
  }) {
    final cellTheme = calendarStyle.cellTheme;

    if (isToday) return Colors.white;
    if (isHoliday || isWeekend) return cellTheme.weekendTextColor;
    return cellTheme.eventIndicatorColor;
  }

  /// Checks if the current date is the selected date.
  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
