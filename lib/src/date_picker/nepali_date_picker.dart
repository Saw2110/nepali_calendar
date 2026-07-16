// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide
// it.
// ignore_for_file: avoid_redundant_argument_values

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

/// Material's minimum touch target.
///
/// Held in portrait on every phone. It cannot be held everywhere: six rows of
/// 48 plus a header, a weekday row and the actions needs roughly 452dp, and a
/// phone in landscape has about 342dp to give. Cells shrink towards
/// [_minCellExtent] rather than the dialog overflowing or the grid scrolling
/// half a month out of sight.
const double _minTouchTarget = 48.0;

/// The smallest a day cell may get before it stops being usable.
const double _minCellExtent = 36.0;

/// Horizontal padding inside the picker.
///
/// Deliberately tight: seven columns need 336dp to hold a 48dp target, and a
/// 375dp phone minus the dialog's insets leaves only a little over that.
const double _gutter = 12.0;

/// Corner radius for interactive surfaces inside the picker.
const double _cornerRadius = 12.0;

/// How long a view change takes.
const Duration _transitionDuration = Duration(milliseconds: 200);

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
  /// Called whenever a date is tapped, before it is confirmed.
  ///
  /// Fires on every tap. To learn what the user actually settled on, use
  /// [onConfirm], or the value returned by [showNepaliDatePicker].
  final Function(NepaliDateTime) onDateSelected;

  /// Initial date to display (defaults to current Nepali date)
  final NepaliDateTime? initialDate;

  /// Styling configuration for the date picker
  final NepaliCalendarStyle calendarStyle;

  /// Which view the picker opens on.
  ///
  /// [NepaliDatePickerMode.year] is the useful one for dates far from today,
  /// such as a birthday: it saves the user paging through months. Whatever the
  /// mode, the picker still returns a full date.
  ///
  /// Added in 0.1.0. [NepaliDatePickerMode] existed before but nothing
  /// accepted it -- it was internal state, so the picker always opened on the
  /// day grid.
  final NepaliDatePickerMode initialMode;

  /// Earliest selectable date. Dates before it are shown but not selectable.
  ///
  /// Clamped to the range the bundled calendar data covers, so a [minDate]
  /// earlier than that has no additional effect.
  final NepaliDateTime? minDate;

  /// Latest selectable date. Dates after it are shown but not selectable.
  ///
  /// Clamped to the range the bundled calendar data covers.
  final NepaliDateTime? maxDate;

  /// Called when the user confirms their choice.
  ///
  /// When null the picker pops the enclosing route with the selected date,
  /// which is what [showNepaliDatePicker] relies on. Supply this to embed the
  /// picker in a page: the widget then leaves the [Navigator] alone and simply
  /// reports the date.
  final ValueChanged<NepaliDateTime>? onConfirm;

  /// Called when the user cancels.
  ///
  /// When null the picker pops the enclosing route. See [onConfirm].
  final VoidCallback? onCancel;

  /// Label for the confirm action. Defaults to "OK" / "ठीक छ".
  final String? confirmText;

  /// Label for the cancel action. Defaults to "Cancel" / "रद्द गर्नुहोस्".
  final String? cancelText;

  const NepaliDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.initialMode = NepaliDatePickerMode.day,
    this.minDate,
    this.maxDate,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
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

  /// Earliest selectable date: [NepaliDatePicker.minDate], never earlier than
  /// the bundled calendar data reaches.
  NepaliDateTime get _minDate {
    final dataStart = NepaliDateTime(
      year: CalendarUtils.nepaliYears.keys.first,
      month: 1,
      day: 1,
    );
    final requested = widget.minDate;
    if (requested == null) return dataStart;
    return requested.compareTo(dataStart) > 0 ? requested : dataStart;
  }

  /// Latest selectable date: [NepaliDatePicker.maxDate], never later than the
  /// bundled calendar data reaches.
  NepaliDateTime get _maxDate {
    final lastYear = CalendarUtils.nepaliYears.keys.last;
    final dataEnd = NepaliDateTime(
      year: lastYear,
      month: 12,
      day: CalendarUtils.nepaliYears[lastYear]![12],
    );
    final requested = widget.maxDate;
    if (requested == null) return dataEnd;
    return requested.compareTo(dataEnd) < 0 ? requested : dataEnd;
  }

  /// Whether [date] may be selected.
  bool _isSelectable(NepaliDateTime date) {
    final day = date.dateOnly;
    return day.compareTo(_minDate.dateOnly) >= 0 &&
        day.compareTo(_maxDate.dateOnly) <= 0;
  }

  /// [date] pulled inside the selectable range.
  ///
  /// The picker clamps rather than asserting: an out-of-range initialDate is
  /// easy to produce from stored data, and opening on the nearest legal date
  /// is friendlier than crashing the app that asked for it.
  NepaliDateTime _clamp(NepaliDateTime date) {
    if (date.compareTo(_minDate) < 0) return _minDate;
    if (date.compareTo(_maxDate) > 0) return _maxDate;
    return date;
  }

  @override
  void initState() {
    super.initState();
    final now = NepaliDateTime.now();
    final initial = _clamp(widget.initialDate ?? now);
    selectedDate = initial;
    displayDate = initial;
    viewMode = widget.initialMode;

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
    // Clamped: today may sit outside a caller's min/max window.
    final today = _clamp(NepaliDateTime.now());
    setState(() {
      displayDate = today;
      selectedDate = today;
      viewMode = NepaliDatePickerMode.day;
    });
  }

  /// Navigate to previous month
  void _previousMonth() {
    if (!_canGoToPreviousMonth) return;
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

  /// Whether any part of the previous month is selectable.
  bool get _canGoToPreviousMonth {
    final previous = displayDate.month == 1
        ? NepaliDateTime(year: displayDate.year - 1, month: 12, day: 1)
        : NepaliDateTime(
            year: displayDate.year,
            month: displayDate.month - 1,
            day: 1,
          );
    if (previous.year < CalendarUtils.nepaliYears.keys.first) return false;
    // The month is reachable if its last day is still on or after the minimum.
    final lastDay = CalendarUtils.nepaliYears[previous.year]![previous.month];
    final monthEnd = NepaliDateTime(
      year: previous.year,
      month: previous.month,
      day: lastDay,
    );
    return monthEnd.compareTo(_minDate.dateOnly) >= 0;
  }

  /// Whether any part of the next month is selectable.
  bool get _canGoToNextMonth {
    final next = displayDate.month == 12
        ? NepaliDateTime(year: displayDate.year + 1, month: 1, day: 1)
        : NepaliDateTime(
            year: displayDate.year,
            month: displayDate.month + 1,
            day: 1,
          );
    if (next.year > CalendarUtils.nepaliYears.keys.last) return false;
    return next.compareTo(_maxDate.dateOnly) <= 0;
  }

  /// Navigate to next month
  void _nextMonth() {
    if (!_canGoToNextMonth) return;
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

  /// The years the year grid may offer.
  ///
  /// A window around the displayed year, clamped to the selectable range --
  /// which is the caller's min/max intersected with the years the bundled
  /// calendar data covers. Up to 0.0.7 this was an unclamped
  /// `displayYear - 15 .. displayYear + 14`, so near either end of the
  /// calendar it offered years with no data behind them -- picking one threw
  /// a null-check error on `CalendarUtils.nepaliYears[year]!`.
  List<int> _selectableYears() {
    const windowBefore = 15;
    const windowSize = 30;

    final firstSupported = _minDate.year;
    final lastSupported = _maxDate.year;

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
    final date = NepaliDateTime(
      year: displayDate.year,
      month: displayDate.month,
      day: day,
    );
    // Cells outside the range are not given an onTap, so this is a backstop
    // rather than the primary guard.
    if (!_isSelectable(date)) return;

    setState(() {
      selectedDate = date;
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
  /// Header: the month/year acts as the toggle into year selection, with
  /// month navigation on the right.
  ///
  /// Up to 0.1.0 year selection hid behind an unlabelled edit-calendar icon,
  /// while "Today" occupied the most prominent corner. The title is the thing
  /// users reach for, so it is the control; Today moves down to the actions.
  Widget _buildHeader() {
    final isDayView = viewMode == NepaliDatePickerMode.day;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 12, 8, 4),
      child: Row(
        children: [
          Flexible(child: _buildTitleToggle(theme, isDayView)),
          const Spacer(),
          // Navigation only means anything on the day grid.
          if (isDayView) ...[
            _buildNavigationButton(
              Icons.chevron_left_rounded,
              _canGoToPreviousMonth ? _previousMonth : null,
              _style.effectiveConfig.language == Language.nepali
                  ? 'अघिल्लो महिना'
                  : 'Previous month',
            ),
            _buildNavigationButton(
              Icons.chevron_right_rounded,
              _canGoToNextMonth ? _nextMonth : null,
              _style.effectiveConfig.language == Language.nepali
                  ? 'अर्को महिना'
                  : 'Next month',
            ),
          ],
        ],
      ),
    );
  }

  /// The month/year title, doubling as the day <-> year toggle.
  Widget _buildTitleToggle(ThemeData theme, bool isDayView) {
    final nepali = _style.effectiveConfig.language == Language.nepali;

    return Semantics(
      button: true,
      label: isDayView
          ? (nepali ? 'वर्ष छान्नुहोस्' : 'Select year')
          : (nepali ? 'मिति छान्नुहोस्' : 'Select date'),
      child: InkWell(
        onTap: _toggleYearView,
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flexible: English month names run wider than their Nepali
              // equivalents ("Baisakh 2081" vs "बैशाख २०८१"), and a rigid Row
              // here overflowed at every screen size in English.
              Flexible(
                child: Text(
                  _getHeaderText(),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: _style.headersStyle.monthHeaderStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: isDayView ? 0 : 0.5,
                duration: _transitionDuration,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Switches between the day grid and year selection.
  void _toggleYearView() {
    setState(() {
      viewMode = viewMode == NepaliDatePickerMode.day
          ? NepaliDatePickerMode.year
          : NepaliDatePickerMode.day;
    });

    if (viewMode == NepaliDatePickerMode.year) {
      // The grid has to exist before it can be scrolled.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedYear();
      });
    }
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
  /// A month-navigation button.
  ///
  /// A null [onTap] renders it disabled rather than hiding it, so the header
  /// does not reflow when you reach the end of the allowed range.
  ///
  /// The colours come from the Material theme. Up to 0.1.0 they were
  /// hard-coded greys (0xFFF3F4F6 on 0xFF374151), which is a light-mode-only
  /// palette.
  Widget _buildNavigationButton(
    IconData icon,
    VoidCallback? onTap,
    String tooltip,
  ) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      // Meets the 48dp minimum touch target without needing the header to be
      // any taller.
      constraints: const BoxConstraints(
        minWidth: _minTouchTarget,
        minHeight: _minTouchTarget,
      ),
      visualDensity: VisualDensity.compact,
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

                // Fit six rows into the height on offer, but never shrink a
                // cell past the point of being usable. If the floor wins, the
                // grid is taller than its viewport, so it has to scroll --
                // otherwise the last row would simply never be built, which is
                // how the 30th and 31st went missing before 0.0.8.
                final availableHeight =
                    constraints.maxHeight - (spacing * (_gridRows - 1));
                final fittedHeight = availableHeight / _gridRows;
                final cellHeight = math.max(fittedHeight, _minCellExtent);
                final needsScroll = cellHeight > fittedHeight;

                return GridView.builder(
                  physics: needsScroll
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
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
                      final isDisabled = !_isSelectable(
                        NepaliDateTime(
                          year: displayDate.year,
                          month: displayDate.month,
                          day: day,
                        ),
                      );
                      return _buildDayCell(
                        day,
                        isSelected: isSelected,
                        isToday: isToday,
                        isDisabled: isDisabled,
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
    bool isDisabled = false,
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

    // A date outside min/max is dimmed further than an adjacent-month date,
    // so "not this month" and "not allowed" stay tellable apart.
    final textColor = isSelected
        ? _style.cellsStyle.onHighlightColor
        : !isCurrentMonth
            ? _style.cellsStyle.dimmedDateTextColor.withValues(alpha: 0.4)
            : isDisabled
                ? (isWeekend ? cellStyle.weekDayColor : cellStyle.dateTextColor)
                    .withValues(alpha: 0.3)
                : isWeekend
                    ? cellStyle.weekDayColor
                    : cellStyle.dayStyle.color ?? cellStyle.dateTextColor;

    final borderColor = isToday && !isSelected ? cellStyle.todayColor : null;

    return Semantics(
      button: !isDisabled,
      enabled: !isDisabled,
      selected: isSelected,
      label: _semanticLabelFor(day, isToday: isToday, isDisabled: isDisabled),
      excludeSemantics: true,
      child: InkResponse(
        // A disabled cell gets no callback, so it neither responds nor shows
        // an ink ripple.
        onTap: isDisabled ? null : onTap,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        // The tap target is the whole grid cell, not just the circle drawn
        // inside it -- the disc is decoration, and shrinking the hit area to
        // match it would make an already-tight target worse.
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: borderColor != null
                    ? Border.all(color: borderColor, width: 1.5)
                    : null,
              ),
              child: Center(
                child: FittedBox(
                  // Devanagari digits are wider than Latin at the same size;
                  // scale down rather than overflow a small cell.
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      dayText,
                      style: cellStyle.dayStyle.copyWith(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: isToday || isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// What a screen reader announces for a date cell.
  ///
  /// Spelled out rather than read as bare digits: "15" alone tells a screen
  /// reader user nothing about which month they are in.
  String _semanticLabelFor(
    int day, {
    required bool isToday,
    required bool isDisabled,
  }) {
    final language = _style.effectiveConfig.language;
    final nepali = language == Language.nepali;
    final date = NepaliDateTime(
      year: displayDate.year,
      month: displayDate.month,
      day: day,
    );

    final parts = <String>[
      MonthUtils.formattedMonth(displayDate.month, language),
      NepaliNumberConverter.formattedNumber('$day', language: language),
      NepaliNumberConverter.formattedNumber(
        '${displayDate.year}',
        language: language,
      ),
      WeekUtils.formattedWeekDay(date.weekday, language),
      if (isToday) nepali ? 'आज' : 'Today',
      if (isDisabled) nepali ? 'उपलब्ध छैन' : 'Unavailable',
    ];
    return parts.join(', ');
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

  /// Confirm.
  ///
  /// Reports through [NepaliDatePicker.onConfirm] when the caller supplied
  /// one and leaves the Navigator alone -- that is what makes the picker
  /// embeddable in a page. With no callback it falls back to popping the
  /// enclosing route with the selected date, which is what
  /// [showNepaliDatePicker] relies on and what every version up to 0.1.0 did
  /// unconditionally.
  void _handleConfirm() {
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      onConfirm(selectedDate);
      return;
    }
    Navigator.of(context).pop(selectedDate);
  }

  /// Cancel. See [_handleConfirm] for why the pop is conditional.
  void _handleCancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
      return;
    }
    Navigator.of(context).pop();
  }

  /// Actions: Today on the left, Cancel and the confirm action on the right.
  ///
  /// Today lives here rather than in the header, where it used to occupy the
  /// most prominent corner despite being the least-used control.
  Widget _buildActions() {
    final nepali = _style.effectiveConfig.language == Language.nepali;
    // Today is pointless when it is outside the allowed range.
    final todayIsReachable = _isSelectable(NepaliDateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter, 12),
      // Flexible labels: the Nepali strings are much wider than the English
      // ones ("रद्द गर्नुहोस्" vs "Cancel"), and a rigid Row overflowed on a
      // narrow phone.
      child: Row(
        children: [
          if (todayIsReachable)
            Flexible(
              child: TextButton(
                onPressed: _goToToday,
                child: Text(
                  nepali ? 'आज' : 'Today',
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ),
          const Spacer(),
          Flexible(
            child: TextButton(
              onPressed: _handleCancel,
              child: Text(
                widget.cancelText ?? (nepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: TextButton(
              onPressed: _handleConfirm,
              child: Text(
                widget.confirmText ?? (nepali ? 'ठीक छ' : 'OK'),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
