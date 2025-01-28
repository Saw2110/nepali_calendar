import 'package:flutter/material.dart';

import '../src.dart';

class EventList<T> extends StatelessWidget {
  final List<CalendarEvent<T>>? eventList;
  final NepaliDateTime selectedDate;
  final bool Function(T? event)? checkIsHoliday;

  const EventList({
    super.key,
    required this.eventList,
    required this.selectedDate,
    this.checkIsHoliday,
  });

  @override
  Widget build(BuildContext context) {
    if (eventList == null) return const SizedBox.shrink();

    final eventsForMonth = eventList!.where(
      (event) =>
          event.date.month == selectedDate.month &&
          event.date.year == selectedDate.year,
    );

    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventsForMonth.length,
      itemBuilder: (context, index) {
        final event = eventsForMonth.elementAt(index);
        final isHoliday = checkIsHoliday?.call(event.events) ?? false;

        return ListTile(
          title: Text(event.events.toString()),
          subtitle: Text(event.date.toString()),
          leading: Column(
            children: [
              Text(event.date.day.toString()),
              Text(event.date.weekday.toString()),
            ],
          ),
          trailing: Icon(
            Icons.circle,
            size: 5,
            color: isHoliday ? Colors.red : Colors.blue,
          ),
        );
      },
    );
  }
}
