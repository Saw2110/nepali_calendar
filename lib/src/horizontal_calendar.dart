// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../nepali_calendar_plus.dart';

/// Base height of the scrolling date strip at a text scale of 1.0.
///
/// Sized for Devanagari, which is noticeably taller than Latin at the same
/// font size -- 56 is enough for "Sun / 12" but clips "आइत / १२".
const double _dateStripBaseHeight = 64.0;
const double _dateStripBaseWidth = 64.0;

class HorizontalNepaliCalendar extends StatefulWidget {
  const HorizontalNepaliCalendar({
    super.key,
    this.initialDate,
    @Deprecated(
      'This parameter has never had any effect. Use '
      'calendarStyle.cellsStyle instead. Will be removed in 1.0.0.',
    )
    this.textColor,
    this.backgroundColor,
    @Deprecated(
      'This parameter has never had any effect. Use '
      'calendarStyle.cellsStyle.selectedColor instead. Will be removed in 1.0.0.',
    )
    this.selectedColor,
    this.showMonth = true,
    required this.onDateSelected,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.headerBuilder,
  });

  final NepaliDateTime? initialDate;

  /// Colour for the date text.
  ///
  /// **This parameter has never been read.** It was accepted by the
  /// constructor in every version up to 0.0.7 but never applied, so passing it
  /// had no effect. It is deprecated rather than wired up, because making a
  /// long-dead parameter suddenly take effect would visibly change the
  /// appearance of apps that pass it.
  ///
  /// Use `calendarStyle.cellsStyle` instead.
  @Deprecated(
    'This parameter has never had any effect. Use calendarStyle.cellsStyle '
    'instead. Will be removed in 1.0.0.',
  )
  final Color? textColor;

  /// Background colour behind the whole strip. This one does take effect.
  final Color? backgroundColor;

  /// Colour for the selected date.
  ///
  /// **This parameter has never been read.** See [textColor] for why it is
  /// deprecated rather than fixed. Use
  /// `calendarStyle.cellsStyle.selectedColor` instead.
  @Deprecated(
    'This parameter has never had any effect. Use '
    'calendarStyle.cellsStyle.selectedColor instead. Will be removed in 1.0.0.',
  )
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

  /// The style to render with, resolved in [build] against any ambient
  /// [NepaliCalendarTheme]. Held as a field because the colour helpers below
  /// have no [BuildContext] of their own.
  NepaliCalendarStyle _style = const NepaliCalendarStyle();

  @override
  void initState() {
    super.initState();
    _todayDate = NepaliDateTime.now();
    _selectedDate = widget.initialDate ?? _todayDate;
    _startDate = _selectedDate.subtract(Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > pre-0.1.0 defaults.
    _style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);

    // Scale with the user's text size preference so the strip does not clip
    // for anyone relying on larger system text.
    final stripHeight =
        MediaQuery.textScalerOf(context).scale(_dateStripBaseHeight);
    // The widget sizes itself to its content. Up to 0.0.7 it was pinned to 8%
    // of the viewport height, which on a phone left too little room for the
    // month title and the date strip together: the strip was painted outside
    // the fixed box, and because Flutter does not hit-test children painted
    // outside their parent's bounds, taps were silently swallowed.
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showMonth)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: widget.headerBuilder?.call(_todayDate, _selectedDate) ??
                  _buildMonthTitle(),
            ),
          SizedBox(
            height: stripHeight,
            child: _buildDateList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTitle() {
    final month = MonthUtils.formattedMonth(
      _selectedDate.month,
      _style.effectiveConfig.language,
    );
    final year = _style.effectiveConfig.language == Language.english
        ? "${_selectedDate.year}"
        : NepaliNumberConverter.englishToNepali(
            _selectedDate.year.toString(),
          );

    ///
    return Text(
      "$year, $month",
      textAlign: TextAlign.start,
      style: _style.headersStyle.monthHeaderStyle,
    );
  }

  Widget _buildDateList() {
    return ListView.builder(
      itemCount: 7,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final date = _startDate.add(Duration(days: index));

        // Check if the date is today
        final bool isToday = _isSameDay(date, _todayDate);
        final bool isSelected = _isSameDay(date, _selectedDate);

        return CalendarItem(
          date: date,
          textColor: _getCellTextColor(isToday, isSelected, date.weekday),
          backgroundColor: _getCellColor(isToday, isSelected, date.weekday),
          style: _style,
          onDatePressed: () => _handleDateSelection(date),
        );
      },
    );
  }

  void _handleDateSelection(NepaliDateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _startDate = _selectedDate.subtract(Duration(days: 2));
    });

    widget.onDateSelected(selectedDate);
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
      return _style.cellsStyle.todayColor;
    }
    if (isToday && isWeekend) {
      return _style.cellsStyle.weekDayColor;
    }
    if (isSelected && !isWeekend) {
      return _style.cellsStyle.selectedColor.withValues(alpha: 0.2);
    }
    if (isSelected && isWeekend) {
      return _style.cellsStyle.weekDayColor.withValues(alpha: 0.2);
    }

    return Colors.transparent; // Default case
  }

// Method to get the cell text color based on today, selected state, and weekday
  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    final isWeekend = _isWeekend(weekday);

    // Today sits on a filled highlight, so use the on-highlight colour.
    if (isToday) return _style.cellsStyle.onHighlightColor;
    if (isSelected && !isWeekend) {
      return _style.cellsStyle.selectedColor;
    }
    if (isSelected && isWeekend) {
      return _style.cellsStyle.weekDayColor;
    }
    if (isWeekend) return _style.cellsStyle.weekDayColor;
    return _style.cellsStyle.dateTextColor;
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int weekday) {
    return WeekUtils.isWeekend(
      weekday,
      _style.effectiveConfig.weekendType,
    );
  }
}

/// One date in [HorizontalNepaliCalendar]'s strip.
///
/// **Deprecated:** this was never intended as public API; it became so because
/// the package exported every internal file. It will be removed in 1.0.0. If
/// you depend on it, please open an issue describing your use case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
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
    return InkWell(
      onTap: onDatePressed,
      child: Container(
        width: _dateStripBaseWidth,
        color: backgroundColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the weekday name
            Text(
              WeekUtils.formattedWeekDay(
                date.weekday,
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
