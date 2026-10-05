import 'package:flutter/material.dart';

import '../date_picker/internal/picker_shared.dart';
import '../src.dart';

/// Custom designs for the parts of [NepaliDatePicker] and
/// [NepaliDateRangePicker].
///
/// Each builder receives a data object describing one part and returns the
/// widget to show for it. The picker keeps doing the work -- dates, bounds,
/// selection, paging, confirming -- and hands over callbacks for the custom
/// widget to call. A builder that returns null, or is not set, keeps the
/// default design for that part, so a design can restyle only some days:
///
/// ```dart
/// showNepaliDatePicker(
///   context: context,
///   pickerBuilder: DatePickerBuilder(
///     dayBuilder: (day) {
///       if (!day.isSelected) return null; // the default for every other day
///       return GestureDetector(
///         onTap: day.onTap,
///         child: CircleAvatar(child: Text('${day.date.day}')),
///       );
///     },
///   ),
/// );
/// ```
///
/// A custom widget is laid out in the same fixed slot as the default one --
/// the picker does not measure it -- so a design has to fit its slot. That
/// is what keeps the grid fixed, without scrolling or jumping.
@immutable
class DatePickerBuilder {
  /// A date in the grid.
  ///
  /// Fills one cell, about 42dp square. Call [PickerDayData.onTap] to select
  /// the date; it is null for a date that cannot be picked. The picker keeps
  /// its own screen-reader label around the cell, so a custom design stays
  /// accessible without extra work.
  ///
  /// In the range picker, a custom day draws its own range band, using
  /// [PickerDayData.rangePosition]; the default band is not drawn under it.
  final Widget? Function(PickerDayData data)? dayBuilder;

  /// A weekday name above the grid, in a row about 20dp high.
  final Widget? Function(PickerWeekdayData data)? weekdayBuilder;

  /// The coloured band at the top of the date picker, about 96dp high: the
  /// selected date in BS and AD. On a screen too short for it on
  /// top it sits beside the grid instead, about 168dp wide; see
  /// [PickerTitleData.isBesideGrid]. Not used by the range picker.
  final Widget? Function(PickerTitleData data)? titleBuilder;

  /// The navigation row above the grid, about 44dp high: the month and year
  /// on show and the arrows that step them.
  ///
  /// Used by the date picker, and by the range picker's two-month layout.
  /// The range picker's phone layout has no header: its months scroll.
  final Widget? Function(PickerHeaderData data)? headerBuilder;

  /// The bar with the actions.
  ///
  /// Below the grid in the date picker -- Today, Close, and OK unless a tap
  /// confirms, in a 44dp row -- and in the range picker's two-month layout.
  /// In the range picker's phone layout this is the bar at the top -- close,
  /// the range picked so far, and Save -- which plays the same role.
  final Widget? Function(PickerFooterData data)? footerBuilder;

  /// A month or a year in the date picker's month and year views, a tile
  /// about 40dp high.
  final Widget? Function(PickerChoiceData data)? choiceBuilder;

  const DatePickerBuilder({
    this.dayBuilder,
    this.weekdayBuilder,
    this.titleBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.choiceBuilder,
  });

  /// A copy with the given builders replaced.
  DatePickerBuilder copyWith({
    Widget? Function(PickerDayData data)? dayBuilder,
    Widget? Function(PickerWeekdayData data)? weekdayBuilder,
    Widget? Function(PickerTitleData data)? titleBuilder,
    Widget? Function(PickerHeaderData data)? headerBuilder,
    Widget? Function(PickerFooterData data)? footerBuilder,
    Widget? Function(PickerChoiceData data)? choiceBuilder,
  }) {
    return DatePickerBuilder(
      dayBuilder: dayBuilder ?? this.dayBuilder,
      weekdayBuilder: weekdayBuilder ?? this.weekdayBuilder,
      titleBuilder: titleBuilder ?? this.titleBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      choiceBuilder: choiceBuilder ?? this.choiceBuilder,
    );
  }
}

