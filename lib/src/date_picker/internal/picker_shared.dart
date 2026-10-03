// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide it.
// ignore_for_file: avoid_redundant_argument_values

/// Pieces shared by [NepaliDatePicker] and [NepaliDateRangePicker].
///
/// Internal: nothing here is exported from the package. The names are public
/// only because Dart privacy is per file, and two picker files need them.
library;

import 'package:flutter/material.dart';

import '../../src.dart';

/// Columns in a month grid: one per weekday.
const int pickerColumns = 7;

/// Rows in a month grid.
///
/// Always six. A month can span six weeks, and a grid that sizes to five
/// silently never builds the sixth -- which is how the 30th and 31st became
/// unselectable before 0.1.0.
const int pickerRows = 6;

/// Gap between day cells.
const double pickerCellGap = 2.0;

/// Corner radius for interactive surfaces: cells, fields and tiles.
///
/// Kept small. Rounder corners read as softer and bulkier than the crisp,
/// compact look the pickers are after.
const double pickerRadius = 6.0;

/// Corner radius of the pickers' dialogs, unless the app's `dialogTheme` sets
/// a shape of its own.
const double pickerDialogRadius = 12.0;

// ---------------------------------------------------------------------------
// Selectable range
// ---------------------------------------------------------------------------

/// The dates a picker will allow, already intersected with the range the
/// bundled calendar data covers.
///
/// Pulled out of the widgets so the bounds rules live in one place rather
/// than being re-derived at each call site.
@immutable
class PickerBounds {
  final NepaliDateTime min;
  final NepaliDateTime max;

  const PickerBounds._(this.min, this.max);

  factory PickerBounds.from({NepaliDateTime? min, NepaliDateTime? max}) {
    final years = CalendarUtils.nepaliYears;
    final firstYear = years.keys.first;
    final lastYear = years.keys.last;

    final dataStart = NepaliDateTime(year: firstYear, month: 1, day: 1);
    final dataEnd = NepaliDateTime(
      year: lastYear,
      month: 12,
      day: years[lastYear]![12],
    );

    // A caller's bounds can only ever narrow the range: asking for BS 1900
    // cannot conjure data that is not bundled.
    final low = (min != null && min.compareTo(dataStart) > 0) ? min : dataStart;
    final high = (max != null && max.compareTo(dataEnd) < 0) ? max : dataEnd;

    return PickerBounds._(low.dateOnly, high.dateOnly);
  }

  bool contains(NepaliDateTime date) {
    final day = date.dateOnly;
    return day.compareTo(min) >= 0 && day.compareTo(max) <= 0;
  }

  /// [date] pulled inside the range.
  ///
  /// Clamps rather than asserting: a stored date drifts out of range easily,
  /// and opening on the nearest legal date beats crashing the caller.
  NepaliDateTime clamp(NepaliDateTime date) {
    if (date.compareTo(min) < 0) return min;
    if (date.compareTo(max) > 0) return max;
    return date;
  }

  /// Whether any day of [month] in [year] is selectable.
  bool containsAnyOf(int year, int month) {
    if (!CalendarUtils.nepaliYears.containsKey(year)) return false;
    final lastDay = CalendarUtils.nepaliYears[year]![month];
    final start = NepaliDateTime(year: year, month: month, day: 1);
    final end = NepaliDateTime(year: year, month: month, day: lastDay);
    return end.compareTo(min) >= 0 && start.compareTo(max) <= 0;
  }

  /// Every month in range, earliest first, as the first day of each.
  List<NepaliDateTime> get months {
    return [
      for (var y = min.year; y <= max.year; y++)
        for (var m = (y == min.year ? min.month : 1);
            m <= (y == max.year ? max.month : 12);
            m++)
          NepaliDateTime(year: y, month: m, day: 1),
    ];
  }
}

/// Whole days from [a] to [b], ignoring the time of day. Negative when [b]
/// comes first.
int pickerDaysBetween(NepaliDateTime a, NepaliDateTime b) {
  final days = CalendarUtils.nepaliDateDifference(a.dateOnly, b.dateOnly);
  return b.dateOnly.compareTo(a.dateOnly) < 0 ? -days : days;
}

// ---------------------------------------------------------------------------
// Month layout
// ---------------------------------------------------------------------------

/// Weekday indices (0 = Sunday) in the order the grid shows them.
List<int> pickerWeekdayOrder(WeekStartType start) {
  switch (start) {
    case WeekStartType.sunday:
      return const [0, 1, 2, 3, 4, 5, 6];
    case WeekStartType.monday:
      return const [1, 2, 3, 4, 5, 6, 0];
  }
}

/// How many cells come before the 1st of [month] in its grid.
int _leadingCells(NepaliDateTime month, WeekStartType weekStart) {
  final weekday =
      NepaliDateTime(year: month.year, month: month.month, day: 1).weekday;
  return switch (weekStart) {
    WeekStartType.sunday => weekday,
    WeekStartType.monday => weekday == 0 ? 6 : weekday - 1,
  };
}

