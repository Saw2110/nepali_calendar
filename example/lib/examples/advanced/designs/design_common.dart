import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../../data/sample_events.dart';

// Pieces both custom designs share. Public only because they span files.

/// Built once. Rebuilding it per frame would re-index the whole event list on
/// every rebuild.
final designEventIndex = CalendarEventIndex.fromList(eventList);

/// Steps the calendar a month at a time.
///
/// `headerBuilder` is handed the same [PageController] the calendar pages with,
/// so a custom header drives navigation without any extra plumbing.
void stepDesignMonth(PageController controller, int delta) {
  controller.animateToPage(
    (controller.page?.round() ?? 0) + delta,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
}

/// The hairline every part of the Traditional design rules itself with.
BorderSide designRule(BuildContext context) => BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: 0.7,
    );

/// A tinted pill. Shared so the two designs stay visually consistent where
/// they are not deliberately different.
class DesignChip extends StatelessWidget {
  const DesignChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
