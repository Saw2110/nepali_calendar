// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';

/// Lists every event in the month of [selectedDate].
///
/// Despite the parameter name this is a **month** list, not a single-day one:
/// selecting the 14th shows the whole month's events, with the selected date
/// only deciding which month that is.
///
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
  final List<CalendarEvent<T>>? eventList;

  /// A prebuilt index over [eventList].
  ///
  /// When null, one is built from [eventList] on each build.
  final CalendarEventIndex<T>? eventIndex;

  /// The date whose **month** is listed.
  ///
  /// Only the year and month are read: the list shows every event in that
  /// month, not only those on this exact day. The day component is ignored.
  final NepaliDateTime selectedDate;
  final Widget? Function(
    BuildContext context,
    int index,
    CalendarEvent<T> event,
  )? itemBuilder;

  const EventList({
    super.key,
    required this.eventList,
    this.eventIndex,
    required this.selectedDate,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (eventList == null && eventIndex == null) {
      return const SizedBox.shrink();
    }

    // Events for the selected month, from the index rather than by scanning
    // the whole list on every build.
    final index = eventIndex ?? CalendarEventIndex<T>.fromList(eventList);
    final eventsForMonth =
        index.eventsInMonth(selectedDate.year, selectedDate.month);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventsForMonth.length,
      itemBuilder: (context, index) {
        final event = eventsForMonth[index];
        final isHoliday = event.isHoliday;

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
