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
  // Callback function when a day is selected
  final OnDateSelected onDaySelected;
  // Style configuration for the calendar
  final CalendarTheme calendarStyle;

  // Constructor requiring all necessary parameters
  const CalendarMonthView({
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
    final spacing = calendarStyle.spacing;

    return Column(
      children: [
        // Display header row showing weekday names
        WeekdayHeader(style: calendarStyle),
        // Spacing between weekday labels and cells
        SizedBox(height: spacing.weekdaysToCellsSpacing),
        // Display grid of days for the month
        CalendarGrid<T>(
          year: year,
          month: month,
          selectedDate: selectedDate,
          eventList: eventList,
          onDaySelected: onDaySelected,
          calendarStyle: calendarStyle,
        ),
      ],
    );
  }
}
