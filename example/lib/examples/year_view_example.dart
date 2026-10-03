import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../data/sample_events.dart';

/// A whole year on one screen: [NepaliYearCalendar].
class YearCalendarExample extends StatefulWidget {
  const YearCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<YearCalendarExample> createState() => _YearCalendarExampleState();
}

class _YearCalendarExampleState extends State<YearCalendarExample> {
  NepaliDateTime? _selected;

  /// The year to open on.
  ///
  /// Deliberately the year the sample events fall in rather than the current
  /// one, so the event and holiday indicators are actually visible. Today's
  /// highlight is demonstrated on the Calendar tab.
  int get _demoYear =>
      eventList.map((event) => event.date.year).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NepaliYearCalendar<Events>(
            year: _demoYear,
            initialDate: _selected,
            eventList: eventList,
            calendarStyle: NepaliCalendarStyle(
              // Config only: no appearance is set here, so the ambient
              // NepaliCalendarTheme still supplies the colours.
              config: CalendarConfig(language: widget.language),
            ),
            // Two per row on a phone, more when there is room.
            monthsPerRow: 2,
            onDaySelected: (date) => setState(() => _selected = date),
          ),
        ),
        if (_selected != null) _buildSelectionBar(context, _selected!),
      ],
    );
  }

  Widget _buildSelectionBar(BuildContext context, NepaliDateTime date) {
    final events = CalendarEventIndex.fromList(eventList).eventsOn(date);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${MonthUtils.formattedMonth(date.month, widget.language)} '
            '${date.day}, ${date.year}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          if (events.isEmpty)
            Text('No events', style: theme.textTheme.bodySmall)
          else
            // A date can hold several events; show them all.
            ...events.map(
              (event) => Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: event.isHoliday
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${event.additionalInfo?.title ?? ''}'
                      '${event.isHoliday ? ' (holiday)' : ''}',
                      style: theme.textTheme.bodyMedium,
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
