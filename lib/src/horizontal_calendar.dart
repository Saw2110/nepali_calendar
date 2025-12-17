import 'package:flutter/material.dart';

import '../nepali_calendar_plus.dart';

class HorizontalNepaliCalendar extends StatefulWidget {
  const HorizontalNepaliCalendar({
    super.key,
    this.initialDate,
    this.textColor,
    this.backgroundColor,
    this.selectedColor,
    this.showMonth = true,
    required this.onDateSelected,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.headerBuilder,
  });

  final NepaliDateTime? initialDate;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? selectedColor;
  final bool showMonth;
  final OnDateSelected onDateSelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(
    NepaliDateTime currentDateTime,
    NepaliDateTime selectedDateTime,
  )? headerBuilder;

  @override
  State<HorizontalNepaliCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalNepaliCalendar> {
  late NepaliDateTime _todayDate;
  late NepaliDateTime _selectedDate;
  late NepaliDateTime _startDate;

  @override
  void initState() {
    super.initState();
    _todayDate = NepaliDateTime.now();
    _selectedDate = widget.initialDate ?? _todayDate;
    _startDate = _selectedDate.subtract(Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height / 100;

    return Container(
      height: height * 8,
      color: widget.backgroundColor ?? Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: widget.showMonth
            ? widget.headerBuilder?.call(_todayDate, _selectedDate) ??
                _buildMonthTitle()
            : null,
        subtitle: _buildDateList(),
      ),
    );
  }

  Widget _buildMonthTitle() {
    final month = MonthUtils.formattedMonth(
      _selectedDate.month,
      widget.calendarStyle.effectiveConfig.language,
    );
    final year =
        widget.calendarStyle.effectiveConfig.language == Language.english
            ? "${_selectedDate.year}"
            : NepaliNumberConverter.englishToNepali(
                _selectedDate.year.toString(),
              );

    ///
    return Text(
      "$year, $month",
      textAlign: TextAlign.start,
      style: widget.calendarStyle.headersStyle.monthHeaderStyle,
    );
  }

  Widget _buildDateList() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final date = _startDate.add(Duration(days: index));

                // Check if the date is today
                final bool isToday = _isSameDay(date, _todayDate);
                final bool isSelected = _isSameDay(date, _selectedDate);

                return CalendarItem(
                  date: date,
                  textColor:
                      _getCellTextColor(isToday, isSelected, date.weekday),
                  backgroundColor:
                      _getCellColor(isToday, isSelected, date.weekday),
                  style: widget.calendarStyle,
                  onDatePressed: () => _handleDateSelection(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleDateSelection(NepaliDateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      widget.onDateSelected(selectedDate);
      _startDate = _selectedDate.subtract(Duration(days: 2));
    });
  }

  /// Method to check if two dates are the same (without considering time)
  bool _isSameDay(NepaliDateTime date1, NepaliDateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

// Method to get the cell background color based on today, selected state, and weekday
  Color _getCellColor(bool isToday, bool isSelected, int weekday) {
    final isWeekend = _isWeekend(weekday);

    if (isToday && !isWeekend) {
      return widget.calendarStyle.cellsStyle.todayColor;
    }
    if (isToday && isWeekend) {
      return widget.calendarStyle.cellsStyle.weekDayColor;
    }
    if (isSelected && !isWeekend) {
      return widget.calendarStyle.cellsStyle.selectedColor
          .withValues(alpha: 0.2);
    }
    if (isSelected && isWeekend) {
      return widget.calendarStyle.cellsStyle.weekDayColor
          .withValues(alpha: 0.2);
    }

    return Colors.transparent; // Default case
  }

// Method to get the cell text color based on today, selected state, and weekday
  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    final isWeekend = _isWeekend(weekday);

    if (isToday) return Colors.white; // Today always white text
    if (isSelected && !isWeekend) {
      return widget.calendarStyle.cellsStyle.selectedColor;
    }
    if (isSelected && isWeekend) {
      return widget.calendarStyle.cellsStyle.weekDayColor;
    }
    if (isWeekend) return widget.calendarStyle.cellsStyle.weekDayColor;
    return Colors.black; // Default text color
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int weekday) {
    // weekday: 1=Monday, 2=Tuesday, ..., 6=Saturday, 7=Sunday
    switch (widget.calendarStyle.effectiveConfig.weekendType) {
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

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.date,
    required this.textColor,
    required this.backgroundColor,
    required this.onDatePressed,
    required this.style,
  });

  final NepaliDateTime date;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onDatePressed;
  final NepaliCalendarStyle style;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    // Adjust the weekday value to match the expected range (0-6)
    final adjustedWeekday = (date.weekday - 1) % 7;

    return InkWell(
      onTap: onDatePressed,
      child: Container(
        width: (width / 7),
        color: backgroundColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the weekday name
            Text(
              WeekUtils.formattedWeekDay(
                adjustedWeekday,
                style.effectiveConfig.language,
                style.effectiveConfig.weekTitleType,
              ),
              style: style.headersStyle.weekHeaderStyle.copyWith(
                color: textColor,
                fontWeight: FontWeight.normal,
                fontSize: 13.0,
              ),
            ),
            // Display the day of the month
            Text(
              style.effectiveConfig.language == Language.english
                  ? "${date.day}"
                  : NepaliNumberConverter.englishToNepali(date.day.toString()),
              style: style.cellsStyle.dayStyle.copyWith(
                color: textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