/// The date each of the 42 cells of [month]'s grid shows, running from the
/// trailing days of the previous month to the leading days of the next.
///
/// Built from the month tables rather than by adding days to the 1st, and
/// null where an adjacent month falls outside the bundled data: the first
/// month of the data has no previous month to borrow days from, and asking
/// for one throws.
List<NepaliDateTime?> pickerMonthDates(
  NepaliDateTime month,
  WeekStartType weekStart,
) {
  final years = CalendarUtils.nepaliYears;
  final year = month.year;
  final m = month.month;
  final length = years[year]![m];
  final leading = _leadingCells(month, weekStart);

  final prevYear = m == 1 ? year - 1 : year;
  final prevMonth = m == 1 ? 12 : m - 1;
  final prevLength = years[prevYear]?[prevMonth];
  final nextYear = m == 12 ? year + 1 : year;
  final nextMonth = m == 12 ? 1 : m + 1;
  final hasNext = years.containsKey(nextYear);

  NepaliDateTime? cell(int index) {
    final day = index - leading + 1;
    if (day < 1) {
      return prevLength == null
          ? null
          : NepaliDateTime(
              year: prevYear,
              month: prevMonth,
              day: prevLength + day,
            );
    }
    if (day > length) {
      return hasNext
          ? NepaliDateTime(year: nextYear, month: nextMonth, day: day - length)
          : null;
    }
    return NepaliDateTime(year: year, month: m, day: day);
  }

  return [for (var i = 0; i < pickerRows * pickerColumns; i++) cell(i)];
}

/// Six fixed rows of seven cells.
///
/// Rows and columns, not a GridView. A GridView only builds what its viewport
/// covers, so a row that did not fit was not clipped -- it did not exist,
/// which is how the 30th and 31st went missing before 0.1.0 -- and it
/// scrolled whenever rounding left it a fraction short. Here every row is
/// always built and the rows share out exactly the height on offer, so the
/// grid is fixed: it never scrolls and never shifts.
///
/// [rowGap] separates rows; cells within a row always sit [pickerCellGap]
/// apart unless [columnGap] says otherwise -- a range band wants none, so it
/// runs unbroken across a week. [rows] is six unless a caller trims a month
/// to the weeks it actually spans.
class PickerMonthGrid extends StatelessWidget {
  /// One per cell; null cells are left empty.
  final List<NepaliDateTime?> dates;
  final Widget Function(NepaliDateTime date) cellBuilder;
  final int rows;
  final double rowGap;
  final double columnGap;

  const PickerMonthGrid({
    super.key,
    required this.dates,
    required this.cellBuilder,
    this.rows = pickerRows,
    this.rowGap = pickerCellGap,
    this.columnGap = pickerCellGap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) SizedBox(height: rowGap),
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < pickerColumns; col++) ...[
                  if (col > 0 && columnGap > 0) SizedBox(width: columnGap),
                  Expanded(child: _cell(dates[row * pickerColumns + col])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _cell(NepaliDateTime? date) =>
      date == null ? const SizedBox.shrink() : cellBuilder(date);
}

/// How many weeks [month] spans in its grid: usually five, sometimes six,
/// rarely four.
int pickerWeeksIn(NepaliDateTime month, WeekStartType weekStart) {
  final length = CalendarUtils.nepaliYears[month.year]![month.month];
  return (_leadingCells(month, weekStart) + length - 1) ~/ pickerColumns + 1;
}

/// Weekday labels above a grid.
class PickerWeekdayRow extends StatelessWidget {
  final NepaliCalendarStyle style;

  const PickerWeekdayRow({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;
    final headerStyle = style.headersStyle.weekHeaderStyle;

    return Row(
      children: pickerWeekdayOrder(config.weekStartType).map((weekday) {
        final isWeekend = WeekUtils.isWeekend(weekday, config.weekendType);
        return Expanded(
          child: Center(
            child: Text(
              WeekUtils.formattedWeekDay(
                weekday,
                config.language,
                config.weekTitleType,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: headerStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? style.cellsStyle.weekDayColor
                    : headerStyle.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Labels
// ---------------------------------------------------------------------------

/// [date] in the Gregorian calendar: "02 Oct 2026".
///
/// Always written in English: it is the Gregorian date, and the format
/// matches what users see on their other devices.
String pickerAdLabel(NepaliDateTime date) {
  final ad = date.toDateTime();
  final day = ad.day.toString().padLeft(2, '0');
  return '$day ${MonthUtils.englishMonthsShort[ad.month - 1]} ${ad.year}';
}

/// A Gregorian range, without repeating what the ends share:
/// "02 – 15 Oct 2026", "28 Sep – 03 Oct 2026", "28 Dec 2026 – 03 Jan 2027".
String pickerAdRangeLabel(NepaliDateTime start, NepaliDateTime end) {
  final a = start.toDateTime();
  final b = end.toDateTime();
  String day(DateTime d) => d.day.toString().padLeft(2, '0');
  String month(DateTime d) => MonthUtils.englishMonthsShort[d.month - 1];

  if (a.year != b.year) {
    return '${pickerAdLabel(start)} – ${pickerAdLabel(end)}';
  }
  if (a.month != b.month) {
    return '${day(a)} ${month(a)} – ${day(b)} ${month(b)} ${b.year}';
  }
  if (a.day != b.day) return '${day(a)} – ${day(b)} ${month(b)} ${b.year}';
  return pickerAdLabel(end);
}

/// "Baisakh 15, 2081" / "बैशाख १५, २०८१".
String pickerBsLabel(NepaliDateTime date, Language language) {
  String number(int n) =>
      NepaliNumberConverter.formattedNumber('$n', language: language);
  return '${MonthUtils.formattedMonth(date.month, language)} '
      '${number(date.day)}, ${number(date.year)}';
}

/// The ambient [MaterialLocalizations], or null outside a [MaterialApp].
///
/// Looked up rather than required: the pickers are usable under a bare
/// [WidgetsApp], and `MaterialLocalizations.of` would throw there.
MaterialLocalizations? pickerMaterialLocalizations(BuildContext context) =>
    Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
