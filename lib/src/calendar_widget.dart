// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import 'src.dart';

// // Main Nepali Calendar widget with generic event type T
class NepaliCalendar<T> extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(CalendarEvent<T> event)? checkIsHoliday;

  /// @Deprecated: Use theme instead
  @Deprecated(
    'Use theme instead. This will be removed in the next major version.',
  )
  CalendarTheme get calendarStyle => theme;

  /// Theme configuration for the calendar.
  ///
  /// Provides comprehensive styling options for all calendar elements.
  final CalendarTheme theme;
  final OnDateSelected? onMonthChanged;
  final OnDateSelected? onDayChanged;

  /// Controller for programmatic control of the calendar.
  ///
  /// Use this to:
  /// - Jump to specific dates
  /// - Navigate between months
  /// - Listen to selection changes
  /// - Control selection mode (single, range, multi)
  final NepaliCalendarController? controller;

  ///
  final Widget? Function(
    NepaliDateTime nepaliDateTime,
    PageController pageController,
  )? headerBuilder;

  final Widget? Function(
    BuildContext context,
    int index,
    NepaliDateTime _,
    CalendarEvent<T> event,
  )? eventBuilder;

  const NepaliCalendar({
    super.key,
    this.initialDate,
    this.eventList,
    this.checkIsHoliday,
    CalendarTheme? theme,
    this.onMonthChanged,
    this.onDayChanged,
    this.eventBuilder,
    this.controller,
    this.headerBuilder,
    // Deprecated parameter for backward compatibility
    @Deprecated('Use theme instead') CalendarTheme? calendarStyle,
  })  : theme = theme ?? calendarStyle ?? const CalendarTheme.defaults(),
        assert(
          eventList == null || checkIsHoliday != null,
          'checkIsHoliday must be provided when eventList is not null',
        );

  @override
  State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
}

// Modified State class
class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
  late PageController _pageController;
  late NepaliDateTime _currentDate;
  late NepaliDateTime _selectedDate;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ??
        widget.controller?.selectedDate ??
        NepaliDateTime.now();
    _selectedDate = _currentDate;
    _initializePageController();

    // Attach controller if provided
    _attachController();
  }

  @override
  void didUpdateWidget(NepaliCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachPageController();
      oldWidget.controller?.removeListener(_onControllerChanged);
      _attachController();
    }
  }

  void _attachController() {
    widget.controller?.attachPageController(_handlePageChangeRequest);
    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _selectedDate = widget.controller?.selectedDate ?? _selectedDate;
      });
    }
  }

  void _handlePageChangeRequest(int pageIndex, {bool animate = true}) {
    if (_pageController.hasClients) {
      if (animate) {
        _pageController.animateToPage(
          pageIndex,
          duration: widget.theme.animations.monthTransitionDuration,
          curve: widget.theme.animations.monthTransitionCurve,
        );
      } else {
        _pageController.jumpToPage(pageIndex);
      }
    }
  }

  @override
  void dispose() {
    // Detach controller when widget is disposed
    widget.controller?.detachPageController();
    widget.controller?.removeListener(_onControllerChanged);
    _pageController.dispose();
    super.dispose();
  }

  // Initialize page controller with correct initial page
  void _initializePageController() {
    _currentPageIndex =
        ((_currentDate.year - CalendarUtils.calenderyearStart) * 12) +
            _currentDate.month -
            1;
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  // Update current date and trigger appropriate callbacks
  void _updateCurrentDate(int year, int month, int day) {
    final previousDate = _selectedDate;
    _selectedDate = NepaliDateTime(year: year, month: month, day: day);

    // Update controller if attached
    widget.controller?.updateSelectedDate(_selectedDate);

    // Call appropriate callback based on what changed
    if (previousDate.month != month) {
      _onMonthChanged(month);
      return;
    }

    _onDayChanged(month, day);
  }

  // Handle month change
  void _onMonthChanged(int month) {
    setState(() {
      widget.onMonthChanged?.call(_selectedDate);
    });
  }

  // Handle day change
  void _onDayChanged(int month, int day) {
    setState(() {
      widget.onDayChanged?.call(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final spacing = theme.spacing;
    final borders = theme.borders;

    // Build scrollable calendar pages
    return PageView.builder(
      controller: _pageController,
      itemCount: CalendarUtils.nepaliYears.length * 12,
      onPageChanged: (index) {
        // Calculate year and month from page index
        final int year = CalendarUtils.calenderyearStart + (index ~/ 12);
        final int month = (index % 12) + 1;

        // Call month changed callback
        widget.onMonthChanged?.call(
          NepaliDateTime(
            year: year,
            month: month,
            day: _currentDate.day,
          ),
        );
        _updateCurrentDate(year, month, _currentDate.day);
      },
      itemBuilder: (context, index) {
        // Calculate year and month for current page
        final year = CalendarUtils.calenderyearStart + (index ~/ 12);
        final month = (index % 12) + 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar container with borders and spacing
            Container(
              margin: theme.calendarPadding,
              padding: spacing.calendarPadding,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: borders.calendarBorder,
                borderRadius: borders.calendarBorderRadius,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendar header with navigation
                  widget.headerBuilder?.call(_selectedDate, _pageController) ??
                      CalendarHeader(
                        selectedDate: _selectedDate,
                        pageController: _pageController,
                        calendarStyle: theme,
                      ),

                  // Spacing between header and weekdays
                  SizedBox(height: spacing.headerToWeekdaysSpacing),

                  // Month view showing days grid
                  CalendarMonthView<T>(
                    year: year,
                    month: month,
                    selectedDate: _selectedDate,
                    eventList: widget.eventList,
                    calendarStyle: theme,
                    onDaySelected: (date) {
                      _updateCurrentDate(date.year, date.month, date.day);
                    },
                  ),
                ],
              ),
            ),
            // Event list for selected date - only show if events exist
            if (widget.eventList != null && widget.eventList!.isNotEmpty)
              Flexible(
                child: EventList<T>(
                  eventList: widget.eventList,
                  selectedDate: _selectedDate,
                  itemBuilder: (context, index, event) =>
                      widget.eventBuilder?.call(
                    context,
                    index,
                    _selectedDate,
                    event,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// NepaliCalendarController is now exported from controllers/calendar_controller.dart
// See: lib/src/controllers/calendar_controller.dart for the full implementation
