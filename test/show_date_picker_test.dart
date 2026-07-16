// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Tests for the modal entry point, [showNepaliDatePicker].
///
/// The theme tests added in 0.1.0 exercised [NepaliDatePicker] embedded
/// directly, never the dialog wrapper -- which is exactly why the wrapper's
/// hard-coded white surface survived. These cover the wrapper itself.
void main() {
  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 10);

  /// Builds a host app. [themed] wraps the tree in a [NepaliCalendarTheme],
  /// which is how a caller opts into dark mode.
  Widget host({
    required Brightness brightness,
    bool themed = false,
    Language language = Language.english,
    ValueChanged<NepaliDateTime?>? onResult,
  }) {
    Widget page(BuildContext context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await showNepaliDatePicker(
                  context: context,
                  initialDate: baisakh2081,
                  calendarStyle: NepaliCalendarStyle(
                    config: CalendarConfig(language: language),
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('open'),
            ),
          ),
        );

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      ),
      home: Builder(
        builder: (context) => themed
            ? NepaliCalendarTheme(
                data: NepaliCalendarThemeData.fromContext(context),
                child: Builder(builder: page),
              )
            : page(context),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The colour the alert actually paints behind the picker.
  ///
  /// The AlertDialog declares no backgroundColor -- that is the point -- so it
  /// has to be read off the Material that Dialog builds.
  Color alertSurface(WidgetTester tester) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.color!;
  }

  group('readable in every theme', () {
    /// The picker is shown as a plain AlertDialog, so its surface comes from
    /// the app's dialogTheme -- dark in a dark app. Its *contents* therefore
    /// have to follow the Material theme too, or a dark app gets the legacy
    /// light palette's black dates on a dark sheet. That is why the picker
    /// falls back to NepaliCalendarThemeData.fromContext where the calendar
    /// widgets fall back to the legacy palette.
    ///
    /// Asserted as contrast rather than as particular colours: the property
    /// that matters is that you can read the dates.
    for (final brightness in Brightness.values) {
      for (final themed in [true, false]) {
        testWidgets(
            'date text is readable (${brightness.name}, themed: $themed)',
            (tester) async {
          await tester.pumpWidget(host(brightness: brightness, themed: themed));
          await open(tester);

          final surface = alertSurface(tester);
          // BS 2081-01-01 is a Saturday, so the 12th is a plain weekday and
          // carries the ordinary date colour rather than the weekend one.
          final dayColour =
              tester.widget<Text>(find.text('12').first).style?.color;

          expect(dayColour, isNotNull);
          expect(
            (dayColour!.computeLuminance() - surface.computeLuminance()).abs(),
            greaterThan(0.3),
            reason: 'date text $dayColour is unreadable on surface $surface',
          );
        });
      }
    }

    testWidgets('the alert brings no surface of its own', (tester) async {
      await tester.pumpWidget(host(brightness: Brightness.dark));
      await open(tester);

      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(
        dialog.backgroundColor,
        isNull,
        reason: 'it should look like every other alert in the app',
      );
      expect(dialog.shape, isNull);
    });
  });

  group('result', () {
    testWidgets('returns the selected date on confirm', (tester) async {
      NepaliDateTime? result;
      var called = false;

      await tester.pumpWidget(
        host(
          brightness: Brightness.light,
          onResult: (value) {
            result = value;
            called = true;
          },
        ),
      );
      await open(tester);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result?.day, 15);
      expect(result?.month, 1);
      expect(result?.year, 2081);
    });

    testWidgets('returns null on cancel', (tester) async {
      NepaliDateTime? result;
      var called = false;

      await tester.pumpWidget(
        host(
          brightness: Brightness.light,
          onResult: (value) {
            result = value;
            called = true;
          },
        ),
      );
      await open(tester);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result, isNull, reason: 'cancel must discard the selection');
    });

    testWidgets('returns null when dismissed by the barrier', (tester) async {
      NepaliDateTime? result;
      var called = false;

      await tester.pumpWidget(
        host(
          brightness: Brightness.light,
          onResult: (value) {
            result = value;
            called = true;
          },
        ),
      );
      await open(tester);

      // Tap the barrier, well away from the dialog.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result, isNull);
    });
  });

  group('cell sizing', () {
    /// Records the sizing contract as it actually is, measured, rather than as
    /// one might wish it were.
    ///
    /// Material asks for a 48dp touch target. Seven columns of 48 need 336dp
    /// plus gutters, and an iPhone SE dialog has about 343dp in total, so 48
    /// is not reachable on a small phone at any sensible padding. Flutter's
    /// own Material DatePicker uses roughly 42dp cells for the same reason.
    ///
    /// What the picker does guarantee: cells never fall below
    /// [_minCellExtent]-ish (36dp), and the dialog never overflows.
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'Pixel 7': Size(412, 915),
      'phone landscape': Size(844, 390),
      'tablet': Size(1024, 768),
    };

    for (final entry in devices.entries) {
      testWidgets('${entry.key} keeps cells usable', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          host(brightness: Brightness.light, language: Language.english),
        );
        await open(tester);

        // Day 12 is unique in Baisakh 2081's grid.
        final cell = tester.getSize(
          find
              .ancestor(of: find.text('12'), matching: find.byType(InkResponse))
              .first,
        );

        expect(
          cell.width,
          greaterThanOrEqualTo(36.0),
          reason: '${entry.key}: cells ${cell.width}x${cell.height} too narrow',
        );
        expect(
          cell.height,
          greaterThanOrEqualTo(36.0),
          reason: '${entry.key}: cells ${cell.width}x${cell.height} too short',
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('fits its viewport', () {
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'phone landscape': Size(844, 390),
      'tablet': Size(1024, 768),
    };

    for (final entry in devices.entries) {
      for (final language in Language.values) {
        testWidgets('${entry.key} in ${language.name} does not overflow',
            (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            host(brightness: Brightness.light, language: language),
          );
          await open(tester);

          expect(
            tester.takeException(),
            isNull,
            reason: 'overflowed on ${entry.key} in ${language.name}',
          );
        });
      }
    }
  });
}
