import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src.dart';

/// Columns in the day grid: one per weekday.
const int _gridColumns = 7;

/// Rows in the day grid. Always six, so the month's last days are never
/// pushed out of the viewport and left unbuilt.
const int _gridRows = 6;

/// Width the picker uses when there is room for it.
const double _preferredWidth = 420.0;

/// Height the picker uses when there is room for it.
const double _preferredHeight = 480.0;

/// A customizable Nepali Date Picker widget for selecting dates in the Bikram Sambat calendar.
///
/// This widget provides three view modes:
/// * Day selection with calendar grid
/// * Month selection
/// * Year selection
///
/// Example usage:
/// ```dart
/// NepaliDatePicker(
///   onDateSelected: (date) {
///     print('Selected: $date');
///   },
///   calendarStyle: NepaliCalendarStyle(
///     config: CalendarConfig(language: Language.nepali),
///     cellsStyle: CellStyle(selectedColor: Colors.blue),
///   ),
/// )
/// ```
class NepaliDatePicker extends StatefulWidget {
  /// Callback function called when a date is selected
  final Function(NepaliDateTime) onDateSelected;

  /// Initial date to display (defaults to current Nepali date)
  final NepaliDateTime? initialDate;

  /// Styling configuration for the date picker
  final NepaliCalendarStyle calendarStyle;

  const NepaliDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.calendarStyle = const NepaliCalendarStyle(),
  });

  @override
  State<NepaliDatePicker> createState() => _NepaliDatePickerState();
}

