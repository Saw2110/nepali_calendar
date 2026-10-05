import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'picker_finders.dart';

NepaliDateTime bs(int year, int month, int day) =>
    NepaliDateTime(year: year, month: month, day: day);

const english = NepaliCalendarStyle(
  config: CalendarConfig(language: Language.english),
);

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

/// The default title band.
final band = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_TitleBand',
);

/// The texts inside the band, top to bottom.
List<String> bandTexts(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(of: band, matching: find.byType(Text)))
    .map((t) => t.data ?? '')
    .toList();

IconButton arrow(WidgetTester tester, String tooltip) =>
    tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(IconButton),
      ),
    );

void main() {
  group('title band', () {
    testWidgets('shows the selected date in BS and AD', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );

      final date = bs(2081, 1, 15);
      final weekday = WeekUtils.formattedWeekDay(
        date.weekday,
        Language.english,
        TitleFormat.half,
      );
      final ad = date.toDateTime();
      expect(bandTexts(tester), [
        '2081',
        '$weekday, ${MonthUtils.formattedMonth(1, Language.english)} 15',
        '${ad.day.toString().padLeft(2, '0')} '
            '${MonthUtils.englishMonthsShort[ad.month - 1]} ${ad.year}',
      ]);
    });

    testWidgets('follows a tap on a date', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );

      await tester.tap(outsideBand('20'));
      await tester.pump();
      expect(bandTexts(tester)[1], endsWith(' 20'));
    });

    testWidgets('is in Nepali for a Nepali picker', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            // Nepali is the default language.
            onDateSelected: (_) {},
          ),
        ),
      );
      expect(bandTexts(tester).first, '२०८१');
      expect(bandTexts(tester)[1], endsWith(' १५'));
      expect(find.text('आज'), findsOneWidget);
    });

    testWidgets('Today, in the action row, selects today', (tester) async {
      NepaliDateTime? picked;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            calendarStyle: english,
            onDateSelected: (date) => picked = date,
          ),
        ),
      );

      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(picked!.isSameDayAs(NepaliDateTime.now()), isTrue);
    });

    testWidgets('Today is hidden when today is out of range', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2000, 1, 15),
            maxDate: bs(2000, 12, 1),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );
      expect(find.text('Today'), findsNothing);
    });
  });

  group('navigation row', () {
    testWidgets('the year arrows step a year and stop at the ends',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 5, 15),
            minDate: bs(2081, 1, 1),
            maxDate: bs(2082, 3, 10),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );

      final month = MonthUtils.formattedMonth(5, Language.english);
      expect(arrow(tester, 'Previous year').onPressed, isNull);

      await tester.tap(find.byTooltip('Next year'));
      await tester.pumpAndSettle();
      expect(outsideBand('2082'), findsOneWidget);
      // Shravan 2082 is past maxDate, so the month is pulled back to it.
      expect(find.text(month), findsNothing);
      expect(
        find.text(MonthUtils.formattedMonth(3, Language.english)),
        findsOneWidget,
      );
      expect(arrow(tester, 'Next year').onPressed, isNull);
      expect(arrow(tester, 'Previous year').onPressed, isNotNull);
    });

    testWidgets('the month arrows step a month', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 5, 15),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(
        find.text(MonthUtils.formattedMonth(6, Language.english)),
        findsOneWidget,
      );
      expect(outsideBand('2081'), findsOneWidget);
    });

    testWidgets('the month arrows rest in the month and year views',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 5, 15),
            calendarStyle: english,
            onDateSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Select month'));
      await tester.pumpAndSettle();
      expect(arrow(tester, 'Previous month').onPressed, isNull);
      expect(arrow(tester, 'Next month').onPressed, isNull);
      expect(arrow(tester, 'Next year').onPressed, isNotNull);

      await tester.tap(find.bySemanticsLabel('Select year'));
      await tester.pumpAndSettle();
      expect(arrow(tester, 'Next month').onPressed, isNull);
      expect(arrow(tester, 'Next page').onPressed, isNotNull);
    });
  });

  group('action row', () {
    Future<void> openDialog(
      WidgetTester tester, {
      required bool autoConfirm,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showNepaliDatePicker(
                context: context,
                initialDate: bs(2081, 1, 15),
                calendarStyle: english,
                autoConfirm: autoConfirm,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('a tap-to-confirm dialog has Close, which returns null',
        (tester) async {
      await openDialog(tester, autoConfirm: true);
      expect(find.text('OK'), findsNothing);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(NepaliDatePicker), findsNothing);
    });

    testWidgets('without auto-confirm, Cancel sits beside OK', (tester) async {
      await openDialog(tester, autoConfirm: false);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('fits', () {
    const sizes = <String, Size>{
      'narrow phone': Size(320, 640),
      'phone landscape': Size(844, 390),
      'small landscape': Size(640, 360),
      'tablet': Size(1024, 768),
    };

    for (final entry in sizes.entries) {
      for (final language in Language.values) {
        testWidgets('${entry.key}, ${language.name}', (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showNepaliDatePicker(
                    context: context,
                    initialDate: bs(2081, 8, 25),
                    autoConfirm: false,
                    calendarStyle: NepaliCalendarStyle(
                      config: CalendarConfig(language: language),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final short = entry.value.height < 500;
          final bandSize = tester.getSize(band);
          if (short) {
            // Beside the grid, so the rows keep a usable height.
            expect(bandSize.width, 168);
          } else {
            expect(bandSize.height, 96);
            // Edge to edge, not shrunk to its text.
            expect(
              bandSize.width,
              tester.getSize(find.byType(NepaliDatePicker)).width,
            );
          }
        });
      }
    }
  });
}
