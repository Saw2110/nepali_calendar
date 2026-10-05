import 'package:example/app/destinations.dart';
import 'package:example/app/showcase_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Smoke tests for the showcase: every destination opens, survives a theme
/// and a language switch, and the pickers open and close.
void main() {
  /// A phone, unless a test says otherwise.
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  final labels = [for (final d in showcaseDestinations) d.label];

  /// Opens a destination from the bottom navigation bar.
  ///
  /// Scoped to the bar: some labels ("Advanced") also appear on the pages.
  Future<void> open(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
          of: find.byType(NavigationBar), matching: find.text(label)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> launch(WidgetTester tester) async {
    usePhone(tester);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
  }

  testWidgets('launches with every destination in the bar', (tester) async {
    await launch(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in labels) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: '$label is missing',
      );
    }
  });

  for (final destination in showcaseDestinations) {
    testWidgets('${destination.label} opens without error', (tester) async {
      await launch(tester);
      await open(tester, destination.label);

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(destination.title),
        ),
        findsOneWidget,
        reason: 'the app bar shows the destination title',
      );
    });
  }

  testWidgets('every destination survives a light/dark switch', (tester) async {
    await launch(tester);

    for (final label in labels) {
      await open(tester, label);

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$label broke in dark');

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$label broke in light');
    }
  });

  testWidgets('every destination survives a language switch', (tester) async {
    await launch(tester);

    for (final label in labels) {
      await open(tester, label);

      await tester.tap(find.byTooltip('Toggle Language'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$label broke in English');

      await tester.tap(find.byTooltip('Toggle Language'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$label broke in Nepali');
    }
  });

  testWidgets('a wide window gets a side rail instead', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('pickers', () {
    testWidgets('the date picker opens and dismisses', (tester) async {
      await launch(tester);
      await open(tester, 'Pickers');

      await tester.tap(find.text('मिति छान्नुहोस्'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(NepaliDatePicker), findsOneWidget);

      // The picker confirms on tap, so there is no Cancel: dismissing it
      // means tapping the barrier, well away from the dialog.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(NepaliDatePicker), findsNothing);
    });

    testWidgets('the custom design opens and cancels', (tester) async {
      await launch(tester);
      await open(tester, 'Pickers');

      await tester.ensureVisible(find.text('डिजाइन हेर्नुहोस्'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('डिजाइन हेर्नुहोस्'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(NepaliDatePicker), findsOneWidget);
      expect(find.text('ठीक छ'), findsOneWidget);

      await tester.tap(find.text('रद्द'));
      await tester.pumpAndSettle();
      expect(find.byType(NepaliDatePicker), findsNothing);
    });

    testWidgets('the range picker opens full screen and closes',
        (tester) async {
      await launch(tester);
      await open(tester, 'Pickers');

      await tester.tap(find.text('दायरा छान्नुहोस्'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(NepaliDateRangePicker), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(NepaliDateRangePicker), findsNothing);
    });
  });

  group('advanced', () {
    /// The chips swap the whole CalendarBuilder, so a design that overflows
    /// or throws only shows up once it is actually selected.
    testWidgets('both custom designs render, in both themes', (tester) async {
      await launch(tester);
      await open(tester, 'Advanced');

      for (final design in ['Traditional', 'Simple']) {
        await tester.tap(find.text(design));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$design threw');

        await tester.tap(find.byTooltip('Toggle Light/Dark'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$design broke in dark');

        await tester.tap(find.byTooltip('Toggle Light/Dark'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('the event index opens', (tester) async {
      await launch(tester);
      await open(tester, 'Advanced');

      await tester.tap(find.text('Event index'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('hasEventsOn(date)'), findsOneWidget);
    });
  });
}
