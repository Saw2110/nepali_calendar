import 'package:flutter/material.dart';

import '../src.dart';

class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final OnDateSelected onDaySelected;
  final CalendarTheme calendarStyle;

  /// Total cells in the grid (6 rows × 7 columns = 42 cells always)
  static const int _totalGridCells = 42;

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

    final gridItems = <Widget>[];
    final cellTheme = calendarStyle.cellTheme;
    final showAdjacentDays = cellTheme.showAdjacentMonthDays;

    // Calculate start offset (how many cells before the 1st of the month)
    final startOffset = weekdayOfFirstDay == 7 ? 0 : weekdayOfFirstDay;

    // Add previous month's trailing days
    if (startOffset > 0) {
      if (showAdjacentDays) {
        gridItems.addAll(_buildPreviousMonthDays(startOffset));
      } else {
        gridItems.addAll(List.generate(startOffset, (_) => const EmptyCell()));
      }
    }

    // Add current month's days
    gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

    // Add next month's leading days to fill 6 rows
    final currentCellCount = startOffset + daysCountInMonth;
    final remainingCells = _totalGridCells - currentCellCount;
    if (remainingCells > 0) {
      if (showAdjacentDays) {
        gridItems.addAll(_buildNextMonthDays(remainingCells));
      } else {
        gridItems
            .addAll(List.generate(remainingCells, (_) => const EmptyCell()));
      }
    }

    // Check if we need table-style borders (no margin = borders would overlap)
    final useTableBorders =
        cellTheme.showBorder && cellTheme.cellMargin == EdgeInsets.zero;

    // Rebuild grid items with skipBorder if using table borders
    final List<Widget> finalGridItems;
    if (useTableBorders) {
      finalGridItems = <Widget>[];

      // Rebuild previous month days with skipBorder
      if (startOffset > 0) {
        if (showAdjacentDays) {
          finalGridItems
              .addAll(_buildPreviousMonthDays(startOffset, skipBorder: true));
        } else {
          finalGridItems
              .addAll(List.generate(startOffset, (_) => const EmptyCell()));
        }
      }

      // Rebuild current month days with skipBorder
      finalGridItems.addAll(
        _buildMonthDays(year, month, daysCountInMonth, skipBorder: true),
      );

      // Rebuild next month days with skipBorder
      final currentCount = startOffset + daysCountInMonth;
      final remaining = _totalGridCells - currentCount;
      if (remaining > 0) {
        if (showAdjacentDays) {
          finalGridItems
              .addAll(_buildNextMonthDays(remaining, skipBorder: true));
        } else {
          finalGridItems
              .addAll(List.generate(remaining, (_) => const EmptyCell()));
        }
      }
    } else {
      finalGridItems = gridItems;
    }

    Widget grid = GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: finalGridItems.length,
      itemBuilder: (context, index) {
        if (useTableBorders) {
          // Table-style borders: each cell has right and bottom border only
          return _wrapWithTableBorder(finalGridItems[index], cellTheme);
        }
        return finalGridItems[index];
      },
    );

    // If using table borders, wrap the grid with top and left border
    if (useTableBorders && cellTheme.cellBorder != null) {
      final borderSide = cellTheme.cellBorder!.top;
      grid = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: borderSide,
            left: borderSide,
          ),
        ),
        child: grid,
      );
    }

    return grid;
  }

  /// Wraps a cell with table-style borders (right and bottom only).
  Widget _wrapWithTableBorder(Widget child, CellTheme cellTheme) {
    final borderSide = cellTheme.cellBorder?.top ?? BorderSide.none;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: borderSide,
          bottom: borderSide,
        ),
      ),
      child: child,
    );
  }

  /// Builds cells for previous month's trailing days.
  List<Widget> _buildPreviousMonthDays(int count, {bool skipBorder = false}) {
    int prevYear = year;
    int prevMonth = month - 1;

    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }

    // Get days in previous month
    final daysInPrevMonth =
        CalendarUtils.nepaliYears[prevYear]?[prevMonth] ?? 30;

    // Build cells for the last 'count' days of the previous month
    final cells = <Widget>[];
    for (var i = count - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      final date = NepaliDateTime(year: prevYear, month: prevMonth, day: day);
      cells.add(
        CalendarCell<T>(
          day: day,
          date: date,
          selectedDate: selectedDate,
          event: null,
          onDaySelected: null,
          calendarStyle: calendarStyle,
          isAdjacentMonth: true,
          skipBorder: skipBorder,
        ),
      );
    }
    return cells;
  }

  /// Builds cells for next month's leading days.
  List<Widget> _buildNextMonthDays(int count, {bool skipBorder = false}) {
    int nextYear = year;
    int nextMonth = month + 1;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    // Build cells for the first 'count' days of the next month
    return List.generate(count, (i) {
      final day = i + 1;
      final date = NepaliDateTime(year: nextYear, month: nextMonth, day: day);
      return CalendarCell<T>(
        day: day,
        date: date,
        selectedDate: selectedDate,
        event: null,
        onDaySelected: null,
        calendarStyle: calendarStyle,
        isAdjacentMonth: true,
        skipBorder: skipBorder,
      );
    });
  }

  // Method to build the list of days in the month
  List<Widget> _buildMonthDays(
    int year,
    int month,
    int daysCountInMonth, {
    bool skipBorder = false,
  }) {
    return List.generate(daysCountInMonth, (index) {
      final day = index + 1;
      final date = NepaliDateTime(year: year, month: month, day: day);
      final event = _getEventForDate(date);

      return CalendarCell<T>(
        day: day,
        date: date,
        selectedDate: selectedDate,
        event: event,
        onDaySelected: onDaySelected,
        calendarStyle: calendarStyle,
        skipBorder: skipBorder,
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
