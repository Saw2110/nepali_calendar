// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_layout.dart';

/// The month view is an implementation detail of [NepaliCalendar]. Use
/// [NepaliCalendar] itself.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarMonthView<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList]. See [CalendarGrid.eventIndex].
  final CalendarEventIndex<T>? eventIndex;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(CalendarCellData<T>)? cellBuilder;
  final Widget Function(WeekdayData)? weekdayBuilder;

  /// Width-to-height ratio of each cell, applied to both the weekday header
  /// and the date grid. See [CalendarGrid.cellAspectRatio].
  final double cellAspectRatio;

  const CalendarMonthView({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    this.eventIndex,
    required this.onDaySelected,
    required this.calendarStyle,
    this.cellBuilder,
    this.weekdayBuilder,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      // Only as tall as its rows. The month view no longer always has six of
      // them, and [NepaliCalendar] sizes its viewport to the month on screen,
      // so a Column that stretched would fight that rather than follow it.
      mainAxisSize: MainAxisSize.min,
      spacing: calendarStyle.effectiveConfig.showBorder ? 0 : 10,
      children: [
        WeekdayHeader(
          style: calendarStyle,
          weekdayBuilder: weekdayBuilder,
          cellAspectRatio: cellAspectRatio,
        ),
        CalendarGrid<T>(
          year: year,
          month: month,
          selectedDate: selectedDate,
          eventList: eventList,
          eventIndex: eventIndex,
          onDaySelected: onDaySelected,
          calendarStyle: calendarStyle,
          cellBuilder: cellBuilder,
          cellAspectRatio: cellAspectRatio,
        ),
      ],
    );

    // The cells draw their right and bottom lines; this closes the table on
    // the top and left.
    final content = calendarStyle.effectiveConfig.showBorder
        ? tableBorder(column, calendarStyle, outerEdge: true)
        : column;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: content,
    );
  }
}
