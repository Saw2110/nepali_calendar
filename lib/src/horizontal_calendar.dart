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
    CalendarTheme? theme,
    @Deprecated('Use theme instead') CalendarTheme? calendarStyle,
    this.headerBuilder,
    this.visibleDays = 7,
    this.height,
  }) : theme = theme ?? calendarStyle ?? const CalendarTheme.defaults();

  final NepaliDateTime? initialDate;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? selectedColor;
  final bool showMonth;
  final OnDateSelected onDateSelected;

  /// Number of visible days in the horizontal calendar.
  /// Default is 7.
  final int visibleDays;

  /// Custom height for the calendar.
  /// If null, uses theme.cellTheme.cellHeight * 2 + spacing.
  final double? height;

  /// @Deprecated: Use theme instead
  @Deprecated(
    'Use theme instead. This will be removed in the next major version.',
  )
  CalendarTheme get calendarStyle => theme;

  /// Theme configuration for the calendar.
  final CalendarTheme theme;
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
    // Center the selected date in the visible range
    _startDate =
        _selectedDate.subtract(Duration(days: widget.visibleDays ~/ 2));
  }

  /// Calculates the calendar height based on theme settings.
  double _calculateHeight() {
    if (widget.height != null) return widget.height!;

    final cellTheme = widget.theme.cellTheme;
    final spacing = widget.theme.spacing;

    // Height = cell height + weekday label height + spacing + header (if shown)
    double height = cellTheme.cellHeight + 20; // cell + weekday label
    if (widget.showMonth) {
      height += widget.theme.headerTheme.headerHeight / 2;
    }
    return height + spacing.headerToWeekdaysSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    // Use explicit backgroundColor > colorScheme.surface > transparent
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final spacing = theme.spacing;
    final borders = theme.borders;

    // Build container decoration with border support
    final decoration = BoxDecoration(
      color: bgColor,
      border: borders.calendarBorder,
      borderRadius: borders.calendarBorderRadius,
    );

    return AnimatedContainer(
      duration: theme.animations.monthTransitionDuration,
      curve: theme.animations.monthTransitionCurve,
      height: _calculateHeight(),
      padding: spacing.calendarPadding,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showMonth)
            widget.headerBuilder?.call(_todayDate, _selectedDate) ??
                _buildMonthTitle(),
          SizedBox(height: spacing.headerToWeekdaysSpacing),
          Expanded(child: _buildDateList()),
        ],
      ),
    );
  }

  Widget _buildMonthTitle() {
    final month = MonthUtils.formattedMonth(
      _selectedDate.month,
      widget.theme.locale,
    );
    final year = widget.theme.locale == CalendarLocale.english
        ? "${_selectedDate.year}"
        : NepaliNumberConverter.englishToNepali(
            _selectedDate.year.toString(),
          );

    return Text(
      "$year, $month",
      textAlign: TextAlign.start,
      style: widget.theme.headerTheme.monthTextStyle,
    );
  }

  Widget _buildDateList() {
    final cellTheme = widget.theme.cellTheme;

    return ListView.builder(
      itemCount: widget.visibleDays,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final date = _startDate.add(Duration(days: index));

        // Check if the date is today
        final bool isToday = _isSameDay(date, _todayDate);
        final bool isSelected = _isSameDay(date, _selectedDate);

        return Padding(
          padding: cellTheme.cellMargin,
          child: CalendarItem(
            date: date,
            textColor: _getCellTextColor(isToday, isSelected, date.weekday),
            backgroundColor: _getCellColor(isToday, isSelected, date.weekday),
            style: widget.theme,
            onDatePressed: () => _handleDateSelection(date),
          ),
        );
      },
    );
  }

  void _handleDateSelection(NepaliDateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      widget.onDateSelected(selectedDate);
      // Center the selected date in the visible range
      _startDate =
          _selectedDate.subtract(Duration(days: widget.visibleDays ~/ 2));
    });
  }

  /// Method to check if two dates are the same (without considering time)
  bool _isSameDay(NepaliDateTime date1, NepaliDateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Gets the cell background color using ColorScheme as Single Source of Truth.
  ///
  /// Priority: Explicit CellTheme property > ColorScheme > Default
  Color _getCellColor(bool isToday, bool isSelected, int weekday) {
    final theme = widget.theme;
    final isWeekend = weekday == 7;

    if (isToday && !isWeekend) {
      return theme.resolvedTodayBackgroundColor;
    }
    if (isToday && isWeekend) {
      return theme.resolvedWeekendTextColor;
    }
    if (isSelected && !isWeekend) {
      return theme.resolvedSelectionColor.withValues(alpha: 0.2);
    }
    if (isSelected && isWeekend) {
      return theme.resolvedWeekendTextColor.withValues(alpha: 0.2);
    }

    return Colors.transparent;
  }

  /// Gets the cell text color using ColorScheme as Single Source of Truth.
  ///
  /// Priority: Explicit CellTheme property > ColorScheme > Default
  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    final theme = widget.theme;
    final isWeekend = weekday == 7;

    if (isToday) {
      return theme.resolvedTodayTextColor;
    }
    if (isSelected && !isWeekend) {
      return theme.resolvedSelectionTextColor;
    }
    if (isSelected && isWeekend) {
      return theme.resolvedWeekendTextColor;
    }
    if (isWeekend) {
      return theme.resolvedWeekendTextColor;
    }
    return theme.resolvedDefaultTextColor;
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
  final CalendarTheme style;

  @override
  Widget build(BuildContext context) {
    final cellTheme = style.cellTheme;
    final weekdayTheme = style.weekdayTheme;

    // Adjust the weekday value to match the expected range (0-6)
    final adjustedWeekday = (date.weekday - 1) % 7;

    // Build cell decoration based on shape and borders
    BoxDecoration decoration = BoxDecoration(
      color: backgroundColor,
      border: cellTheme.showBorder ? cellTheme.cellBorder : null,
    );

    // Apply shape-based border radius
    if (cellTheme.shape == CellShape.circle) {
      decoration = decoration.copyWith(shape: BoxShape.circle);
    } else if (cellTheme.shape == CellShape.roundedSquare) {
      decoration = decoration.copyWith(
        borderRadius: BorderRadius.circular(cellTheme.borderRadius),
      );
    }

    return InkWell(
      onTap: onDatePressed,
      borderRadius: cellTheme.shape == CellShape.circle
          ? BorderRadius.circular(cellTheme.cellWidth / 2)
          : cellTheme.shape == CellShape.roundedSquare
              ? BorderRadius.circular(cellTheme.borderRadius)
              : null,
      child: Container(
        width: cellTheme.cellWidth,
        height: cellTheme.cellHeight,
        decoration: decoration,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the weekday name
            Text(
              WeekUtils.formattedWeekDay(
                adjustedWeekday,
                style.locale,
                weekdayTheme.format,
              ),
              style: (weekdayTheme.textStyle ??
                      const TextStyle(fontWeight: FontWeight.bold))
                  .copyWith(
                color: textColor,
                fontWeight: FontWeight.normal,
                fontSize: 11.0,
              ),
            ),
            // Display the day of the month
            Text(
              style.locale == CalendarLocale.english
                  ? "${date.day}"
                  : NepaliNumberConverter.englishToNepali(date.day.toString()),
              style: cellTheme.defaultTextStyle.copyWith(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
