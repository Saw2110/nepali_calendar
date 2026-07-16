import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'src.dart';

/// Largest a compact day cell is allowed to get.
///
/// Twelve months on one screen means the cells are driven by the tile width;
/// without a cap they would grow absurdly tall on a wide desktop window.
const double _maxCompactCellHeight = 28.0;

/// Smallest a compact day cell may shrink to and still be readable and
/// tappable.
const double _minCompactCellHeight = 14.0;

/// Rows in a month grid. Always six, so a month's last days can never be
/// pushed out of the viewport and left unbuilt.
const int _monthRows = 6;

/// Columns in a month grid: one per weekday.
const int _monthColumns = 7;

/// Shows a whole Nepali year at once, as a scrollable grid of compact months.
///
/// ```dart
/// NepaliYearCalendar(
///   year: 2081,
///   onDaySelected: (date) => print(date),
/// )
/// ```
///
/// Two months per row by default; see [monthsPerRow]. Styling follows the same
/// rules as every other widget here -- an explicit [calendarStyle] wins,
/// otherwise an ambient [NepaliCalendarTheme] applies, otherwise the built-in
/// defaults:
///
/// ```dart
/// NepaliCalendarTheme(
///   data: NepaliCalendarThemeData.fromContext(context),
///   child: NepaliYearCalendar(year: 2081),
/// )
/// ```
class NepaliYearCalendar<T> extends StatefulWidget {
  /// The Nepali year to show. Defaults to the current year.
  final int? year;

  /// The initially selected date.
  ///
  /// When [jumpToSelectedMonth] is set, its month is scrolled into view.
  final NepaliDateTime? initialDate;

  /// Events to mark. A date may carry several.
  final List<CalendarEvent<T>>? eventList;

  /// Explicit styling. Leave unset to follow an ambient [NepaliCalendarTheme].
  final NepaliCalendarStyle calendarStyle;

  /// Called when a date is tapped.
  final OnDateSelected? onDaySelected;

  /// Called when the year changes via the header arrows.
  final ValueChanged<int>? onYearChanged;

  /// Months per row. Defaults to two, as in a wall calendar.
  final int monthsPerRow;

  /// Whether to show the year header with its navigation arrows.
  final bool showHeader;

  /// Whether to scroll [initialDate]'s month into view on first build.
  final bool jumpToSelectedMonth;

  /// Replaces the year header.
  final Widget Function(int year)? headerBuilder;

  /// Replaces a month's title.
  final Widget Function(int year, int month)? monthTitleBuilder;

  const NepaliYearCalendar({
    super.key,
    this.year,
    this.initialDate,
    this.eventList,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onDaySelected,
    this.onYearChanged,
    this.monthsPerRow = 2,
    this.showHeader = true,
    this.jumpToSelectedMonth = false,
    this.headerBuilder,
    this.monthTitleBuilder,
  }) : assert(monthsPerRow > 0, 'monthsPerRow must be at least 1');

  @override
  State<NepaliYearCalendar<T>> createState() => _NepaliYearCalendarState<T>();
}

class _NepaliYearCalendarState<T> extends State<NepaliYearCalendar<T>> {
  late int _year;
  late NepaliDateTime? _selectedDate;
  late CalendarEventIndex<T> _eventIndex;

