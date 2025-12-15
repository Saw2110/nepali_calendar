import 'package:flutter/material.dart';

import '../src.dart';

/// A callback type for determining if a Nepali day is selectable.
typedef NepaliSelectableDayPredicate = bool Function(NepaliDateTime day);

/// Nepali Date Picker Widget for inline usage.
///
/// This widget provides a calendar-based date picker for selecting
/// Nepali dates. It supports three view modes:
/// - Day view: Calendar grid for selecting a day
/// - Month view: 12-month grid for selecting a month
/// - Year view: Year grid for selecting a year
///
/// Tap on the header to switch between views.
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
///   weekStart: WeekStart.sunday,
///   weekend: Weekend.saturday,
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
  final NepaliSelectableDayPredicate? selectableDayPredicate;

  /// Specifies which day the week starts on.
  final WeekStart weekStart;

  /// Specifies which days are considered weekends.
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
  late PageController _dayPageController;
  late NepaliDatePickerMode _mode;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = NepaliDateTime(
      year: widget.initialDate.year,
      month: widget.initialDate.month,
    );
    _mode = NepaliDatePickerMode.day;
    _initPageController();
  }

  void _initPageController() {
    final initialPage = _getPageIndex(_displayedMonth);
    final clampedPage = initialPage.clamp(0, _totalPages - 1);
    _dayPageController = PageController(initialPage: clampedPage);
  }

  void _reinitPageController() {
    final oldController = _dayPageController;
    _initPageController();
    oldController.dispose();
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
    setState(() => _selectedDate = date);
    widget.onDateChanged(date);
  }

  void _handleMonthSelected(int month) {
    final newDisplayedMonth = NepaliDateTime(
      year: _displayedMonth.year,
      month: month,
    );

    setState(() {
      _displayedMonth = newDisplayedMonth;
      _mode = NepaliDatePickerMode.day;
      // Reinitialize page controller to show the correct month
      _reinitPageController();
    });
  }

  void _handleYearSelected(int year) {
    // Ensure month is valid for the selected year
    int month = _displayedMonth.month;

    // Check if the year/month combination is within valid range
    // If not, adjust to the nearest valid month
    if (year == widget.firstDate.year && month < widget.firstDate.month) {
      month = widget.firstDate.month;
    } else if (year == widget.lastDate.year && month > widget.lastDate.month) {
      month = widget.lastDate.month;
    }

    setState(() {
      _displayedMonth = NepaliDateTime(year: year, month: month);
      _mode = NepaliDatePickerMode.month;
    });
  }

  void _switchToMonthView() {
    setState(() => _mode = NepaliDatePickerMode.month);
  }

  void _switchToYearView() {
    setState(() => _mode = NepaliDatePickerMode.year);
  }

  bool _isDateSelectable(NepaliDateTime date) {
    if (_compareDates(date, widget.firstDate) < 0) return false;
    if (_compareDates(date, widget.lastDate) > 0) return false;
    if (widget.selectableDayPredicate != null) {
      return widget.selectableDayPredicate!(date);
    }
    return true;
  }

  bool _isMonthSelectable(int year, int month) {
    final firstOfMonth = NepaliDateTime(year: year, month: month);
    final lastOfMonth = NepaliDateTime(
      year: year,
      month: month,
      day: CalendarUtils.nepaliYears[year]?[month] ?? 30,
    );
    // Month is selectable if any day in it could be within range
    return _compareDates(lastOfMonth, widget.firstDate) >= 0 &&
        _compareDates(firstOfMonth, widget.lastDate) <= 0;
  }

  bool _isYearSelectable(int year) {
    return year >= widget.firstDate.year && year <= widget.lastDate.year;
  }

  int _compareDates(NepaliDateTime a, NepaliDateTime b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  void _goToPreviousMonth() {
    if (_dayPageController.page! > 0) {
      _dayPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextMonth() {
    if (_dayPageController.page! < _totalPages - 1) {
      _dayPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _dayPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        widget.theme ?? CalendarTheme.fromMaterialTheme(Theme.of(context));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildCurrentView(theme),
    );
  }

  Widget _buildCurrentView(CalendarTheme theme) {
    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _DayView(
          key: const ValueKey('day'),
          displayedMonth: _displayedMonth,
          selectedDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          theme: theme,
          weekStart: widget.weekStart,
          weekend: widget.weekend,
          pageController: _dayPageController,
          totalPages: _totalPages,
          onDaySelected: _handleDaySelected,
          onHeaderTap: _switchToMonthView,
          onPreviousMonth: _goToPreviousMonth,
          onNextMonth: _goToNextMonth,
          onPageChanged: (date) => setState(() => _displayedMonth = date),
          getDateFromPageIndex: _getDateFromPageIndex,
          getPageIndex: _getPageIndex,
          isDateSelectable: _isDateSelectable,
        );
      case NepaliDatePickerMode.month:
        return _MonthView(
          key: const ValueKey('month'),
          displayedYear: _displayedMonth.year,
          selectedMonth: _selectedDate.month,
          selectedYear: _selectedDate.year,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          theme: theme,
          onMonthSelected: _handleMonthSelected,
          onYearTap: _switchToYearView,
          isMonthSelectable: _isMonthSelectable,
        );
      case NepaliDatePickerMode.year:
        return _YearView(
          key: const ValueKey('year'),
          displayedYear: _displayedMonth.year,
          selectedYear: _selectedDate.year,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          theme: theme,
          onYearSelected: _handleYearSelected,
          isYearSelectable: _isYearSelectable,
        );
    }
  }
}

/// Day view - shows calendar grid for selecting a day.
class _DayView extends StatelessWidget {
  final NepaliDateTime displayedMonth;
  final NepaliDateTime selectedDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final CalendarTheme theme;
  final WeekStart weekStart;
  final Weekend weekend;
  final PageController pageController;
  final int totalPages;
  final ValueChanged<NepaliDateTime> onDaySelected;
  final VoidCallback onHeaderTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<NepaliDateTime> onPageChanged;
  final NepaliDateTime Function(int) getDateFromPageIndex;
  final int Function(NepaliDateTime) getPageIndex;
  final bool Function(NepaliDateTime) isDateSelectable;

  const _DayView({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.theme,
    required this.weekStart,
    required this.weekend,
    required this.pageController,
    required this.totalPages,
    required this.onDaySelected,
    required this.onHeaderTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPageChanged,
    required this.getDateFromPageIndex,
    required this.getPageIndex,
    required this.isDateSelectable,
  });

  static const int _totalGridCells = 42;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: theme.spacing.headerToWeekdaysSpacing * 2),
        _buildWeekdayLabels(),
        SizedBox(height: theme.spacing.weekdaysToCellsSpacing * 2),
        SizedBox(
          height: 6.5 *
              (theme.cellTheme.cellHeight +
                  theme.cellTheme.cellMargin.vertical),
          child: PageView.builder(
            controller: pageController,
            itemCount: totalPages,
            onPageChanged: (index) =>
                onPageChanged(getDateFromPageIndex(index)),
            itemBuilder: (context, index) {
              final monthDate = getDateFromPageIndex(index);
              return _buildMonthGrid(monthDate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final headerTheme = theme.headerTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;

    final monthName = MonthUtils.formattedMonth(
      displayedMonth.month,
      isNepali ? CalendarLocale.nepali : CalendarLocale.english,
    );
    final year = isNepali
        ? NepaliNumberConverter.englishToNepali(displayedMonth.year.toString())
        : displayedMonth.year.toString();

    final canGoPrevious = getPageIndex(displayedMonth) > 0;
    final canGoNext = getPageIndex(displayedMonth) < totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: headerTheme.headerBackgroundColor,
        border: headerTheme.headerBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month/Year selector on the left
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$monthName $year',
                    style: headerTheme.monthTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: headerTheme.monthTextStyle.color,
                  ),
                ],
              ),
            ),
          ),
          // Navigation arrows on the right
          if (headerTheme.showNavigationButtons)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: headerTheme.navigationIconSize,
                    color: canGoPrevious
                        ? headerTheme.navigationIconColor
                        : theme.colorScheme.disabled,
                  ),
                  onPressed: canGoPrevious ? onPreviousMonth : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    size: headerTheme.navigationIconSize,
                    color: canGoNext
                        ? headerTheme.navigationIconColor
                        : theme.colorScheme.disabled,
                  ),
                  onPressed: canGoNext ? onNextMonth : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final weekdayTheme = theme.weekdayTheme;
    final locale = theme.locale;
    final weekdayOrder = weekStart.weekdayOrder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayIndex = weekdayOrder[index];
        final weekday = dayIndex == 0 ? 8 : dayIndex + 1;
        final isWeekend = weekend.isWeekend(weekday);

        String weekdayName;
        if (weekdayTheme.customLabels != null &&
            weekdayTheme.customLabels!.length == 7) {
          weekdayName = weekdayTheme.customLabels![index];
        } else {
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

  Widget _buildMonthGrid(NepaliDateTime monthDate) {
    final daysInMonth =
        CalendarUtils.nepaliYears[monthDate.year]![monthDate.month];
    final firstDayOfMonth =
        NepaliDateTime(year: monthDate.year, month: monthDate.month);
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = weekStart.getGridOffset(firstWeekday);

    final cells = <Widget>[];

    // Previous month days
    if (startOffset > 0) {
      final prevMonthDays = _getPreviousMonthDays(monthDate, startOffset);
      for (final day in prevMonthDays) {
        cells.add(_buildAdjacentMonthDayCell(day));
      }
    }

    // Current month days
    for (var day = 1; day <= daysInMonth; day++) {
      final date = NepaliDateTime(
        year: monthDate.year,
        month: monthDate.month,
        day: day,
      );
      cells.add(_buildDayCell(date));
    }

    // Next month days
    final currentCellCount = startOffset + daysInMonth;
    final remainingCells = _totalGridCells - currentCellCount;
    if (remainingCells > 0) {
      final nextMonthDays = List.generate(remainingCells, (i) => i + 1);
      for (final day in nextMonthDays) {
        cells.add(_buildAdjacentMonthDayCell(day));
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  List<int> _getPreviousMonthDays(NepaliDateTime monthDate, int count) {
    int prevYear = monthDate.year;
    int prevMonth = monthDate.month - 1;
    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }
    final prevMonthDays = CalendarUtils.nepaliYears[prevYear]?[prevMonth] ?? 30;
    final days = <int>[];
    for (var i = count - 1; i >= 0; i--) {
      days.add(prevMonthDays - i);
    }
    return days;
  }

  Widget _buildAdjacentMonthDayCell(int day) {
    final cellTheme = theme.cellTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;
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
      child: Text(dayText, style: adjacentTextStyle),
    );
  }

  Widget _buildDayCell(NepaliDateTime date) {
    final cellTheme = theme.cellTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;

    final isSelected = _compareDates(date, selectedDate) == 0;
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelectable = isDateSelectable(date);
    final isWeekendDay = weekend.isWeekend(date.weekday);

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
    } else if (isWeekendDay) {
      textStyle = cellTheme.weekendTextStyle ??
          textStyle.copyWith(color: cellTheme.weekendTextColor);
    }

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: cellTheme.selectionColor,
        shape: cellTheme.shape == CellShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: cellTheme.shape == CellShape.roundedSquare
            ? BorderRadius.circular(cellTheme.borderRadius)
            : null,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: cellTheme.todayBackgroundColor,
        shape: cellTheme.shape == CellShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: cellTheme.shape == CellShape.roundedSquare
            ? BorderRadius.circular(cellTheme.borderRadius)
            : null,
      );
    }

    final dayText = isNepali
        ? NepaliNumberConverter.englishToNepali(date.day.toString())
        : date.day.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(cellTheme.borderRadius),
      onTap: isSelectable ? () => onDaySelected(date) : null,
      child: Container(
        margin: cellTheme.cellMargin,
        width: cellTheme.cellWidth,
        height: cellTheme.cellHeight,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(dayText, style: textStyle),
      ),
    );
  }

  int _compareDates(NepaliDateTime a, NepaliDateTime b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }
}

