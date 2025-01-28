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
    // List of weekday indices (0 = Sunday, 6 = Saturday)
    const List<int> weekdays = [0, 1, 2, 3, 4, 5, 6];
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
                // Bold styling for weekday names
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }
}
