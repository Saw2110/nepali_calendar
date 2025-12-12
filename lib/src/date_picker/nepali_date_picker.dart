import 'package:flutter/material.dart';

import '../src.dart';

/// A callback type for determining if a Nepali day is selectable.
typedef NepaliSelectableDayPredicate = bool Function(NepaliDateTime day);

/// Nepali Date Picker Widget for inline usage.
///
/// This widget provides a calendar-based date picker for selecting
/// Nepali dates. It can be used inline within your UI or as part
/// of a dialog.
///
/// Example usage:
/// ```dart
/// NepaliDatePicker(
///   initialDate: NepaliDateTime.now(),
///   firstDate: NepaliDateTime(year: 2070),
///   lastDate: NepaliDateTime(year: 2090),
///   onDateChanged: (date) {
///     print('Selected: $date');
///   },
///   weekStart: WeekStart.sunday,  // Week starts from Sunday
///   weekend: Weekend.saturday,     // Saturday is the weekend
/// )
/// ```
class NepaliDatePicker extends StatefulWidget {
  /// The initially selected date.
  final NepaliDateTime initialDate;

  /// The earliest selectable date.
  final NepaliDateTime firstDate;

  /// The latest selectable date.
  final NepaliDateTime lastDate;

  /// Called when the user selects a date.
  final ValueChanged<NepaliDateTime> onDateChanged;

  /// Theme configuration for the picker.
  final CalendarTheme? theme;

  /// A predicate to determine if a day is selectable.
  ///
  /// If provided, only days for which this returns true can be selected.
  final NepaliSelectableDayPredicate? selectableDayPredicate;

  /// Specifies which day the week starts on.
  ///
  /// Defaults to [WeekStart.sunday] (common in Nepal).
  /// Use [WeekStart.monday] for ISO 8601 standard or European convention.
  /// Use [WeekStart.saturday] for some Middle Eastern countries.
  final WeekStart weekStart;

  /// Specifies which days are considered weekends.
  ///
  /// Defaults to [Weekend.saturday] (common in Nepal).
  /// Use [Weekend.saturdayAndSunday] for Western countries.
  /// Use [Weekend.fridayAndSaturday] for some Middle Eastern countries.
  final Weekend weekend;

  /// Creates a Nepali date picker widget.
  const NepaliDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.theme,
    this.selectableDayPredicate,
    this.weekStart = WeekStart.sunday,
    this.weekend = Weekend.saturday,
  });

  @override
  State<NepaliDatePicker> createState() => _NepaliDatePickerState();
}

