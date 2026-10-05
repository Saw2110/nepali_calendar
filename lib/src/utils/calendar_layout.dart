/// Layout pieces the calendar widgets share.
///
/// Internal: nothing here is exported from the package. The names are public
/// only because Dart privacy is per file, and several widget files need them.
library;

import 'package:flutter/widgets.dart';

import '../enum/week_config.dart';
import '../models/calendar_style.dart';

/// Weekday indices (0 = Sunday) in the order a week row shows them.
List<int> weekdayOrder(WeekStartType start) => switch (start) {
      WeekStartType.sunday => const [0, 1, 2, 3, 4, 5, 6],
      WeekStartType.monday => const [1, 2, 3, 4, 5, 6, 0],
    };

/// [month] of [year] moved by [delta] months, rolling over the year.
(int year, int month) shiftMonth(int year, int month, int delta) {
  final index = year * 12 + (month - 1) + delta;
  return (index ~/ 12, index % 12 + 1);
}

/// Draws [style]'s table lines around [child]: right and bottom for a cell,
/// or top and left for the outer edge of the whole table.
///
/// Drawn over the child, not under it. A DecoratedBox paints behind its child
/// by default, and a today or selected cell fills its background corner to
/// corner -- which painted straight over these lines.
Widget tableBorder(
  Widget child,
  NepaliCalendarStyle style, {
  bool outerEdge = false,
}) {
  final side = BorderSide(
    color: style.cellsStyle.borderColor.withValues(alpha: 0.3),
  );
  return DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      border: outerEdge
          ? Border(top: side, left: side)
          : Border(right: side, bottom: side),
    ),
    child: child,
  );
}