class _NepaliDatePickerState extends State<NepaliDatePicker>
    with SingleTickerProviderStateMixin {
  late NepaliDateTime selectedDate;
  late NepaliDateTime displayDate;
  late NepaliDatePickerMode viewMode;
  late AnimationController _animationController;
  late ScrollController _yearScrollController;

  /// The style to render with, resolved in [build] against any ambient
  /// [NepaliCalendarTheme]. Held as a field because the section builders
  /// below have no [BuildContext] of their own.
  NepaliCalendarStyle _style = const NepaliCalendarStyle();

  @override
  void initState() {
    super.initState();
    final now = NepaliDateTime.now();
    selectedDate = widget.initialDate ?? now;
    displayDate = widget.initialDate ?? now;
    viewMode = NepaliDatePickerMode.day;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    _yearScrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _yearScrollController.dispose();
    super.dispose();
  }

  /// Navigate to today's date
  void _goToToday() {
    setState(() {
      displayDate = NepaliDateTime.now();
      selectedDate = NepaliDateTime.now();
      viewMode = NepaliDatePickerMode.day;
    });
  }

  /// Navigate to previous month
  void _previousMonth() {
    setState(() {
      if (displayDate.month == 1) {
        displayDate = NepaliDateTime(
          year: displayDate.year - 1,
          month: 12,
        );
      } else {
        displayDate = NepaliDateTime(
          year: displayDate.year,
          month: displayDate.month - 1,
        );
      }
    });
  }

  /// Navigate to next month
  void _nextMonth() {
    setState(() {
      if (displayDate.month == 12) {
        displayDate = NepaliDateTime(
          year: displayDate.year + 1,
        );
      } else {
        displayDate = NepaliDateTime(
          year: displayDate.year,
          month: displayDate.month + 1,
        );
      }
    });
  }

  /// Toggle to year selection mode
  void _toggleEditMode() {
    setState(() {
      viewMode = NepaliDatePickerMode.year;
    });

    // Scroll to selected year after the view changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  /// The years the year grid may offer.
  ///
  /// A window around the displayed year, clamped to the range the calendar
  /// actually holds data for. Up to 0.0.7 this was an unclamped
  /// `displayYear - 15 .. displayYear + 14`, so near either end of the
  /// calendar it offered years with no data behind them -- picking one threw
  /// a null-check error on `CalendarUtils.nepaliYears[year]!`.
  List<int> _selectableYears() {
    const windowBefore = 15;
    const windowSize = 30;

    final firstSupported = CalendarUtils.nepaliYears.keys.first;
    final lastSupported = CalendarUtils.nepaliYears.keys.last;

    // Slide the window back inside the supported range rather than truncating
    // it, so the grid keeps offering a full set of years at either end.
    var start = displayDate.year - windowBefore;
    if (start + windowSize - 1 > lastSupported) {
      start = lastSupported - windowSize + 1;
    }
    if (start < firstSupported) start = firstSupported;

    final end = math.min(start + windowSize - 1, lastSupported);

    return [for (var year = start; year <= end; year++) year];
  }

  /// Scroll to the selected year in the year grid
  void _scrollToSelectedYear() {
    if (!_yearScrollController.hasClients) return;

    final years = _selectableYears();
    final selectedIndex = years.indexOf(displayDate.year);

    if (selectedIndex != -1) {
      // Calculate the scroll position
      // Each row has 3 items, so divide by 3 to get row index
      final rowIndex = selectedIndex ~/ 3;
      // Approximate item height (childAspectRatio 1.5, spacing 15)
      const itemHeight = 60.0; // Approximate height based on aspect ratio
      final scrollPosition = rowIndex * (itemHeight + 15);

      _yearScrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Select a year and move to month selection
  void _selectYear(int year) {
    setState(() {
      displayDate = NepaliDateTime(
        year: year,
        month: displayDate.month,
      );
      viewMode = NepaliDatePickerMode.month;
    });
  }

  /// Select a month and move to day selection
  void _selectMonth(int month) {
    setState(() {
      displayDate = NepaliDateTime(
        year: displayDate.year,
        month: month,
      );
      viewMode = NepaliDatePickerMode.day;
    });
  }

  /// Select a day and trigger callback
  void _selectDay(int day) {
    setState(() {
      selectedDate = NepaliDateTime(
        year: displayDate.year,
        month: displayDate.month,
        day: day,
      );
      widget.onDateSelected(selectedDate);
    });
  }

  /// Get days in current display month
  List<int> _getDaysInMonth() {
    final daysCount =
        CalendarUtils.nepaliYears[displayDate.year]![displayDate.month];
    return List.generate(daysCount, (index) => index + 1);
  }

  /// Get first day of week for current display month
  /// Normalized based on week start configuration
  int _getFirstDayOfWeek() {
    final firstDay = NepaliDateTime(
      year: displayDate.year,
      month: displayDate.month,
    );
    final weekday = firstDay.weekday; // 0=Sunday, 1=Monday, ..., 6=Saturday

    // Normalize based on week start type
    switch (_style.effectiveConfig.weekStartType) {
      case WeekStartType.sunday:
        return weekday; // No change needed
      case WeekStartType.monday:
        // If week starts on Monday, Sunday becomes last day (6)
        return weekday == 0 ? 6 : weekday - 1;
    }
  }

  /// Get previous month days to display
  List<int> _getPreviousMonthDays() {
    final firstDayOfWeek = _getFirstDayOfWeek();

    // Calculate previous month
    final prevMonth = displayDate.month == 1 ? 12 : displayDate.month - 1;
    final prevYear =
        displayDate.month == 1 ? displayDate.year - 1 : displayDate.year;

    // Get days in previous month using CalendarUtils
    final prevMonthDays = CalendarUtils.nepaliYears[prevYear]![prevMonth];

    // Return last N days of previous month
    return List.generate(
      firstDayOfWeek,
      (index) => prevMonthDays - firstDayOfWeek + index + 1,
    );
  }

  /// Build header with navigation
  Widget _buildHeader() {
    final effectiveConfig = _style.effectiveConfig;
    final todayButtonColor = _style.cellsStyle.selectedColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _goToToday,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                effectiveConfig.language == Language.nepali ? 'आज' : 'Today',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: todayButtonColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          // Flexible so a long title shrinks rather than overflowing. English
          // month names are wider than their Nepali equivalents ("Baisakh
          // 2081" vs "बैशाख २०८१"), and up to 0.0.7 this Row was rigid: the
          // English header overflowed at every screen size, including on
          // desktop, because it did not fit the picker's own fixed width.
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewMode == NepaliDatePickerMode.day) ...[
                  _buildNavigationButton(
                    Icons.chevron_left_rounded,
                    _previousMonth,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    _getHeaderText(),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: _style.headersStyle.monthHeaderStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (viewMode == NepaliDatePickerMode.day) ...[
                  const SizedBox(width: 8),
                  _buildNavigationButton(
                    Icons.chevron_right_rounded,
                    _nextMonth,
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: _toggleEditMode,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: todayButtonColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get header text based on current view mode
  String _getHeaderText() {
    final effectiveConfig = _style.effectiveConfig;
    final monthName = MonthUtils.formattedMonth(
      displayDate.month,
      effectiveConfig.language,
    );
    final year = effectiveConfig.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(displayDate.year.toString())
        : displayDate.year.toString();

    switch (viewMode) {
      case NepaliDatePickerMode.day:
        return '$monthName $year';
      case NepaliDatePickerMode.month:
        return year;
      case NepaliDatePickerMode.year:
        return effectiveConfig.language == Language.nepali
            ? 'वर्ष छान्नुहोस्'
            : 'Select Year';
    }
  }

  /// Build navigation button
  Widget _buildNavigationButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF374151)),
      ),
    );
  }

  /// Build weekday headers based on week start configuration
  Widget _buildWeekDayHeaders() {
    final effectiveConfig = _style.effectiveConfig;
    final weekendColor = _style.cellsStyle.weekDayColor;
    final weekdayStyle = _style.headersStyle.weekHeaderStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: _getWeekdayOrder().map((dayIndex) {
          final weekday = WeekUtils.formattedWeekDay(
            dayIndex,
            effectiveConfig.language,
            effectiveConfig.weekTitleType,
          );
          final isWeekend = WeekUtils.isWeekend(
            dayIndex,
            effectiveConfig.weekendType,
          );
          return Expanded(
            child: Center(
              child: Text(
                weekday,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: weekdayStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isWeekend ? weekendColor : weekdayStyle.color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get weekday order based on week start configuration
  List<int> _getWeekdayOrder() {
    switch (_style.effectiveConfig.weekStartType) {
      case WeekStartType.sunday:
        return [0, 1, 2, 3, 4, 5, 6]; // Sun-Sat
      case WeekStartType.monday:
        return [1, 2, 3, 4, 5, 6, 0]; // Mon-Sun
    }
  }

  /// Build day grid view with swipe gesture support
  Widget _buildDayGrid() {
    final previousMonthDays = _getPreviousMonthDays();
    final currentMonthDays = _getDaysInMonth();
    final totalCells = previousMonthDays.length + currentMonthDays.length;
    final nextMonthDays = (42 - totalCells) > 0 ? 42 - totalCells : 0;

    return Column(
      children: [
        _buildWeekDayHeaders(),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swipe right to left (next month)
              if (details.primaryVelocity! < -500) {
                _nextMonth();
              }
              // Swipe left to right (previous month)
              else if (details.primaryVelocity! > 500) {
                _previousMonth();
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Size the cells so all six rows fit the space available.
                //
                // Up to 0.0.7 cells were square regardless of the room on
                // offer. Inside the picker's fixed height that left the grid
                // short of a row, and because a GridView only builds what its
                // viewport covers -- with scrolling disabled here, so it could
                // not be reached either -- the sixth row was never built. The
                // last days of the month, the 30th and 31st, simply did not
                // exist and could not be selected.
                const spacing = 4.0;
                final cellWidth =
                    (constraints.maxWidth - (spacing * (_gridColumns - 1))) /
                        _gridColumns;
                final cellHeight =
                    (constraints.maxHeight - (spacing * (_gridRows - 1))) /
                        _gridRows;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridColumns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio:
                        cellHeight > 0 ? cellWidth / cellHeight : 1.0,
                  ),
                  itemCount: previousMonthDays.length +
                      currentMonthDays.length +
                      nextMonthDays,
                  itemBuilder: (context, index) {
                    if (index < previousMonthDays.length) {
                      return _buildDayCell(
                        previousMonthDays[index],
                        isCurrentMonth: false,
                      );
                    } else if (index <
                        previousMonthDays.length + currentMonthDays.length) {
                      final day =
                          currentMonthDays[index - previousMonthDays.length];
                      final isSelected =
                          selectedDate.year == displayDate.year &&
                              selectedDate.month == displayDate.month &&
                              selectedDate.day == day;
                      final today = NepaliDateTime.now();
                      final isToday = today.year == displayDate.year &&
                          today.month == displayDate.month &&
                          today.day == day;
                      return _buildDayCell(
                        day,
                        isSelected: isSelected,
                        isToday: isToday,
                        onTap: () => _selectDay(day),
                      );
                    } else {
                      final day = index -
                          previousMonthDays.length -
                          currentMonthDays.length +
                          1;
                      return _buildDayCell(day, isCurrentMonth: false);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build individual day cell with weekend detection
  Widget _buildDayCell(
    int day, {
    bool isCurrentMonth = true,
    bool isSelected = false,
    bool isToday = false,
    VoidCallback? onTap,
  }) {
    final effectiveConfig = _style.effectiveConfig;
    final cellStyle = _style.cellsStyle;

    final dayText = effectiveConfig.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(day.toString())
        : day.toString();

    // Calculate weekday for this date to determine if it's a weekend
    final date = NepaliDateTime(
      year: displayDate.year,
      month: displayDate.month,
      day: day,
    );
    final isWeekend = isCurrentMonth
        ? WeekUtils.isWeekend(date.weekday, effectiveConfig.weekendType)
        : false;

    // Determine colors based on state
    final backgroundColor = isSelected
        ? cellStyle.selectedColor
        : isToday
            ? cellStyle.todayColor.withValues(alpha: 0.3)
            : Colors.transparent;

    final textColor = isSelected
        ? _style.cellsStyle.onHighlightColor
        : !isCurrentMonth
            ? _style.cellsStyle.dimmedDateTextColor.withValues(alpha: 0.4)
            : isWeekend
                ? cellStyle.weekDayColor
                : cellStyle.dayStyle.color ?? cellStyle.dateTextColor;

    final borderColor = isToday && !isSelected ? cellStyle.todayColor : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            dayText,
            style: cellStyle.dayStyle.copyWith(
              color: textColor,
              fontSize: 15,
              fontWeight:
                  isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  /// Build year grid view
  Widget _buildYearGrid() {
    final effectiveConfig = _style.effectiveConfig;
    final cellStyle = _style.cellsStyle;
    final yearStyle = _style.headersStyle.yearHeaderStyle;

    final years = _selectableYears();

    return GridView.builder(
      controller: _yearScrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == displayDate.year;
        final yearText = effectiveConfig.language == Language.nepali
            ? NepaliNumberConverter.englishToNepali(year.toString())
            : year.toString();

        return InkWell(
          onTap: () => _selectYear(year),
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? cellStyle.selectedColor
                  : cellStyle.borderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                yearText,
                style: yearStyle.copyWith(
                  color:
                      isSelected ? cellStyle.onHighlightColor : yearStyle.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build month grid view
  Widget _buildMonthGrid() {
    final effectiveConfig = _style.effectiveConfig;
    final cellStyle = _style.cellsStyle;
    final monthStyle = _style.headersStyle.monthHeaderStyle;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected = month == displayDate.month;
        final monthName = MonthUtils.formattedMonth(
          month,
          effectiveConfig.language,
        );

        return InkWell(
          onTap: () => _selectMonth(month),
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? cellStyle.selectedColor
                  : cellStyle.borderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                monthName,
                style: monthStyle.copyWith(
                  color: isSelected
                      ? cellStyle.onHighlightColor
                      : monthStyle.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > pre-0.1.0 defaults.
    _style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Divider(
          height: 1,
          color: _style.cellsStyle.borderColor.withValues(alpha: 0.2),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: viewMode == NepaliDatePickerMode.day
                  ? _buildDayGrid()
                  : viewMode == NepaliDatePickerMode.month
                      ? _buildMonthGrid()
                      : _buildYearGrid(),
            ),
          ),
        ),
        _buildActions(),
      ],
    );

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Prefer the natural size, but never exceed what is actually
          // available. Up to 0.0.7 this was pinned to 420x480 regardless of
          // the screen, so the picker overflowed on any phone narrower than
          // 420 logical pixels -- an iPhone SE, for instance.
          final available = MediaQuery.sizeOf(context);
          final width = math.min(
            _preferredWidth,
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : available.width,
          );
          final height = math.min(
            _preferredHeight,
            constraints.hasBoundedHeight
                ? constraints.maxHeight
                : available.height,
          );

          return SizedBox(
            width: width,
            height: height,
            child: content,
          );
        },
      ),
    );
  }

// Action Buttons
  _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      // Flexible so the labels shrink rather than overflow. The Nepali labels
      // are much wider than the English ones ("रद्द गर्नुहोस्" vs "Cancel"),
      // which pushed this Row past the edge on a narrow phone.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                _style.effectiveConfig.language == Language.nepali
                    ? 'रद्द गर्नुहोस्'
                    : 'Cancel',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedDate);
              },
              child: Text(
                _style.effectiveConfig.language == Language.nepali
                    ? 'ठीक छ'
                    : 'OK',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
