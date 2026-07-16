// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Layout tests for [NepaliDatePicker].
///
/// The "does not overflow" tests elsewhere cannot catch a cramped layout:
/// `TextOverflow.ellipsis` turns an overflow *error* into silent truncation,
/// so a picker whose title reads "असार २०..." passes them cleanly. These
/// assert the thing that actually matters -- that the text is readable.
void main() {
  /// Every [Text] in the tree that got ellipsised.
  List<String> truncatedTexts(WidgetTester tester) {
    final truncated = <String>[];
    for (final element in find.byType(Text).evaluate()) {
      final paragraph = element.renderObject;
      if (paragraph is RenderParagraph && paragraph.didExceedMaxLines) {
        truncated.add((element.widget as Text).data ?? '<span>');
      }
    }
    return truncated;
  }

  Widget host({
    required Language language,
    NepaliDatePickerMode mode = NepaliDatePickerMode.day,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: NepaliDatePicker(
            // Asar 2083 is a 32-day month, and "असार २०८३" is a long title.
            initialDate: NepaliDateTime(year: 2083, month: 3, day: 15),
            initialMode: mode,
            calendarStyle: NepaliCalendarStyle(
              config: CalendarConfig(language: language),
            ),
            onDateSelected: (_) {},
          ),
        ),
      ),
    );
  }

  group('nothing is truncated', () {
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'Pixel 7': Size(412, 915),
      'tablet': Size(1024, 768),
    };

    for (final entry in devices.entries) {
      for (final language in Language.values) {
        testWidgets('${entry.key} in ${language.name}', (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(host(language: language));
          await tester.pumpAndSettle();

          expect(
            truncatedTexts(tester),
            isEmpty,
            reason: '${entry.key}/${language.name}: text was cut off',
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    /// The Nepali labels are the wide ones -- "रद्द गर्नुहोस्" against
    /// "Cancel" -- so they are what a too-tight layout truncates first.
    testWidgets('the Nepali action labels fit', (tester) async {
      await tester.pumpWidget(host(language: Language.nepali));
      await tester.pumpAndSettle();

      expect(truncatedTexts(tester), isNot(contains('रद्द गर्नुहोस्')));
      expect(truncatedTexts(tester), isNot(contains('ठीक छ')));
      expect(truncatedTexts(tester), isNot(contains('आज')));
    });

    testWidgets('the Nepali month title fits', (tester) async {
      await tester.pumpWidget(host(language: Language.nepali));
      await tester.pumpAndSettle();

      expect(truncatedTexts(tester), isNot(contains('असार २०८३')));
    });

    for (final mode in NepaliDatePickerMode.values) {
      testWidgets('${mode.name} view fits in Nepali', (tester) async {
        await tester.pumpWidget(host(language: Language.nepali, mode: mode));
        await tester.pumpAndSettle();

        expect(
          truncatedTexts(tester),
          isEmpty,
          reason: '${mode.name} view cut text off',
        );
      });
    }
  });

  group('nothing is truncated in the dialog either', () {
    /// The tests above build the picker directly, where it gets all the width
    /// it asks for. Through showNepaliDatePicker the dialog's insets cap it,
    /// which is a different -- and tighter -- constraint. It is where the
    /// truncation actually showed up on a real phone.
    const devices = <String, Size>{
      'iPhone SE': Size(375, 667),
      'iPhone 14': Size(390, 844),
      'Pixel 7': Size(412, 915),
    };

    for (final entry in devices.entries) {
      for (final language in Language.values) {
        testWidgets('${entry.key} in ${language.name}', (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => showNepaliDatePicker(
                        context: context,
                        initialDate:
                            NepaliDateTime(year: 2083, month: 3, day: 15),
                        calendarStyle: NepaliCalendarStyle(
                          config: CalendarConfig(language: language),
                        ),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(
            truncatedTexts(tester),
            isEmpty,
            reason: '${entry.key}/${language.name}: text was cut off',
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('stays readable at a larger text scale', () {
    testWidgets('1.3x does not overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: Scaffold(
                body: Center(
                  child: NepaliDatePicker(
                    initialDate: NepaliDateTime(year: 2083, month: 3, day: 15),
                    onDateSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Truncation is tolerable here -- overflow is not.
      expect(tester.takeException(), isNull);
    });
  });
}
