// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar-related utilities
import '../src.dart';

// Widget to display a monthly calendar view with generic event type T
class CalendarMonthView<T> extends StatelessWidget {
  // Year to display in the calendar
  final int year;
  // Month to display in the calendar
  final int month;
  // Currently selected date
  final NepaliDateTime selectedDate;
  // Optional list of calendar events
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList]. See [CalendarGrid.eventIndex].
  final CalendarEventIndex<T>? eventIndex;
  // Callback function when a day is selected
  final OnDateSelected onDaySelected;
  // Style configuration for the calendar
  final NepaliCalendarStyle calendarStyle;
  // Optional custom cell builder
  final Widget Function(CalendarCellData<T>)? cellBuilder;
  // Optional custom weekday builder
  final Widget Function(WeekdayData)? weekdayBuilder;

  /// Width-to-height ratio of each cell, applied to both the weekday header
  /// and the date grid. See [CalendarGrid.cellAspectRatio].
  final double cellAspectRatio;

  // Constructor requiring all necessary parameters
  const CalendarMonthView({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    this.eventIndex,
    required this.onDaySelected,
    required this.calendarStyle,
    this.cellBuilder,
    this.weekdayBuilder,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      spacing: calendarStyle.effectiveConfig.showBorder ? 0 : 10,
      children: [
        // Display header row showing weekday names
        WeekdayHeader(
          style: calendarStyle,
          weekdayBuilder: weekdayBuilder,
          cellAspectRatio: cellAspectRatio,
        ),
        // Display grid of days for the month
        CalendarGrid<T>(
          year: year,
          month: month,
          selectedDate: selectedDate,
          eventList: eventList,
          eventIndex: eventIndex,
          onDaySelected: onDaySelected,
          calendarStyle: calendarStyle,
          cellBuilder: cellBuilder,
          cellAspectRatio: cellAspectRatio,
        ),
      ],
    );

    // Wrap with table-style border container if borders are enabled
    final borderColor =
        calendarStyle.cellsStyle.borderColor.withValues(alpha: 0.3);

    final content = calendarStyle.effectiveConfig.showBorder
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor),
                left: BorderSide(color: borderColor),
              ),
            ),
            child: column,
          )
        : column;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: content,
    );
  }
}
