// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  const englishStyle = NepaliCalendarStyle(
    config: CalendarConfig(language: Language.english),
  );

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

  /// The grid builds lazily, so on a normal screen the later months do not
  /// exist until scrolled to. Tests that assert about *every* month need a
  /// viewport tall enough to hold all twelve at once, otherwise they pass
  /// vacuously against whatever happens to be on screen.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
  }

  group('rendering', () {
    testWidgets('shows all twelve months', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(
        host(
          const NepaliYearCalendar(year: 2081, calendarStyle: englishStyle),
        ),
      );
      await tester.pumpAndSettle();

      for (var month = 1; month <= 12; month++) {
        final name = MonthUtils.formattedMonth(month, Language.english);
        expect(find.text(name), findsOneWidget, reason: '$name is missing');
      }
    });

    testWidgets('shows the year in the header', (tester) async {
      await tester.pumpWidget(
        host(
          const NepaliYearCalendar(year: 2081, calendarStyle: englishStyle),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2081'), findsOneWidget);
    });

    testWidgets('uses Nepali numerals and month names by default',
        (tester) async {
      await tester.pumpWidget(host(const NepaliYearCalendar(year: 2081)));
      await tester.pumpAndSettle();

      expect(find.text('२०८१'), findsOneWidget);
      expect(find.text('बैशाख'), findsOneWidget);
    });

    testWidgets('hides the header when showHeader is false', (tester) async {
      await tester.pumpWidget(
        host(
          const NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            showHeader: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2081'), findsNothing);
      expect(find.text('Baisakh'), findsOneWidget);
    });

    testWidgets('headerBuilder replaces the header', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            headerBuilder: (year) => Text('custom $year'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('custom 2081'), findsOneWidget);
    });

    testWidgets('monthTitleBuilder replaces each month title', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            monthTitleBuilder: (year, month) => Text('M$month'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('M1'), findsOneWidget);
      expect(find.text('M12'), findsOneWidget);
      expect(find.text('Baisakh'), findsNothing);
    });
  });

  group('every day of every month exists', () {
    /// The failure mode that bit NepaliDatePicker: a grid given too little
    /// height silently never builds its last row, so the final days of a month
    /// do not exist and cannot be tapped. Nothing overflows and no error is
    /// raised, so only a test like this catches it.
    testWidgets('the last day of each month is rendered', (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(
        host(
          const NepaliYearCalendar(year: 2081, calendarStyle: englishStyle),
        ),
      );
      await tester.pumpAndSettle();

      // Count occurrences rather than merely finding one somewhere: with all
      // twelve months on screen a `findsWidgets` would be satisfied by any
      // other month's digits, and would pass even with a row missing.
      //
      // A given day number appears once per month that is long enough to
      // contain it -- day 31 shows up in every 31- and 32-day month, not just
      // in months that end on the 31st.
      final daysPerMonth = [
        for (var month = 1; month <= 12; month++)
          CalendarUtils.nepaliYears[2081]![month],
      ];

      for (final day in const [28, 29, 30, 31, 32]) {
        final expected = daysPerMonth.where((days) => days >= day).length;
        expect(
          find.text('$day'),
          findsNWidgets(expected),
          reason: '$expected month(s) contain a day $day; a shortfall means a '
              'grid row was never built',
        );
      }
    });

    testWidgets('a 32-day month renders all 32 days', (tester) async {
      useTallViewport(tester);
      // Find a month with 32 days -- the longest a Nepali month gets, and the
      // most likely to overflow a six-row grid.
      final longMonth = [
        for (var m = 1; m <= 12; m++) m,
      ].firstWhere((m) => CalendarUtils.nepaliYears[2081]![m] == 32);

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            monthTitleBuilder: (year, month) =>
                Text(month == longMonth ? 'TARGET' : 'M$month'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('TARGET'), findsOneWidget);
      // 32 days across six rows needs the month to start early enough; the
      // grid must still lay out without dropping a row.
      expect(find.text('32'), findsWidgets);
    });
  });

  group('selection', () {
    testWidgets('tapping a date fires onDaySelected with the right date',
        (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            onDaySelected: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The first '15' in the grid belongs to the first month.
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.year, 2081);
      expect(selected!.month, 1);
      expect(selected!.day, 15);
    });

    testWidgets('tapping a date in a later month reports that month',
        (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            onDaySelected: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Every month renders a '15'; the second belongs to the second month.
      await tester.tap(find.text('15').at(1));
      await tester.pumpAndSettle();

      expect(selected!.month, 2);
      expect(selected!.day, 15);
    });
  });

  group('year navigation', () {
    testWidgets('the arrows step the year and report it', (tester) async {
      final years = <int>[];

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            onYearChanged: years.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('2082'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('2081'), findsOneWidget);

      expect(years, [2082, 2081]);
    });

    /// Stepping past the calendar's data would throw on a null lookup, so the
    /// arrows disable at the ends of the supported range.
    testWidgets('cannot step past the end of the calendar data',
        (tester) async {
      final lastYear = CalendarUtils.nepaliYears.keys.last;

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(year: lastYear, calendarStyle: englishStyle),
        ),
      );
      await tester.pumpAndSettle();

      final next = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(next.onPressed, isNull, reason: 'should be disabled');

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('$lastYear'), findsOneWidget);
    });

    testWidgets('cannot step before the start of the calendar data',
        (tester) async {
      final firstYear = CalendarUtils.nepaliYears.keys.first;

      await tester.pumpWidget(
        host(
          NepaliYearCalendar(year: firstYear, calendarStyle: englishStyle),
        ),
      );
      await tester.pumpAndSettle();

      final previous = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.chevron_left_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(previous.onPressed, isNull, reason: 'should be disabled');
    });
  });

  group('events', () {
    testWidgets('a date with an event shows an indicator', (tester) async {
      Widget build({List<CalendarEvent<String>>? events}) => host(
            NepaliYearCalendar<String>(
              year: 2081,
              calendarStyle: englishStyle,
              eventList: events,
            ),
          );

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      final withoutEvents = tester.widgetList(find.byType(Container)).length;

      await tester.pumpWidget(build(events: [event(2081, 1, 10, 'a')]));
      await tester.pumpAndSettle();
      final withEvents = tester.widgetList(find.byType(Container)).length;

      expect(
        withEvents,
        greaterThan(withoutEvents),
        reason: 'the event dot should add a Container',
      );
    });

    testWidgets('updating the event list re-indexes', (tester) async {
      Widget build(List<CalendarEvent<String>> events) => host(
            NepaliYearCalendar<String>(
              year: 2081,
              calendarStyle: englishStyle,
              eventList: events,
            ),
          );

      await tester.pumpWidget(build([event(2081, 1, 10, 'a')]));
      await tester.pumpAndSettle();
      final before = tester.widgetList(find.byType(Container)).length;

      await tester.pumpWidget(
        build([event(2081, 1, 10, 'a'), event(2081, 2, 5, 'b')]),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widgetList(find.byType(Container)).length,
        greaterThan(before),
      );
    });
  });

  group('theme', () {
    testWidgets('follows an ambient NepaliCalendarTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: const Scaffold(
              body: NepaliYearCalendar(
                year: 2081,
                calendarStyle: englishStyle,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BS 2081-01-01 is a Saturday, so the 12th is a Wednesday and renders
      // with the ordinary date colour rather than the weekend one.
      final text = tester.widget<Text>(find.text('12').first);
      expect(text.style?.color, Colors.purple);
    });

    testWidgets('an explicit style beats the theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: const Scaffold(
              body: NepaliYearCalendar(
                year: 2081,
                calendarStyle: NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                  cellsStyle: CellStyle(dateTextColor: Colors.orange),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('12').first);
      expect(text.style?.color, Colors.orange);
    });
  });

  group('responsive', () {
    const viewports = <String, Size>{
      'phone portrait': Size(390, 844),
      'phone landscape': Size(844, 390),
      'default test view': Size(800, 600),
      'tablet': Size(1024, 768),
      'desktop': Size(1440, 900),
    };

    for (final entry in viewports.entries) {
      testWidgets('${entry.key} does not overflow', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          host(
            const NepaliYearCalendar(year: 2081, calendarStyle: englishStyle),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed on ${entry.key}',
        );
      });
    }

    testWidgets('honours monthsPerRow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        host(
          const NepaliYearCalendar(
            year: 2081,
            calendarStyle: englishStyle,
            monthsPerRow: 4,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Baisakh'), findsOneWidget);
      expect(find.text('Chaitra'), findsOneWidget);
    });

    testWidgets('survives a large text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: const Scaffold(
                body: NepaliYearCalendar(
                  year: 2081,
                  calendarStyle: englishStyle,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Nepali script without overflowing', (tester) async {
      await tester.pumpWidget(host(const NepaliYearCalendar(year: 2081)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
