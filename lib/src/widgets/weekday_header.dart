// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_layout.dart';

/// How far the weekday names follow the system font scale before they stop.
///
/// The same limit as a day cell's number. This row stacks the Nepali and
/// English names in the height of a single cell, so it must not grow past
/// the cells beneath it.
const double _maxWeekdayTextScale = 1.3;

/// The weekday header is an implementation detail of [NepaliCalendar]. To
/// customise it, use `CalendarBuilder.weekdayBuilder`.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class WeekdayHeader extends StatelessWidget {
  final NepaliCalendarStyle style;
  final Widget Function(WeekdayData)? weekdayBuilder;

  /// Width-to-height ratio of each weekday cell.
  ///
  /// Defaults to 1.0 (square). See [CalendarGrid.cellAspectRatio].
  final double cellAspectRatio;

  /// [cellAspectRatio], guarded against the values the grid delegate rejects.
  double get _effectiveAspectRatio =>
      cellAspectRatio > 0 && cellAspectRatio.isFinite ? cellAspectRatio : 1.0;

  const WeekdayHeader({
    super.key,
    required this.style,
    this.weekdayBuilder,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Everything below is the same for all seven cells, so it is worked out
    // once here rather than per cell.
    final config = style.effectiveConfig;
    final weekdays = weekdayOrder(config.weekStartType);

    // Colours from the resolved style, which NepaliCalendar has already
    // resolved against any ambient NepaliCalendarTheme -- so the row follows
    // a dark theme like the dates beneath it.
    final weekdayColor = style.headersStyle.weekHeaderStyle.color ??
        style.cellsStyle.dateTextColor;
    final weekendColor = style.cellsStyle.weekDayColor;

    // Two stacked lines in a cell whose height comes from the viewport, not
    // from its text. Follow the user's font size as far as the cell can take
    // it, then scale the block down to fit rather than spilling out of it.
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _maxWeekdayTextScale);

    Widget name(
      int day,
      Language language,
      double size,
      FontWeight? weight,
      Color color,
    ) {
      return Text(
        WeekUtils.formattedWeekDay(day, language, config.weekTitleType),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textScaler: scaler,
        style: TextStyle(fontSize: size, fontWeight: weight, color: color),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: _effectiveAspectRatio,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = weekdays[index];
        final isWeekend = WeekUtils.isWeekend(day, config.weekendType);
        final color = isWeekend ? weekendColor : weekdayColor;

        final cell = weekdayBuilder != null
            ? weekdayBuilder!(
                WeekdayData(
                  weekday: day,
                  language: config.language,
                  isWeekend: isWeekend,
                  format: config.weekTitleType,
                  style: style,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    name(day, Language.nepali, 12, FontWeight.bold, color),
                    const SizedBox(height: 2),
                    name(
                      day,
                      Language.english,
                      10,
                      null,
                      color.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              );

        // Right and bottom lines per cell; CalendarMonthView adds the outer
        // top and left edge.
        return config.showBorder ? tableBorder(cell, style) : cell;
      },
    );
  }
}
