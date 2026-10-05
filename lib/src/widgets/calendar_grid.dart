// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_layout.dart';

/// The grid is an implementation detail of [NepaliCalendar]. Use
/// [NepaliCalendar] or [NepaliYearCalendar], and `CalendarBuilder` to
/// customise them.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarGrid<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime selectedDate;

  /// The events to mark on the grid.
  ///
  /// Prefer passing a prebuilt [eventIndex]: this list is re-indexed on every
  /// build, whereas an index can be built once and reused across months.
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList].
  ///
  /// When null, one is built from [eventList] on each build. [NepaliCalendar]
  /// supplies this so the index is built once per event-list change rather
  /// than once per month page.
  final CalendarEventIndex<T>? eventIndex;

  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(CalendarCellData<T>)? cellBuilder;

  /// Width-to-height ratio of each day cell.
  ///
  /// Defaults to 1.0 (square cells). [NepaliCalendar] passes a ratio greater
  /// than 1 on wide viewports so that cells grow sideways rather than making
  /// the calendar as tall as the viewport is wide.
  final double cellAspectRatio;

  /// [cellAspectRatio], guarded against the values the grid delegate rejects.
  double get _effectiveAspectRatio =>
      cellAspectRatio > 0 && cellAspectRatio.isFinite ? cellAspectRatio : 1.0;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventList,
    this.eventIndex,
    required this.onDaySelected,
    required this.calendarStyle,
    this.cellBuilder,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final config = calendarStyle.effectiveConfig;
    final index = _index;

    final leading = WeekUtils.normalizeWeekday(
      NepaliDateTime(year: year, month: month).weekday,
      config.weekStartType,
    );
    final length = _daysInMonth(year, month) ?? 0;
    final (prevYear, prevMonth) = shiftMonth(year, month, -1);
    final (nextYear, nextMonth) = shiftMonth(year, month, 1);
    // Null past either end of the bundled data: the first and last supported
    // months have no neighbour to borrow dates from, so those cells stay
    // blank rather than the page failing to build.
    final prevLength = _daysInMonth(prevYear, prevMonth);
    final nextLength = _daysInMonth(nextYear, nextMonth);

    // Each cell is worked out from its position: before the 1st is the
    // previous month, past the last day the next one, both dimmed.
    Widget cellAt(int position) {
      final day = position - leading + 1;
      if (day < 1) {
        return prevLength == null
            ? const SizedBox.shrink()
            : _cell(prevYear, prevMonth, prevLength + day, index, dimmed: true);
      }
      if (day > length) {
        return nextLength == null
            ? const SizedBox.shrink()
            : _cell(nextYear, nextMonth, day - length, index, dimmed: true);
      }
      return _cell(year, month, day, index);
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: _effectiveAspectRatio,
      ),
      // Five or six rows, whichever this month needs -- unless the config
      // asks for six unconditionally.
      itemCount: _rowCount * 7,
      itemBuilder: (context, position) {
        final cell = cellAt(position);
        // Right and bottom lines per cell; CalendarMonthView adds the outer
        // top and left edge.
        return config.showBorder ? tableBorder(cell, calendarStyle) : cell;
      },
    );
  }

  CalendarCell<T> _cell(
    int year,
    int month,
    int day,
    CalendarEventIndex<T> index, {
    bool dimmed = false,
  }) {
    final date = NepaliDateTime(year: year, month: month, day: day);
    return CalendarCell<T>(
      day: day,
      date: date,
      selectedDate: selectedDate,
      events: index.eventsOn(date),
      onDaySelected: onDaySelected,
      calendarStyle: calendarStyle,
      isDimmed: dimmed,
      cellBuilder: cellBuilder,
    );
  }

  /// How many week rows this month is drawn with.
  ///
  /// Five or six, as the month needs, so a five-row month does not end in a
  /// whole row of the next month's dates. See
  /// [CalendarConfig.sixWeekMonthsEnforced].
  int get _rowCount => calendarStyle.effectiveConfig.sixWeekMonthsEnforced
      ? CalendarUtils.maxWeekRowsInMonth
      : CalendarUtils.weekRowsInMonth(
          year,
          month,
          calendarStyle.effectiveConfig.weekStartType,
        );

  /// The index to look events up in.
  ///
  /// Uses the prebuilt [eventIndex] when given; otherwise builds one from
  /// [eventList] so callers constructing a [CalendarGrid] directly still work.
  CalendarEventIndex<T> get _index =>
      eventIndex ?? CalendarEventIndex<T>.fromList(eventList);

  /// The number of days in a month, or null for a year outside the bundled
  /// data.
  ///
  /// The first and last supported months spill their leading and trailing
  /// cells into a year the package has no data for. Reading those through
  /// `nepaliYears[year]!` brought the whole calendar down on those two pages.
  int? _daysInMonth(int year, int month) =>
      CalendarUtils.nepaliYears[year]?[month];
}
