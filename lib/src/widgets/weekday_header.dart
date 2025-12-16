// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import '../src.dart';

// Widget to display header row of weekday names
class WeekdayHeader extends StatelessWidget {
  // Style configuration for the calendar
  final NepaliCalendarStyle style;
  const WeekdayHeader({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    // Get weekday indices based on week start configuration
    final List<int> weekdays = _getWeekdayOrder();
    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Text(
                // Format weekday name based on language and title type
                WeekUtils.formattedWeekDay(
                  day,
                  style.language,
                  style.headersStyle.weekTitleType,
                ),
                textAlign: TextAlign.center,
                // Apply weekend color to weekend day names
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isWeekend(day)
                      ? style.cellsStyle.weekDayColor
                      : Colors.black87,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Get the order of weekdays based on week start type
  List<int> _getWeekdayOrder() {
    switch (style.weekStartType) {
      case WeekStartType.sunday:
        // Sunday (0) to Saturday (6)
        return [0, 1, 2, 3, 4, 5, 6];
      case WeekStartType.monday:
        // Monday (1) to Sunday (0)
        return [1, 2, 3, 4, 5, 6, 0];
    }
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int dayIndex) {
    // dayIndex: 0=Sunday, 1=Monday, ..., 6=Saturday
    // Convert to NepaliDateTime weekday format: 1=Monday, ..., 6=Saturday, 7=Sunday
    final weekday = dayIndex == 0 ? 7 : dayIndex;

    switch (style.weekendType) {
      case WeekendType.saturdayAndSunday:
        return weekday == 6 || weekday == 7;
      case WeekendType.fridayAndSaturday:
        return weekday == 5 || weekday == 6;
      case WeekendType.saturday:
        return weekday == 6;
      case WeekendType.sunday:
        return weekday == 7;
    }
  }
}