class _NepaliDatePickerState extends State<NepaliDatePicker> {
  late NepaliDateTime _selectedDate;
  late NepaliDateTime _displayedMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = NepaliDateTime(
      year: widget.initialDate.year,
      month: widget.initialDate.month,
    );
    _initPageController();
  }

  void _initPageController() {
    final initialPage = _getPageIndex(_displayedMonth);
    _pageController = PageController(initialPage: initialPage);
  }

  int _getPageIndex(NepaliDateTime date) {
    return ((date.year - widget.firstDate.year) * 12) +
        (date.month - widget.firstDate.month);
  }

  NepaliDateTime _getDateFromPageIndex(int index) {
    final totalMonths =
        (widget.firstDate.year * 12) + widget.firstDate.month - 1 + index;
    final year = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    return NepaliDateTime(year: year, month: month);
  }

  int get _totalPages {
    return ((widget.lastDate.year - widget.firstDate.year) * 12) +
        (widget.lastDate.month - widget.firstDate.month) +
        1;
  }

  void _handleDaySelected(NepaliDateTime date) {
    if (!_isDateSelectable(date)) return;

    setState(() {
      _selectedDate = date;
    });
    widget.onDateChanged(date);
  }

  bool _isDateSelectable(NepaliDateTime date) {
    // Check if date is within bounds
    if (_compareDates(date, widget.firstDate) < 0) return false;
    if (_compareDates(date, widget.lastDate) > 0) return false;

    // Check custom predicate
    if (widget.selectableDayPredicate != null) {
      return widget.selectableDayPredicate!(date);
    }

    return true;
  }

  int _compareDates(NepaliDateTime a, NepaliDateTime b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  void _goToPreviousMonth() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextMonth() {
    if (_pageController.page! < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        widget.theme ?? CalendarTheme.fromMaterialTheme(Theme.of(context));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(theme),
        SizedBox(height: theme.spacing.headerToWeekdaysSpacing * 2),
        _buildWeekdayLabels(theme),
        SizedBox(height: theme.spacing.weekdaysToCellsSpacing * 2),
        // Always 6 rows (42 cells) for consistent height
        SizedBox(
          height: 6.5 *
              (theme.cellTheme.cellHeight +
                  theme.cellTheme.cellMargin.vertical),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: (index) {
              setState(() {
                _displayedMonth = _getDateFromPageIndex(index);
              });
            },
            itemBuilder: (context, index) {
              final monthDate = _getDateFromPageIndex(index);
              return _buildMonthGrid(monthDate, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(CalendarTheme theme) {
    final headerTheme = theme.headerTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;

    final monthName = MonthUtils.formattedMonth(
      _displayedMonth.month,
      isNepali ? CalendarLocale.nepali : CalendarLocale.english,
    );
    final year = isNepali
        ? NepaliNumberConverter.englishToNepali(_displayedMonth.year.toString())
        : _displayedMonth.year.toString();

    final canGoPrevious = _getPageIndex(_displayedMonth) > 0;
    final canGoNext = _getPageIndex(_displayedMonth) < _totalPages - 1;

    return Container(
      height: headerTheme.headerHeight,
      padding: headerTheme.headerPadding,
      decoration: BoxDecoration(
        color: headerTheme.headerBackgroundColor,
        border: headerTheme.headerBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (headerTheme.showNavigationButtons)
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                size: headerTheme.navigationIconSize,
                color: canGoPrevious
                    ? headerTheme.navigationIconColor
                    : theme.colorScheme.disabled,
              ),
              onPressed: canGoPrevious ? _goToPreviousMonth : null,
            ),
          Expanded(
            child: Text(
              '$monthName $year',
              style: headerTheme.monthTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          if (headerTheme.showNavigationButtons)
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: headerTheme.navigationIconSize,
                color: canGoNext
                    ? headerTheme.navigationIconColor
                    : theme.colorScheme.disabled,
              ),
              onPressed: canGoNext ? _goToNextMonth : null,
            ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(CalendarTheme theme) {
    final weekdayTheme = theme.weekdayTheme;
    final locale = theme.locale;

    // Get weekday order based on weekStart setting
    final weekdayOrder = widget.weekStart.weekdayOrder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayIndex = weekdayOrder[index];
        // Check if this day is a weekend based on weekend setting
        // dayIndex is 0-based (0=Sunday, ..., 6=Saturday)
        // Convert to NepaliDateTime weekday format for weekend check
        final weekday = dayIndex == 6 ? 7 : dayIndex + 1;
        final isWeekend = widget.weekend.isWeekend(weekday);

        String weekdayName;
        if (weekdayTheme.customLabels != null &&
            weekdayTheme.customLabels!.length == 7) {
          weekdayName = weekdayTheme.customLabels![index];
        } else {
          // Pass the format directly from theme
          // WeekdayFormat.full returns full names, others return abbreviated
          weekdayName = WeekUtils.formattedWeekDay(
            dayIndex,
            locale,
            weekdayTheme.format,
          );
        }

        return SizedBox(
          width: theme.cellTheme.cellWidth,
          child: Text(
            weekdayName,
            style: isWeekend
                ? weekdayTheme.weekendTextStyle ?? weekdayTheme.textStyle
                : weekdayTheme.textStyle,
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  /// Total cells in the grid (6 rows × 7 columns = 42 cells always)
  static const int _totalGridCells = 42;

  Widget _buildMonthGrid(NepaliDateTime monthDate, CalendarTheme theme) {
    final daysInMonth =
        CalendarUtils.nepaliYears[monthDate.year]![monthDate.month];
    final firstDayOfMonth =
        NepaliDateTime(year: monthDate.year, month: monthDate.month);

    // Calculate the grid offset based on weekStart setting
    // NepaliDateTime.weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = widget.weekStart.getGridOffset(firstWeekday);

    final cells = <Widget>[];

    // Add previous month's trailing days (shown in light grey)
    if (startOffset > 0) {
      final prevMonthDays = _getPreviousMonthDays(monthDate, startOffset);
      for (final day in prevMonthDays) {
        cells.add(_buildAdjacentMonthDayCell(day, theme));
      }
    }

    // Add current month's day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final date = NepaliDateTime(
        year: monthDate.year,
        month: monthDate.month,
        day: day,
      );
      cells.add(_buildDayCell(date, theme));
    }

    // Calculate remaining cells to fill 6 rows (42 cells total)
    final currentCellCount = startOffset + daysInMonth;
    final remainingCells = _totalGridCells - currentCellCount;

    // Add next month's leading days to fill all remaining cells (shown in light grey)
    if (remainingCells > 0) {
      final nextMonthDays = _getNextMonthDays(monthDate, remainingCells);
      for (final day in nextMonthDays) {
        cells.add(_buildAdjacentMonthDayCell(day, theme));
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  /// Gets the trailing days from the previous month to fill the first row.
  List<int> _getPreviousMonthDays(NepaliDateTime monthDate, int count) {
    int prevYear = monthDate.year;
    int prevMonth = monthDate.month - 1;

    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }

    // Get days in previous month
    final prevMonthDays = CalendarUtils.nepaliYears[prevYear]?[prevMonth] ?? 30;

    // Return the last 'count' days of the previous month
    final days = <int>[];
    for (var i = count - 1; i >= 0; i--) {
      days.add(prevMonthDays - i);
    }
    return days;
  }

  /// Gets the leading days from the next month to fill remaining cells.
  List<int> _getNextMonthDays(NepaliDateTime monthDate, int count) {
    // Simply return 1, 2, 3, ... up to count
    return List.generate(count, (i) => i + 1);
  }

  /// Builds a cell for adjacent month days (previous/next month).
  /// These are displayed in light grey and are not tappable.
  Widget _buildAdjacentMonthDayCell(int day, CalendarTheme theme) {
    final cellTheme = theme.cellTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;

    // Use a very light grey color for adjacent month days
    final adjacentTextStyle = cellTheme.defaultTextStyle.copyWith(
      color: theme.colorScheme.disabled.withValues(alpha: 0.5),
    );

    final dayText = isNepali
        ? NepaliNumberConverter.englishToNepali(day.toString())
        : day.toString();

    return Container(
      margin: cellTheme.cellMargin,
      width: cellTheme.cellWidth,
      height: cellTheme.cellHeight,
      alignment: Alignment.center,
      child: Text(
        dayText,
        style: adjacentTextStyle,
      ),
    );
  }

  Widget _buildDayCell(NepaliDateTime date, CalendarTheme theme) {
    final cellTheme = theme.cellTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;

    final isSelected = _compareDates(date, _selectedDate) == 0;
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelectable = _isDateSelectable(date);
    final isWeekend = widget.weekend.isWeekend(date.weekday);

    // Determine text style
    TextStyle textStyle = cellTheme.defaultTextStyle;
    if (!isSelectable) {
      textStyle = cellTheme.disabledTextStyle ??
          textStyle.copyWith(
            color: cellTheme.disabledTextColor ?? theme.colorScheme.disabled,
          );
    } else if (isSelected) {
      textStyle = cellTheme.selectedTextStyle ??
          textStyle.copyWith(
            color: cellTheme.selectedTextColor ?? theme.colorScheme.onPrimary,
          );
    } else if (isToday) {
      textStyle = cellTheme.todayTextStyle ??
          textStyle.copyWith(
            color: cellTheme.todayTextColor ?? theme.colorScheme.onPrimary,
          );
    } else if (isWeekend) {
      textStyle = cellTheme.weekendTextStyle ??
          textStyle.copyWith(
            color: cellTheme.weekendTextColor,
          );
    }

    // Determine decoration
    BoxDecoration? decoration;
    if (isSelected) {
      decoration = _getSelectionDecoration(cellTheme, theme.colorScheme);
    } else if (isToday) {
      decoration = _getTodayDecoration(cellTheme, theme.colorScheme);
    }

    final dayText = isNepali
        ? NepaliNumberConverter.englishToNepali(date.day.toString())
        : date.day.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(cellTheme.borderRadius),
      onTap: isSelectable ? () => _handleDaySelected(date) : null,
      child: Container(
        margin: cellTheme.cellMargin,
        width: cellTheme.cellWidth,
        height: cellTheme.cellHeight,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          dayText,
          style: textStyle,
        ),
      ),
    );
  }

  BoxDecoration _getSelectionDecoration(
    CellTheme cellTheme,
    CalendarColorScheme colorScheme,
  ) {
    return BoxDecoration(
      color: cellTheme.selectionColor,
      shape: cellTheme.shape == CellShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: cellTheme.shape == CellShape.roundedSquare
          ? BorderRadius.circular(cellTheme.borderRadius)
          : null,
    );
  }

  BoxDecoration _getTodayDecoration(
    CellTheme cellTheme,
    CalendarColorScheme colorScheme,
  ) {
    return BoxDecoration(
      color: cellTheme.todayBackgroundColor,
      shape: cellTheme.shape == CellShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: cellTheme.shape == CellShape.roundedSquare
          ? BorderRadius.circular(cellTheme.borderRadius)
          : null,
    );
  }
}
