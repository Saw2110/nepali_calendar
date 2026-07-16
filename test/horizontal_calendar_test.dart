// ignore_for_file: avoid_redundant_argument_values, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Behaviour tests for [HorizontalNepaliCalendar].
void main() {
  // HorizontalNepaliCalendar sizes itself as 8% of the viewport height, so on
  // the default 600px-tall test view each cell gets 48px -- not enough for its
  // two lines of text, which clips the cell and breaks hit-testing. Pin a
  // realistic phone surface.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(400, 900);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 10);

  const englishStyle = NepaliCalendarStyle(
    config: CalendarConfig(language: Language.english),
  );

  group('rendering', () {
    testWidgets('renders a seven-day strip', (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalendarItem), findsNWidgets(7));
    });

    testWidgets('the strip starts two days before the selected date',
        (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Selected is the 10th, so the strip runs 8th..14th.
      expect(find.text('8'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('7'), findsNothing);
      expect(find.text('15'), findsNothing);
    });

    testWidgets('shows the month title by default', (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2081, Baisakh'), findsOneWidget);
    });

    testWidgets('hides the month title when showMonth is false',
        (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            showMonth: false,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2081, Baisakh'), findsNothing);
    });

    testWidgets('headerBuilder replaces the month title', (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            headerBuilder: (today, selected) =>
                Text('custom-${selected.month}'),
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('custom-1'), findsOneWidget);
      expect(find.text('2081, Baisakh'), findsNothing);
    });

    testWidgets('uses Nepali numerals by default', (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('१०'), findsOneWidget);
    });
  });

  group('selection', () {
    testWidgets('tapping a date fires onDateSelected with it', (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 12);
      expect(selected!.month, 1);
      expect(selected!.year, 2081);
    });

    testWidgets('the strip re-centres on the newly selected date',
        (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      // Now selected is the 12th, so the strip should run 10th..16th.
      expect(find.text('16'), findsOneWidget);
      expect(find.text('9'), findsNothing);
    });

    testWidgets('selection crosses a month boundary correctly', (tester) async {
      NepaliDateTime? selected;

      // Baisakh 2081 has 31 days; the strip from the 30th runs into Jestha.
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: NepaliDateTime(year: 2081, month: 1, day: 30),
            calendarStyle: englishStyle,
            onDateSelected: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.month, 2, reason: 'rolled into Jestha');
      expect(selected!.day, 1);
    });
  });

  group('tappable at real device sizes', () {
    /// Regression guard. Up to 0.0.7 the widget pinned itself to 8% of the
    /// viewport height. With the month title shown -- the default -- the date
    /// strip was pushed outside that fixed box on every phone-sized screen.
    /// Flutter still painted it, so it looked fine, but it refuses to
    /// hit-test children painted outside their parent's bounds, so taps were
    /// silently swallowed and onDateSelected never fired.
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'Pixel 7': Size(412, 915),
      'iPad Air': Size(820, 1180),
    };

    for (final entry in devices.entries) {
      for (final showMonth in [true, false]) {
        testWidgets('${entry.key} (showMonth: $showMonth)', (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;

          NepaliDateTime? selected;
          await tester.pumpWidget(
            host(
              HorizontalNepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: englishStyle,
                showMonth: showMonth,
                onDateSelected: (date) => selected = date,
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('12'));
          await tester.pumpAndSettle();

          expect(
            selected?.day,
            12,
            reason: 'dates must be tappable on ${entry.key}',
          );
        });
      }
    }
  });

  group('does not clip its content', () {
    /// The strip height must fit Devanagari, which is taller than Latin at the
    /// same font size, and must grow with the user's text scale. Overflow here
    /// is what made taps stop working in the first place.
    testWidgets('renders Nepali script without overflowing', (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('१०'), findsOneWidget);
    });

    testWidgets('stays tappable at a large text scale', (tester) async {
      NepaliDateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            // copyWith, not a fresh MediaQueryData -- a bare one has a zero
            // size, which would leave nothing to lay out.
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: Scaffold(
                body: HorizontalNepaliCalendar(
                  initialDate: baisakh2081,
                  calendarStyle: englishStyle,
                  onDateSelected: (date) => selected = date,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      expect(selected?.day, 12);
    });
  });

  group('known gaps', () {
    /// [HorizontalNepaliCalendar.textColor] and
    /// [HorizontalNepaliCalendar.selectedColor] are accepted by the
    /// constructor but never read -- only `backgroundColor` is wired up.
    /// These tests document that, so the deprecation is grounded in a
    /// demonstrated fact rather than a reading of the code.
    testWidgets('textColor is accepted but has no effect', (tester) async {
      Future<Color?> dayColorWith(Color? textColor) async {
        await tester.pumpWidget(
          host(
            HorizontalNepaliCalendar(
              initialDate: baisakh2081,
              calendarStyle: englishStyle,
              textColor: textColor,
              onDateSelected: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.widget<Text>(find.text('12')).style?.color;
      }

      expect(await dayColorWith(null), await dayColorWith(Colors.purple));
    });

    testWidgets('selectedColor is accepted but has no effect', (tester) async {
      Future<Color?> cellColorWith(Color? selectedColor) async {
        await tester.pumpWidget(
          host(
            HorizontalNepaliCalendar(
              initialDate: baisakh2081,
              calendarStyle: englishStyle,
              selectedColor: selectedColor,
              onDateSelected: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('10'),
                matching: find.byType(Container),
              )
              .first,
        );
        return container.color;
      }

      expect(await cellColorWith(null), await cellColorWith(Colors.purple));
    });

    testWidgets('backgroundColor, by contrast, does take effect',
        (tester) async {
      await tester.pumpWidget(
        host(
          HorizontalNepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: englishStyle,
            backgroundColor: Colors.amber,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scope the search to the widget under test -- Scaffold and Material
      // contribute ColoredBoxes of their own.
      final box = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(HorizontalNepaliCalendar),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(box.color, Colors.amber);
    });
  });
}