/// Where a date sits in the range picker's selection.
enum PickerRangePosition {
  /// Not in the range; always this in the date picker.
  none,

  /// The first day of a range longer than one day.
  start,

  /// Strictly between the ends.
  middle,

  /// The last day of a range longer than one day.
  end,

  /// The only day: a start with no end yet, or a one-day range.
  single,
}

/// One date of the grid, for [DatePickerBuilder.dayBuilder].
@immutable
class PickerDayData {
  final NepaliDateTime date;
  final bool isToday;

  /// The picked date, or -- in the range picker -- either end of the range.
  final bool isSelected;

  /// Outside the selectable range ([NepaliDatePicker.minDate] /
  /// [NepaliDatePicker.maxDate], or past a range picker's `maxDays`).
  final bool isDisabled;

  /// A day of the month before or after the one on show. The date picker
  /// shows these dimmed and inert; the range picker leaves them blank and
  /// never asks for them.
  final bool isOtherMonth;

  final bool isWeekend;

  /// Where the date sits in the range picker's selection.
  final PickerRangePosition rangePosition;

  /// Selects the date, with the configured haptic feedback. Null when the
  /// date cannot be picked.
  final VoidCallback? onTap;

  /// The resolved style: colours from the ambient [NepaliCalendarTheme] or an
  /// explicit style.
  final NepaliCalendarStyle style;

  final Language language;

  const PickerDayData({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isDisabled,
    required this.isOtherMonth,
    required this.isWeekend,
    required this.rangePosition,
    required this.onTap,
    required this.style,
    required this.language,
  });

  /// Strictly inside the range picker's range, between its ends.
  bool get isInRange => rangePosition == PickerRangePosition.middle;

  /// The day number in the picker's language: `15` or `१५`.
  String get label =>
      NepaliNumberConverter.formattedNumber('${date.day}', language: language);
}

/// One weekday name above the grid, for [DatePickerBuilder.weekdayBuilder].
@immutable
class PickerWeekdayData {
  /// 0 for Sunday through 6 for Saturday.
  final int weekday;

  /// The name as the picker would write it, following its `weekdayFormat`:
  /// `आ`, `आइत` or `आइतबार`.
  final String label;

  final bool isWeekend;
  final NepaliCalendarStyle style;
  final Language language;

  const PickerWeekdayData({
    required this.weekday,
    required this.label,
    required this.isWeekend,
    required this.style,
    required this.language,
  });
}

/// The date picker's title band, for [DatePickerBuilder.titleBuilder].
@immutable
class PickerTitleData {
  /// The date picked so far.
  final NepaliDateTime selected;

  /// Jumps to and selects today -- confirming it too when a tap confirms.
  /// Null when today is out of range. The default band leaves Today to the
  /// action row; a custom band may offer it too.
  final VoidCallback? onToday;

  /// Whether the band sits beside the grid -- a tall, narrow slot -- rather
  /// than above it. The picker does this on a screen too short for the band
  /// on top, such as a phone in landscape.
  final bool isBesideGrid;

  final NepaliCalendarStyle style;
  final Language language;

  const PickerTitleData({
    required this.selected,
    required this.onToday,
    this.isBesideGrid = false,
    required this.style,
    required this.language,
  });

  /// The year in the picker's language: `2083` or `२०८३`.
  String get yearLabel => NepaliNumberConverter.formattedNumber(
        '${selected.year}',
        language: language,
      );

  /// Weekday, month and day: `Mon, Ashoj 19` or `सोम, असोज १९`.
  String get dateLabel {
    final weekday = WeekUtils.formattedWeekDay(
      selected.weekday,
      language,
      TitleFormat.half,
    );
    final month = MonthUtils.formattedMonth(selected.month, language);
    final day = NepaliNumberConverter.formattedNumber(
      '${selected.day}',
      language: language,
    );
    return '$weekday, $month $day';
  }

