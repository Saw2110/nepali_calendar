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
        reason: 'Baisakh 2081 is one of the months that needs six rows',
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

  group('height budget', _measuresItsActualHeight);

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

  /// Controller jumps used to be mistaken for swipes: every page the
  /// PageView passed through set the date and fired callbacks.
  group('controller jumps', () {
    testWidgets('runCallback: false fires no callbacks', (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);
      final fired = <NepaliDateTime>[];

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            controller: controller,
            onMonthChanged: fired.add,
            onDayChanged: fired.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.jumpToDate(
        NepaliDateTime(year: 2081, month: 5, day: 20),
        animate: false,
      );
      await tester.pumpAndSettle();

      expect(fired, isEmpty);
      expect(controller.selectedDate!.day, 20);
    });

    testWidgets(
        'an animated jump fires once and keeps its day past shorter months',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);
      final fired = <NepaliDateTime>[];

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            controller: controller,
            onMonthChanged: fired.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BS 2081: Shrawan has 32 days; Asar, passed on the way, has 31.
      controller.jumpToDate(
        NepaliDateTime(year: 2081, month: 4, day: 32),
        runCallback: true,
      );
      await tester.pumpAndSettle();

      expect(fired, hasLength(1));
      expect(controller.selectedDate!.month, 4);
      expect(controller.selectedDate!.day, 32);
    });

    testWidgets('a replaced controller no longer drives the calendar',
        (tester) async {
      final first = NepaliCalendarController();
      final second = NepaliCalendarController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final fired = <NepaliDateTime>[];

      Widget calendar(NepaliCalendarController c) => host(
            NepaliCalendar(
              initialDate: NepaliDateTime(year: 2081, month: 1, day: 10),
              controller: c,
              onMonthChanged: fired.add,
            ),
          );

      await tester.pumpWidget(calendar(first));
      await tester.pumpAndSettle();
      await tester.pumpWidget(calendar(second));
      await tester.pumpAndSettle();

      first.nextMonth(animate: false);
      await tester.pumpAndSettle();

      expect(fired, isEmpty);
      expect(second.selectedDate!.month, 1);
    });

    testWidgets('a controller that outlives its calendar does not throw',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(NepaliCalendar(controller: controller)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());

      controller.nextMonth(animate: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    /// Attaching used to notify listeners in the middle of building, so a
    /// ListenableBuilder above the calendar threw.
    testWidgets('a listener above the calendar can rebuild on attach',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Column(
              children: [
                Text('${controller.selectedDate?.day}'),
                Expanded(
                  child: NepaliCalendar(
                    controller: controller,
                    initialDate: NepaliDateTime(year: 2081, month: 1, day: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('10'), findsWidgets);
    });
  });

  group('data edges and month lengths', () {
    /// A collapsed pane or a page mid-transition can hand the calendar zero
    /// width; the grid then gets a zero aspect ratio and must not throw.
    testWidgets('a zero-width calendar builds without throwing',
        (tester) async {
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(
              width: 0,
              height: 600,
              child: NepaliCalendar(initialDate: baisakh2081),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    /// Swiping keeps the selected day number. From the 32nd of a 32-day month
    /// into a 31-day one, that used to build an invalid date that silently
    /// became the 1st of the month after.
    testWidgets('swiping clamps the day to the new month', (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      // BS 2081: Jestha has 32 days, Asar 31.
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2081, month: 2, day: 32),
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(PageView),
        const Offset(-600, 0),
        2000,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.selectedDate!.month, 3);
      expect(controller.selectedDate!.day, 31);
    });

    testWidgets('nextMonth does nothing at the last supported month',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);
      final last = CalendarUtils.nepaliYears.keys.last;

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: last, month: 12, day: 1),
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.nextMonth();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.selectedDate!.year, last);
      expect(controller.selectedDate!.month, 12);
    });

    testWidgets('previousMonth does nothing at the first supported month',
        (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);
      final first = CalendarUtils.nepaliYears.keys.first;

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: first, month: 1, day: 15),
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.previousMonth();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.selectedDate!.year, first);
      expect(controller.selectedDate!.month, 1);
    });
  });
}

/// Regression guard for the grid-height budget.
///
/// Up to 0.1.0 the grid took a share of the *screen* height, so putting
/// anything above the calendar -- a toolbar, a filter row, a segmented button
/// -- overflowed it by however tall that thing was. The example's Custom tab
/// surfaced it: a 68px switcher above the calendar overflowed by 8px.
void _measuresItsActualHeight() {
  testWidgets('sizes to the height it is given, not the screen',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              // Chrome above the calendar, which is what used to break it.
              const SizedBox(height: 120, child: Placeholder()),
              Expanded(
                child: NepaliCalendar(
                  initialDate: NepaliDateTime(year: 2081, month: 1, day: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