/// Month view - shows 12 months grid for selecting a month.
class _MonthView extends StatelessWidget {
  final int displayedYear;
  final int selectedMonth;
  final int selectedYear;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final CalendarTheme theme;
  final ValueChanged<int> onMonthSelected;
  final VoidCallback onYearTap;
  final bool Function(int year, int month) isMonthSelectable;

  const _MonthView({
    super.key,
    required this.displayedYear,
    required this.selectedMonth,
    required this.selectedYear,
    required this.firstDate,
    required this.lastDate,
    required this.theme,
    required this.onMonthSelected,
    required this.onYearTap,
    required this.isMonthSelectable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildMonthGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    final headerTheme = theme.headerTheme;
    final isNepali = theme.locale == CalendarLocale.nepali;
    final yearText = isNepali
        ? NepaliNumberConverter.englishToNepali(displayedYear.toString())
        : displayedYear.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: headerTheme.headerBackgroundColor,
        border: headerTheme.headerBorder,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onYearTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    yearText,
                    style: headerTheme.monthTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: headerTheme.monthTextStyle.color,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final isNepali = theme.locale == CalendarLocale.nepali;
    final cellTheme = theme.cellTheme;
    final now = NepaliDateTime.now();
    final isCurrentYear = displayedYear == now.year;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected =
            selectedYear == displayedYear && selectedMonth == month;
        final isCurrentMonth = isCurrentYear && now.month == month;
        final isSelectable = isMonthSelectable(displayedYear, month);

        final monthName = MonthUtils.formattedMonth(
          month,
          isNepali ? CalendarLocale.nepali : CalendarLocale.english,
        );

        TextStyle textStyle = cellTheme.defaultTextStyle.copyWith(fontSize: 14);
        if (!isSelectable) {
          textStyle = textStyle.copyWith(
            color: theme.colorScheme.disabled,
          );
        } else if (isSelected) {
          textStyle = textStyle.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          );
        } else if (isCurrentMonth) {
          textStyle = textStyle.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          );
        }

