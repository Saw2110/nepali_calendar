// These tests exercise deprecated members on purpose -- they must keep working
// until 1.0.0, and that is exactly what is being verified.
// ignore_for_file: deprecated_member_use_from_same_package

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Behaviour tests for [NepaliCalendar].
///
/// These pin the observable contract -- what renders, what the callbacks fire,
/// how config is honoured -- so the internal refactor can proceed safely.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  // A fixed date well away from today, so "today" highlighting can never make
  // these tests pass or fail depending on when they run.
  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 1);

  group('rendering', () {
    testWidgets('renders a weekday header and a 42-cell grid', (tester) async {
      await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
      await tester.pumpAndSettle();

      expect(find.byType(WeekdayHeader), findsOneWidget);
      expect(find.byType(CalendarGrid), findsWidgets);
      expect(
        find.byType(CalendarCell),
        findsNWidgets(42),
        reason: 'always six rows of seven',
      );
    });

    testWidgets('shows Nepali numerals by default', (tester) async {
      await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
      await tester.pumpAndSettle();

      // 1 -> १, 15 -> १५
      expect(find.text('१'), findsWidgets);
      expect(find.text('१५'), findsWidgets);
    });

    testWidgets('shows Arabic numerals when language is english',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15'), findsWidgets);
      expect(find.text('१५'), findsNothing);
    });

    testWidgets('shows the English date alongside when showEnglishDate is set',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(showEnglishDate: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BS 2081-01-01 is AD 2024-04-13, so the AD day 13 must appear.
      expect(find.text('13'), findsWidgets);
    });
  });

  group('fits its viewport', () {
    /// Regression guard. Up to 0.0.7 the month view used square cells
    /// unconditionally and sized itself as `viewportWidth + 16`, so the
    /// calendar was always as tall as the window was wide. On a phone that
    /// roughly worked; on a tablet, desktop window or browser it overflowed.
    /// The 800x600 default test view overflowed by 280px.
    const viewports = <String, Size>{
      'phone portrait': Size(390, 844),
      'phone landscape': Size(844, 390),
      'default test view': Size(800, 600),
      'tablet': Size(1024, 768),
      'desktop': Size(1440, 900),
      'wide desktop': Size(1920, 1080),
    };

    for (final entry in viewports.entries) {
      testWidgets(
          '${entry.key} (${entry.value.width.toInt()}x'
          '${entry.value.height.toInt()}) does not overflow', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed on ${entry.key}',
        );
        expect(find.byType(CalendarCell), findsNWidgets(42));
      });
    }

    testWidgets('cells stay tappable on a wide viewport', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;

      NepaliDateTime? selected;
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            onDayChanged: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(selected?.day, 15);
    });
  });

  group('selection', () {
    testWidgets('tapping a day fires onDayChanged with that date',
        (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            onDayChanged: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 15);
      expect(selected!.month, 1);
      expect(selected!.year, 2081);
    });

    testWidgets(
        'selecting a day in the same month does not fire onMonthChanged',
        (tester) async {
      var monthChanges = 0;

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            onMonthChanged: (_) => monthChanges++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(monthChanges, 0);
    });
  });

  group('controller', () {
    testWidgets('jumpToDate moves the calendar to the requested month',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            controller: controller,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.jumpToDate(NepaliDateTime(year: 2081, month: 5, day: 10));
      await tester.pumpAndSettle();

      expect(controller.selectedDate!.month, 5);
      expect(controller.selectedDate!.day, 10);
    });

    testWidgets('nextMonth and previousMonth step by one month',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(NepaliCalendar(initialDate: baisakh2081, controller: controller)),
      );
      await tester.pumpAndSettle();

      controller.nextMonth();
      await tester.pumpAndSettle();
      expect(controller.selectedDate!.month, 2);

      controller.previousMonth();
      await tester.pumpAndSettle();
      expect(controller.selectedDate!.month, 1);
    });

    testWidgets('nextMonth rolls over into the next year', (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2081, month: 12, day: 1),
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.nextMonth();
      await tester.pumpAndSettle();

      expect(controller.selectedDate!.year, 2082);
      expect(controller.selectedDate!.month, 1);
    });
  });

  group('events', () {
    testWidgets('a date with an event renders an indicator dot',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            eventList: [
              CalendarEvent<String>(
                date: NepaliDateTime(year: 2081, month: 1, day: 10),
                additionalInfo: 'Something',
              ),
            ],
            checkIsHoliday: (event) => event.isHoliday,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // One dot in the grid cell, one in the event list below it.
      expect(find.byIcon(Icons.circle), findsWidgets);
    });
  });

  group('custom builders', () {
    testWidgets('calendarBuilder.cellBuilder replaces the default cell',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            calendarBuilder: CalendarBuilder<String>(
              cellBuilder: (data) => Text('cell-${data.day}'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('cell-15'), findsOneWidget);
    });

    testWidgets('calendarBuilder.headerBuilder replaces the default header',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            calendarBuilder: CalendarBuilder<String>(
              headerBuilder: (date, controller) => Text('header-${date.month}'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('header-1'), findsOneWidget);
      expect(find.byType(CalendarHeader), findsNothing);
    });
  });
}
