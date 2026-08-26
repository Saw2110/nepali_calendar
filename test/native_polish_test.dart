import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Dates are written out in full for clarity, defaults included.
// ignore_for_file: avoid_redundant_argument_values
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Tests for the platform-native behaviour added in 0.1.1: screen-reader
/// labels, ink feedback, keyboard focus, haptics and text scaling.
///
/// These are the things a calendar is expected to do simply because it runs on
/// a phone, and up to 0.1.0 the month view did none of them.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  // Fixed, so "today" highlighting cannot make a test pass or fail depending
  // on the day it runs.
  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 1);

  /// Records every haptic the framework is asked for.
  List<String> captureHaptics(WidgetTester tester) {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return calls;
  }

  group('semantics', () {
    testWidgets('a day cell announces the whole date, not just the number',
        (tester) async {
      final handle = tester.ensureSemantics();
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

      // Baisakh 1 2081 was a Saturday.
      expect(
        find.bySemanticsLabel(RegExp(r'Baisakh, 1, 2081, Saturday')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('announces Devanagari digits to a Nepali reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('बैशाख, १५, २०८१')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('announces holidays and how many events a date carries',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          NepaliCalendar<String>(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            eventList: [
              CalendarEvent<String>(
                date: NepaliDateTime(year: 2081, month: 1, day: 10),
                isHoliday: true,
                additionalInfo: 'Holiday',
              ),
              CalendarEvent<String>(
                date: NepaliDateTime(year: 2081, month: 1, day: 10),
                additionalInfo: 'Standup',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp(r'Baisakh, 10, 2081, .*Holiday, 2 events'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('marks adjacent-month dates as such', (tester) async {
      final handle = tester.ensureSemantics();
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

      expect(find.bySemanticsLabel(RegExp('Other month')), findsWidgets);
      handle.dispose();
    });

    testWidgets('the month title is a header node', (tester) async {
      final handle = tester.ensureSemantics();
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

      expect(
        tester.getSemantics(find.bySemanticsLabel('Baisakh 2081')),
        matchesSemantics(label: 'Baisakh 2081', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('the navigation arrows are labelled', (tester) async {
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

      expect(find.byTooltip('Previous month'), findsOneWidget);
      expect(find.byTooltip('Next month'), findsOneWidget);
    });
  });

  group('ink and focus', () {
    testWidgets('every day cell has an ink surface, so taps ripple',
        (tester) async {
      await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
      await tester.pumpAndSettle();

      // Counted per cell rather than across the tree: the PageView keeps the
      // neighbouring months alive, so a global count is three months' worth.
      for (var i = 0; i < 42; i++) {
        expect(
          find.descendant(
            of: find.byType(CalendarCell).at(i),
            matching: find.byType(InkWell),
          ),
          findsOneWidget,
          reason: 'cell $i must ripple on tap',
        );
      }
    });

    testWidgets('a day cell can be reached by Tab and activated by Enter',
        (tester) async {
      NepaliDateTime? selected;
      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            // Both, because Tab reaches the leading cells of the grid first
            // and those belong to the previous month -- selecting one is
            // reported as a month change, not a day change.
            onDayChanged: (date) => selected = date,
            onMonthChanged: (date) => selected = date,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab forward until focus lands inside a date cell. The two header
      // arrows come first in traversal order, so this takes a few presses.
      var landedOnACell = false;
      for (var i = 0; i < 8 && !landedOnACell; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        final focused = tester.binding.focusManager.primaryFocus?.context;
        if (focused != null) {
          landedOnACell =
              focused.findAncestorWidgetOfExactType<CalendarCell<dynamic>>() !=
                  null;
        }
      }

      expect(
        landedOnACell,
        isTrue,
        reason: 'the date grid must be reachable from the keyboard',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        selected,
        isNotNull,
        reason: 'Enter must activate the focused date',
      );
    });
  });

  group('haptics', () {
    testWidgets('selecting a date fires the keypress tick', (tester) async {
      final haptics = captureHaptics(tester);

      await tester.pumpWidget(host(NepaliCalendar(initialDate: baisakh2081)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('१५').first);
      await tester.pumpAndSettle();

      expect(haptics, contains('HapticFeedbackType.lightImpact'));
    });

    testWidgets('no tick when haptics are off', (tester) async {
      final haptics = captureHaptics(tester);

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(hapticFeedback: CalendarHaptics.none),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('१५').first);
      await tester.pumpAndSettle();

      expect(haptics, isEmpty);
    });

    testWidgets('the year view ticks too', (tester) async {
      final haptics = captureHaptics(tester);

      await tester.pumpWidget(
        host(NepaliYearCalendar(year: 2081, onDaySelected: (_) {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('१५').first);
      await tester.pumpAndSettle();

      expect(haptics, contains('HapticFeedbackType.lightImpact'));
    });

    testWidgets('the strength follows the configured value', (tester) async {
      final haptics = captureHaptics(tester);

      await tester.pumpWidget(
        host(
          NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(hapticFeedback: CalendarHaptics.heavy),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('१५').first);
      await tester.pumpAndSettle();

      expect(haptics, contains('HapticFeedbackType.heavyImpact'));
    });

    testWidgets('every value maps to the platform call it names',
        (tester) async {
      final haptics = captureHaptics(tester);
      // Pumped so there is a binding for the platform channel to run on.
      await tester.pumpWidget(host(const SizedBox()));

      for (final value in CalendarHaptics.values) {
        await value.perform();
      }
      await tester.pump();

      expect(haptics, [
        // CalendarHaptics.none sends nothing at all.
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });
  });

  group('text scaling', () {
    testWidgets('a large system font does not overflow the month grid',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            // Well past the largest setting Android or iOS offers.
            data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: Scaffold(body: NepaliCalendar(initialDate: baisakh2081)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the day number stops scaling before it leaves the cell',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: Scaffold(body: NepaliCalendar(initialDate: baisakh2081)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dayText = tester.widget<Text>(find.text('१५').first);
      expect(dayText.textScaler, isNotNull);
      expect(
        dayText.textScaler!.scale(10),
        lessThan(30),
        reason: 'the clamp must bite well below the requested 3x',
      );
    });
  });

  group('dialog labels', () {
    testWidgets('an English picker borrows the app\'s own button labels',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showNepaliDatePicker(
                  context: context,
                  calendarStyle: const NepaliCalendarStyle(
                    config: CalendarConfig(language: Language.english),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // MaterialLocalizations' en labels, which are what every other dialog in
      // the app shows.
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('a Nepali picker keeps its own labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showNepaliDatePicker(context: context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('रद्द गर्नुहोस्'), findsOneWidget);
      expect(find.text('ठीक छ'), findsOneWidget);
    });
  });
}
