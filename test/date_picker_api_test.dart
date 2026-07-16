// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

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

      expect(find.text('Baisakh 2081'), findsOneWidget);
      expect(find.text('15'), findsOneWidget, reason: 'day grid is showing');
    });

    testWidgets('year opens on the year grid', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            initialMode: NepaliDatePickerMode.year,
            // Bounded so the whole window fits on screen: the year grid
            // scrolls, and an unbounded window would leave later years
            // unbuilt and unfindable.
            minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2085, month: 12, day: 30),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Year'), findsOneWidget);
      expect(find.text('2081'), findsOneWidget, reason: 'a year tile');
      expect(find.text('2085'), findsOneWidget, reason: 'neighbouring years');
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
            // Bounded so every year tile is laid out; see above.
            minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
            maxDate: NepaliDateTime(year: 2085, month: 12, day: 30),
            onDateSelected: (_) {},
            onConfirm: (date) => confirmed = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('2085'));
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
        find.text('Baisakh 2081'),
        findsOneWidget,
        reason: 'opens on the nearest legal date',
      );
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

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('Baisakh 2081'),
        findsOneWidget,
        reason: 'next month is entirely outside the range',
      );

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Baisakh 2081'), findsOneWidget);

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

      expect(find.text('2080'), findsOneWidget);
      expect(find.text('2081'), findsOneWidget);
      expect(find.text('2082'), findsOneWidget);
      expect(find.text('2079'), findsNothing, reason: 'before minDate');
      expect(find.text('2083'), findsNothing, reason: 'after maxDate');
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

    /// The back-compatible path: no callbacks means the old pop behaviour,
    /// which showNepaliDatePicker depends on.
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
  });
}
