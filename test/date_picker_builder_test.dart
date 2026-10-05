import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';
import 'package:nepali_calendar_plus/src/date_picker/internal/picker_shared.dart';

NepaliDateTime bs(int year, int month, int day) =>
    NepaliDateTime(year: year, month: month, day: day);

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

/// The days of [month] a day builder was asked for, by day number.
Map<int, PickerDayData> daysOf(List<PickerDayData> seen, int month) => {
      for (final d in seen)
        if (d.date.month == month && !d.isOtherMonth) d.date.day: d,
    };

void main() {
  group('dayBuilder', () {
    testWidgets('draws custom days, whose taps select', (tester) async {
      NepaliDateTime? picked;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            onDateSelected: (date) => picked = date,
            pickerBuilder: DatePickerBuilder(
              dayBuilder: (day) => GestureDetector(
                onTap: day.onTap,
                child: Text('d${day.date.month}-${day.date.day}'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('d1-15'), findsOneWidget);
      expect(find.byType(PickerDaySquare), findsNothing);

      await tester.tap(find.text('d1-20'));
      await tester.pump();
      expect(picked!.isSameDayAs(bs(2081, 1, 20)), isTrue);
    });

    testWidgets('describes each day', (tester) async {
      final seen = <PickerDayData>[];
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            minDate: bs(2081, 1, 10),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              dayBuilder: (day) {
                seen.add(day);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );

      final days = daysOf(seen, 1);
      expect(days[15]!.isSelected, isTrue);
      expect(days[16]!.isSelected, isFalse);
      expect(days[5]!.isDisabled, isTrue);
      expect(days[5]!.onTap, isNull);
      expect(days[15]!.onTap, isNotNull);
      expect(days[15]!.rangePosition, PickerRangePosition.none);
      expect(days[15]!.label, isNotEmpty);

      // Days of the neighbouring months are offered too, and are inert.
      final other = seen.where((d) => d.isOtherMonth);
      expect(other, isNotEmpty);
      expect(other.every((d) => d.onTap == null), isTrue);
    });

    testWidgets('null keeps the default for that day', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              dayBuilder: (day) => day.isSelected ? const Text('custom') : null,
            ),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      // Every other cell of the six-week grid is the default square.
      expect(find.byType(PickerDaySquare), findsNWidgets(41));
    });

    testWidgets('keeps the picker\'s semantics around a custom day',
        (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            onDateSelected: (_) {},
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            pickerBuilder: DatePickerBuilder(
              dayBuilder: (_) => const SizedBox.expand(),
            ),
          ),
        ),
      );

      final month = MonthUtils.formattedMonth(1, Language.english);
      final cell = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('$month, 15, '),
        ),
      );
      expect(cell.properties.selected, isTrue);
      expect(cell.properties.button, isTrue);
    });
  });

  group('weekdayBuilder', () {
    for (final format in <TitleFormat?>[null, ...TitleFormat.values]) {
      testWidgets('gets the labels for ${format?.name ?? 'initials'}',
          (tester) async {
        final seen = <PickerWeekdayData>[];
        await tester.pumpWidget(
          host(
            NepaliDatePicker(
              initialDate: bs(2081, 1, 15),
              weekdayFormat: format,
              onDateSelected: (_) {},
              pickerBuilder: DatePickerBuilder(
                weekdayBuilder: (data) {
                  seen.add(data);
                  return Text('w${data.weekday}');
                },
              ),
            ),
          ),
        );

        expect(find.text('w0'), findsOneWidget);
        final last = seen.sublist(seen.length - 7);
        for (final data in last) {
          final expected = format == null
              ? WeekUtils.formattedShortWeekDay(data.weekday, data.language)
              : WeekUtils.formattedWeekDay(data.weekday, data.language, format);
          expect(data.label, expected);
        }
        expect(last.map((d) => d.weekday).toSet(), {0, 1, 2, 3, 4, 5, 6});
      });
    }
  });

  group('headerBuilder', () {
    testWidgets('pages months and opens the views', (tester) async {
      late PickerHeaderData header;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            minDate: bs(2081, 1, 1),
            maxDate: bs(2081, 2, 10),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              headerBuilder: (data) {
                header = data;
                return Text('H ${data.month.year}-${data.month.month}');
              },
            ),
          ),
        ),
      );

      expect(find.text('H 2081-1'), findsOneWidget);
      expect(header.mode, NepaliDatePickerMode.day);
      expect(header.onPreviousYear, isNull, reason: 'only 2081 is in range');
      expect(header.onNextYear, isNull);
      expect(header.secondMonth, isNull);
      expect(header.onPrevious, isNull, reason: 'at the start of the range');
      expect(header.onNext, isNotNull);

      header.onNext!();
      await tester.pumpAndSettle();
      expect(find.text('H 2081-2'), findsOneWidget);
      expect(header.onNext, isNull, reason: 'at the end of the range');
      expect(header.onPrevious, isNotNull);

      header.onYearTap!();
      await tester.pumpAndSettle();
      expect(header.mode, NepaliDatePickerMode.year);

      header.onMonthTap!();
      await tester.pumpAndSettle();
      expect(header.mode, NepaliDatePickerMode.month);

      header.onMonthTap!();
      await tester.pumpAndSettle();
      expect(header.mode, NepaliDatePickerMode.day);
    });
  });

  group('footerBuilder', () {
    testWidgets('takes the action row', (tester) async {
      const key = Key('footer');
      late PickerFooterData footer;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              footerBuilder: (data) {
                footer = data;
                return const SizedBox.expand(key: key);
              },
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(key)).height, 44);
      expect(find.text('OK'), findsNothing);
      expect(footer.selected!.isSameDayAs(bs(2081, 1, 15)), isTrue);
      expect(footer.onConfirm, isNotNull);
      expect(footer.onCancel, isNotNull);
      expect(footer.range, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onToday selects today', (tester) async {
      NepaliDateTime? picked;
      late PickerFooterData footer;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            onDateSelected: (date) => picked = date,
            pickerBuilder: DatePickerBuilder(
              footerBuilder: (data) {
                footer = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      footer.onToday!();
      await tester.pump();
      expect(picked!.isSameDayAs(NepaliDateTime.now()), isTrue);
      expect(footer.selected!.isSameDayAs(NepaliDateTime.now()), isTrue);
    });

    testWidgets('onToday is null when today is out of range', (tester) async {
      late PickerFooterData footer;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2000, 1, 15),
            maxDate: bs(2000, 12, 1),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              footerBuilder: (data) {
                footer = data;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(footer.onToday, isNull);
    });

    /// Opens [showNepaliDatePicker] with a custom footer, reporting what the
    /// dialog returns to [onResult].
    Future<void> openDialog(
      WidgetTester tester, {
      required bool autoConfirm,
      required ValueChanged<PickerFooterData> onFooter,
      ValueChanged<NepaliDateTime?>? onResult,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await showNepaliDatePicker(
                  context: context,
                  initialDate: bs(2081, 1, 15),
                  autoConfirm: autoConfirm,
                  pickerBuilder: DatePickerBuilder(
                    footerBuilder: (data) {
                      onFooter(data);
                      return const SizedBox.shrink();
                    },
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('onConfirm returns the date from the dialog', (tester) async {
      late PickerFooterData footer;
      NepaliDateTime? result;
      await openDialog(
        tester,
        autoConfirm: false,
        onFooter: (data) => footer = data,
        onResult: (date) => result = date,
      );

      footer.onConfirm!();
      await tester.pumpAndSettle();
      expect(result!.isSameDayAs(bs(2081, 1, 15)), isTrue);
      expect(find.byType(NepaliDatePicker), findsNothing);
    });

    testWidgets('onCancel closes the dialog', (tester) async {
      late PickerFooterData footer;
      await openDialog(
        tester,
        autoConfirm: false,
        onFooter: (data) => footer = data,
      );
      expect(find.byType(NepaliDatePicker), findsOneWidget);

      footer.onCancel!();
      await tester.pumpAndSettle();
      expect(find.byType(NepaliDatePicker), findsNothing);
    });

    testWidgets('a tap-to-confirm dialog offers close but no confirm',
        (tester) async {
      late PickerFooterData footer;
      await openDialog(
        tester,
        autoConfirm: true,
        onFooter: (data) => footer = data,
      );
      expect(footer.onConfirm, isNull);
      expect(footer.onCancel, isNotNull);
      expect(footer.onToday, isNotNull);
    });
  });

  group('titleBuilder', () {
    testWidgets('replaces the band, with the date and Today', (tester) async {
      late PickerTitleData title;
      NepaliDateTime? picked;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            onDateSelected: (date) => picked = date,
            pickerBuilder: DatePickerBuilder(
              titleBuilder: (data) {
                title = data;
                return Text('T ${data.dateLabel}');
              },
            ),
          ),
        ),
      );

      final weekday = WeekUtils.formattedWeekDay(
        bs(2081, 1, 15).weekday,
        Language.english,
        TitleFormat.half,
      );
      final month = MonthUtils.formattedMonth(1, Language.english);
      expect(find.text('T $weekday, $month 15'), findsOneWidget);
      expect(title.yearLabel, '2081');
      expect(title.adLabel, isNotEmpty);
      expect(title.isBesideGrid, isFalse);

      title.onToday!();
      await tester.pump();
      expect(picked!.isSameDayAs(NepaliDateTime.now()), isTrue);
      expect(title.selected.isSameDayAs(NepaliDateTime.now()), isTrue);
    });

    testWidgets('null keeps the default band', (tester) async {
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 1, 15),
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(titleBuilder: (_) => null),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_TitleBand',
        ),
        findsOneWidget,
      );
    });
  });

  group('choiceBuilder', () {
    testWidgets('custom tiles walk from year to month to day', (tester) async {
      final seen = <String, PickerChoiceData>{};
      late PickerHeaderData header;
      await tester.pumpWidget(
        host(
          NepaliDatePicker(
            initialDate: bs(2081, 5, 15),
            initialMode: NepaliDatePickerMode.year,
            minDate: bs(2081, 3, 1),
            onDateSelected: (_) {},
            pickerBuilder: DatePickerBuilder(
              headerBuilder: (data) {
                header = data;
                return null;
              },
              choiceBuilder: (choice) {
                final key = '${choice.isYear ? 'y' : 'm'}${choice.value}';
                seen[key] = choice;
                return GestureDetector(onTap: choice.onTap, child: Text(key));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(seen['y2081']!.isSelected, isTrue);
      await tester.tap(find.text('y2081'));
      await tester.pumpAndSettle();
      expect(header.mode, NepaliDatePickerMode.month);

      // Months before minDate are disabled and inert.
      expect(seen['m1']!.isDisabled, isTrue);
      expect(seen['m1']!.onTap, isNull);
      expect(seen['m5']!.isSelected, isTrue);

      await tester.tap(find.text('m7'));
      await tester.pumpAndSettle();
      expect(header.mode, NepaliDatePickerMode.day);
      expect(header.month.month, 7);
    });
  });

  group('range picker', () {
    testWidgets('reports where each day sits in the range', (tester) async {
      final seen = <PickerDayData>[];
      await tester.pumpWidget(
        host(
          NepaliDateRangePicker(
            initialRange: NepaliDateTimeRange(
              start: bs(2081, 1, 10),
              end: bs(2081, 1, 12),
            ),
            onConfirm: (_) {},
            pickerBuilder: DatePickerBuilder(
              dayBuilder: (day) {
                seen.add(day);
                return GestureDetector(
                  onTap: day.onTap,
                  child: Text('d${day.date.month}-${day.date.day}'),
                );
              },
            ),
          ),
        ),
      );

      var days = daysOf(seen, 1);
      expect(days[9]!.rangePosition, PickerRangePosition.none);
      expect(days[10]!.rangePosition, PickerRangePosition.start);
      expect(days[11]!.rangePosition, PickerRangePosition.middle);
      expect(days[11]!.isInRange, isTrue);
      expect(days[12]!.rangePosition, PickerRangePosition.end);
      expect(days[10]!.isSelected, isTrue);
      expect(days[11]!.isSelected, isFalse);
      expect(seen.any((d) => d.isOtherMonth), isFalse);

      seen.clear();
      await tester.tap(find.text('d1-20'));
      await tester.pump();
      days = daysOf(seen, 1);
      expect(days[20]!.rangePosition, PickerRangePosition.single);
      expect(days[10]!.rangePosition, PickerRangePosition.none);
    });

    testWidgets('header and footer in the side-by-side layout', (tester) async {
      late PickerHeaderData header;
      late PickerFooterData footer;
      NepaliDateTimeRange? confirmed;
      await tester.pumpWidget(
        host(
          NepaliDateRangePicker(
            initialRange: NepaliDateTimeRange(
              start: bs(2081, 1, 10),
              end: bs(2081, 1, 12),
            ),
            onConfirm: (range) => confirmed = range,
            pickerBuilder: DatePickerBuilder(
              headerBuilder: (data) {
                header = data;
                return Text('H ${data.month.month}+${data.secondMonth!.month}');
              },
              footerBuilder: (data) {
                footer = data;
                return const Text('F');
              },
            ),
          ),
        ),
      );

      expect(find.text('H 1+2'), findsOneWidget);
      expect(header.onMonthTap, isNull);
      expect(header.onYearTap, isNull);
      expect(header.onPreviousYear, isNull, reason: 'no year arrows here');
      expect(header.onNextYear, isNull);
      header.onNext!();
      await tester.pump();
      expect(find.text('H 2+3'), findsOneWidget);

      expect(find.text('F'), findsOneWidget);
      expect(footer.onToday, isNull);
      expect(footer.selected, isNull);
      expect(footer.rangeStart!.isSameDayAs(bs(2081, 1, 10)), isTrue);
      footer.onConfirm!();
      expect(confirmed!.end.isSameDayAs(bs(2081, 1, 12)), isTrue);
    });

    testWidgets('the phone layout\'s top bar is the footer', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late PickerFooterData footer;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NepaliDateRangePicker(
              onConfirm: (_) {},
              calendarStyle: const NepaliCalendarStyle(
                config: CalendarConfig(language: Language.english),
              ),
              pickerBuilder: DatePickerBuilder(
                footerBuilder: (data) {
                  footer = data;
                  return const SizedBox(height: 56, child: Text('top bar'));
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('top bar'), findsOneWidget);
      expect(find.text('Select range'), findsNothing);
      expect(footer.onConfirm, isNull, reason: 'nothing picked yet');
      expect(footer.onCancel, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });

  test('copyWith replaces only what it is given', () {
    Widget day(PickerDayData _) => const SizedBox();
    Widget footer(PickerFooterData _) => const SizedBox();
    final builder = DatePickerBuilder(dayBuilder: day);
    final copy = builder.copyWith(footerBuilder: footer);
    expect(copy.dayBuilder, same(builder.dayBuilder));
    expect(copy.footerBuilder, isNotNull);
    expect(copy.headerBuilder, isNull);
  });
}
