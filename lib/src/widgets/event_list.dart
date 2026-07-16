// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar-related utilities
import '../src.dart';

// Widget to display a list of calendar events with generic type T
/// The event list is an implementation detail of [NepaliCalendar]. To build
/// your own, query [CalendarEventIndex.eventsInMonth] and render it however
/// you like.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class EventList<T> extends StatelessWidget {
  // Optional list of calendar events
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList].
  ///
  /// When null, one is built from [eventList] on each build.
  final CalendarEventIndex<T>? eventIndex;

  // Currently selected date to filter events
  final NepaliDateTime selectedDate;
  // Optional custom builder for event list items
  final Widget? Function(
    BuildContext context,
    int index,
    CalendarEvent<T> event,
  )? itemBuilder;

  // Constructor with required and optional parameters
  const EventList({
    super.key,
    required this.eventList,
    this.eventIndex,
    required this.selectedDate,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no events
    if (eventList == null && eventIndex == null) {
      return const SizedBox.shrink();
    }

    // Events for the selected month. This used to be a linear `where` over the
    // whole list, re-scanned on each build and re-walked by `elementAt` for
    // every row -- quadratic in the number of events in the month.
    final index = eventIndex ?? CalendarEventIndex<T>.fromList(eventList);
    final eventsForMonth =
        index.eventsInMonth(selectedDate.year, selectedDate.month);

    // Build scrollable list of events
    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventsForMonth.length,
      itemBuilder: (context, index) {
        // Get event at current index
        final event = eventsForMonth[index];
        // Check if event is marked as holiday
        final isHoliday = event.isHoliday;

        // Use custom item builder if provided, otherwise use default ListTile
        return itemBuilder?.call(context, index, event) ??
            ListTile(
              title: Text(event.date.toString()),
              leading: Icon(
                Icons.circle,
                size: 5,
                // Use red for holidays, blue for regular events
                color: isHoliday ? Colors.red : Colors.blue,
              ),
            );
      },
    );
  }
}
