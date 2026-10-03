import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../../data/sample_events.dart';
import 'design_common.dart';

/// The Traditional design: the printed Nepali patro. A ruled grid, Saturdays
/// and holidays in red, and the AD date in the corner of every cell.
CalendarBuilder<Events> traditionalDesign(Language language) {
  return CalendarBuilder<Events>(
    headerBuilder: (date, controller) => _TraditionalHeader(
      date: date,
      controller: controller,
      language: language,
    ),
    weekdayBuilder: (data) => _TraditionalWeekday(data: data),
    cellBuilder: (data) => _TraditionalCell(data: data, language: language),
    eventBuilder: (context, index, date, event) =>
        _TraditionalEventRow(event: event, language: language),
  );
}

/// A solid band with the month centred in it, the way a wall calendar prints
/// its masthead.
class _TraditionalHeader extends StatelessWidget {
  const _TraditionalHeader({
    required this.date,
    required this.controller,
    required this.language,
  });

  final NepaliDateTime date;
  final PageController controller;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => stepDesignMonth(controller, -1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: theme.colorScheme.onPrimaryContainer,
            tooltip: 'Previous month',
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MonthUtils.formattedMonth(date.month, language),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  // The AD span the Nepali month straddles, the way a patro
                  // prints it under the month name.
                  _gregorianSpan(date),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => stepDesignMonth(controller, 1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: theme.colorScheme.onPrimaryContainer,
            tooltip: 'Next month',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  /// e.g. `Jun / Jul 2026` -- a Nepali month nearly always spans two AD ones.
  String _gregorianSpan(NepaliDateTime date) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final first =
        NepaliDateTime(year: date.year, month: date.month, day: 1).toDateTime();
    final lastDay = CalendarUtils.nepaliYears[date.year]![date.month];
    final last =
        NepaliDateTime(year: date.year, month: date.month, day: lastDay)
            .toDateTime();

    if (first.month == last.month) {
      return '${names[first.month - 1]} ${first.year}';
    }
    return '${names[first.month - 1]} / ${names[last.month - 1]} ${last.year}';
  }
}

/// A ruled header row, Saturday in the weekend colour like a printed patro.
class _TraditionalWeekday extends StatelessWidget {
  const _TraditionalWeekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border(right: designRule(context), bottom: designRule(context)),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            WeekUtils.formattedShortWeekDay(data.weekday, data.language),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: data.isWeekend
                  ? data.style.cellsStyle.weekDayColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// A ruled box with the Nepali date large in the middle and the AD date small
/// in the corner -- the single most recognisable thing about a printed patro.
class _TraditionalCell extends StatelessWidget {
  const _TraditionalCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = data.style.cellsStyle;

    final Color foreground;
    if (data.isDimmed) {
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.45);
    } else if (data.isToday) {
      foreground = cells.onHighlightColor;
    } else if (data.isHoliday || data.isWeekend) {
      // Red Saturdays and red holidays are the convention the printed
      // calendars use, and the theme's weekend colour already is that red.
      foreground = cells.weekDayColor;
    } else {
      foreground = cells.dateTextColor;
    }

    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: data.isToday
              ? cells.todayColor
              : data.isSelected
                  ? cells.selectedColor.withValues(alpha: 0.18)
                  : data.isDimmed
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.25)
                      : null,
          // Right and bottom only: neighbouring cells share a single line
          // instead of drawing two against each other.
          border:
              Border(right: designRule(context), bottom: designRule(context)),
        ),
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  NepaliNumberConverter.formattedNumber(
                    '${data.day}',
                    language: language,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        data.isToday ? FontWeight.w800 : FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 3,
              child: Text(
                '${data.date.toDateTime().day}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  height: 1,
                  color: data.isToday
                      ? cells.onHighlightColor.withValues(alpha: 0.8)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            if (data.hasEvents && !data.isDimmed)
              Positioned(
                left: 3,
                bottom: 3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.isToday
                        ? cells.onHighlightColor
                        : data.isHoliday
                            ? cells.weekDayColor
                            : cells.dotColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A ruled row with the date boxed off on the left, like the notes column
/// printed down the side of a patro.
class _TraditionalEventRow extends StatelessWidget {
  const _TraditionalEventRow({required this.event, required this.language});

  final CalendarEvent<Events> event;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                border: Border(right: designRule(context)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    NepaliNumberConverter.formattedNumber(
                      '${event.date.day}',
                      language: language,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: accent,
                    ),
                  ),
                  Text(
                    WeekUtils.formattedShortWeekDay(
                      event.date.weekday,
                      language,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            info?.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (event.isHoliday)
                          DesignChip(label: 'बिदा', color: accent),
                      ],
                    ),
                    if (info != null && info.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
