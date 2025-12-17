import 'package:flutter/material.dart';

import '../src.dart';

/// A class that manages all custom builders for the Nepali Calendar.
///
/// This class provides a centralized way to customize the appearance and
/// behavior of different calendar components through builder functions.
///
/// Example usage:
/// ```dart
/// final calendarBuilder = NepaliCalendarBuilder<MyEventType>(
///   headerBuilder: (date, controller) => MyCustomHeader(date),
///   cellBuilder: (data) => MyCustomCell(data),
///   weekdayBuilder: (data) => MyCustomWeekday(data),
///   eventBuilder: (context, index, event) => MyEventWidget(event),
/// );
///
/// NepaliCalendar(
///   calendarBuilder: calendarBuilder,
///   // ... other properties
/// )
/// ```
class CalendarBuilder<T> {
  /// Custom header builder for the calendar.
  ///
  /// Provides the selected date and page controller for navigation.
  /// If null, the default [CalendarHeader] will be used.
  ///
  /// Example:
  /// ```dart
  /// headerBuilder: (date, controller) {
  ///   return Row(
  ///     children: [
  ///       IconButton(
  ///         icon: Icon(Icons.arrow_back),
  ///         onPressed: () => controller.previousPage(...),
  ///       ),
  ///       Text('${date.month}/${date.year}'),
  ///       IconButton(
  ///         icon: Icon(Icons.arrow_forward),
  ///         onPressed: () => controller.nextPage(...),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  final Widget? Function(
    NepaliDateTime date,
    PageController controller,
  )? headerBuilder;

  /// Custom cell builder for individual calendar date cells.
  ///
  /// Provides comprehensive data about the cell including date, state,
  /// and styling information through [CalendarCellData].
  ///
  /// If null, the default [CalendarCell] will be used.
  ///
  /// Example:
  /// ```dart
  /// cellBuilder: (data) {
  ///   return Container(
  ///     decoration: BoxDecoration(
  ///       color: data.isToday ? Colors.blue : Colors.white,
  ///       border: Border.all(color: Colors.grey),
  ///     ),
  ///     child: Center(
  ///       child: Text('${data.day}'),
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(CalendarCellData<T> data)? cellBuilder;

  /// Custom weekday header builder.
  ///
  /// Provides data about the weekday including index, language, and
  /// weekend status through [WeekdayData].
  ///
  /// If null, the default [WeekdayHeader] will be used.
  ///
  /// Example:
  /// ```dart
  /// weekdayBuilder: (data) {
  ///   return Text(
  ///     data.weekdayName,
  ///     style: TextStyle(
  ///       color: data.isWeekend ? Colors.red : Colors.black,
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(WeekdayData data)? weekdayBuilder;

  /// Custom event builder for individual event items in the event list.
  ///
  /// Provides context, index, selected date, and event data.
  /// If null, a default event widget will be used.
  ///
  /// Example:
  /// ```dart
  /// eventBuilder: (context, index, date, event) {
  ///   return ListTile(
  ///     title: Text(event.additionalInfo.title),
  ///     subtitle: Text(event.date.toString()),
  ///     leading: Icon(
  ///       event.isHoliday ? Icons.celebration : Icons.event,
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget? Function(
    BuildContext context,
    int index,
    NepaliDateTime date,
    CalendarEvent<T> event,
  )? eventBuilder;

  /// Creates a [CalendarBuilder] instance with customizable builder functions.
  ///
  /// All parameters are optional. If a builder is not provided, the default
  /// implementation will be used.
  const CalendarBuilder({
    this.headerBuilder,
    this.cellBuilder,
    this.weekdayBuilder,
    this.eventBuilder,
  });

  /// Creates a copy of this builder with the given fields replaced with new values.
  CalendarBuilder<T> copyWith({
    Widget? Function(NepaliDateTime, PageController)? headerBuilder,
    Widget Function(CalendarCellData<T>)? cellBuilder,
    Widget Function(WeekdayData)? weekdayBuilder,
    Widget? Function(BuildContext, int, NepaliDateTime, CalendarEvent<T>)?
        eventBuilder,
  }) {
    return CalendarBuilder<T>(
      headerBuilder: headerBuilder ?? this.headerBuilder,
      cellBuilder: cellBuilder ?? this.cellBuilder,
      weekdayBuilder: weekdayBuilder ?? this.weekdayBuilder,
      eventBuilder: eventBuilder ?? this.eventBuilder,
    );
  }
}

/// Data class providing comprehensive information for building a calendar cell.
class CalendarCellData<T> {
  /// The Nepali date for this cell
  final NepaliDateTime date;

  /// The day number (1-32)
  final int day;

  /// Whether this cell represents today's date
  final bool isToday;

  /// Whether this cell is currently selected
  final bool isSelected;

  /// Whether this cell is dimmed (previous/next month dates)
  final bool isDimmed;

  /// Whether this date falls on a weekend
  final bool isWeekend;

  /// The event associated with this date, if any
  final CalendarEvent<T>? event;

  /// Callback to invoke when the cell is tapped
  final VoidCallback onTap;

  /// The calendar style configuration for accessing colors and text styles
  final NepaliCalendarStyle style;

  const CalendarCellData({
    required this.date,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isDimmed,
    required this.isWeekend,
    required this.event,
    required this.onTap,
    required this.style,
  });
}

/// Data class providing information for building a weekday header.
class WeekdayData {
  /// The weekday index (0=Sunday, 1=Monday, ..., 6=Saturday)
  final int weekday;

  /// The display language for the weekday name
  final Language language;

  /// Whether this weekday is considered a weekend
  final bool isWeekend;

  /// The format for displaying the weekday name (full, half, short)
  final TitleFormat format;

  /// The calendar style configuration
  final NepaliCalendarStyle style;

  /// The formatted weekday name based on language and format
  String get weekdayName =>
      WeekUtils.formattedWeekDay(weekday, language, format);

  const WeekdayData({
    required this.weekday,
    required this.language,
    required this.isWeekend,
    required this.format,
    required this.style,
  });
}

/// Data class providing information for building an event list.
class EventListData<T> {
  /// The build context
  final BuildContext context;

  /// The list of events for the selected date
  final List<CalendarEvent<T>> events;

  /// The currently selected date
  final NepaliDateTime selectedDate;

  /// Optional default event builder function
  final Widget? Function(BuildContext, int, CalendarEvent<T>)?
      defaultEventBuilder;

  const EventListData({
    required this.context,
    required this.events,
    required this.selectedDate,
    this.defaultEventBuilder,
  });
}
