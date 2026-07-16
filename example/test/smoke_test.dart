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

      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '$tab tab threw');
    });
  }

  testWidgets('every tab survives a light/dark switch', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    for (final tab in tabs) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab broke in dark mode');

      await tester.tap(find.byTooltip('Toggle Light/Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '$tab broke back in light');
    }
  });

  testWidgets('every tab survives a language switch', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    for (final tab in tabs) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();

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
