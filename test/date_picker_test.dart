// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'picker_finders.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  // Year selection is reached by tapping the year field in the header. Up to
  // 0.1.0 it hid behind an unlabelled edit-calendar icon.

  const englishStyle = NepaliCalendarStyle(
    config: CalendarConfig(language: Language.english),
  );

  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 10);

  group('day view', () {
    testWidgets('opens on the initial date', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Baisakh'), findsOneWidget);
      expect(outsideBand('2081'), findsOneWidget);
    });

    /// Regression guard, and the most important test in this file.
    ///
    /// Up to 0.0.7 the day grid used square cells inside the picker's fixed
    /// height, which left it a row short. A GridView only builds what its
    /// viewport covers, and scrolling is disabled here, so the sixth row was
    /// never built: the 30th and 31st of the month did not exist and could
    /// not be selected. Nothing overflowed and no error was raised -- the
    /// month just quietly ended early.
    testWidgets('every day of the month is present and selectable',
        (tester) async {
      for (final month in [1, 2, 6, 12]) {
        final daysInMonth = CalendarUtils.nepaliYears[2081]![month];
        NepaliDateTime? selected;

        await tester.pumpWidget(
          host(
            NepaliDatePicker(
              key: ValueKey(month),
              initialDate: NepaliDateTime(year: 2081, month: month, day: 1),
              calendarStyle: englishStyle,
              // Selection only: an auto-confirm would pop the test's route.
              autoConfirm: false,
              onDateSelected: (date) => selected = date,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The last day must be rendered...
        expect(
          find.text('$daysInMonth'),
          findsWidgets,
          reason: 'BS 2081-$month has $daysInMonth days; the last is missing',
        );

        // ...and actually selectable, not merely painted.
        await tester.tap(find.text('$daysInMonth').last);
        await tester.pumpAndSettle();

        expect(
          selected?.day,
          daysInMonth,
          reason: 'could not select day $daysInMonth of BS 2081-$month',
        );
      }
    });

    testWidgets('renders six rows so the layout never shifts', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 6 rows x 7 columns, filled out with adjacent months' days. Day cells
      // are InkResponse (a circular Material ripple); InkWell is a different
      // type, so this counts cells and nothing else.
      expect(find.byType(InkResponse), findsNWidgets(42));
    });

    testWidgets('tapping a day fires onDateSelected', (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.year, 2081);
      expect(selected!.month, 1);
      expect(selected!.day, 15);
    });
  });

  group('year range', () {
    /// The year grid offers `displayYear - 15 .. displayYear + 14` with no
    /// clamping to the range the calendar actually has data for (BS 1970-2100).
    /// Near either end it therefore offers unusable years.
    testWidgets('does not offer years past the end of the calendar data',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            // 2099 is inside the supported range; +14 would reach 2113.
            initialDate: NepaliDateTime(year: 2099, month: 1, day: 1),
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the year view.
      await tester.tap(outsideBand('2099'));
      await tester.pumpAndSettle();

      final lastSupported = CalendarUtils.nepaliYears.keys.last;
      for (var year = lastSupported + 1; year <= 2113; year++) {
        expect(
          find.text('$year'),
          findsNothing,
          reason: 'BS $year has no calendar data and must not be offered',
        );
      }
    });

    testWidgets('does not offer years before the start of the calendar data',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            // 1975 is inside the supported range; -15 would reach 1960.
            initialDate: NepaliDateTime(year: 1975, month: 1, day: 1),
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(outsideBand('1975'));
      await tester.pumpAndSettle();

      final firstSupported = CalendarUtils.nepaliYears.keys.first;
      for (var year = 1960; year < firstSupported; year++) {
        expect(
          find.text('$year'),
          findsNothing,
          reason: 'BS $year has no calendar data and must not be offered',
        );
      }
    });

    testWidgets('every year the grid offers is usable', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: NepaliDateTime(year: 2099, month: 1, day: 1),
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(outsideBand('2099'));
      await tester.pumpAndSettle();

      // Whatever years are on offer near the end of the calendar, picking one
      // must land in the month view rather than throwing on missing data.
      final firstSupported = CalendarUtils.nepaliYears.keys.first;
      final lastSupported = CalendarUtils.nepaliYears.keys.last;

      final offered = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => int.tryParse(t.data ?? ''))
          .whereType<int>()
          .where((n) => n >= 1900 && n <= 2300)
          .toSet();

      expect(offered, isNotEmpty, reason: 'the year grid rendered no years');
      for (final year in offered) {
        expect(
          year,
          inInclusiveRange(firstSupported, lastSupported),
          reason: 'BS $year is offered but has no calendar data',
        );
      }

      await tester.tap(outsideBand('${offered.reduce(math.max)}').first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('fits its viewport', () {
    /// Regression guard for two separate defects present up to 0.0.7:
    ///
    /// * the header Row was rigid, and English month names are wider than
    ///   their Nepali equivalents ("Baisakh 2081" vs "बैशाख २०८१"), so in
    ///   English the picker overflowed its own fixed width at *every* screen
    ///   size, desktop included;
    /// * the picker was pinned to 420x480 regardless of the screen, so it
    ///   overflowed any phone narrower than 420 logical pixels.
    ///
    /// Together those left it rendering cleanly only in Nepali on a screen of
    /// at least 390 pixels.
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'Pixel 7': Size(412, 915),
      'default test view': Size(800, 600),
      'desktop': Size(1440, 900),
    };

    for (final entry in devices.entries) {
      for (final language in Language.values) {
        testWidgets('${entry.key} in ${language.name} does not overflow',
            (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            host(
              NepaliDatePicker(
                initialDate: baisakh2081,
                calendarStyle: NepaliCalendarStyle(
                  config: CalendarConfig(language: language),
                ),
                onDateSelected: (_) {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'overflowed on ${entry.key} in ${language.name}',
          );
        });
      }
    }
  });

  group('mode switching', () {
    testWidgets('the year field opens the year grid, then month, then day',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Year view: neighbouring years become visible.
      await tester.tap(outsideBand('2081'));
      await tester.pumpAndSettle();
      expect(outsideBand('2085'), findsOneWidget);

      // Choosing a year moves to the month view.
      await tester.tap(outsideBand('2085'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Jestha'), findsWidgets);

      // Choosing a month moves back to the day view.
      await tester.tap(find.textContaining('Jestha').first);
      await tester.pumpAndSettle();
      expect(find.text('15'), findsOneWidget);
    });
  });

  group('month page and year list', () {
    testWidgets('the month field opens months, and closes them again',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Baisakh'));
      await tester.pumpAndSettle();
      expect(find.text('Jestha'), findsOneWidget);
      expect(find.text('15'), findsNothing, reason: 'the days are swapped out');

      // The field and the tile both read Baisakh; the field comes first.
      await tester.tap(find.text('Baisakh').first);
      await tester.pumpAndSettle();
      expect(find.text('15'), findsOneWidget, reason: 'back on the days');
    });

    testWidgets('the year list opens on the selected year', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The field and the highlighted tile.
      expect(outsideBand('2081'), findsNWidgets(2));
    });

    testWidgets('the year list reaches every year in the data', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final list = find.byType(Scrollable).last;
      final first = CalendarUtils.nepaliYears.keys.first;
      final last = CalendarUtils.nepaliYears.keys.last;

      await tester.scrollUntilVisible(
        find.text('$first'),
        -200,
        scrollable: list,
      );
      expect(find.text('$first'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('$last'),
        200,
        scrollable: list,
      );
      expect(find.text('$last'), findsOneWidget);
    });

    testWidgets('in the year view the arrows scroll, and stop at the ends',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By tooltip: the month and the year each have a pair of arrows.
      IconButton arrow(String tooltip) => tester.widget<IconButton>(
            find.ancestor(
              of: find.byTooltip(tooltip),
              matching: find.byType(IconButton),
            ),
          );
      double offset() => tester
          .state<ScrollableState>(find.byType(Scrollable).last)
          .position
          .pixels;

      final before = offset();
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(offset(), greaterThan(before));

      // Keep going until the arrow gives out at the end of the list.
      for (var i = 0; i < 100; i++) {
        if (arrow('Next page').onPressed == null) break;
        await tester.tap(find.byTooltip('Next page'));
        await tester.pumpAndSettle();
      }
      expect(arrow('Next page').onPressed, isNull);
      expect(
        outsideBand('${CalendarUtils.nepaliYears.keys.last}'),
        findsOneWidget,
      );
      expect(arrow('Previous page').onPressed, isNotNull);
    });

    testWidgets('in the month view the arrows step the year', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.month,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2082, month: 12, day: 30),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By tooltip: the month and the year each have a pair of arrows.
      IconButton arrow(String tooltip) => tester.widget<IconButton>(
            find.ancestor(
              of: find.byTooltip(tooltip),
              matching: find.byType(IconButton),
            ),
          );

      expect(arrow('Previous year').onPressed, isNull);

      await tester.tap(find.byTooltip('Next year'));
      await tester.pumpAndSettle();
      expect(outsideBand('2082'), findsOneWidget, reason: 'the year field');
      expect(find.text('Chaitra'), findsOneWidget, reason: 'still on months');
      expect(
        arrow('Next year').onPressed,
        isNull,
        reason: 'stops at maxDate',
      );
    });
  });

  testWidgets('opens on the first month of the data without throwing',
      (tester) async {
    // The grid's leading cells would fall before the data starts; they are
    // left empty rather than computed.
    final first = CalendarUtils.nepaliYears.keys.first;
    await tester.pumpWidget(
      host(
        NepaliDatePicker(
          initialDate: NepaliDateTime(year: first, month: 1, day: 1),
          calendarStyle: englishStyle,
          onDateSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Baisakh'), findsOneWidget);
  });
}