  final _monthKeys = List.generate(12, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _year = widget.year ?? _selectedDate?.year ?? NepaliDateTime.now().year;
    _eventIndex = CalendarEventIndex<T>.fromList(widget.eventList);

    if (widget.jumpToSelectedMonth && _selectedDate != null) {
      // The months must be laid out before one can be scrolled to.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMonth(_selectedDate!.month);
      });
    }
  }

  @override
  void didUpdateWidget(NepaliYearCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Identity, not equality: the list is not ours and may be mutated in place,
    // so a deep comparison would be costly and unreliable.
    if (!identical(widget.eventList, oldWidget.eventList)) {
      _eventIndex = CalendarEventIndex<T>.fromList(widget.eventList);
    }
    if (widget.year != oldWidget.year && widget.year != null) {
      _year = widget.year!;
    }
  }

  void _scrollToMonth(int month) {
    final context = _monthKeys[month - 1].currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  /// The years the calendar has data for.
  static int get _firstYear => CalendarUtils.nepaliYears.keys.first;
  static int get _lastYear => CalendarUtils.nepaliYears.keys.last;

  void _changeYear(int delta) {
    final next = _year + delta;
    // Clamped to the data we actually hold: stepping past it would throw on a
    // null lookup rather than simply doing nothing.
    if (next < _firstYear || next > _lastYear) return;

    setState(() => _year = next);
    widget.onYearChanged?.call(next);
  }

  void _handleDaySelected(NepaliDateTime date) {
    setState(() => _selectedDate = date);
    widget.onDaySelected?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    final style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);
    final config = style.effectiveConfig;

    return Column(
      children: [
        if (widget.showHeader)
          widget.headerBuilder?.call(_year) ?? _buildHeader(style, config),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              const padding = 8.0;

              final available = constraints.maxWidth -
                  (padding * 2) -
                  (spacing * (widget.monthsPerRow - 1));
              final tileWidth = available / widget.monthsPerRow;

              // Size the day cells from the tile, then derive the tile height
              // from them, so every one of the six rows has somewhere to go.
              // Cells that were merely square would make each tile as tall as
              // it is wide.
              final cellWidth = tileWidth / _monthColumns;
              final cellHeight = math.max(
                _minCompactCellHeight,
                math.min(cellWidth, _maxCompactCellHeight),
              );

              // Text-driven parts scale with the user's text size; Devanagari
              // also needs more room than Latin at the same point size.
              final scaler = MediaQuery.textScalerOf(context);
              final titleHeight = scaler.scale(24.0);
              final weekdayHeight = scaler.scale(18.0);
              final tileHeight =
                  titleHeight + weekdayHeight + (cellHeight * _monthRows) + 4;

              return GridView.builder(
                padding: const EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.monthsPerRow,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: tileWidth / tileHeight,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  return _CompactMonth<T>(
                    key: _monthKeys[index],
                    year: _year,
                    month: month,
                    selectedDate: _selectedDate,
                    eventIndex: _eventIndex,
                    style: style,
                    titleHeight: titleHeight,
                    weekdayHeight: weekdayHeight,
                    onDaySelected: _handleDaySelected,
                    titleBuilder: widget.monthTitleBuilder,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(NepaliCalendarStyle style, CalendarConfig config) {
    final yearText = config.language == Language.english
        ? '$_year'
        : NepaliNumberConverter.englishToNepali('$_year');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            // Disabled rather than hidden at the ends of the range, so the
            // header does not jump around.
            onPressed: _year > _firstYear ? () => _changeYear(-1) : null,
            tooltip: 'Previous year',
          ),
          Flexible(
            child: Text(
              yearText,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: style.headersStyle.yearHeaderStyle,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _year < _lastYear ? () => _changeYear(1) : null,
            tooltip: 'Next year',
          ),
        ],
      ),
    );
  }
}

/// One month of the year grid: a title, a row of weekday initials, and six
/// rows of dates.
class _CompactMonth<T> extends StatelessWidget {
  final int year;
  final int month;
  final NepaliDateTime? selectedDate;
  final CalendarEventIndex<T> eventIndex;
  final NepaliCalendarStyle style;
  final double titleHeight;
  final double weekdayHeight;
  final OnDateSelected onDaySelected;
  final Widget Function(int year, int month)? titleBuilder;

  const _CompactMonth({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.eventIndex,
    required this.style,
    required this.titleHeight,
    required this.weekdayHeight,
    required this.onDaySelected,
    this.titleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: titleHeight,
          child: titleBuilder?.call(year, month) ?? _buildTitle(config),
        ),
        SizedBox(height: weekdayHeight, child: _buildWeekdays(config)),
        Expanded(child: _buildDays(config)),
      ],
    );
  }

  Widget _buildTitle(CalendarConfig config) {
    return Center(
      child: Text(
        MonthUtils.formattedMonth(month, config.language),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: style.headersStyle.monthHeaderStyle.copyWith(fontSize: 13),
      ),
    );
  }

  Widget _buildWeekdays(CalendarConfig config) {
    return Row(
      children: _weekdayOrder(config).map((weekday) {
        final isWeekend = WeekUtils.isWeekend(weekday, config.weekendType);
        return Expanded(
          child: Center(
            child: Text(
              WeekUtils.formattedShortWeekDay(weekday, config.language),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: style.headersStyle.weekHeaderStyle.copyWith(
                fontSize: 9,
                color: isWeekend
                    ? style.cellsStyle.weekDayColor
                    : style.headersStyle.weekHeaderStyle.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDays(CalendarConfig config) {
    final leading = _leadingBlanks(config);
    final daysInMonth = CalendarUtils.nepaliYears[year]![month];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive the ratio from the room actually on offer, so all six rows
        // are laid out and none is silently dropped.
        final cellWidth = constraints.maxWidth / _monthColumns;
        final cellHeight = constraints.maxHeight / _monthRows;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _monthColumns,
            childAspectRatio: cellHeight > 0 ? cellWidth / cellHeight : 1.0,
          ),
          itemCount: _monthRows * _monthColumns,
          itemBuilder: (context, index) {
            final day = index - leading + 1;
            // Cells before the 1st and after the last stay empty: a compact
            // month has no room for adjacent months' dates.
            if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

            return _CompactDay<T>(
              date: NepaliDateTime(year: year, month: month, day: day),
              day: day,
              selectedDate: selectedDate,
              eventIndex: eventIndex,
              style: style,
              config: config,
              onDaySelected: onDaySelected,
            );
          },
        );
      },
    );
  }

  /// Blank cells before the 1st, honouring the configured week start.
  int _leadingBlanks(CalendarConfig config) {
    final weekday = NepaliDateTime(year: year, month: month).weekday;
    switch (config.weekStartType) {
      case WeekStartType.sunday:
        return weekday;
      case WeekStartType.monday:
        return weekday == 0 ? 6 : weekday - 1;
    }
  }

  List<int> _weekdayOrder(CalendarConfig config) {
    switch (config.weekStartType) {
      case WeekStartType.sunday:
        return const [0, 1, 2, 3, 4, 5, 6];
      case WeekStartType.monday:
        return const [1, 2, 3, 4, 5, 6, 0];
    }
  }
}

/// A single date in a compact month.
class _CompactDay<T> extends StatelessWidget {
  final NepaliDateTime date;
  final int day;
  final NepaliDateTime? selectedDate;
  final CalendarEventIndex<T> eventIndex;
  final NepaliCalendarStyle style;
  final CalendarConfig config;
  final OnDateSelected onDaySelected;

  const _CompactDay({
    required this.date,
    required this.day,
    required this.selectedDate,
    required this.eventIndex,
    required this.style,
    required this.config,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cells = style.cellsStyle;

    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelected = selectedDate != null && selectedDate!.isSameDayAs(date);
    final isWeekend = WeekUtils.isWeekend(date.weekday, config.weekendType);
    final hasEvents = eventIndex.hasEventsOn(date);
    // Any event on the date, not just the first.
    final isHoliday = eventIndex.isHoliday(date);

    final label = config.language == Language.english
        ? '$day'
        : NepaliNumberConverter.englishToNepali('$day');

    return GestureDetector(
      onTap: () => onDaySelected(date),
      // Transparent cells must still take a tap, or only the digits would.
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _background(cells, isToday, isSelected),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: FittedBox(
                // The cells are small and Devanagari digits are wide; scale
                // down rather than overflow.
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: _foreground(
                      cells,
                      isToday: isToday,
                      isSelected: isSelected,
                      isWeekend: isWeekend,
                      isHoliday: isHoliday,
                    ),
                  ),
                ),
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColour(cells, isToday, isSelected, isHoliday),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _background(CellStyle cells, bool isToday, bool isSelected) {
    if (isToday) return cells.todayColor;
    if (isSelected) return cells.selectedColor.withValues(alpha: 0.25);
    return Colors.transparent;
  }

  Color _foreground(
    CellStyle cells, {
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
    required bool isHoliday,
  }) {
    if (isToday) return cells.onHighlightColor;
    // Holidays read like weekends, which is the convention the month view uses.
    if (isHoliday || isWeekend) return cells.weekDayColor;
    return cells.dateTextColor;
  }

  Color _dotColour(
    CellStyle cells,
    bool isToday,
    bool isSelected,
    bool isHoliday,
  ) {
    if (isToday) return cells.onHighlightColor;
    if (isHoliday) return cells.weekDayColor;
    return cells.dotColor;
  }
}
