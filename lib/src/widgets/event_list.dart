// Import Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom source file containing calendar-related utilities
import '../src.dart';

// Widget to display a list of calendar events with generic type T
class EventList<T> extends StatelessWidget {
  // Optional list of calendar events
  final List<CalendarEvent<T>>? eventList;
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
    required this.selectedDate,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no events
    if (eventList == null) return const SizedBox.shrink();

    // Filter events for selected month and year
    final eventsForMonth = eventList!.where(
      (event) =>
          event.eventDate.month == selectedDate.month &&
          event.eventDate.year == selectedDate.year,
    );

    // Build scrollable list of events
    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventsForMonth.length,
      itemBuilder: (context, index) {
        // Get event at current index
        final event = eventsForMonth.elementAt(index);
        // Check if event is marked as holiday
        final isHoliday = event.isHoliday;

        // Use custom item builder if provided, otherwise use default ListTile
        return itemBuilder?.call(context, index, event) ??
            ListTile(
              title: Text(event.eventDate.toString()),
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
