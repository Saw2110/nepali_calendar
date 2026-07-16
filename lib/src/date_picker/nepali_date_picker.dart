// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide
// it.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src.dart';

/// What [_NepaliDatePickerState._measure] works out for a given viewport.
class _PickerMetrics {
  final double width;
  final double height;
  final double cellExtent;

  const _PickerMetrics({
    required this.width,
    required this.height,
    required this.cellExtent,
  });
}

/// Columns in the day grid: one per weekday.
const int _gridColumns = 7;

/// Rows in the day grid. Always six, so the month's last days are never
/// pushed out of the viewport and left unbuilt.
const int _gridRows = 6;

/// Width the picker uses when there is room for it.
///
/// Driven by the actions row, not the grid. The Nepali labels are the widest
/// thing in the picker -- "रद्द गर्नुहोस्" against "Cancel" -- and at 344 they
/// overflowed by 20dp. The grid is narrower than this and is centred within
/// it, so cells stay square instead of stretching to fill.
const double _preferredWidth = 368.0;

/// Height of the month/year header row.
const double _headerHeight = 48.0;

/// Height of the weekday initials row.
const double _weekdayRowHeight = 24.0;

/// Height of the actions row.
const double _actionsHeight = 44.0;

/// Vertical padding above and below the grid, combined.
const double _verticalPadding = 12.0;

/// Gap between day cells.
const double _cellSpacing = 2.0;

/// Minimum touch target Material asks for.
///
/// Reachable for the header's icon buttons, but not for day cells: seven
/// columns of 48 need 336dp plus gutters, and a small phone's dialog has
/// barely that in total. Flutter's own Material DatePicker lands near 42dp for
/// the same reason. Cells aim for [_maxCellExtent] and shrink towards
/// [_minCellExtent] as the space demands.
const double _minTouchTarget = 48.0;

/// The largest a day cell grows to.
///
/// Capped so the picker stays compact rather than ballooning on a tablet.
const double _maxCellExtent = 42.0;

/// The smallest a day cell may get before it stops being usable.
///
/// Below this the grid scrolls instead of shrinking further.
const double _minCellExtent = 36.0;

