// These tests exercise deprecated members on purpose -- they must keep working
// until 1.0.0, and that is exactly what is being verified.
// ignore_for_file: deprecated_member_use_from_same_package

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Locks in the month-filtering behaviour of [EventList].
///
/// This is the "events filtered by month" contract that must survive the
/// internal refactor unchanged.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

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

  testWidgets('renders nothing when the event list is null', (tester) async {
    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: null,
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 1),
        ),
      ),
    );

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('shows only events in the selected month and year',
      (tester) async {
    final events = [
      event(2081, 1, 1, 'in-month A'),
      event(2081, 1, 20, 'in-month B'),
      event(2081, 2, 1, 'other month'),
      event(2080, 1, 1, 'other year, same month'),
    ];

    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: events,
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 5),
          itemBuilder: (context, index, e) => Text(e.additionalInfo!),
        ),
      ),
    );

    expect(find.text('in-month A'), findsOneWidget);
    expect(find.text('in-month B'), findsOneWidget);
    expect(find.text('other month'), findsNothing);
    expect(find.text('other year, same month'), findsNothing);
  });

  testWidgets('filters by month, not by the exact selected day',
      (tester) async {
    // Selecting the 5th must still show an event on the 20th of that month.
    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: [event(2081, 1, 20, 'later that month')],
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 5),
          itemBuilder: (context, index, e) => Text(e.additionalInfo!),
        ),
      ),
    );

    expect(find.text('later that month'), findsOneWidget);
  });

  testWidgets('renders an empty list when no events fall in the month',
      (tester) async {
    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: [event(2081, 6, 1, 'far away')],
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 1),
          itemBuilder: (context, index, e) => Text(e.additionalInfo!),
        ),
      ),
    );

    expect(find.text('far away'), findsNothing);
  });

  testWidgets('the default item builder marks holidays red and events blue',
      (tester) async {
    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: [
            event(2081, 1, 1, 'holiday', isHoliday: true),
            event(2081, 1, 2, 'regular'),
          ],
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 1),
        ),
      ),
    );

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();

    expect(icons, hasLength(2));
    expect(icons[0].color, Colors.red, reason: 'holiday');
    expect(icons[1].color, Colors.blue, reason: 'regular event');
  });

  testWidgets('itemBuilder receives a contiguous index', (tester) async {
    final seen = <int>[];

    await tester.pumpWidget(
      host(
        EventList<String>(
          eventList: [
            event(2081, 2, 1, 'skipped'),
            event(2081, 1, 1, 'a'),
            event(2081, 1, 2, 'b'),
          ],
          selectedDate: NepaliDateTime(year: 2081, month: 1, day: 1),
          itemBuilder: (context, index, e) {
            seen.add(index);
            return Text(e.additionalInfo!);
          },
        ),
      ),
    );

    expect(seen, [0, 1], reason: 'filtered events reindex from zero');
  });

  /// The event list shrink-wraps its content, so anything that centred it left
  /// sparse months floating in the middle of the space below the grid. Only
  /// months with enough events to fill that space looked right, which is what
  /// made this easy to miss.
  group('sits at the top of the space below the calendar', () {
    /// How far [NepaliCalendar]'s event list starts below the top of the
    /// region it was given. Zero means flush.
    Future<double> listOffset(
      WidgetTester tester,
      List<CalendarEvent<String>> events,
    ) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: NepaliDateTime(year: 2081, month: 1, day: 1),
            eventList: events,
            calendarBuilder: CalendarBuilder<String>(
              eventBuilder: (context, index, date, e) =>
                  SizedBox(height: 40, child: Text(e.additionalInfo!)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      return tester.getTopLeft(find.byType(EventList<String>)).dy -
          tester.getTopLeft(find.byType(AnimatedSwitcher)).dy;
    }

    testWidgets('with a single event', (tester) async {
      expect(await listOffset(tester, [event(2081, 1, 1, 'only one')]), 0);
    });

    testWidgets('with no events in the month', (tester) async {
      expect(await listOffset(tester, [event(2081, 6, 1, 'far away')]), 0);
    });

    testWidgets('with more events than fit', (tester) async {
      final events = [
        for (var day = 1; day <= 20; day++) event(2081, 1, day, 'event $day'),
      ];

      expect(await listOffset(tester, events), 0);
    });
  });
}
