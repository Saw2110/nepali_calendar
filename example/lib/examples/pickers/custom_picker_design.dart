import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../widgets/bilingual.dart';

/// A `DatePickerBuilder` that restyles the date picker: round days, a
/// left-aligned title with the arrows together on the right, and a footer of
/// Today, Cancel and Done.
///
/// Each builder only draws; the picker still owns the dates, the bounds and
/// confirming, and hands over the callbacks to call. The weekday names and the
/// month and year tiles are left unset, so they keep the default design.
DatePickerBuilder customPickerDesign(BuildContext context, Language language) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return DatePickerBuilder(
    dayBuilder: (day) {
      // Blank rather than dimmed: the grid shows only this month.
      if (day.isOtherMonth) return const SizedBox.shrink();

      final Color? fill = day.isSelected ? colors.primary : null;
      final Color text;
      if (day.isSelected) {
        text = colors.onPrimary;
      } else if (day.isDisabled) {
        text = colors.onSurface.withValues(alpha: 0.3);
      } else if (day.isWeekend) {
        text = colors.error;
      } else {
        text = colors.onSurface;
      }

      return Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: fill ?? Colors.transparent,
            shape: CircleBorder(
              side: day.isToday && !day.isSelected
                  ? BorderSide(color: colors.primary, width: 1.5)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: day.onTap,
              child: Center(
                child: Text(
                  day.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: text,
                    fontWeight:
                        day.isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    headerBuilder: (header) => Padding(
      padding: const EdgeInsets.only(left: 20, right: 4),
      child: Row(
        children: [
          // The title opens the year list; tapped again, it closes it.
          InkWell(
            onTap: header.onYearTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${header.monthLabel} ${header.yearLabel}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    header.mode == NepaliDatePickerMode.day
                        ? Icons.arrow_drop_down_rounded
                        : Icons.arrow_drop_up_rounded,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: header.onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: header.onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    ),
    // The action row's 44dp slot, under the grid.
    footerBuilder: (footer) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          TextButton(
            onPressed: footer.onToday,
            child: Text(language.pick('Today', 'आज')),
          ),
          const Spacer(),
          TextButton(
            onPressed: footer.onCancel,
            child: Text(language.pick('Cancel', 'रद्द')),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: footer.onConfirm,
            child: Text(language.pick('Done', 'ठीक छ')),
          ),
        ],
      ),
    ),
  );
}