/// Horizontal padding inside the picker.
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
  /// Year selection used to hide behind an unlabelled edit-calendar icon while
  /// "Today" took the most prominent corner despite being the least-used
  /// action. The title is what users reach for, so the title is the control.
  Widget _buildHeader() {
    final isDayView = viewMode == NepaliDatePickerMode.day;
    final nepali = _style.effectiveConfig.language == Language.nepali;

    return Padding(
      padding: const EdgeInsets.only(left: _gutter, right: 4),
      child: Row(
        children: [
          // Expanded, not Flexible-beside-a-Spacer. Both default to flex: 1,
          // so a Flexible and a Spacer *split* the free space and the title
          // ellipsised with room to spare -- "असार २०..." on a full-size
          // phone. Expanded gives the title whatever the buttons leave.
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildTitleToggle(isDayView),
            ),
          ),
          // Navigation only means anything on the day grid.
          if (isDayView) ...[
            _buildNavigationButton(
              Icons.chevron_left_rounded,
              _canGoToPreviousMonth ? _previousMonth : null,
              nepali ? 'अघिल्लो महिना' : 'Previous month',
            ),
            _buildNavigationButton(
              Icons.chevron_right_rounded,
              _canGoToNextMonth ? _nextMonth : null,
              nepali ? 'अर्को महिना' : 'Next month',
            ),
          ],
        ],
      ),
    );
  }

  /// The month/year title, doubling as the day <-> year toggle.
  Widget _buildTitleToggle(bool isDayView) {
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flexible so a genuinely oversized title degrades rather than
              // overflowing -- a last resort, not the normal case.
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
              const SizedBox(width: 2),
              AnimatedRotation(
                turns: isDayView ? 0 : 0.5,
                duration: _transitionDuration,
                child: const Icon(Icons.arrow_drop_down_rounded, size: 22),
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

  /// The weekday initials above the grid.
  ///
  /// Deliberately the *short* form regardless of `weekTitleType`. The half
  /// form ("आइत", "मंगल", "बिहि") forces the columns far wider than the digits
  /// need, and was half of what made the picker look bulky; a date grid only
  /// needs enough to identify the column, which is why native pickers use
  /// initials. `weekTitleType` still applies to the calendar widgets, where
  /// there is room for it.
  Widget _buildWeekDayHeaders() {
    final effectiveConfig = _style.effectiveConfig;
    final weekendColor = _style.cellsStyle.weekDayColor;
    final weekdayStyle = _style.headersStyle.weekHeaderStyle;

    return Row(
      children: _getWeekdayOrder().map((dayIndex) {
        final weekday = WeekUtils.formattedShortWeekDay(
          dayIndex,
          effectiveConfig.language,
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
                fontWeight: FontWeight.w600,
                color: isWeekend ? weekendColor : weekdayStyle.color,
              ),
            ),
          ),
        );
      }).toList(),
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

    return SizedBox.expand(
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

            final cellWidth =
                (constraints.maxWidth - (_cellSpacing * (_gridColumns - 1))) /
                    _gridColumns;

            // Fit six rows into the height on offer, but never shrink a
            // cell past the point of being usable. If the floor wins, the
            // grid is taller than its viewport, so it has to scroll --
            // otherwise the last row would simply never be built, which is
            // how the 30th and 31st went missing before 0.0.8.
            final availableHeight =
                constraints.maxHeight - (_cellSpacing * (_gridRows - 1));
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
                crossAxisSpacing: _cellSpacing,
                mainAxisSpacing: _cellSpacing,
                childAspectRatio: cellHeight > 0 ? cellWidth / cellHeight : 1.0,
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

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = _measure(context, constraints);
          return SizedBox(
            width: size.width,
            height: size.height,
            child: _buildContent(size.cellExtent),
          );
        },
      ),
    );
  }

  /// Works out how big the picker wants to be.
  ///
  /// The picker sizes to its content rather than filling a fixed box. Up to
  /// 0.1.0 it was pinned to 420x480 whatever it contained, so on most screens
  /// the rows floated apart in dead space -- which is what made it look bulky.
  _PickerMetrics _measure(BuildContext context, BoxConstraints constraints) {
    final available = MediaQuery.sizeOf(context);
    final maxWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : available.width;
    final maxHeight =
        constraints.hasBoundedHeight ? constraints.maxHeight : available.height;

    final width = math.min(_preferredWidth, maxWidth);

    // Cell height follows the width, so cells stay roughly square, capped so
    // they do not balloon on a tablet.
    final cellWidth =
        (width - (_gutter * 2) - (_cellSpacing * (_gridColumns - 1))) /
            _gridColumns;
    var cellExtent = cellWidth.clamp(_minCellExtent, _maxCellExtent);

    const chrome =
        _headerHeight + _weekdayRowHeight + _actionsHeight + _verticalPadding;
    const gaps = _cellSpacing * (_gridRows - 1);

    var height = chrome + (cellExtent * _gridRows) + gaps;

    if (height > maxHeight) {
      // Not enough room -- a phone in landscape, typically. Shrink the cells
      // towards the floor; below it the grid scrolls rather than the dialog
      // overflowing or a row going unbuilt.
      final budget = maxHeight - chrome - gaps;
      cellExtent = math.max(budget / _gridRows, _minCellExtent);
      height = math.min(maxHeight, chrome + (cellExtent * _gridRows) + gaps);
    }

    return _PickerMetrics(
      width: width,
      height: height,
      cellExtent: cellExtent,
    );
  }

  Widget _buildContent(double cellExtent) {
    final isDayView = viewMode == NepaliDatePickerMode.day;

    // The grid takes exactly the width its cells need and sits centred, rather
    // than stretching to the dialog's width -- which is set by the actions row
    // and is wider. Stretching would give oblong cells on every screen.
    final gridWidth =
        (cellExtent * _gridColumns) + (_cellSpacing * (_gridColumns - 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _headerHeight, child: _buildHeader()),
        // The weekday row means nothing outside the day grid. Total height is
        // fixed either way, so hiding it hands the space to the grid rather
        // than making the dialog jump.
        if (isDayView)
          SizedBox(
            height: _weekdayRowHeight,
            child: Center(
              child: SizedBox(width: gridWidth, child: _buildWeekDayHeaders()),
            ),
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _verticalPadding / 2,
              ),
              child: SizedBox(
                width: gridWidth,
                child: AnimatedSwitcher(
                  duration: _transitionDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(viewMode),
                    child: switch (viewMode) {
                      NepaliDatePickerMode.day => _buildDayGrid(),
                      NepaliDatePickerMode.month => _buildMonthGrid(),
                      NepaliDatePickerMode.year => _buildYearGrid(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: _actionsHeight, child: _buildActions()),
      ],
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

  /// Actions: Today on the left, Cancel and confirm on the right.
  ///
  /// Today sits here rather than in the header, where it used to take the most
  /// prominent corner despite being the least-used control.
  Widget _buildActions() {
    final nepali = _style.effectiveConfig.language == Language.nepali;
    // Today is meaningless when it falls outside the allowed range.
    final todayIsReachable = _isSelectable(NepaliDateTime.now());

    // No Flexible on the buttons: they take their natural width and the Spacer
    // absorbs the rest. Wrapping them in Flexible made them compete with the
    // Spacer for free space, so "रद्द गर्नुहोस्" ellipsised to "रद्द गर्नुह..."
    // on a screen with room to spare.
    // Tight padding rather than a wider dialog. The Nepali labels are much
    // longer than the English ones ("रद्द गर्नुहोस्" vs "Cancel"), and at the
    // default TextButton padding all three together do not fit a compact
    // picker on a phone.
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, _actionsHeight - 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (todayIsReachable)
            TextButton(
              onPressed: _goToToday,
              style: style,
              child: Text(nepali ? 'आज' : 'Today', softWrap: false),
            )
          else
            const SizedBox.shrink(),
          // One Flexible taking the remaining space, rather than a Flexible
          // sitting next to a Spacer. Both default to flex: 1, so that pairing
          // *splits* the free space and the labels ellipsised with room to
          // spare -- "रद्द गर्नुह..." on a full-size phone. Here the labels
          // take their natural width and only shrink when they genuinely
          // cannot fit, as at a large text scale.
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: _handleCancel,
                    style: style,
                    child: Text(
                      widget.cancelText ??
                          (nepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _handleConfirm,
                  style: style,
                  child: Text(
                    widget.confirmText ?? (nepali ? 'ठीक छ' : 'OK'),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
