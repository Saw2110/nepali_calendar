import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../data/sample_events.dart';
import '../../widgets/event_tile.dart';

/// [CalendarEventIndex] on its own, without a calendar around it.
///
/// The index is just a date-keyed lookup over a list of [CalendarEvent]s, so it
/// is useful anywhere you need "what is on this day?" -- an agenda, a badge on
/// a home screen, a day detail sheet -- not only inside the calendar widgets.
///
/// The whole API is five calls, all of them O(1):
///
/// * `eventsOn(date)`      -- every event on a day, not just the first
/// * `hasEventsOn(date)`   -- is there anything at all
/// * `isHoliday(date)`     -- is any event on that day a holiday
/// * `firstEventOn(date)`  -- one event, or null
/// * `eventsInMonth(y, m)` -- the whole month
class EventIndexExample extends StatefulWidget {
  const EventIndexExample({super.key, required this.language});

  final Language language;

  @override
  State<EventIndexExample> createState() => _EventIndexExampleState();
}

class _EventIndexExampleState extends State<EventIndexExample> {
  /// Build the index once, in a field -- not in `build`. Indexing walks the
  /// whole event list, and doing that per frame is the cost the index exists to
  /// avoid in the first place.
  late final CalendarEventIndex<Events> _index =
      CalendarEventIndex.fromList(eventList);

  /// Starts on a date that actually has events, so the first thing on screen
  /// is a hit rather than an empty state.
  NepaliDateTime _date = NepaliDateTime(year: 2083, month: 1, day: 1);

  /// Steps a day at a time, rolling over month and year ends.
  void _stepDay(int delta) {
    setState(() {
      var year = _date.year;
      var month = _date.month;
      var day = _date.day + delta;

      if (day < 1) {
        month -= 1;
        if (month < 1) {
          month = 12;
          year -= 1;
        }
        day = CalendarUtils.nepaliYears[year]![month];
      } else if (day > CalendarUtils.nepaliYears[year]![month]) {
        day = 1;
        month += 1;
        if (month > 12) {
          month = 1;
          year += 1;
        }
      }

      _date = NepaliDateTime(year: year, month: month, day: day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The five lookups. Each one is a map hit -- no scanning of eventList.
    final events = _index.eventsOn(_date);
    final hasEvents = _index.hasEventsOn(_date);
    final isHoliday = _index.isHoliday(_date);
    final first = _index.firstEventOn(_date);
    final monthCount = _index.eventsInMonth(_date.year, _date.month).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // -- the date being queried --------------------------------------
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => _stepDay(-1),
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous day',
            ),
            Expanded(
              child: Text(
                '${MonthUtils.formattedMonth(_date.month, widget.language)} '
                '${_date.day}, ${_date.year}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => _stepDay(1),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next day',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // -- what the index says about it --------------------------------
        _IndexRow(call: 'hasEventsOn(date)', result: '$hasEvents'),
        _IndexRow(call: 'isHoliday(date)', result: '$isHoliday'),
        _IndexRow(call: 'eventsOn(date).length', result: '${events.length}'),
        _IndexRow(
          call: 'firstEventOn(date)',
          result: first?.additionalInfo?.title ?? 'null',
        ),
        _IndexRow(
          call: 'eventsInMonth(year, month).length',
          result: '$monthCount',
        ),

        const Divider(height: 32),

        // -- and the events themselves -----------------------------------
        // `eventsOn` keeps every event on a date, so a day with a holiday and
        // an ordinary event returns both.
        if (events.isEmpty)
          Text(
            'No events on this day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          )
        else
          ...events.map(
            (event) => EventTile(event: event, language: widget.language),
          ),
      ],
    );
  }
}

/// One `call -> result` line. Monospace on the left so the calls line up.
class _IndexRow extends StatelessWidget {
  const _IndexRow({required this.call, required this.result});

  final String call;
  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              call,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              result,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
