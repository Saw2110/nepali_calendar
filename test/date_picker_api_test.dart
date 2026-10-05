// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'picker_finders.dart';

/// Covers the parameters added in 0.1.0: initialMode, minDate/maxDate,
/// onConfirm/onCancel and the label overrides.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  // Baisakh 2081 lays out as 25..30 (trailing Chaitra 2080), then 1..31, then
  // 1..5 (leading Jestha). So the digits 1-5 and 25-30 each appear twice in
  // the grid and only days 6..24 are unique -- these tests stick to those, so
  // a finder can never land on an adjacent month's cell by accident.

  const englishStyle = NepaliCalendarStyle(
    config: CalendarConfig(language: Language.english),
  );

  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 10);

  group('initialMode', () {
    /// NepaliDatePickerMode was exported from the start but nothing accepted
    /// it -- it was internal state, so the picker always opened on the day
    /// grid and a birthday meant paging back through years by hand.
    testWidgets('day is the default', (tester) async {
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

      expect(find.text('Baisakh'), findsOneWidget, reason: 'month field');
      expect(outsideBand('2081'), findsOneWidget, reason: 'year field');
      expect(find.text('15'), findsOneWidget, reason: 'day grid is showing');
    });

    testWidgets('year opens on the year grid', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            // Bounded so the range fits one page.
            minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2085, month: 12, day: 30),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        outsideBand('2081'),
        findsNWidgets(2),
        reason: 'the year field and its tile',
      );
      expect(outsideBand('2085'), findsOneWidget, reason: 'neighbouring years');
    });

    testWidgets('month opens on the month grid', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.month,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A 4x3 page: all twelve months at once.
      expect(find.text('Jestha'), findsOneWidget);
      expect(find.text('Chaitra'), findsOneWidget);
    });

    testWidgets('year mode still walks down to a full date', (tester) async {
      NepaliDateTime? confirmed;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            // Bounded so every year tile is on one page; see above.
            minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2085, month: 12, day: 30),
            onDateSelected: (_) {},
            onConfirm: (date) => confirmed = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(outsideBand('2085'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jestha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(confirmed?.year, 2085);
      expect(confirmed?.month, 2);
      expect(confirmed?.day, 12);
    });
  });

  group('minDate / maxDate', () {
    testWidgets('dates before minDate cannot be selected', (tester) async {
      NepaliDateTime? tapped;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            onDateSelected: (date) => tapped = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('7'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isNull, reason: 'the 7th is before minDate');

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(tapped?.day, 15, reason: 'the 15th is in range');
    });

    testWidgets('dates after maxDate cannot be selected', (tester) async {
      NepaliDateTime? tapped;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            maxDate: NepaliDateTime(year: 2081, month: 1, day: 20),
            onDateSelected: (date) => tapped = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('24'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isNull, reason: 'the 24th is after maxDate');

      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();
      expect(tapped?.day, 18);
    });

    testWidgets('the boundary dates themselves are selectable', (tester) async {
      NepaliDateTime? tapped;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            maxDate: NepaliDateTime(year: 2081, month: 1, day: 20),
            // Two taps in a row: the first must not confirm and pop.
            autoConfirm: false,
            onDateSelected: (date) => tapped = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      expect(tapped?.day, 10, reason: 'minDate is inclusive');

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(tapped?.day, 20, reason: 'maxDate is inclusive');
    });

    testWidgets('an out-of-range initialDate is clamped, not thrown',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            // Well before minDate -- easy to produce from stored data.
            initialDate: NepaliDateTime(year: 2070, month: 1, day: 1),
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            maxDate: NepaliDateTime(year: 2081, month: 1, day: 20),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text('Baisakh'),
        findsOneWidget,
        reason: 'opens on the nearest legal date',
      );
      expect(outsideBand('2081'), findsOneWidget);
    });

    testWidgets('month navigation will not leave the range', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2081, month: 1, day: 31),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(
        find.text('Baisakh'),
        findsOneWidget,
        reason: 'next month is entirely outside the range',
      );

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('Baisakh'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('the year grid offers only years in range', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2082, month: 12, day: 30),
            initialMode: NepaliDatePickerMode.year,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(outsideBand('2080'), findsOneWidget);
      expect(outsideBand('2081'), findsWidgets, reason: 'field and tile');
      expect(outsideBand('2082'), findsOneWidget);
      expect(outsideBand('2079'), findsNothing, reason: 'before minDate');
      expect(outsideBand('2083'), findsNothing, reason: 'after maxDate');
    });

    testWidgets('a range wider than the data is clamped to the data',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 1970, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2100, month: 12, day: 30),
            initialMode: NepaliDatePickerMode.year,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Whatever is on offer must be backed by real data.
      final offered = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => int.tryParse(t.data ?? ''))
          .whereType<int>()
          .where((n) => n >= 1900 && n <= 2300);

      for (final year in offered) {
        expect(
          CalendarUtils.nepaliYears.containsKey(year),
          isTrue,
          reason: 'BS $year has no calendar data',
        );
      }
      expect(tester.takeException(), isNull);
    });
  });

  /// The selection used to stay put when the bounds changed under it, so the
  /// picker could hold a date it would refuse to let the user pick.
  group('bounds that change while open', () {
    testWidgets('a raised minDate pulls the selection into range',
        (tester) async {
      Widget picker(NepaliDateTime? min) => host(
            NepaliDatePicker(
              initialDate: baisakh2081,
              calendarStyle: englishStyle,
              minDate: min,
              onDateSelected: (_) {},
            ),
          );

      await tester.pumpWidget(picker(null));
      await tester.pumpAndSettle();

      final raised = NepaliDateTime(year: 2081, month: 1, day: 20);
      await tester.pumpWidget(picker(raised));
      await tester.pumpAndSettle();

      // The footer shows the selected date in AD.
      final ad = raised.toDateTime();
      final months = MonthUtils.englishMonthsShort;
      expect(
        find.text(
          '${ad.day.toString().padLeft(2, '0')} ${months[ad.month - 1]} '
          '${ad.year}',
        ),
        findsOneWidget,
      );
    });
  });

  group('onConfirm / onCancel', () {
    /// Up to 0.1.0 the picker called Navigator.pop unconditionally, so
    /// embedding it in a page and pressing Cancel popped the page.
    testWidgets('onConfirm reports without touching the Navigator',
        (tester) async {
      NepaliDateTime? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: NepaliDatePicker(
                        initialDate: baisakh2081,
                        calendarStyle: englishStyle,
                        onDateSelected: (_) {},
                        onConfirm: (date) => confirmed = date,
                      ),
                    ),
                  ),
                ),
                child: const Text('push'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(confirmed?.day, 15);
      expect(
        find.byType(NepaliDatePicker),
        findsOneWidget,
        reason: 'the page must still be there',
      );
    });

    testWidgets('onCancel reports without touching the Navigator',
        (tester) async {
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: NepaliDatePicker(
                        initialDate: baisakh2081,
                        calendarStyle: englishStyle,
                        autoConfirm: false,
                        onDateSelected: (_) {},
                        onCancel: () => cancelled = true,
                      ),
                    ),
                  ),
                ),
                child: const Text('push'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
      expect(
        find.byType(NepaliDatePicker),
        findsOneWidget,
        reason: 'the page must still be there',
      );
    });

    /// The back-compatible path: no callbacks means the old pop behaviour.
    testWidgets('without callbacks, still pops the route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: NepaliDatePicker(
                        initialDate: baisakh2081,
                        calendarStyle: englishStyle,
                        autoConfirm: false,
                        onDateSelected: (_) {},
                      ),
                    ),
                  ),
                ),
                child: const Text('push'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(NepaliDatePicker), findsNothing);
    });
  });

  group('autoConfirm', () {
    testWidgets('with autoConfirm, a tap pops the route with the date',
        (tester) async {
      NepaliDateTime? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<NepaliDateTime>(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: NepaliDatePicker(
                          initialDate: baisakh2081,
                          calendarStyle: englishStyle,
                          autoConfirm: true,
                          onDateSelected: (_) {},
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('push'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsNothing, reason: 'no actions row');
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(NepaliDatePicker), findsNothing);
      expect(result?.day, 15);
    });

    /// The embeddable widget keeps the 0.1.0 flow unless asked otherwise: an
    /// app that put the picker on a page and listened to onDateSelected must
    /// not have that page popped by a tap.
    testWidgets('off by default: a tap only selects until OK is pressed',
        (tester) async {
      NepaliDateTime? confirmed;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
            onConfirm: (date) => confirmed = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(confirmed, isNull, reason: 'the tap must not confirm');

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed?.day, 15);
    });

    testWidgets('without the footer the picker never confirms itself',
        (tester) async {
      NepaliDateTime? tapped;
      NepaliDateTime? confirmed;

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            showActions: false,
            onDateSelected: (date) => tapped = date,
            onConfirm: (date) => confirmed = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(tapped?.day, 15);
      expect(confirmed, isNull, reason: 'the host owns confirmation');
    });
  });

  group('footer', () {
    testWidgets('shows the selected date in AD', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            // BS 2083-06-16 is AD 2026-10-02.
            initialDate: NepaliDateTime(year: 2083, month: 6, day: 16),
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('02 Oct 2026'), findsOneWidget);
    });
  });

  group('label overrides', () {
    testWidgets('confirmText and cancelText replace the defaults',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            confirmText: 'Save',
            cancelText: 'Back',
            autoConfirm: false,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('OK'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('defaults follow the language', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            autoConfirm: false,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ठीक छ'), findsOneWidget);
      expect(find.text('रद्द गर्नुहोस्'), findsOneWidget);
    });
  });

  group('semantics', () {
    testWidgets('a date announces its full date, not a bare number',
        (tester) async {
      final handle = tester.ensureSemantics();

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

      // BS 2081-01-15 is a Saturday.
      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 15, 2081, Saturday')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a disabled date is announced as unavailable', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            minDate: NepaliDateTime(year: 2081, month: 1, day: 10),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 7, .*Unavailable')),
        findsOneWidget,
      );
      handle.dispose();
    });

    /// A neighbouring month's day cannot be tapped, so a screen reader must
    /// not offer it as an enabled button.
    testWidgets('a day from a neighbouring month is not an enabled button',
        (tester) async {
      final handle = tester.ensureSemantics();

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

      // Baisakh 2081 opens with the last days of Chaitra 2080.
      final cell = tester.widget<Semantics>(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  (w.properties.label ?? '').startsWith('Chaitra, 30, '),
            )
            .first,
      );
      expect(cell.properties.button, isFalse);
      expect(cell.properties.enabled, isFalse);
      handle.dispose();
    });
  });
}
