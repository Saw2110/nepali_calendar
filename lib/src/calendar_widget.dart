import 'package:flutter/material.dart';

import 'src.dart';

class NepaliCalendar<T> extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(T? event)? checkIsHoliday;
  final NepaliCalenderStyle calendarStyle;
  final void Function(NepaliDateTime nepaliDateTime)? onMonthChanged;
  final void Function(NepaliDateTime nepaliDateTime)? onDayChanged;

  const NepaliCalendar({
    super.key,
    this.initialDate,
    this.eventList,
    this.checkIsHoliday,
    this.calendarStyle = const NepaliCalenderStyle(),
    this.onMonthChanged,
    this.onDayChanged,
  });

  @override
  State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
}

class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
  late PageController _pageController;
  late NepaliDateTime _currentDate;
  late NepaliDateTime _selectedDate;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? NepaliDateTime.now();
    _selectedDate = _currentDate;
    _initializePageController();
  }

  void _initializePageController() {
    _currentPageIndex =
        ((_currentDate.year - CalendarUtils.calenderyearStart) * 12) +
            _currentDate.month -
            1;
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  void _updateCurrentDate(int year, int month, int day) {
    setState(() {
      _selectedDate = NepaliDateTime(year: year, month: month, day: day);
    });
    widget.onDayChanged?.call(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final calendarStyle = widget.calendarStyle;
    return Column(
      children: [
        CalendarHeader(
          selectedDate: _selectedDate,
          pageController: _pageController,
          calendarStyle: calendarStyle,
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: CalendarUtils.nepaliYears.length * 12,
            onPageChanged: (index) {
              final int year = CalendarUtils.calenderyearStart + (index ~/ 12);
              final int month = (index % 12) + 1;

              widget.onMonthChanged?.call(
                NepaliDateTime(
                  year: year,
                  month: month,
                  day: _currentDate.day,
                ),
              );
              _updateCurrentDate(year, month, _currentDate.day);
            },
            itemBuilder: (context, index) {
              final year = CalendarUtils.calenderyearStart + (index ~/ 12);
              final month = (index % 12) + 1;

              return CalendarMonthView<T>(
                year: year,
                month: month,
                selectedDate: _selectedDate,
                eventList: widget.eventList,
                checkIsHoliday: widget.checkIsHoliday,
                calendarStyle: calendarStyle,
                onDaySelected: (date) {
                  _updateCurrentDate(date.year, date.month, date.day);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