  /// The same date in the Gregorian calendar, always in English:
  /// `05 Oct 2026`.
  String get adLabel => pickerAdLabel(selected);
}

/// The navigation row above the grid, for [DatePickerBuilder.headerBuilder].
@immutable
class PickerHeaderData {
  /// The month on show: its 1st. In the range picker's two-month layout,
  /// the left-hand month.
  final NepaliDateTime month;

  /// The right-hand month of the range picker's two-month layout; null in
  /// the date picker.
  final NepaliDateTime? secondMonth;

  /// Which view the date picker shows. Always [NepaliDatePickerMode.day] in
  /// the range picker.
  final NepaliDatePickerMode mode;

  /// Steps back: a month in the day view, a year in the month view, a
  /// screenful in the year view. Null at the start of the range.
  final VoidCallback? onPrevious;

  /// Steps forward, as [onPrevious]. Null at the end of the range.
  final VoidCallback? onNext;

  /// Steps back a year -- a screenful of the list in the year view. Null at
  /// the start of the range, and in the range picker.
  final VoidCallback? onPreviousYear;

  /// Steps forward, as [onPreviousYear]. Null at the end of the range, and in
  /// the range picker.
  final VoidCallback? onNextYear;

  /// Opens the month view, or returns to the days if it is open. Null in the
  /// range picker.
  final VoidCallback? onMonthTap;

  /// Opens the year view, or returns to the days if it is open. Null in the
  /// range picker.
  final VoidCallback? onYearTap;

  final NepaliCalendarStyle style;
  final Language language;

  const PickerHeaderData({
    required this.month,
    this.secondMonth,
    required this.mode,
    required this.onPrevious,
    required this.onNext,
    this.onPreviousYear,
    this.onNextYear,
    this.onMonthTap,
    this.onYearTap,
    required this.style,
    required this.language,
  });

  /// The month's name in the picker's language: `Ashoj` or `असोज`.
  String get monthLabel => MonthUtils.formattedMonth(month.month, language);

  /// The year in the picker's language: `2083` or `२०८३`.
  String get yearLabel => NepaliNumberConverter.formattedNumber(
        '${month.year}',
        language: language,
      );
}

/// The result and the actions, for [DatePickerBuilder.footerBuilder].
@immutable
class PickerFooterData {
  /// The date picked so far in the date picker; null in the range picker.
  final NepaliDateTime? selected;

  /// The range picker's finished range; null until both ends are set, and in
  /// the date picker.
  final NepaliDateTimeRange? range;

  /// The range picker's start, set as soon as it is picked; null in the date
  /// picker.
  final NepaliDateTime? rangeStart;

  /// Jumps to and selects today. Null when today is out of range, and in the
  /// range picker.
  final VoidCallback? onToday;

  /// Confirms the selection. Null when there is nothing to confirm yet --
  /// and in the date picker when a tap already confirms (`autoConfirm`).
  final VoidCallback? onConfirm;

  /// Closes without picking. Always set: both pickers can always be closed.
  final VoidCallback? onCancel;

  final NepaliCalendarStyle style;
  final Language language;

  const PickerFooterData({
    this.selected,
    this.range,
    this.rangeStart,
    required this.onToday,
    required this.onConfirm,
    required this.onCancel,
    required this.style,
    required this.language,
  });
}

/// A month or a year in the date picker's month and year views, for
/// [DatePickerBuilder.choiceBuilder].
@immutable
class PickerChoiceData {
  /// The month (1-12) or the year this tile picks.
  final int value;

  /// Whether this is a year rather than a month.
  final bool isYear;

  /// The month's name or the year, in the picker's language.
  final String label;

  /// The month or year currently on show.
  final bool isSelected;

  /// No day of it is selectable.
  final bool isDisabled;

  /// Picks it. Null when [isDisabled].
  final VoidCallback? onTap;

  final NepaliCalendarStyle style;
  final Language language;

  const PickerChoiceData({
    required this.value,
    required this.isYear,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    required this.style,
    required this.language,
  });
}
