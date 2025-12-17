// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import 'src.dart';

// // Main Nepali Calendar widget with generic event type T
class NepaliCalendar<T> extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(CalendarEvent<T> event)? checkIsHoliday;
  final NepaliCalendarStyle calendarStyle;
  final OnDateSelected? onMonthChanged;
  final OnDateSelected? onDayChanged;
  // Add controller parameter
  final NepaliCalendarController? controller;

  /// Custom builder for calendar components.
  ///
  /// Provides a centralized way to customize header, cells, weekdays, and events.
  /// This is the recommended way to customize calendar appearance.
  ///
  /// Example:
  /// ```dart
  /// NepaliCalendar(
  ///   calendarBuilder: NepaliCalendarBuilder(
  ///     headerBuilder: (date, controller) => MyHeader(date),
  ///     cellBuilder: (data) => MyCell(data),
  ///     eventBuilder: (context, index, date, event) => MyEvent(event),
  ///   ),
  /// )
  /// ```
  final NepaliCalendarBuilder<T>? calendarBuilder;

  /// Custom header builder for the calendar.
  ///
  /// **Deprecated:** Use [calendarBuilder] with [NepaliCalendarBuilder.headerBuilder] instead.
  ///
  /// This will be removed in a future version.
  @Deprecated(
    'Use calendarBuilder.headerBuilder instead. This will be removed in a future version.',
  )
  final Widget? Function(
    NepaliDateTime nepaliDateTime,
    PageController pageController,
  )? headerBuilder;

  /// Custom event builder for individual event items.
  ///
  /// **Deprecated:** Use [calendarBuilder] with [NepaliCalendarBuilder.eventBuilder] instead.
  ///
  /// This will be removed in a future version.
  @Deprecated(
    'Use calendarBuilder.eventBuilder instead. This will be removed in a future version.',
  )
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
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onMonthChanged,
    this.onDayChanged,
    this.calendarBuilder,
    @Deprecated('Use calendarBuilder.eventBuilder instead') this.eventBuilder,
    this.controller,
    @Deprecated('Use calendarBuilder.headerBuilder instead') this.headerBuilder,
  }) : assert(
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
  late ValueNotifier<NepaliDateTime> _selectedDateNotifier;
  late ValueNotifier<int> _currentPageIndexNotifier;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? NepaliDateTime.now();
    _selectedDateNotifier = ValueNotifier(_currentDate);
    _initializePageController();
    _currentPageIndexNotifier = ValueNotifier(_currentPageIndex);

    // Attach controller if provided
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    // Detach controller when widget is disposed
    widget.controller?._detach();
    _pageController.dispose();
    _selectedDateNotifier.dispose();
    _currentPageIndexNotifier.dispose();
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
    final previousDate = _selectedDateNotifier.value;
    final newDate = NepaliDateTime(year: year, month: month, day: day);
    _selectedDateNotifier.value = newDate;

    // Call appropriate callback based on what changed
    if (previousDate.month != month || previousDate.year != year) {
      widget.onMonthChanged?.call(newDate);
    } else {
      widget.onDayChanged?.call(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarStyle = widget.calendarStyle;

    return Column(
      children: [
        // Calendar card containing header and month view (outside PageView)
        Card(
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar header with navigation (updates via ValueNotifier)
              ValueListenableBuilder<NepaliDateTime>(
                valueListenable: _selectedDateNotifier,
                builder: (context, selectedDate, _) {
                  // Priority: calendarBuilder.headerBuilder > deprecated headerBuilder > default
                  final customHeader = widget.calendarBuilder?.headerBuilder
                          ?.call(selectedDate, _pageController) ??
                      widget.headerBuilder?.call(selectedDate, _pageController);

                  return customHeader ??
                      CalendarHeader(
                        selectedDate: selectedDate,
                        pageController: _pageController,
                        calendarStyle: calendarStyle,
                      );
                },
              ),

              // Only calendar grid in PageView (swipeable months)
              // Use LayoutBuilder to get available width and calculate height
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate height based on width for square cells
                  // 7 columns + 1 header row + 6 data rows + padding
                  final cellWidth = constraints.maxWidth / 7;
                  final gridHeight = (cellWidth * 7) + 16; // 6 rows + padding

                  return SizedBox(
                    height: gridHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: CalendarUtils.nepaliYears.length * 12,
                      // Add physics for smoother scrolling
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        // Calculate year and month from page index
                        final int year =
                            CalendarUtils.calenderyearStart + (index ~/ 12);
                        final int month = (index % 12) + 1;

                        // Update page index notifier
                        _currentPageIndexNotifier.value = index;

                        // Update current date and trigger callback
                        _updateCurrentDate(
                          year,
                          month,
                          _selectedDateNotifier.value.day,
                        );
                      },
                      itemBuilder: (context, index) {
                        // Calculate year and month for current page
                        final year =
                            CalendarUtils.calenderyearStart + (index ~/ 12);
                        final month = (index % 12) + 1;

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            // Calculate page offset for smooth transitions
                            double scale = 1.0;
                            double opacity = 1.0;

                            if (_pageController.position.haveDimensions) {
                              final double page =
                                  _pageController.page ?? index.toDouble();
                              final double offset = (page - index).abs();

                              // Smooth scale transition: 1.0 -> 0.85 (less dramatic)
                              // Using a curve for smoother interpolation
                              scale = 1.0 - (offset * 0.15).clamp(0.0, 0.15);

                              // Smooth opacity transition: 1.0 -> 0.5
                              // Faster fade to avoid "stuck" feeling
                              opacity = 1.0 - (offset * 0.5).clamp(0.0, 0.5);
                            }

                            return Center(
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: ValueListenableBuilder<NepaliDateTime>(
                            valueListenable: _selectedDateNotifier,
                            builder: (context, selectedDate, _) {
                              return CalendarMonthView<T>(
                                year: year,
                                month: month,
                                selectedDate: selectedDate,
                                eventList: widget.eventList,
                                calendarStyle: calendarStyle,
                                cellBuilder:
                                    widget.calendarBuilder?.cellBuilder,
                                weekdayBuilder:
                                    widget.calendarBuilder?.weekdayBuilder,
                                onDaySelected: (date) {
                                  _updateCurrentDate(
                                    date.year,
                                    date.month,
                                    date.day,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Event list for selected date (outside PageView with animation)
        Expanded(
          child: ValueListenableBuilder<NepaliDateTime>(
            valueListenable: _selectedDateNotifier,
            builder: (context, selectedDate, _) {
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: EventList<T>(
                  key: ValueKey(
                    '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  ),
                  eventList: widget.eventList,
                  selectedDate: selectedDate,
                  itemBuilder: (context, index, event) {
                    // Priority: calendarBuilder.eventBuilder > deprecated eventBuilder > null
                    return widget.calendarBuilder?.eventBuilder
                            ?.call(context, index, selectedDate, event) ??
                        widget.eventBuilder?.call(
                          context,
                          index,
                          selectedDate,
                          event,
                        );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NepaliCalendarController {
  _NepaliCalendarState? _calendarState;

  // Attach state to controller
  void _attach(_NepaliCalendarState state) {
    _calendarState = state;
  }

  // Detach state from controller
  void _detach() {
    _calendarState = null;
  }

  // Jump to specific date
  void jumpToDate(NepaliDateTime date) {
    if (_calendarState == null) return;

    final pageIndex =
        ((date.year - CalendarUtils.calenderyearStart) * 12) + date.month - 1;

    _calendarState!._pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _calendarState!._updateCurrentDate(date.year, date.month, date.day);
  }

  // Jump to today's date
  void jumpToToday() {
    final today = NepaliDateTime.now();
    jumpToDate(today);
  }

  // Get currently selected date
  NepaliDateTime? get selectedDate =>
      _calendarState?._selectedDateNotifier.value;
}
