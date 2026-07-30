// The row-count plumbing runs through CalendarGrid, which is deprecated but
// still the thing under test.
// ignore_for_file: deprecated_member_use_from_same_package

// Spelling the day out keeps the dates under test readable.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// A Nepali month needs five or six week rows depending on the weekday it
/// starts on. Up to 0.0.7 every month was drawn with six regardless, so
/// five-row months carried a whole trailing row of the next month's dates.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('CalendarUtils.weekRowsInMonth', () {
    test('a month that spills into a sixth row needs six', () {
      // Shrawan 2083 has 31 days and starts on a Friday: 5 leading cells plus
      // 31 days is 36, which does not fit in 35.
      expect(
        CalendarUtils.weekRowsInMonth(2083, 4, WeekStartType.sunday),
        6,
      );
    });

    test('a month that fits exactly needs five', () {
      // Bhadra 2083 has 31 days and starts on a Monday: 1 + 31 = 32 cells.
      expect(
        CalendarUtils.weekRowsInMonth(2083, 5, WeekStartType.sunday),
        5,
      );
    });

    test('the week start day changes the answer', () {
      // Starting the week on Monday moves Bhadra's leading offset from 1 to 0
      // and Shrawan's from 5 to 4 -- enough to change Shrawan's row count.
      expect(
        CalendarUtils.weekRowsInMonth(2083, 4, WeekStartType.monday),
        5,
      );
      expect(
        CalendarUtils.weekRowsInMonth(2083, 5, WeekStartType.monday),
        5,
      );
    });

    test('is always five or six, for every month in the bundled data', () {
      for (final weekStartType in WeekStartType.values) {
        for (final year in CalendarUtils.nepaliYears.keys) {
          for (var month = 1; month <= 12; month++) {
            final rows =
                CalendarUtils.weekRowsInMonth(year, month, weekStartType);

            expect(
              rows,
              anyOf(5, 6),
              reason: '$year/$month under $weekStartType gave $rows rows',
            );
          }
        }
      }
    });

    test('every day of the month fits in the rows it reports', () {
      for (final weekStartType in WeekStartType.values) {
        for (final year in CalendarUtils.nepaliYears.keys) {
          for (var month = 1; month <= 12; month++) {
            final leading = WeekUtils.normalizeWeekday(
              NepaliDateTime(year: year, month: month).weekday,
              weekStartType,
            );
            final days = CalendarUtils.nepaliYears[year]![month];
            final cells =
                CalendarUtils.weekRowsInMonth(year, month, weekStartType) * 7;

            expect(
              leading + days,
              lessThanOrEqualTo(cells),
              reason: '$year/$month under $weekStartType is short by '
                  '${leading + days - cells} cells',
            );
            expect(
              leading + days,
              greaterThan(cells - 7),
              reason: '$year/$month under $weekStartType has a wholly empty '
                  'trailing row',
            );
          }
        }
      }
    });

    test('falls back to six rows outside the bundled data', () {
      expect(
        CalendarUtils.weekRowsInMonth(9999, 1, WeekStartType.sunday),
        CalendarUtils.maxWeekRowsInMonth,
      );
    });
  });

  group('NepaliCalendar row count', () {
    testWidgets('a five-row month renders 35 cells, not 42', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2083, month: 5, day: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalendarCell), findsNWidgets(35));
    });

    testWidgets('a six-row month still renders 42 cells', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2083, month: 4, day: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalendarCell), findsNWidgets(42));
    });

    testWidgets('sixWeekMonthsEnforced pads a five-row month back out',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2083, month: 5, day: 1),
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(sixWeekMonthsEnforced: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalendarCell), findsNWidgets(42));
    });

    testWidgets('a five-row month stops at the end of its last week',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: NepaliDateTime(year: 2083, month: 5, day: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cells = tester.widgetList(find.byType(CalendarCell)).toList();

      // Bhadra starts on a Monday, so one trailing day of Shrawan leads.
      final first = cells.first as dynamic;
      expect(first.date.month, 4);
      expect(first.date.day, 31);

      // ...and it ends on a Wednesday, so Ashoj 1-3 complete the last row and
      // nothing follows. A sixth row would have run to Ashoj 10.
      final last = cells.last as dynamic;
      expect(last.date.month, 6);
      expect(last.date.day, 3);
    });
  });

  group('NepaliCalendar viewport height', () {
    /// The height the calendar's page viewport settles at for [date].
    Future<double> heightFor(
      WidgetTester tester,
      NepaliDateTime date, {
      bool sixWeekMonthsEnforced = false,
    }) async {
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            // A fresh key per date: initialDate is only read in initState, so
            // re-pumping without one would keep showing the first month.
            key: ValueKey('$date $sixWeekMonthsEnforced'),
            initialDate: date,
            calendarStyle: NepaliCalendarStyle(
              config: CalendarConfig(
                sixWeekMonthsEnforced: sixWeekMonthsEnforced,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      return tester.getSize(find.byType(PageView)).height;
    }

    testWidgets('a five-row month is shorter than a six-row one',
        (tester) async {
      final sixRow =
          await heightFor(tester, NepaliDateTime(year: 2083, month: 4, day: 1));
      final fiveRow =
          await heightFor(tester, NepaliDateTime(year: 2083, month: 5, day: 1));

      expect(fiveRow, lessThan(sixRow));
    });

    testWidgets('sixWeekMonthsEnforced keeps the height constant',
        (tester) async {
      final sixRowMonth = await heightFor(
        tester,
        NepaliDateTime(year: 2083, month: 4, day: 1),
        sixWeekMonthsEnforced: true,
      );
      final fiveRowMonth = await heightFor(
        tester,
        NepaliDateTime(year: 2083, month: 5, day: 1),
        sixWeekMonthsEnforced: true,
      );

      expect(fiveRowMonth, sixRowMonth);
    });

    testWidgets('swiping between months does not overflow', (tester) async {
      final controller = NepaliCalendarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            controller: controller,
            initialDate: NepaliDateTime(year: 2083, month: 4, day: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step across the six-row/five-row boundary in both directions, pumping
      // mid-animation where the viewport is between the two heights.
      for (var i = 0; i < 4; i++) {
        controller.nextMonth();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      for (var i = 0; i < 4; i++) {
        controller.previousMonth();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
