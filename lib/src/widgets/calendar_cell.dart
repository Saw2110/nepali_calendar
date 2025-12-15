import 'package:flutter/material.dart';

import '../src.dart';

/// Widget for displaying a single calendar day cell.
class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final OnDateSelected? onDaySelected;
  final CalendarTheme calendarStyle;

  /// Whether this cell represents a day from an adjacent month (previous/next).
  /// Adjacent month days are displayed with dim colors and are not tappable.
  final bool isAdjacentMonth;

  /// Whether to skip applying cell border (used when grid handles borders).
  final bool skipBorder;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    required this.event,
    required this.onDaySelected,
    required this.calendarStyle,
    this.isAdjacentMonth = false,
    this.skipBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final cellTheme = calendarStyle.cellTheme;
    final colorScheme = calendarStyle.colorScheme;

    // Adjacent month days have special styling
    if (isAdjacentMonth) {
      return _buildAdjacentMonthCell(cellTheme, colorScheme);
    }

    // Check various states for current month days
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelected = _isSelectedDate(date);
    final isHoliday = event?.isHoliday ?? false;
    final isWeekend = date.weekday == 7; // Saturday
    final hasEvent = event != null;

    return GestureDetector(
      onTap: onDaySelected != null ? () => onDaySelected!(date) : null,
      child: Container(
        margin: cellTheme.cellMargin,
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
                right: 5,
                bottom: 4,
                child: Text(
                  "${date.toDateTime().day}",
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.7)
                        : cellTheme.englishDateColor,
                  ),
                ),
              ),

            // Event indicator
            if (hasEvent)
              Positioned(
                bottom: 4,
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

  /// Builds a cell for adjacent month days (previous/next month).
  /// These are displayed with dim colors and are not tappable.
  Widget _buildAdjacentMonthCell(
    CellTheme cellTheme,
    CalendarColorScheme colorScheme,
  ) {
    // Resolve adjacent month color: explicit > colorScheme.disabled > default
    final adjacentColor = cellTheme.adjacentMonthTextColor;
    // Skip border if grid is handling it (table-style borders)
    final showCellBorder = cellTheme.showBorder && !skipBorder;

    return Container(
      margin: cellTheme.cellMargin,
      decoration: BoxDecoration(
        border: showCellBorder ? cellTheme.cellBorder : null,
        borderRadius: _getBorderRadius(),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main date text (dim color)
          Center(
            child: Text(
              calendarStyle.locale == CalendarLocale.english
                  ? "$day"
                  : NepaliNumberConverter.englishToNepali(day.toString()),
              style: cellTheme.defaultTextStyle.copyWith(color: adjacentColor),
            ),
          ),

          // English date display (dim color)
          if (cellTheme.showEnglishDate)
            Positioned(
              right: 5,
              bottom: 4,
              child: Text(
                "${date.toDateTime().day}",
                style: TextStyle(
                  fontSize: 10,
                  color: adjacentColor.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gets the decoration for the cell based on state.
  ///
  /// Color resolution priority:
  /// 1. Explicit CellTheme property (if set)
  /// 2. ColorScheme semantic color
  /// 3. Default fallback
  BoxDecoration _getCellDecoration({
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
  }) {
    final cellTheme = calendarStyle.cellTheme;

    // Determine background color (ColorScheme is used via resolved colors)
    Color backgroundColor = Colors.transparent;

    if (isToday) {
      backgroundColor = calendarStyle.resolvedTodayBackgroundColor;
    } else if (isSelected) {
      backgroundColor =
          calendarStyle.resolvedSelectionColor.withValues(alpha: 0.2);
    } else if (isWeekend && cellTheme.weekendBackgroundColor != null) {
      backgroundColor = cellTheme.weekendBackgroundColor!;
    }

    // Skip border if grid is handling it (table-style borders)
    final showCellBorder = cellTheme.showBorder && !skipBorder;

    return BoxDecoration(
      color: backgroundColor,
      border: showCellBorder ? cellTheme.cellBorder : null,
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
        return BorderRadius.circular(cellTheme.borderRadius);
      case CellShape.square:
        return BorderRadius.zero;
    }
  }

  /// Gets the text style for the cell based on state.
  ///
  /// Color resolution priority:
  /// 1. Explicit TextStyle (if set)
  /// 2. Explicit color property (if set)
  /// 3. ColorScheme semantic color
  /// 4. Default fallback
  TextStyle _getTextStyle({
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
    required bool hasEvent,
  }) {
    final cellTheme = calendarStyle.cellTheme;
    final colorScheme = calendarStyle.colorScheme;

    // Today: explicit style > explicit color > colorScheme.onToday > white
    if (isToday) {
      return cellTheme.todayTextStyle ??
          cellTheme.defaultTextStyle.copyWith(
            color: cellTheme.todayTextColor ?? colorScheme.onToday,
          );
    }

    // Selected: explicit style > explicit color > colorScheme.onPrimary > primary
    if (isSelected) {
      return cellTheme.selectedTextStyle ??
          cellTheme.defaultTextStyle.copyWith(
            color: cellTheme.selectedTextColor ?? colorScheme.onPrimary,
          );
    }

    // Weekend: explicit style > explicit color > colorScheme.weekend > red
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

    // Default: explicit style > colorScheme.onSurface > black
    final defaultColor =
        cellTheme.defaultTextStyle.color ?? colorScheme.onSurface;
    return cellTheme.defaultTextStyle.copyWith(color: defaultColor);
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
