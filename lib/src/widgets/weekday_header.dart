// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import '../src.dart';

// Widget to display header row of weekday names
class WeekdayHeader extends StatelessWidget {
  // Style configuration for the calendar
  final CalendarTheme style;
  const WeekdayHeader({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final weekdayTheme = style.weekdayTheme;

    // Return empty widget if weekday row should be hidden
    if (!weekdayTheme.show) {
      return const SizedBox.shrink();
    }

    // List of weekday indices (0 = Sunday, 6 = Saturday)
    const List<int> weekdays = [0, 1, 2, 3, 4, 5, 6];

    return Container(
      height: weekdayTheme.height,
      padding: weekdayTheme.padding,
      decoration: weekdayTheme.decoration ??
          (weekdayTheme.backgroundColor != null
              ? BoxDecoration(color: weekdayTheme.backgroundColor)
              : null),
      child: Row(
        mainAxisAlignment: weekdayTheme.alignment,
        children: weekdays.map((day) => _buildWeekdayLabel(day)).toList(),
      ),
    );
  }

  /// Builds a single weekday label.
  Widget _buildWeekdayLabel(int day) {
    final weekdayTheme = style.weekdayTheme;

    // Get the label text
    final String label = _getWeekdayLabel(day);

    // Determine if this is a weekend day (Saturday = 6)
    final bool isWeekend = day == 6;

    // Get the appropriate text style
    final TextStyle? textStyle =
        isWeekend && weekdayTheme.weekendTextStyle != null
            ? weekdayTheme.weekendTextStyle
            : weekdayTheme.textStyle ??
                const TextStyle(fontWeight: FontWeight.bold);

    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }

  /// Gets the weekday label based on custom labels or format.
  String _getWeekdayLabel(int day) {
    final weekdayTheme = style.weekdayTheme;

    // Use custom labels if provided
    if (weekdayTheme.customLabels != null &&
        weekdayTheme.customLabels!.length == 7) {
      return weekdayTheme.customLabels![day];
    }

    // Use formatted weekday based on locale and format from WeekdayTheme
    return WeekUtils.formattedWeekDay(
      day,
      style.locale,
      weekdayTheme.format,
    );
  }
}
