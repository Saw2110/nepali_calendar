import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../../data/sample_events.dart';
import 'design_common.dart';

/// The Simple design: airy and monochrome. No boxes anywhere, one accent
/// colour, and the dates themselves carry the page.
CalendarBuilder<Events> simpleDesign(Language language) {
  return CalendarBuilder<Events>(
    headerBuilder: (date, controller) => _SimpleHeader(
      date: date,
      controller: controller,
      language: language,
    ),
    weekdayBuilder: (data) => _SimpleWeekday(data: data),
    cellBuilder: (data) => _SimpleCell(data: data, language: language),
    eventBuilder: (context, index, date, event) =>
        _SimpleEventRow(event: event),
  );
}

/// The year in small caps above a large, lightly-weighted month, with the
/// month's event count as a quiet footnote and ghost arrows on the right.
class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
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
    final count = designEventIndex.eventsInMonth(date.year, date.month).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NepaliNumberConverter.formattedNumber(
                        '${date.year}',
                        language: language,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      MonthUtils.formattedMonth(date.month, language),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        // Light weight and tight tracking is most of what makes
                        // this design read as "Simple" rather than "default".
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        count == 1 ? '1 event' : '$count events',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _GhostArrow(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Previous month',
                onPressed: () => stepDesignMonth(controller, -1),
              ),
              const SizedBox(width: 4),
              _GhostArrow(
                icon: Icons.arrow_forward_ios_rounded,
                tooltip: 'Next month',
                onPressed: () => stepDesignMonth(controller, 1),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 24,
          endIndent: 24,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// An outlined circle rather than a filled button -- the design has no other
/// filled surfaces, and a tonal button here would be the loudest thing on it.
class _GhostArrow extends StatelessWidget {
  const _GhostArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        shape: const CircleBorder(),
      ),
    );
  }
}

/// A single wide-tracked initial. Deliberately the quietest row on the page.
class _SimpleWeekday extends StatelessWidget {
  const _SimpleWeekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = WeekUtils.formattedShortWeekDay(data.weekday, data.language);

    return Center(
      child: Text(
        // One character in English; Devanagari initials are already short, so
        // they are left whole.
        data.language == Language.english && label.isNotEmpty
            ? label.characters.first.toUpperCase()
            : label,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
          color: data.isWeekend
              ? data.style.cellsStyle.weekDayColor.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

/// No box, no fill, no ring: just the number, with a hairline bar underneath
/// when the day has events. Selection is the one solid shape in the design.
class _SimpleCell extends StatelessWidget {
  const _SimpleCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    // Already resolved against the ambient theme by NepaliCalendar.
    final cells = data.style.cellsStyle;

    final Color foreground;
    if (data.isDimmed) {
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.4);
    } else if (data.isSelected) {
      foreground = cells.onHighlightColor;
    } else if (data.isToday) {
      foreground = cells.selectedColor;
    } else if (data.isHoliday || data.isWeekend) {
      foreground = cells.weekDayColor;
    } else {
      foreground = cells.dateTextColor;
    }

    return GestureDetector(
      onTap: data.onTap,
      // Most of a cell is empty space; without this only the digits would
      // register a tap.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: data.isSelected ? cells.selectedColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    NepaliNumberConverter.formattedNumber(
                      '${data.day}',
                      language: language,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      // Today is bold instead of filled, so the fill can mean
                      // selection and nothing else.
                      fontWeight:
                          data.isToday ? FontWeight.w700 : FontWeight.w400,
                      color: foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // The bar is always laid out, empty or not, so the numbers stay
              // on one baseline across the whole grid.
              SizedBox(
                height: 2,
                width: 12,
                child: data.hasEvents && !data.isDimmed
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: data.isSelected
                              ? cells.onHighlightColor
                              : data.isHoliday
                                  ? cells.weekDayColor
                                  : cells.dotColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A hairline-separated row. No card, no fill -- the list matches the grid.
class _SimpleEventRow extends StatelessWidget {
  const _SimpleEventRow({required this.event});

  final CalendarEvent<Events> event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (event.isHoliday)
                      DesignChip(label: 'Holiday', color: accent),
                  ],
                ),
                if (info != null && info.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
