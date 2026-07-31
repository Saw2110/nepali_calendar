// ignore_for_file: avoid_redundant_argument_values, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  final baisakh2081 = NepaliDateTime(year: 2081, month: 1, day: 10);

  /// The colour a given day's text actually renders with.
  ///
  /// Pick a weekday, not a weekend: BS 2081-01-01 is a Saturday, so the 8th,
  /// 15th, 22nd and 29th all render with the weekend colour rather than the
  /// ordinary date colour. The 12th is a Wednesday.
  Color? dayTextColour(WidgetTester tester, String day) {
    return tester.widget<Text>(find.text(day).first).style?.color;
  }

  group('resolution order', () {
    /// The load-bearing guarantee of the whole theme layer: a calendar with
    /// no NepaliCalendarTheme above it must look exactly as it did before the
    /// theme layer existed.
    testWidgets('without a theme, nothing changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NepaliCalendar(
              initialDate: baisakh2081,
              calendarStyle: const NepaliCalendarStyle(
                config: CalendarConfig(language: Language.english),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The pre-0.1.0 default for an ordinary weekday.
      expect(dayTextColour(tester, '12'), Colors.black);
    });

    testWidgets('a theme applies when no explicit style is given',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dayTextColour(tester, '12'), Colors.purple);
    });

    testWidgets('an explicit style beats the theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                  cellsStyle: CellStyle(dateTextColor: Colors.orange),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        dayTextColour(tester, '12'),
        Colors.orange,
        reason: 'a hand-styled calendar must not be restyled by a theme',
      );
    });

    /// A style passed purely to set behaviour -- language, weekend days --
    /// carries no appearance intent, so it must not suppress the theme.
    testWidgets('a config-only style still gets themed colours',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(
                    language: Language.english,
                    weekendType: WeekendType.saturdayAndSunday,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dayTextColour(tester, '12'), Colors.purple);
    });
  });

  group('config survives resolution', () {
    testWidgets('language is preserved when a theme applies', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.dark(),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15'), findsWidgets, reason: 'still English numerals');
      expect(find.text('१५'), findsNothing);
    });

    /// The deprecated top-level style properties live outside `config`, so a
    /// naive resolution that copied only `config` would silently drop them.
    testWidgets('deprecated showEnglishDate survives a theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy(),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  showEnglishDate: true,
                  language: Language.english,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // BS 2081-01-01 is AD 2024-04-13, so the AD day must still be shown.
      expect(
        find.text('13'),
        findsWidgets,
        reason: 'showEnglishDate must not be lost when a theme resolves',
      );
    });
  });

  group('dark theme', () {
    testWidgets('renders light text on a dark surface', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.dark(),
            child: Scaffold(
              body: NepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final colour = dayTextColour(tester, '12')!;

      // A dark theme's date text must be light enough to read on a dark
      // surface -- the exact value depends on the ColorScheme.
      expect(
        colour.computeLuminance(),
        greaterThan(0.5),
        reason: 'dark theme should use light date text, got $colour',
      );
    });

    testWidgets('light and dark differ', (tester) async {
      Future<Color?> colourFor(NepaliCalendarThemeData data) async {
        await tester.pumpWidget(
          MaterialApp(
            home: NepaliCalendarTheme(
              data: data,
              child: Scaffold(
                body: NepaliCalendar(
                  initialDate: baisakh2081,
                  calendarStyle: const NepaliCalendarStyle(
                    config: CalendarConfig(language: Language.english),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return dayTextColour(tester, '12');
      }

      final light = await colourFor(NepaliCalendarThemeData.light());
      final dark = await colourFor(NepaliCalendarThemeData.dark());

      expect(light, isNot(dark));
    });
  });

  group('fromContext follows the Material theme', () {
    testWidgets('picks up the ambient ColorScheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          home: Builder(
            builder: (context) => NepaliCalendarTheme(
              data: NepaliCalendarThemeData.fromContext(context),
              child: Scaffold(
                body: NepaliCalendar(
                  initialDate: baisakh2081,
                  calendarStyle: const NepaliCalendarStyle(
                    config: CalendarConfig(language: Language.english),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
      expect(dayTextColour(tester, '12'), scheme.onSurface);
    });
  });

  group('NepaliCalendarThemeData', () {
    test('legacy() reproduces the pre-0.1.0 defaults exactly', () {
      final legacy = NepaliCalendarThemeData.legacy();
      const cells = CellStyle();
      const headers = HeaderStyle();

      expect(legacy.todayColor, cells.todayColor);
      expect(legacy.selectedColor, cells.selectedColor);
      expect(legacy.weekendColor, cells.weekDayColor);
      expect(legacy.eventDotColor, cells.dotColor);
      expect(legacy.dateTextColor, cells.dateTextColor);
      expect(legacy.onHighlightColor, cells.onHighlightColor);
      expect(legacy.englishDateColor, cells.baseLineDateColor);
      expect(legacy.dayStyle, cells.dayStyle);
      expect(legacy.monthHeaderStyle, headers.monthHeaderStyle);
      expect(legacy.yearHeaderStyle, headers.yearHeaderStyle);
    });

    test('toStyle() round-trips through NepaliCalendarStyle', () {
      final theme = NepaliCalendarThemeData.legacy()
          .copyWith(todayColor: Colors.pink, selectedColor: Colors.amber);
      final style = theme.toStyle();

      expect(style.cellsStyle.todayColor, Colors.pink);
      expect(style.cellsStyle.selectedColor, Colors.amber);
    });

    test('toStyle() carries the config through', () {
      const config = CalendarConfig(
        language: Language.english,
        weekendType: WeekendType.fridayAndSaturday,
      );
      final style = NepaliCalendarThemeData.legacy().toStyle(config: config);

      expect(style.effectiveConfig.language, Language.english);
      expect(style.effectiveConfig.weekendType, WeekendType.fridayAndSaturday);
    });

    test('copyWith replaces only what it is given', () {
      final base = NepaliCalendarThemeData.legacy();
      final tweaked = base.copyWith(todayColor: Colors.orange);

      expect(tweaked.todayColor, Colors.orange);
      expect(tweaked.selectedColor, base.selectedColor);
      expect(tweaked.dateTextColor, base.dateTextColor);
    });

    test('value equality', () {
      expect(
        NepaliCalendarThemeData.legacy(),
        NepaliCalendarThemeData.legacy(),
      );
      expect(
        NepaliCalendarThemeData.legacy().hashCode,
        NepaliCalendarThemeData.legacy().hashCode,
      );
      final tweaked =
          NepaliCalendarThemeData.legacy().copyWith(todayColor: Colors.pink);
      expect(NepaliCalendarThemeData.legacy(), isNot(tweaked));
    });
  });

  group('crosses route boundaries', () {
    /// NepaliCalendarTheme is an InheritedTheme, not a plain InheritedWidget,
    /// so Flutter captures and re-injects it across a route push. Without
    /// that, anything shown via a Navigator -- a dialog, a pushed page --
    /// would silently fall back to the legacy palette, because the overlay's
    /// ancestors are the Navigator and the app, not whatever sits in `home:`.
    Widget pushedCalendar() => Scaffold(
          body: NepaliCalendar(
            initialDate: baisakh2081,
            calendarStyle: const NepaliCalendarStyle(
              config: CalendarConfig(language: Language.english),
            ),
          ),
        );

    /// Documents a real limitation rather than a bug: `showDialog` captures
    /// InheritedThemes, but `Navigator.push` does not. A theme placed in
    /// `home:` therefore covers that subtree and any dialog opened from it,
    /// but not a pushed route -- the new route is a sibling under the
    /// Navigator, not a descendant of `home:`. Nothing the package can do
    /// about it; the answer is to place the theme above the Navigator.
    testWidgets('a theme inside home: does NOT reach a pushed route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => pushedCalendar()),
                  ),
                  child: const Text('push'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      expect(
        dayTextColour(tester, '12'),
        Colors.black,
        reason: 'falls back to the legacy palette, as documented',
      );
    });

    testWidgets('a theme in MaterialApp.builder DOES reach a pushed route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // Above the Navigator, so every route sees it. This is the placement
          // to recommend for app-wide theming.
          builder: (context, child) => NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => pushedCalendar()),
                ),
                child: const Text('push'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      expect(dayTextColour(tester, '12'), Colors.purple);
    });

    testWidgets('reaches a dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showNepaliDatePicker(
                    context: context,
                    initialDate: baisakh2081,
                    calendarStyle: const NepaliCalendarStyle(
                      config: CalendarConfig(language: Language.english),
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

      expect(dayTextColour(tester, '12'), Colors.purple);
    });
  });

  group('theme reaches the other widgets', () {
    testWidgets('HorizontalNepaliCalendar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.legacy()
                .copyWith(dateTextColor: Colors.purple),
            child: Scaffold(
              body: HorizontalNepaliCalendar(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                ),
                onDateSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dayTextColour(tester, '12'), Colors.purple);
    });

    testWidgets('NepaliDatePicker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NepaliCalendarTheme(
            data: NepaliCalendarThemeData.dark(),
            child: Scaffold(
              body: NepaliDatePicker(
                initialDate: baisakh2081,
                calendarStyle: const NepaliCalendarStyle(
                  config: CalendarConfig(language: Language.english),
                ),
                onDateSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        dayTextColour(tester, '12')!.computeLuminance(),
        greaterThan(0.5),
        reason: 'dark theme should reach the picker',
      );
    });
  });

  /// Up to 0.0.7 `weekendType` and `weekStartType` were accepted by copyWith and
  /// then silently dropped, so the returned style was identical to the original.
  group('NepaliCalendarStyle.copyWith', () {
    test('applies weekendType and weekStartType to the config', () {
      const original = NepaliCalendarStyle(
        config: CalendarConfig(
          weekendType: WeekendType.saturday,
          weekStartType: WeekStartType.sunday,
        ),
      );

      final updated = original.copyWith(
        weekendType: WeekendType.fridayAndSaturday,
        weekStartType: WeekStartType.monday,
      );

      expect(
          updated.effectiveConfig.weekendType, WeekendType.fridayAndSaturday);
      expect(updated.effectiveConfig.weekStartType, WeekStartType.monday);
    });

    test('leaves the rest of the config alone', () {
      const original = NepaliCalendarStyle(
        config: CalendarConfig(
          showEnglishDate: true,
          language: Language.english,
          sixWeekMonthsEnforced: true,
        ),
      );

      final updated = original.copyWith(weekStartType: WeekStartType.monday);

      expect(updated.effectiveConfig.showEnglishDate, isTrue);
      expect(updated.effectiveConfig.language, Language.english);
      expect(updated.effectiveConfig.sixWeekMonthsEnforced, isTrue);
      expect(updated.effectiveConfig.weekStartType, WeekStartType.monday);
    });

    test(
        'works when the original has no config, carrying the legacy '
        'properties across', () {
      // The deprecated top-level properties are the only source of config here,
      // so they have to survive being folded into a synthesised one.
      const original = NepaliCalendarStyle(
        showEnglishDate: true,
        language: Language.english,
      );

      final updated = original.copyWith(weekendType: WeekendType.sunday);

      expect(updated.effectiveConfig.weekendType, WeekendType.sunday);
      expect(updated.effectiveConfig.showEnglishDate, isTrue);
      expect(updated.effectiveConfig.language, Language.english);
    });

    test('does not synthesise a config when neither is passed', () {
      const original = NepaliCalendarStyle(showEnglishDate: true);

      final updated = original.copyWith(showBorder: true);

      expect(
        updated.config,
        isNull,
        reason: 'an unrelated copyWith must not turn a null config non-null, '
            'which would suppress theme resolution',
      );
      expect(updated.effectiveConfig.showEnglishDate, isTrue);
      expect(updated.effectiveConfig.showBorder, isTrue);
    });

    test('an explicit config wins over the existing one', () {
      const original = NepaliCalendarStyle(
        config: CalendarConfig(weekendType: WeekendType.saturday),
      );

      final updated = original.copyWith(
        config: const CalendarConfig(weekendType: WeekendType.sunday),
      );

      expect(updated.effectiveConfig.weekendType, WeekendType.sunday);
    });
  });
}
