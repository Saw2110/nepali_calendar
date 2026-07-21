// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// The calendar's header rows must follow the theme like everything else.
///
/// The theme tests elsewhere check the *date cells*, which is why hard-coded
/// colours in the weekday row and the month/year header survived: a calendar
/// can have perfectly themed dates sitting under a header stuck in light mode.
void main() {
  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 1);

  Widget host({
    required Brightness brightness,
    bool showBorder = false,
  }) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      ),
      builder: (context, child) => NepaliCalendarTheme(
        data: NepaliCalendarThemeData.fromContext(context),
        child: child!,
      ),
      home: Scaffold(
        body: NepaliCalendar(
          initialDate: baisakh2081,
          calendarStyle: NepaliCalendarStyle(
            config: CalendarConfig(
              language: Language.english,
              showBorder: showBorder,
            ),
          ),
        ),
      ),
    );
  }

  /// The surface the calendar is painted on.
  Color surfaceOf(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(NepaliCalendar)))
        .colorScheme
        .surface;
  }

  void expectReadable(Color? colour, Color surface, {required String what}) {
    expect(colour, isNotNull, reason: '$what has no colour');
    expect(
      (colour!.computeLuminance() - surface.computeLuminance()).abs(),
      greaterThan(0.25),
      reason: '$what is $colour, unreadable on $surface',
    );
  }

  group('weekday row follows the theme', () {
    /// The weekday names were hard-coded to Colors.black87 and Colors.black54,
    /// so in a dark app the row was near-invisible above perfectly themed
    /// dates.
    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name}: weekday names are readable',
          (tester) async {
        await tester.pumpWidget(host(brightness: brightness));
        await tester.pumpAndSettle();

        final surface = surfaceOf(tester);

        // The default weekday header shows the Nepali name above the English
        // one. Wednesday is a plain weekday in the default configuration, so
        // it carries the ordinary colour rather than the weekend one.
        expectReadable(
          tester.widget<Text>(find.text('बुध')).style?.color,
          surface,
          what: 'the Nepali weekday name',
        );
        expectReadable(
          tester.widget<Text>(find.text('Wed')).style?.color,
          surface,
          what: 'the English weekday name',
        );
      });
    }
  });

  group('month and year header follow the theme', () {
    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name}: month and year are readable',
          (tester) async {
        await tester.pumpWidget(host(brightness: brightness));
        await tester.pumpAndSettle();

        final surface = surfaceOf(tester);

        expectReadable(
          tester.widget<Text>(find.text('Baisakh')).style?.color,
          surface,
          what: 'the month name',
        );
        expectReadable(
          tester.widget<Text>(find.text('2081')).style?.color,
          surface,
          what: 'the year',
        );
      });
    }
  });

  group('borders follow the theme', () {
    /// showBorder drew Colors.grey regardless of theme. The example switches
    /// it on, so this is what a dark-mode user actually sees.
    testWidgets('the border colour comes from the style', (tester) async {
      await tester.pumpWidget(
        host(brightness: Brightness.dark, showBorder: true),
      );
      await tester.pumpAndSettle();

      // Every themed border derives from cellsStyle.borderColor. Colors.grey
      // is what the hard-coded version used, so its presence is the tell.
      final borders = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.border)
          .whereType<Border>()
          // _wrapWithTableBorder draws right and bottom, not top -- reading
          // only `top` gets the default BorderSide and passes vacuously.
          .expand(
            (border) => [border.top, border.right, border.bottom, border.left],
          )
          .where((side) => side.style != BorderStyle.none)
          .map((side) => side.color)
          .toSet();

      expect(borders, isNotEmpty, reason: 'showBorder drew no borders');
      for (final colour in borders) {
        expect(
          colour.toARGB32(),
          isNot(Colors.grey.withValues(alpha: 0.3).toARGB32()),
          reason: 'border is hard-coded grey rather than themed',
        );
      }
    });
  });
}
