import 'package:flutter/material.dart';

import '../src.dart';

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

  /// Scroll to the selected year in the year grid
  void _scrollToSelectedYear() {
    if (!_yearScrollController.hasClients) return;

    final currentYear = displayDate.year;
    final years = List.generate(30, (index) => currentYear - 15 + index);
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
    switch (widget.calendarStyle.effectiveConfig.weekStartType) {
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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
    final todayButtonColor = widget.calendarStyle.cellsStyle.selectedColor;

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
          Row(
            children: [
              if (viewMode == NepaliDatePickerMode.day) ...[
                _buildNavigationButton(
                  Icons.chevron_left_rounded,
                  _previousMonth,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                _getHeaderText(),
                style:
                    widget.calendarStyle.headersStyle.monthHeaderStyle.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              if (viewMode == NepaliDatePickerMode.day) ...[
                const SizedBox(width: 12),
                _buildNavigationButton(
                  Icons.chevron_right_rounded,
                  _nextMonth,
                ),
              ],
            ],
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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
    final weekendColor = widget.calendarStyle.cellsStyle.weekDayColor;
    final weekdayStyle = widget.calendarStyle.headersStyle.weekHeaderStyle;

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
    switch (widget.calendarStyle.effectiveConfig.weekStartType) {
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
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
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
                  final isSelected = selectedDate.year == displayDate.year &&
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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
    final cellStyle = widget.calendarStyle.cellsStyle;

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
        ? Colors.white
        : !isCurrentMonth
            ? Colors.grey.withValues(alpha: 0.4)
            : isWeekend
                ? cellStyle.weekDayColor
                : cellStyle.dayStyle.color ?? Colors.black;

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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
    final cellStyle = widget.calendarStyle.cellsStyle;
    final yearStyle = widget.calendarStyle.headersStyle.yearHeaderStyle;

    final currentYear = displayDate.year;
    final years = List.generate(30, (index) => currentYear - 15 + index);

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
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                yearText,
                style: yearStyle.copyWith(
                  color: isSelected ? Colors.white : yearStyle.color,
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
    final effectiveConfig = widget.calendarStyle.effectiveConfig;
    final cellStyle = widget.calendarStyle.cellsStyle;
    final monthStyle = widget.calendarStyle.headersStyle.monthHeaderStyle;

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
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                monthName,
                style: monthStyle.copyWith(
                  color: isSelected ? Colors.white : monthStyle.color,
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
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Divider(height: 1, color: Colors.grey[200]),
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
      child: SizedBox(
        width: 420,
        height: 480,
        child: content,
      ),
    );
  }

// Action Buttons
  _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              widget.calendarStyle.effectiveConfig.language == Language.nepali
                  ? 'रद्द गर्नुहोस्'
                  : 'Cancel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(selectedDate);
            },
            child: Text(
              widget.calendarStyle.effectiveConfig.language == Language.nepali
                  ? 'ठीक छ'
                  : 'OK',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
