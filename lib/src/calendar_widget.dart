// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math' as math;

// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import 'src.dart';

/// Largest height a single day cell is allowed to take.
///
/// Without a cap the month view scales with viewport *width*, which makes the
/// calendar as tall as the window is wide on tablets, desktop and web.
const double _maxCellHeight = 64.0;

/// Smallest height a day cell may shrink to before it stops being a usable
/// tap target. Below this the calendar would rather overflow than be unusable.
const double _minCellHeight = 32.0;

/// Share of the available height the month grid may occupy.
///
/// The grid sits in a [Column] alongside the header and the event list, so its
/// own [LayoutBuilder] is handed an unbounded height and cannot see what is
/// left for it. [NepaliCalendar] measures the height it was actually given and
/// hands the grid this share of it, leaving the rest for the header above and
/// the event list below.
///
/// Measured, not assumed: up to 0.0.7 this was a fraction of the *screen*
/// height, so putting anything above the calendar -- a toolbar, a filter row --
/// overflowed it by however tall that thing was.
const double _gridHeightFraction = 0.62;

/// One weekday-header row plus the most date rows a month can need.
///
/// Cells are sized against this rather than against the row count of the month
/// on screen, so that swiping from a five-row month to a six-row one changes
/// the calendar's height without also resizing every cell in it.
const int _totalRows = 1 + CalendarUtils.maxWeekRowsInMonth;

/// [CalendarMonthView] wraps itself in 8px of padding on every side.
const double _monthViewPadding = 16.0;

