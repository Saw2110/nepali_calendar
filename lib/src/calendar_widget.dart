// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar utilities
import 'src.dart';

// Main Nepali Calendar widget with generic event type T
class NepaliCalendar<T> extends StatefulWidget {
  // Initial date to display in calendar
  final NepaliDateTime? initialDate;
  // Optional list of calendar events
  final List<CalendarEvent<T>>? eventList;
  // Optional function to determine if an event is a holiday
  final bool Function(CalendarEvent<T> event)? checkIsHoliday;
  // Style configuration for the calendar
  final NepaliCalendarStyle calendarStyle;
  // Callback when month is changed
  final void Function(NepaliDateTime _)? onMonthChanged;
  // Callback when day is changed
  final void Function(NepaliDateTime _)? onDayChanged;

  // Optional custom builder for event items
  final Widget? Function(
    BuildContext context,
    int index,
    NepaliDateTime _,
    CalendarEvent<T> event,
  )? eventBuilder;

  // Constructor with optional parameters
  const NepaliCalendar({
    super.key,
    this.initialDate,
    this.eventList,
    this.checkIsHoliday,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onMonthChanged,
    this.onDayChanged,
    this.eventBuilder,
  }) : assert(
          eventList == null || checkIsHoliday != null,
          'checkIsHoliday must be provided when eventList is not null',
        );
  @override
  State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
}

// State class for NepaliCalendar
class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
  // Controller for page view
  late PageController _pageController;
  // Currently displayed date
  late NepaliDateTime _currentDate;
  // Currently selected date
  late NepaliDateTime _selectedDate;
  // Current page index in page view
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    // Initialize dates with provided initial date or current date
    _currentDate = widget.initialDate ?? NepaliDateTime.now();
    _selectedDate = _currentDate;
    _initializePageController();
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
    final calendarStyle = widget.calendarStyle;
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
          children: [
            // Calendar card containing header and month view
            Card(
              elevation: 0,
              child: Column(
                children: [
                  // Calendar header with navigation
                  CalendarHeader(
                    selectedDate: _selectedDate,
                    pageController: _pageController,
                    calendarStyle: calendarStyle,
                  ),
                  // Month view showing days grid
                  CalendarMonthView<T>(
                    year: year,
                    month: month,
                    selectedDate: _selectedDate,
                    eventList: widget.eventList,
                    calendarStyle: calendarStyle,
                    onDaySelected: (date) {
                      _updateCurrentDate(date.year, date.month, date.day);
                    },
                  ),
                ],
              ),
            ),
            // Event list for selected date
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