        BoxDecoration? decoration;
        if (isSelected) {
          decoration = BoxDecoration(
            color: cellTheme.selectionColor,
            borderRadius: BorderRadius.circular(8),
          );
        } else if (isCurrentMonth) {
          decoration = BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          );
        }

        return InkWell(
          onTap: isSelectable ? () => onMonthSelected(month) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(monthName, style: textStyle),
          ),
        );
      },
    );
  }
}

/// Year view - shows grid of years for selecting a year.
class _YearView extends StatefulWidget {
  final int displayedYear;
  final int selectedYear;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final CalendarTheme theme;
  final ValueChanged<int> onYearSelected;
  final bool Function(int) isYearSelectable;

  const _YearView({
    super.key,
    required this.displayedYear,
    required this.selectedYear,
    required this.firstDate,
    required this.lastDate,
    required this.theme,
    required this.onYearSelected,
    required this.isYearSelectable,
  });

  @override
  State<_YearView> createState() => _YearViewState();
}

class _YearViewState extends State<_YearView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelectedYear());
  }

  void _scrollToSelectedYear() {
    final yearIndex = widget.displayedYear - widget.firstDate.year;
    final rowIndex = yearIndex ~/ 4;
    // Each row is approximately 56 pixels (48 height + 8 spacing)
    final scrollOffset = (rowIndex * 56.0) - 100;
    if (scrollOffset > 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildYearGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    final headerTheme = widget.theme.headerTheme;
    final isNepali = widget.theme.locale == CalendarLocale.nepali;
    final title = isNepali ? 'वर्ष छान्नुहोस्' : 'Select Year';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: headerTheme.headerBackgroundColor,
        border: headerTheme.headerBorder,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: headerTheme.monthTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearGrid() {
    final cellTheme = widget.theme.cellTheme;
    final isNepali = widget.theme.locale == CalendarLocale.nepali;
    final now = NepaliDateTime.now();
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    return SizedBox(
      height: 250,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = widget.selectedYear == year;
          final isCurrentYear = now.year == year;
          final isSelectable = widget.isYearSelectable(year);

          final yearText = isNepali
              ? NepaliNumberConverter.englishToNepali(year.toString())
              : year.toString();

          TextStyle textStyle =
              cellTheme.defaultTextStyle.copyWith(fontSize: 14);
          if (!isSelectable) {
            textStyle = textStyle.copyWith(
              color: widget.theme.colorScheme.disabled,
            );
          } else if (isSelected) {
            textStyle = textStyle.copyWith(
              color: widget.theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            );
          } else if (isCurrentYear) {
            textStyle = textStyle.copyWith(
              color: widget.theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }

          BoxDecoration? decoration;
          if (isSelected) {
            decoration = BoxDecoration(
              color: cellTheme.selectionColor,
              borderRadius: BorderRadius.circular(8),
            );
          } else if (isCurrentYear) {
            decoration = BoxDecoration(
              border: Border.all(
                color: widget.theme.colorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            );
          }

          return InkWell(
            onTap: isSelectable ? () => widget.onYearSelected(year) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: decoration,
              alignment: Alignment.center,
              child: Text(yearText, style: textStyle),
            ),
          );
        },
      ),
    );
  }
}
