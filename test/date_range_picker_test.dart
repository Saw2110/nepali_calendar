// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';
import 'package:nepali_calendar_plus/src/date_picker/internal/picker_shared.dart';
import 'package:nepali_calendar_plus/src/date_picker/internal/range_selection.dart';

/// Tests for the range picker: the [NepaliDateTimeRange] model, the
/// selection rules, and both layouts.
void main() {
  NepaliDateTime bs(int year, int month, int day) =>
      NepaliDateTime(year: year, month: month, day: day);

  const englishStyle = NepaliCalendarStyle(
    config: CalendarConfig(language: Language.english),
  );

  // Baisakh 2081: 31 days. Bounding a picker to it leaves one month on
  // screen, so a day number is never ambiguous.
  final baisakhStart = bs(2081, 1, 1);
  final baisakhEnd = bs(2081, 1, 31);

  group('NepaliDateTimeRange', () {
    test('counts both ends', () {
      expect(
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16)).days,
        7,
      );
      expect(
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 10)).days,
        1,
        reason: 'a same-day range is one day long',
      );
    });

    test('counts across a month boundary', () {
      // Baisakh 2081 has 31 days: the 30th to Jestha 2nd is 4 days.
      expect(
        NepaliDateTimeRange(start: bs(2081, 1, 30), end: bs(2081, 2, 2)).days,
        4,
      );
    });

    test('contains its ends and nothing outside', () {
      final range =
          NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16));
      expect(range.contains(bs(2081, 1, 10)), isTrue);
      expect(range.contains(bs(2081, 1, 13)), isTrue);
      expect(range.contains(bs(2081, 1, 16)), isTrue);
      expect(range.contains(bs(2081, 1, 9)), isFalse);
      expect(range.contains(bs(2081, 1, 17)), isFalse);
    });

    test('compares by value', () {
      expect(
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16)),
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16)),
      );
    });

    test('converts to AD', () {
      // BS 2083-06-10 to 2083-06-16 is AD 2026-09-26 to 2026-10-02.
      final ad =
          NepaliDateTimeRange(start: bs(2083, 6, 10), end: bs(2083, 6, 16))
              .toDateTimeRange();
      expect(ad.start, DateTime(2026, 9, 26));
      expect(ad.end, DateTime(2026, 10, 2));
    });

    test('rejects an end before the start', () {
      expect(
        () => NepaliDateTimeRange(start: bs(2081, 1, 16), end: bs(2081, 1, 10)),
        throwsArgumentError,
      );
    });
  });

  group('RangeSelection', () {
    final bounds = PickerBounds.from(min: baisakhStart, max: baisakhEnd);

    test('first tap starts, second ends, third starts over', () {
      var s = const RangeSelection();
      s = s.tap(bs(2081, 1, 10), bounds);
      expect(s.start, bs(2081, 1, 10));
      expect(s.end, isNull);
      expect(s.isComplete, isFalse);

      s = s.tap(bs(2081, 1, 16), bounds);
      expect(
        s.range,
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16)),
      );

      s = s.tap(bs(2081, 1, 20), bounds);
      expect(s.start, bs(2081, 1, 20));
      expect(s.end, isNull, reason: 'a complete range resets');
    });

    test('a tap before the start moves the start', () {
      final s = const RangeSelection()
          .tap(bs(2081, 1, 10), bounds)
          .tap(bs(2081, 1, 5), bounds);
      expect(s.start, bs(2081, 1, 5));
      expect(s.end, isNull);
    });

    test('the same day twice is a one-day range', () {
      final s = const RangeSelection()
          .tap(bs(2081, 1, 10), bounds)
          .tap(bs(2081, 1, 10), bounds);
      expect(s.range?.days, 1);
    });

    test('dates outside the bounds are ignored', () {
      final s = const RangeSelection().tap(bs(2081, 2, 5), bounds);
      expect(s.start, isNull);
    });

    test('maxDays limits the end, counting both ends', () {
      final start = const RangeSelection().tap(bs(2081, 1, 10), bounds);

      expect(start.isSelectable(bs(2081, 1, 16), bounds, maxDays: 7), isTrue);
      expect(start.isSelectable(bs(2081, 1, 17), bounds, maxDays: 7), isFalse);
      expect(
        start.isSelectable(bs(2081, 1, 3), bounds, maxDays: 7),
        isTrue,
        reason: 'an earlier date moves the start instead',
      );

      final rejected = start.tap(bs(2081, 1, 17), bounds, maxDays: 7);
      expect(rejected, start);
    });

    test('positions for painting', () {
      final s = const RangeSelection()
          .tap(bs(2081, 1, 10), bounds)
          .tap(bs(2081, 1, 12), bounds);
      expect(s.positionOf(bs(2081, 1, 9)), PickerRangePosition.none);
      expect(s.positionOf(bs(2081, 1, 10)), PickerRangePosition.start);
      expect(s.positionOf(bs(2081, 1, 11)), PickerRangePosition.middle);
      expect(s.positionOf(bs(2081, 1, 12)), PickerRangePosition.end);

      final single = const RangeSelection().tap(bs(2081, 1, 10), bounds);
      expect(single.positionOf(bs(2081, 1, 10)), PickerRangePosition.single);
    });
  });

  group('phone layout', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      NepaliDateTimeRange? initialRange,
      int? maxDays,
      ValueChanged<NepaliDateTimeRange>? onConfirm,
      VoidCallback? onCancel,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NepaliDateRangePicker(
              initialRange: initialRange,
              minDate: baisakhStart,
              maxDate: baisakhEnd,
              maxDays: maxDays,
              calendarStyle: englishStyle,
              onConfirm: onConfirm ?? (_) {},
              onCancel: onCancel ?? () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    FilledButton save(WidgetTester tester) =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    testWidgets('Save is disabled until both ends are set', (tester) async {
      NepaliDateTimeRange? confirmed;
      await pumpPicker(tester, onConfirm: (range) => confirmed = range);

      expect(find.text('Start date – End date'), findsOneWidget);
      expect(save(tester).onPressed, isNull);

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      expect(save(tester).onPressed, isNull, reason: 'only a start so far');
      expect(find.text('Baisakh 10, 2081 – End date'), findsOneWidget);

      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();
      expect(save(tester).onPressed, isNotNull);
      expect(find.text('Baisakh 10 – Baisakh 16, 2081'), findsOneWidget);
      expect(find.textContaining('7 days'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(
        confirmed,
        NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 16)),
      );
    });

    testWidgets('close cancels', (tester) async {
      var cancelled = false;
      await pumpPicker(tester, onCancel: () => cancelled = true);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(cancelled, isTrue);
    });

    testWidgets('opens with an initial range', (tester) async {
      await pumpPicker(
        tester,
        initialRange:
            NepaliDateTimeRange(start: bs(2081, 1, 3), end: bs(2081, 1, 5)),
      );
      expect(find.text('Baisakh 3 – Baisakh 5, 2081'), findsOneWidget);
      expect(save(tester).onPressed, isNotNull);
    });

    testWidgets('an initial range longer than maxDays is ignored',
        (tester) async {
      await pumpPicker(
        tester,
        // 8 days, against a 5-day limit.
        initialRange:
            NepaliDateTimeRange(start: bs(2081, 1, 3), end: bs(2081, 1, 10)),
        maxDays: 5,
      );

      expect(find.text('Start date – End date'), findsOneWidget);
      expect(save(tester).onPressed, isNull);
    });

    testWidgets('maxDays leaves later dates inert', (tester) async {
      await pumpPicker(tester, maxDays: 5);

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(save(tester).onPressed, isNull, reason: 'the 20th is too far');

      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      expect(save(tester).onPressed, isNotNull);
    });

    testWidgets('the ends and the days between announce their part',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(
        tester,
        initialRange:
            NepaliDateTimeRange(start: bs(2081, 1, 10), end: bs(2081, 1, 12)),
      );

      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 10, .*Start date')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 11, .*In range')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 12, .*End date')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('lists every month in range and opens on the start',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NepaliDateRangePicker(
              initialRange: NepaliDateTimeRange(
                start: bs(2081, 6, 10),
                end: bs(2081, 6, 12),
              ),
              minDate: bs(2081, 1, 1),
              maxDate: bs(2081, 12, 30),
              calendarStyle: englishStyle,
              onConfirm: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Ashoj 2081'),
        findsOneWidget,
        reason: 'opened on the start month',
      );
      expect(
        find.text('Baisakh 2081'),
        findsNothing,
        reason: 'not at the top of the list',
      );

      final list = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Chaitra 2081'),
        300,
        scrollable: list,
      );
      expect(find.text('Chaitra 2081'), findsOneWidget);
    });
  });

  group('showNepaliDateRangePicker', () {
    Widget host({
      required ValueChanged<NepaliDateTimeRange?> onResult,
      Language language = Language.english,
    }) {
      return MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  onResult(
                    await showNepaliDateRangePicker(
                      context: context,
                      initialRange: NepaliDateTimeRange(
                        start: bs(2081, 1, 10),
                        end: bs(2081, 1, 12),
                      ),
                      calendarStyle: NepaliCalendarStyle(
                        config: CalendarConfig(language: language),
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('a phone gets a full-screen page', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      NepaliDateTimeRange? result;
      var called = false;
      await tester.pumpWidget(
        host(
          onResult: (r) {
            result = r;
            called = true;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.getSize(find.byType(NepaliDateRangePicker)).width,
        390,
      );

      // Save, as MaterialLocalizations spells it, returns the range.
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
      expect(result?.days, 3);
    });

    testWidgets('a tablet gets two months side by side', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      NepaliDateTimeRange? result;
      var called = false;
      await tester.pumpWidget(
        host(
          onResult: (r) {
            result = r;
            called = true;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Baisakh 2081'), findsOneWidget);
      expect(find.text('Jestha 2081'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Baisakh 2081'), findsNothing);
      expect(find.text('Jestha 2081'), findsOneWidget);
      expect(find.text('Asar 2081'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
      expect(result, isNull);
    });

    group('fits its viewport', () {
      const devices = <String, Size>{
        'iPhone SE': Size(375, 667),
        'Pixel 7': Size(412, 915),
        'phone landscape': Size(844, 390),
        'tablet': Size(1024, 768),
      };

      for (final entry in devices.entries) {
        for (final language in Language.values) {
          testWidgets('${entry.key} in ${language.name}', (tester) async {
            tester.view.physicalSize = entry.value;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              host(onResult: (_) {}, language: language),
            );
            await tester.tap(find.text('open'));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          });
        }
      }
    });
  });
}
