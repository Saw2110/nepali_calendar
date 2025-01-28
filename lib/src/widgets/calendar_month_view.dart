import 'package:flutter/material.dart';

import '../src.dart';

class CalendarMonthView<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(T? event)? checkIsHoliday;
  final void Function(NepaliDateTime) onDaySelected;
  final NepaliCalenderStyle calendarStyle;

  const CalendarMonthView({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    required this.onDaySelected,
    this.checkIsHoliday,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WeekdayHeader(),
        CalendarGrid<T>(
          year: year,
          month: month,
          selectedDate: selectedDate,
          eventList: eventList,
          checkIsHoliday: checkIsHoliday,
          onDaySelected: onDaySelected,
          calendarStyle: calendarStyle,
        ),
        Flexible(
          child: EventList<T>(
            eventList: eventList,
            selectedDate: selectedDate,
            checkIsHoliday: checkIsHoliday,
          ),
        ),
      ],
    );
  }
}
