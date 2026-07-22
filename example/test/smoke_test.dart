import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

/// Smoke tests for the example app.
///
/// The analyzer cannot catch a `DefaultTabController(length:)` that disagrees
/// with the number of tabs -- it is just an int -- so the app has to actually
/// be driven to find it.
void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(412, 915);
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

  const tabs = ['Calendar', 'Horizontal', 'Date Picker', 'Year View', 'Custom'];

  /// Opens a tab by name.
  ///
  /// The TabBar is scrollable and the later tabs start off the right edge of a
  /// phone, where a plain `tap` lands outside the render tree and silently does
  /// nothing -- leaving the test asserting against whichever tab it was already
  /// on. Scrolling the tab into view first is what makes these tests mean
  /// anything.
  Future<void> openTab(WidgetTester tester, String tab) async {
    await tester.ensureVisible(find.text(tab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  testWidgets('launches with every tab present', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final tab in tabs) {
      expect(find.text(tab), findsOneWidget, reason: '$tab tab is missing');
    }
  });

  for (final tab in tabs) {
    testWidgets('the $tab tab opens without error', (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      await openTab(tester, tab);

      expect(tester.takeException(), isNull, reason: '$tab tab threw');
    });
  }

  testWidgets('every tab survives a light/dark switch', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    for (final tab in tabs) {
      await openTab(tester, tab);

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab broke in dark mode');

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '$tab broke back in light');
    }
  });

  /// The picker opens as an alert dialog and closes cleanly.
  testWidgets('the date picker opens and cancels', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await openTab(tester, 'Date Picker');

    await tester.tap(find.text('मिति छान्नुहोस्').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('रद्द गर्नुहोस्'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  /// The segmented switcher swaps the whole CalendarBuilder, so a design that
  /// overflows or throws only shows up once it is actually selected.
  testWidgets('every custom design renders, in both themes', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await openTab(tester, 'Custom');

    for (final design in ['Traditional', 'Premium']) {
      await tester.tap(find.text(design));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$design threw');

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '$design broke in dark mode');

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('every tab survives a language switch', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    for (final tab in tabs) {
      await openTab(tester, tab);

      await tester.tap(find.byTooltip('Toggle Language'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab broke in English');

      await tester.tap(find.byTooltip('Toggle Language'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '$tab broke back in Nepali');
    }
  });
}
