// Import required Flutter material package
import 'package:flutter/material.dart';

// Import custom source file
import '../src.dart';

// Widget to display the calendar header with month/year and navigation buttons
class CalendarHeader extends StatelessWidget {
  // Selected date to display in header
  final NepaliDateTime selectedDate;
  // Controller for handling page transitions
  final PageController pageController;
  // Style configuration for the calendar
  final NepaliCalendarStyle calendarStyle;

  // Constructor with required parameters
  const CalendarHeader({
    super.key,
    required this.selectedDate,
    required this.pageController,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left navigation button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              // Check if controller is attached before navigating
              if (pageController.hasClients) {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
          ),
          // Center section containing month and year
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 5.0,
              children: [
                // Month display
                Flexible(
                  child: Text(
                    MonthUtils.formattedMonth(
                      selectedDate.month,
                      calendarStyle.effectiveConfig.language,
                    ),
                    style: calendarStyle.headersStyle.monthHeaderStyle,
                  ),
                ),
                // Year display with language-specific formatting
                Flexible(
                  child: Text(
                    calendarStyle.effectiveConfig.language == Language.english
                        ? "${selectedDate.year}"
                        : NepaliNumberConverter.englishToNepali(
                            selectedDate.year.toString(),
                          ),
                    style: calendarStyle.headersStyle.yearHeaderStyle,
                  ),
                ),
              ],
            ),
          ),
          // Right navigation button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // Check if controller is attached before navigating
              if (pageController.hasClients) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
