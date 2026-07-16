// ignore_for_file: avoid_redundant_argument_values, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  CalendarEvent<String> event(
    int year,
    int month,
    int day,
    String label, {
    bool isHoliday = false,
  }) {
    return CalendarEvent<String>(
      date: NepaliDateTime(year: year, month: month, day: day),
      isHoliday: isHoliday,
      additionalInfo: label,
    );
  }

  group('CalendarEventIndex', () {
    test('an empty or null list yields an empty index', () {
      expect(CalendarEventIndex<String>.fromList(null).isEmpty, isTrue);
      expect(CalendarEventIndex<String>.fromList([]).isEmpty, isTrue);
      expect(CalendarEventIndex<String>.empty().isEmpty, isTrue);
    });

    test('finds events by day', () {
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 1, 'a'),
        event(2081, 1, 5, 'b'),
      ]);

      expect(
        index
            .eventsOn(NepaliDateTime(year: 2081, month: 1, day: 1))
            .single
            .additionalInfo,
        'a',
      );
      expect(
        index.eventsOn(NepaliDateTime(year: 2081, month: 1, day: 2)),
        isEmpty,
      );
    });

    /// The capability the old `firstWhere` lookup could not express at all.
    test('keeps every event on a date, in order', () {
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 1, 'first'),
        event(2081, 1, 1, 'second'),
        event(2081, 1, 1, 'third'),
      ]);

      final events =
          index.eventsOn(NepaliDateTime(year: 2081, month: 1, day: 1));

      expect(events.map((e) => e.additionalInfo), ['first', 'second', 'third']);
    });

    test('ignores the time component when matching a day', () {
      final index = CalendarEventIndex.fromList([
        CalendarEvent<String>(
          date: NepaliDateTime(year: 2081, month: 1, day: 1, hour: 14),
          additionalInfo: 'afternoon',
        ),
      ]);

      expect(
        index.eventsOn(NepaliDateTime(year: 2081, month: 1, day: 1)),
        hasLength(1),
      );
    });

    test('does not confuse dates that pack to similar keys', () {
      // A naive key such as year*10000 + month*100 + day is fine, but a
      // sloppier one (say year + month + day) would collide here.
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 11, 'jan 11'),
        event(2081, 11, 1, 'nov 1'),
        event(2082, 1, 1, 'next year'),
      ]);

      expect(
        index
            .eventsOn(NepaliDateTime(year: 2081, month: 1, day: 11))
            .single
            .additionalInfo,
        'jan 11',
      );
      expect(
        index
            .eventsOn(NepaliDateTime(year: 2081, month: 11, day: 1))
            .single
            .additionalInfo,
        'nov 1',
      );
      expect(
        index
            .eventsOn(NepaliDateTime(year: 2082, month: 1, day: 1))
            .single
            .additionalInfo,
        'next year',
      );
    });

    test('finds events by month', () {
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 1, 'a'),
        event(2081, 1, 20, 'b'),
        event(2081, 2, 1, 'other month'),
        event(2080, 1, 1, 'other year'),
      ]);

      expect(
        index.eventsInMonth(2081, 1).map((e) => e.additionalInfo),
        ['a', 'b'],
      );
      expect(index.eventsInMonth(2081, 3), isEmpty);
    });

    test('isHoliday is true if any event on the date is a holiday', () {
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 1, 'ordinary'),
        event(2081, 1, 1, 'festival', isHoliday: true),
        event(2081, 1, 2, 'ordinary only'),
      ]);

      expect(
        index.isHoliday(NepaliDateTime(year: 2081, month: 1, day: 1)),
        isTrue,
        reason: 'the holiday is second in the list, not first',
      );
      expect(
        index.isHoliday(NepaliDateTime(year: 2081, month: 1, day: 2)),
        isFalse,
      );
    });

    test('firstEventOn returns the first, or null', () {
      final index = CalendarEventIndex.fromList([
        event(2081, 1, 1, 'first'),
        event(2081, 1, 1, 'second'),
      ]);

      expect(
        index
            .firstEventOn(NepaliDateTime(year: 2081, month: 1, day: 1))!
            .additionalInfo,
        'first',
      );
      expect(
        index.firstEventOn(NepaliDateTime(year: 2081, month: 1, day: 9)),
        isNull,
      );
    });

    test('hasEventsOn', () {
      final index = CalendarEventIndex.fromList([event(2081, 1, 1, 'a')]);

      expect(
        index.hasEventsOn(NepaliDateTime(year: 2081, month: 1, day: 1)),
        isTrue,
      );
      expect(
        index.hasEventsOn(NepaliDateTime(year: 2081, month: 1, day: 2)),
        isFalse,
      );
    });

    test('returned lists are unmodifiable', () {
      final index = CalendarEventIndex.fromList([event(2081, 1, 1, 'a')]);
      final events =
          index.eventsOn(NepaliDateTime(year: 2081, month: 1, day: 1));

      expect(
        () => events.add(event(2081, 1, 1, 'sneaky')),
        throwsUnsupportedError,
      );
    });
  });

  group('NepaliCalendar integration', () {
    Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

    final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 1);

    testWidgets('a date with several events reads as a holiday if any is',
        (tester) async {
      final seen = <int, CalendarCellData<String>>{};

      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            eventList: [
              event(2081, 1, 10, 'ordinary'),
              event(2081, 1, 10, 'festival', isHoliday: true),
            ],
            calendarBuilder: CalendarBuilder<String>(
              cellBuilder: (data) {
                if (data.date.month == 1 && !data.isDimmed) {
                  seen[data.day] = data;
                }
                return Text('${data.day}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(seen[10]!.events, hasLength(2));
      expect(
        seen[10]!.isHoliday,
        isTrue,
        reason: 'the holiday is the second event on the date',
      );
      expect(seen[11]!.events, isEmpty);
      expect(seen[11]!.hasEvents, isFalse);
    });

    testWidgets('cellBuilder reading the deprecated data.event still works',
        (tester) async {
      String? label;

      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            eventList: [event(2081, 1, 10, 'legacy read')],
            calendarBuilder: CalendarBuilder<String>(
              cellBuilder: (data) {
                if (data.date.day == 10 && data.date.month == 1) {
                  label = data.event?.additionalInfo;
                }
                return Text('${data.day}');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(label, 'legacy read');
    });

    /// checkIsHoliday used to be mandatory whenever eventList was given, but
    /// its result was never read. It is now optional.
    testWidgets('eventList no longer requires checkIsHoliday', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            eventList: [event(2081, 1, 10, 'a')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('passing checkIsHoliday still compiles and is ignored',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            eventList: [event(2081, 1, 10, 'a', isHoliday: true)],
            // Deliberately contradicts isHoliday: the callback is not read.
            checkIsHoliday: (event) => false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('updating the event list re-indexes', (tester) async {
      Widget build(List<CalendarEvent<String>> events) => host(
            NepaliCalendar<String>(
              initialDate: baisakh2081,
              eventList: events,
              calendarStyle: const NepaliCalendarStyle(
                config: CalendarConfig(language: Language.english),
              ),
              calendarBuilder: CalendarBuilder<String>(
                eventBuilder: (context, index, date, event) =>
                    Text('event:${event.additionalInfo}'),
              ),
            ),
          );

      await tester.pumpWidget(build([event(2081, 1, 10, 'before')]));
      await tester.pumpAndSettle();
      expect(find.text('event:before'), findsOneWidget);

      await tester.pumpWidget(build([event(2081, 1, 10, 'after')]));
      await tester.pumpAndSettle();

      expect(find.text('event:after'), findsOneWidget);
      expect(find.text('event:before'), findsNothing);
    });
  });
}
