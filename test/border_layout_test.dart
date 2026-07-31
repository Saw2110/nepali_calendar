// The table-border plumbing lives on widgets that are deprecated but still the
// thing under test.
// ignore_for_file: deprecated_member_use_from_same_package

// Spelling the day out keeps the dates under test readable.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Geometry and paint order of `showBorder: true`.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  Widget calendar({
    required bool showBorder,
    NepaliDateTime? date,
  }) {
    return NepaliCalendar(
      key: ValueKey('$showBorder $date'),
      initialDate: date ?? NepaliDateTime(year: 2083, month: 4, day: 1),
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(showBorder: showBorder),
      ),
    );
  }

  /// Every wrapper that draws a table rule: the per-cell right/bottom lines and
  /// the month view's outer top/left frame. A cell's own background decoration
  /// has no border, so it is filtered out.
  Iterable<DecoratedBox> ruleBoxes(WidgetTester tester) {
    return tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where((box) {
      final decoration = box.decoration;
      return decoration is BoxDecoration && decoration.border != null;
    });
  }

  group('paint order', () {
    /// Up to 0.0.7 these painted *behind* the cell. Every cell fills itself
    /// corner to corner, so today's opaque background erased its own right and
    /// bottom rules, and a selected cell tinted them a different colour from
    /// every other line in the table. The header row was unaffected -- its
    /// cells have no background -- which is what made the two rows look like
    /// they were drawn to different rules.
    testWidgets('table rules draw over cell backgrounds, not under them',
        (tester) async {
      await tester.pumpWidget(host(calendar(showBorder: true)));
      await tester.pumpAndSettle();

      final rules = ruleBoxes(tester).toList();

      expect(rules, isNotEmpty, reason: 'showBorder should draw rules at all');
      expect(
        rules.every((b) => b.position == DecorationPosition.foreground),
        isTrue,
        reason: 'a background-positioned rule is painted over by the cell',
      );
    });

    testWidgets('holds when today is on screen', (tester) async {
      // Today's cell is the opaque one, so it is the case that regressed.
      await tester.pumpWidget(
        host(calendar(showBorder: true, date: NepaliDateTime.now())),
      );
      await tester.pumpAndSettle();

      expect(
        ruleBoxes(tester).every((b) => b.position == DecorationPosition.foreground),
        isTrue,
      );
    });

    testWidgets('no rules are drawn when showBorder is false', (tester) async {
      await tester.pumpWidget(host(calendar(showBorder: false)));
      await tester.pumpAndSettle();

      expect(ruleBoxes(tester), isEmpty);
    });
  });

  group('column alignment', () {
    testWidgets('weekday labels sit over their date columns', (tester) async {
      await tester.pumpWidget(host(calendar(showBorder: true)));
      await tester.pumpAndSettle();

      const labels = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'];
      final cells = find.byType(CalendarCell);

      for (var column = 0; column < 7; column++) {
        expect(
          tester.getRect(find.text(labels[column]).first).center.dx,
          closeTo(tester.getRect(cells.at(column)).center.dx, 0.01),
          reason: 'column $column header and dates must share a centre',
        );
      }
    });
  });

  group('vertical budget', () {
    /// The cell size is derived from the width the grid actually gets. Up to
    /// 0.0.7 it was derived from the full width, ignoring CalendarMonthView's
    /// own padding, so every row came out narrower and therefore shorter than
    /// the budget assumed -- leaving a dead strip at the bottom of each page.
    Future<void> expectNoDeadStrip(
      WidgetTester tester, {
      required bool showBorder,
      required NepaliDateTime date,
    }) async {
      await tester.pumpWidget(
        host(calendar(showBorder: showBorder, date: date)),
      );
      await tester.pumpAndSettle();

      final viewport = tester.getRect(find.byType(PageView)).height;
      final content =
          tester.getRect(find.byType(CalendarMonthView).first).height;

      expect(
        content,
        closeTo(viewport, 0.5),
        reason: 'month content should fill its page, not leave a strip',
      );
    }

    testWidgets('a six-row month fills its page', (tester) async {
      await expectNoDeadStrip(
        tester,
        showBorder: true,
        date: NepaliDateTime(year: 2083, month: 4, day: 1),
      );
    });

    testWidgets('a five-row month fills its page', (tester) async {
      await expectNoDeadStrip(
        tester,
        showBorder: true,
        date: NepaliDateTime(year: 2083, month: 5, day: 1),
      );
    });

    testWidgets('the 10px header gap is accounted for when borders are off',
        (tester) async {
      await expectNoDeadStrip(
        tester,
        showBorder: false,
        date: NepaliDateTime(year: 2083, month: 4, day: 1),
      );
    });
  });
}