// // Main Nepali Calendar widget with generic event type T
class NepaliCalendar<T> extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final List<CalendarEvent<T>>? eventList;

  /// Whether an event marks its date as a holiday.
  ///
  /// **Deprecated and unused.** [CalendarEvent.isHoliday] already carries this,
  /// and that is what the calendar reads -- this callback's return value has
  /// never been consulted. It was only ever enforced by an assertion that made
  /// it mandatory alongside [eventList].
  ///
  /// Passing it is now optional and has no effect. Set
  /// [CalendarEvent.isHoliday] on the event instead.
  @Deprecated(
    'Unused: the calendar reads CalendarEvent.isHoliday instead. Passing this '
    'has no effect and it is no longer required. Will be removed in 1.0.0.',
  )
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
  ///   calendarBuilder: CalendarBuilder(
  ///     headerBuilder: (date, controller) => MyHeader(date),
  ///     cellBuilder: (data) => MyCell(data),
  ///     eventBuilder: (context, index, date, event) => MyEvent(event),
  ///   ),
  /// )
  /// ```
  final CalendarBuilder<T>? calendarBuilder;

  /// Custom header builder for the calendar.
  ///
  /// **Deprecated:** Use [calendarBuilder] with [CalendarBuilder.headerBuilder] instead.
  ///
  /// This will be removed in 1.0.0.
  @Deprecated(
    'Use calendarBuilder.headerBuilder instead. Will be removed in 1.0.0.',
  )
  final Widget? Function(
    NepaliDateTime nepaliDateTime,
    PageController pageController,
  )? headerBuilder;

  /// Custom event builder for individual event items.
  ///
  /// **Deprecated:** Use [calendarBuilder] with [CalendarBuilder.eventBuilder] instead.
  ///
  /// This will be removed in 1.0.0.
  @Deprecated(
    'Use calendarBuilder.eventBuilder instead. Will be removed in 1.0.0.',
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
    @Deprecated('Unused; set CalendarEvent.isHoliday instead')
    this.checkIsHoliday,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onMonthChanged,
    this.onDayChanged,
    this.calendarBuilder,
    @Deprecated('Use calendarBuilder.eventBuilder instead') this.eventBuilder,
    this.controller,
    @Deprecated('Use calendarBuilder.headerBuilder instead') this.headerBuilder,
  });
  // The assertion requiring checkIsHoliday alongside eventList has been
  // dropped. It forced callers to supply a callback whose result was never
  // read -- holidays come from CalendarEvent.isHoliday. Removing a constraint
  // cannot break a caller that satisfied it.

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

  /// Date-keyed index over [NepaliCalendar.eventList].
  ///
  /// Built once per event-list change rather than per month page: the PageView
  /// builds several months at a time, and each month asks after 35 or 42 dates.
  late CalendarEventIndex<T> _eventIndex;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? NepaliDateTime.now();
    _selectedDateNotifier = ValueNotifier(_currentDate);
    _initializePageController();
    _currentPageIndexNotifier = ValueNotifier(_currentPageIndex);
    _eventIndex = CalendarEventIndex<T>.fromList(widget.eventList);

    // Initialize controller if provided
    widget.controller?.init(
      selectedDateCallback: _handleDateChanged,
      initialDate: _currentDate,
    );
  }

  @override
  void didUpdateWidget(NepaliCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-index when the events change. Identity is the right test here: the
    // list is not owned by this widget and could be mutated in place, so a
    // deep comparison would be both costly and unreliable.
    if (!identical(widget.eventList, oldWidget.eventList)) {
      _eventIndex = CalendarEventIndex<T>.fromList(widget.eventList);
    }

    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      widget.controller?.init(
        selectedDateCallback: _handleDateChanged,
        initialDate: _selectedDateNotifier.value,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectedDateNotifier.dispose();
    _currentPageIndexNotifier.dispose();
    super.dispose();
  }

  // Handle date changes from controller
  void _handleDateChanged(
    NepaliDateTime date, {
    required bool runCallback,
    required bool animate,
  }) {
    final pageIndex =
        ((date.year - CalendarUtils.calenderyearStart) * 12) + date.month - 1;

    if (animate) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(pageIndex);
    }

    _updateCurrentDate(date.year, date.month, date.day, runCallback);
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
  void _updateCurrentDate(
    int year,
    int month,
    int day, [
    bool runCallback = true,
  ]) {
    final previousDate = _selectedDateNotifier.value;
    final newDate = NepaliDateTime(year: year, month: month, day: day);
    _selectedDateNotifier.value = newDate;

    // Update controller's internal state
    widget.controller?.selectedDate = newDate;

    // Call appropriate callback based on what changed
    if (runCallback) {
      if (previousDate.month != month || previousDate.year != year) {
        widget.onMonthChanged?.call(newDate);
      } else {
        widget.onDayChanged?.call(newDate);
      }
    }
  }

  /// How many date rows are on screen right now, as a fraction.
  ///
  /// A Nepali month needs five or six rows depending on the weekday it starts
  /// on. During a swipe both the outgoing and incoming month are visible, so
  /// there is no single right answer -- this interpolates between the two by
  /// how far the swipe has travelled, which is what lets the calendar's height
  /// follow the drag rather than jump once it settles.
  double _visibleWeekRows(NepaliCalendarStyle calendarStyle) {
    final config = calendarStyle.effectiveConfig;
    if (config.sixWeekMonthsEnforced) {
      return CalendarUtils.maxWeekRowsInMonth.toDouble();
    }

    // `page` is only readable once the PageView has been laid out; before then
    // the last settled index is the best available answer.
    final fallback = _currentPageIndexNotifier.value.toDouble();
    final page =
        _pageController.hasClients && _pageController.position.haveDimensions
            ? (_pageController.page ?? fallback)
            : fallback;

    final lastPage = (CalendarUtils.nepaliYears.length * 12) - 1;
    final from = page.floor().clamp(0, lastPage);
    final to = page.ceil().clamp(0, lastPage);

    final fromRows = _weekRowsForPage(from, config.weekStartType);
    if (to == from) return fromRows.toDouble();

    final toRows = _weekRowsForPage(to, config.weekStartType);
    final t = (page - from).clamp(0.0, 1.0);
    return fromRows + ((toRows - fromRows) * t);
  }

  /// The row count of the month a PageView index maps to.
  int _weekRowsForPage(int index, WeekStartType weekStartType) =>
      CalendarUtils.weekRowsInMonth(
        CalendarUtils.calenderyearStart + (index ~/ 12),
        (index % 12) + 1,
        weekStartType,
      );

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > pre-0.1.0 defaults.
    final calendarStyle =
        NepaliCalendarTheme.resolve(context, widget.calendarStyle);

    // Measure the height actually on offer rather than assuming the calendar
    // owns the screen. Anything placed above it -- a toolbar, a filter row --
    // shrinks what it gets, and sizing from MediaQuery would overflow by
    // exactly that much.
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final availableHeight = outerConstraints.hasBoundedHeight
            ? outerConstraints.maxHeight
            // Unbounded: inside a scroll view, say. Nothing better to measure
            // against, so fall back to the screen.
            : MediaQuery.sizeOf(context).height;

        return _buildCalendar(context, calendarStyle, availableHeight);
      },
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    NepaliCalendarStyle calendarStyle,
    double availableHeight,
  ) {
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
                  // The month view is one weekday-header row plus six date
                  // rows, all seven columns wide.
                  //
                  // Up to 0.0.7 cells were always square, which made the whole
                  // calendar as tall as the viewport was wide: on anything
                  // wider than a phone -- a tablet, desktop window or browser
                  // -- it overflowed its parent. Cap the cell height instead,
                  // so cells grow sideways on wide viewports rather than the
                  // calendar growing without bound.
                  //
                  // Measure against the width the grid actually gets, which is
                  // what is left after CalendarMonthView's own padding. Up to
                  // 0.0.7 this divided the full width, so every row came out
                  // narrower -- and therefore shorter -- than the budget
                  // assumed, leaving a dead strip at the bottom of each page
                  // worth roughly the padding itself.
                  final gridWidth =
                      math.max(0.0, constraints.maxWidth - _monthViewPadding);
                  final cellWidth = gridWidth / 7;

                  // Square cells, but never taller than the cap, and never
                  // taller than the height budget allows -- the latter is what
                  // keeps a phone in landscape from overflowing. Never smaller
                  // than the minimum, so the cells stay tappable.
                  final heightBudget =
                      (availableHeight * _gridHeightFraction) / _totalRows;
                  final cellHeight = math.max(
                    _minCellHeight,
                    math.min(math.min(cellWidth, _maxCellHeight), heightBudget),
                  );
                  // A viewport can be handed zero width -- a collapsed pane, a
                  // page mid-transition, a parent that lays out before it has
                  // measured itself -- and `SliverGridDelegateWithFixedCross
                  // AxisCount` asserts on a ratio that is not positive and
                  // finite. Fall back to square cells for those frames rather
                  // than throwing; the next frame with real width corrects it.
                  final rawAspectRatio = cellWidth / cellHeight;
                  final cellAspectRatio =
                      rawAspectRatio > 0 && rawAspectRatio.isFinite
                          ? rawAspectRatio
                          : 1.0;

                  // CalendarMonthView adds 8px padding all round, and spaces
                  // the header off the grid unless borders are drawn.
                  final rowSpacing =
                      calendarStyle.effectiveConfig.showBorder ? 0.0 : 10.0;
                  final chrome = rowSpacing + _monthViewPadding + cellHeight;

                  final pageView = PageView.builder(
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

                          // Mid-swipe the viewport is somewhere between the
                          // outgoing and incoming months' heights, so a
                          // six-row month can be handed less room than it
                          // needs. Let it lay out at its natural height and
                          // clip the surplus off the bottom -- constraining
                          // it instead would make the month view's Column
                          // report an overflow on every frame of the swipe.
                          return ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              minHeight: 0,
                              maxHeight: double.infinity,
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity,
                                  child: child,
                                ),
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
                              eventIndex: _eventIndex,
                              calendarStyle: calendarStyle,
                              cellAspectRatio: cellAspectRatio,
                              cellBuilder: widget.calendarBuilder?.cellBuilder,
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
                  );

                  // The viewport tracks the height of the month on screen, and
                  // interpolates between the two while a swipe is in flight --
                  // reacting on onPageChanged instead would snap after the
                  // page settled. The PageView is passed through as `child` so
                  // that resizing does not rebuild it every frame.
                  return AnimatedBuilder(
                    animation: _pageController,
                    child: pageView,
                    builder: (context, child) {
                      final gridHeight = chrome +
                          (cellHeight * _visibleWeekRows(calendarStyle));

                      return ClipRect(
                        child: SizedBox(height: gridHeight, child: child),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // Events for the selected date's *month* (outside PageView, animated).
        // Keyed by year-month, so it re-runs the transition when the month
        // changes rather than on every day tap.
        Expanded(
          child: ValueListenableBuilder<NepaliDateTime>(
            valueListenable: _selectedDateNotifier,
            builder: (context, selectedDate, _) {
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                // AnimatedSwitcher.defaultLayoutBuilder centres its child, and
                // the event list shrink-wraps its content: a month with one
                // event ended up floating in the middle of the space left
                // below the grid instead of sitting under it. Only months with
                // enough events to fill the space looked right.
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
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
                    '${selectedDate.year}-${selectedDate.month}',
                  ),
                  eventList: widget.eventList,
                  eventIndex: _eventIndex,
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
