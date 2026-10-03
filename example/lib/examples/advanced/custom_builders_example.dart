import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../data/sample_events.dart';
import 'designs/simple_design.dart';
import 'designs/traditional_design.dart';

/// `CalendarBuilder` replaces the header, the weekday row, the day cell and the
/// event row. The package keeps owning the dates, the grid layout and the event
/// lookup, so a custom design is a drawing job rather than a rewrite.
///
/// Two are shown, and they deliberately pull in opposite directions -- that
/// contrast is the useful thing to copy from:
///
/// * **Simple** -- airy and monochrome. No boxes anywhere, one accent colour,
///   and the dates themselves carry the page. See `designs/simple_design.dart`.
/// * **Traditional** -- the printed Nepali patro. A ruled grid, Saturdays and
///   holidays in red, and the AD date in the corner of every cell. See
///   `designs/traditional_design.dart`.
///
/// Every colour comes from the theme: `Theme.of(context).colorScheme` for
/// surfaces, and `data.style` for calendar-semantic colours, which the calendar
/// has already resolved against the ambient [NepaliCalendarTheme]. Hard-coding
/// one here would look right in one mode and unreadable in the other.
enum _CustomDesign {
  simple('Simple'),
  traditional('Traditional');

  const _CustomDesign(this.label);

  final String label;
}

class CustomBuildersExample extends StatefulWidget {
  const CustomBuildersExample({super.key, required this.language});

  final Language language;

  @override
  State<CustomBuildersExample> createState() => _CustomBuildersExampleState();
}

class _CustomBuildersExampleState extends State<CustomBuildersExample> {
  _CustomDesign _design = _CustomDesign.simple;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSwitcher(),
        Expanded(
          child: NepaliCalendar<Events>(
            // Keyed by design so a switch rebuilds from scratch rather than
            // trying to reuse the previous design's element tree.
            key: ValueKey(_design),
            eventList: eventList,
            calendarBuilder: _builderFor(_design),
            calendarStyle: NepaliCalendarStyle(
              // Config only: no colours, so the theme still drives the palette.
              // showBorder stays off for both designs -- the traditional cell
              // rules its own grid, and doubling the package's borders onto it
              // would thicken every line.
              config: CalendarConfig(
                language: widget.language,
                weekendType: WeekendType.saturday,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Chips rather than a second segmented button: the Advanced page already
  /// has one above this, and two stacked read as one control.
  Widget _buildSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          for (final design in _CustomDesign.values) ...[
            ChoiceChip(
              label: Text(design.label),
              selected: _design == design,
              onSelected: (_) => setState(() => _design = design),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  CalendarBuilder<Events> _builderFor(_CustomDesign design) {
    switch (design) {
      case _CustomDesign.simple:
        return simpleDesign(widget.language);
      case _CustomDesign.traditional:
        return traditionalDesign(widget.language);
    }
  }
}
