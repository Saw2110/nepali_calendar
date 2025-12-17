// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import '../src.dart';

// Widget to display header row of weekday names
class WeekdayHeader extends StatelessWidget {
  // Style configuration for the calendar
  final NepaliCalendarStyle style;
  // Optional custom weekday builder
  final Widget Function(WeekdayData)? weekdayBuilder;

  const WeekdayHeader({
    super.key,
    required this.style,
    this.weekdayBuilder,
  });

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
        final isWeekend = _isWeekend(day);

        Widget cell;

        // If custom weekdayBuilder is provided, use it
        if (weekdayBuilder != null) {
          final weekdayData = WeekdayData(
            weekday: day,
            language: style.effectiveConfig.language,
            isWeekend: isWeekend,
            format: style.effectiveConfig.weekTitleType,
            style: style,
          );
          cell = weekdayBuilder!(weekdayData);
        } else {
          // Default weekday header implementation
          // Note: Borders are handled by grid wrapper, not individual cells
          cell = Column(
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
                  color: isWeekend
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
                  color: isWeekend
                      ? style.cellsStyle.weekDayColor.withValues(alpha: 0.7)
                      : Colors.black54,
                ),
              ),
            ],
          );
        }

        // Wrap with table-style borders if enabled
        if (style.effectiveConfig.showBorder) {
          return _wrapWithTableBorder(cell);
        }
        return cell;
      },
    );

    // Don't add top/left border here - CalendarMonthView will handle it
    return headerGrid;
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

  /// Wraps a weekday cell with table-style borders (right and bottom only).
  Widget _wrapWithTableBorder(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: child,
    );
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int dayIndex) {
    return WeekUtils.isWeekend(dayIndex, style.effectiveConfig.weekendType);
  }
}
