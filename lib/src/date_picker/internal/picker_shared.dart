// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide it.
// ignore_for_file: avoid_redundant_argument_values

/// Pieces shared by [NepaliDatePicker] and [NepaliDateRangePicker].
///
/// Internal: nothing here is exported from the package. The names are public
/// only because Dart privacy is per file, and two picker files need them.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../src.dart';
import '../../utils/calendar_layout.dart';

/// Columns in a month grid: one per weekday.
const int pickerColumns = 7;

/// Rows in a month grid.
///
/// Always six: a month can span six weeks.
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

/// Horizontal padding inside both pickers.
const double pickerGutter = 12.0;

/// Minimum touch target for the pickers' header arrows.
const double pickerNavButtonSize = 44.0;

/// From this width up, the range picker shows two months side by side; below
/// it, every month in one vertical list. Material's range picker switches at
/// the same width.
const double pickerWideBreakpoint = 600.0;

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
    const years = CalendarUtils.nepaliYears;
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

  /// The 1st of the month [delta] months after [month], or null if none of
  /// that month is selectable.
  NepaliDateTime? monthOffset(NepaliDateTime month, int delta) {
    final (year, m) = shiftMonth(month.year, month.month, delta);
    if (!containsAnyOf(year, m)) return null;
    return NepaliDateTime(year: year, month: m, day: 1);
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

/// How many cells come before the 1st of [month] in its grid.
int _leadingCells(NepaliDateTime month, WeekStartType weekStart) =>
    WeekUtils.normalizeWeekday(
      NepaliDateTime(year: month.year, month: month.month, day: 1).weekday,
      weekStart,
    );

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
  const years = CalendarUtils.nepaliYears;
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
/// Rows and columns, not a GridView. A GridView only builds the rows its
/// viewport covers -- a row that does not fit is not clipped, it does not
/// exist, so the month's last days can vanish -- and it scrolls when rounding
/// leaves it a fraction short. Here every row is always built and the rows
/// share out exactly the height on offer, so the grid never scrolls.
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

/// Weekday labels above a grid.
class PickerWeekdayRow extends StatelessWidget {
  final NepaliCalendarStyle style;

  /// Null for initials; otherwise the longer form. See
  /// [NepaliDatePicker.weekdayFormat].
  final TitleFormat? format;

  /// Custom designs; its [DatePickerBuilder.weekdayBuilder] draws the labels.
  final DatePickerBuilder? builder;

  const PickerWeekdayRow({
    super.key,
    required this.style,
    this.format,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;
    final headerStyle = style.headersStyle.weekHeaderStyle;

    return Row(
      children: weekdayOrder(config.weekStartType).map((weekday) {
        final isWeekend = WeekUtils.isWeekend(weekday, config.weekendType);
        final label = format == null
            ? WeekUtils.formattedShortWeekDay(weekday, config.language)
            : WeekUtils.formattedWeekDay(weekday, config.language, format!);
        final custom = builder?.weekdayBuilder?.call(
          PickerWeekdayData(
            weekday: weekday,
            label: label,
            isWeekend: isWeekend,
            style: style,
            language: config.language,
          ),
        );
        if (custom != null) return Expanded(child: custom);

        return Expanded(
          child: Center(
            // Scaled down rather than cut off when a long name is wider than
            // its column; initials always fit and are never scaled.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
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

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

/// A day's number on its square: filled for a selection, ringed for today.
///
/// Both pickers' day cells draw this; the cell around it decides the tap,
/// the semantics and, in the range picker, the band behind it.
class PickerDaySquare extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDateTime date;

  /// Painted in the selection colour: the selected date, or a range end.
  final bool filled;
  final bool isToday;

  /// Outside the selectable range: drawn faintly.
  final bool isDisabled;

  /// A neighbouring month's day: drawn fainter still than [isDisabled], so
  /// "not this month" and "not allowed" stay tellable apart.
  final bool isDimmed;

  const PickerDaySquare({
    super.key,
    required this.style,
    required this.date,
    required this.filled,
    required this.isToday,
    required this.isDisabled,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final cells = style.cellsStyle;
    final config = style.effectiveConfig;
    final isWeekend = WeekUtils.isWeekend(date.weekday, config.weekendType);

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: filled ? cells.selectedColor : null,
            borderRadius: BorderRadius.circular(pickerRadius),
            border: isToday && !filled
                ? Border.all(color: cells.todayColor, width: 1.5)
                : null,
          ),
          child: Center(
            child: FittedBox(
              // Devanagari digits run wider than Latin at the same size.
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  NepaliNumberConverter.formattedNumber(
                    '${date.day}',
                    language: config.language,
                  ),
                  style: cells.dayStyle.copyWith(
                    fontSize: 14,
                    fontWeight:
                        filled || isToday ? FontWeight.w700 : FontWeight.w500,
                    color: _foreground(cells, isWeekend),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _foreground(CellStyle cells, bool isWeekend) {
    if (filled) return cells.onHighlightColor;
    if (isDimmed) return cells.dimmedDateTextColor.withValues(alpha: 0.4);
    if (isDisabled) {
      return (isWeekend ? cells.weekDayColor : cells.dateTextColor)
          .withValues(alpha: 0.3);
    }
    if (isToday) return cells.todayColor;
    if (isWeekend) return cells.weekDayColor;
    return cells.dateTextColor;
  }
}

/// A day cell's tap: the configured haptic, then [onTap]. Null when the cell
/// is inert, so it neither responds nor ripples.
VoidCallback? pickerDayTap(
  CalendarConfig config,
  VoidCallback onTap, {
  required bool enabled,
}) {
  if (!enabled) return null;
  return () {
    config.hapticFeedback.perform();
    onTap();
  };
}

/// A picker header arrow. A null [onPressed] shows it disabled rather than
/// hiding it, so the header does not reflow at the ends of the range.
class PickerNavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const PickerNavButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: pickerNavButtonSize,
        minHeight: pickerNavButtonSize,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// A picker footer: a divider, then [text] on the left and [actions] on the
/// right.
class PickerFooter extends StatelessWidget {
  final String text;
  final List<Widget> actions;

  const PickerFooter({super.key, required this.text, required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
          indent: pickerGutter,
          endIndent: pickerGutter,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: pickerGutter, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Space [showPickerDialog] keeps between its dialog and the screen edges.
///
/// AlertDialog's default 40dp side insets leave a small phone too little room
/// for the grid; only the position is nudged.
const EdgeInsets pickerDialogInsets =
    EdgeInsets.symmetric(horizontal: 16, vertical: 24);

/// Shows [builder]'s picker in a plain [AlertDialog].
///
/// No background colour or elevation of its own, so it looks like the app's
/// other alerts. The shape is the one exception -- Material 3's default 28dp
/// radius made a compact picker look like a bubble -- and it still defers to
/// a `dialogTheme` shape.
///
/// [contentPadding] defaults to a little space above and below the picker; a
/// picker whose top is a coloured band passes zero, and the dialog clips the
/// band to its rounded corners.
Future<T?> showPickerDialog<T>({
  required BuildContext context,
  required double preferredWidth,
  required bool barrierDismissible,
  required Color? barrierColor,
  required WidgetBuilder builder,
  EdgeInsets contentPadding = const EdgeInsets.only(top: 8, bottom: 4),
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    builder: (context) => AlertDialog(
      shape: DialogTheme.of(context).shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pickerDialogRadius),
          ),
      contentPadding: contentPadding,
      clipBehavior: Clip.antiAlias,
      insetPadding: pickerDialogInsets,
      // A tight width, on purpose: AlertDialog measures its content's
      // intrinsic width, which the pickers' LayoutBuilder cannot report.
      content: SizedBox(
        width: math.min(
          preferredWidth,
          MediaQuery.sizeOf(context).width - pickerDialogInsets.horizontal,
        ),
        child: Builder(builder: builder),
      ),
    ),
  );
}
