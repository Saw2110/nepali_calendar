import 'package:flutter/material.dart';

import '../src.dart';

class CalendarHeader extends StatelessWidget {
  final NepaliDateTime selectedDate;
  final PageController pageController;
  final NepaliCalenderStyle calendarStyle;

  const CalendarHeader({
    super.key,
    required this.selectedDate,
    required this.pageController,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            if (pageController.hasClients) {
              pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        Text(
          'Year ${selectedDate.year}, Month ${selectedDate.month}',
          style: calendarStyle.headerTextStyle ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            if (pageController.hasClients) {
              pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
    );
  }
}
