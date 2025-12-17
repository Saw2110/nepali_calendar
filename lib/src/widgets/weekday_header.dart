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

    final headerGrid = GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 columns for 7 days in a week
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = weekdays[index];
        return DecoratedBox(
          decoration: style.effectiveConfig.showBorder
              ? BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nepali weekday name
              Text(
                WeekUtils.formattedWeekDay(
                  day,
                  Language.nepali,
                  style.effectiveConfig.weekTitleType,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _isWeekend(day)
                      ? style.cellsStyle.weekDayColor
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              // English weekday name
              Text(
                WeekUtils.formattedWeekDay(
                  day,
                  Language.english,
                  style.effectiveConfig.weekTitleType,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  color: _isWeekend(day)
                      ? style.cellsStyle.weekDayColor.withValues(alpha: 0.7)
                      : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Wrap with container to add top and left borders for table-style border
    return style.effectiveConfig.showBorder
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                left: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: headerGrid,
          )
        : headerGrid;
  }

  // Get the order of weekdays based on week start type
  List<int> _getWeekdayOrder() {
    switch (style.effectiveConfig.weekStartType) {
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

    switch (style.effectiveConfig.weekendType) {
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
