import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../data/sample_events.dart';
import '../widgets/bilingual.dart';
import '../widgets/event_tile.dart';

/// A one-week strip: [HorizontalNepaliCalendar], useful above a day's agenda.
class HorizontalCalendarExample extends StatefulWidget {
  const HorizontalCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<HorizontalCalendarExample> createState() =>
      _HorizontalCalendarExampleState();
}

class _HorizontalCalendarExampleState extends State<HorizontalCalendarExample> {
  late NepaliDateTime _selected = NepaliDateTime.now();
  bool _showMonth = true;
  WeekendType _weekendType = WeekendType.saturday;

  late final CalendarEventIndex<Events> _index =
      CalendarEventIndex.fromList(eventList);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          clipBehavior: Clip.antiAlias,
          child: HorizontalNepaliCalendar(
            initialDate: _selected,
            showMonth: _showMonth,
            calendarStyle: NepaliCalendarStyle(
              config: CalendarConfig(
                language: widget.language,
                weekendType: _weekendType,
              ),
            ),
            onDateSelected: (date) => setState(() => _selected = date),
          ),
        ),
        _buildOptions(context),
        Expanded(child: _buildAgenda(context, theme)),
      ],
    );
  }

  /// The strip's two options as settings rows: labelled, aligned, and one
  /// control each, rather than chips that wrap onto a second line.
  Widget _buildOptions(BuildContext context) {
    final theme = Theme.of(context);
    final language = widget.language;

    // A Material, not a decorated Container: the tiles paint their ripples on
    // the nearest Material, and a coloured box between would hide them.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            SwitchListTile(
              dense: true,
              title:
                  Text(language.pick('Show month title', 'महिना देखाउनुहोस्')),
              value: _showMonth,
              onChanged: (value) => setState(() => _showMonth = value),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              dense: true,
              title: Text(language.pick('Weekend', 'बिदाको दिन')),
              trailing: SegmentedButton<WeekendType>(
                segments: [
                  ButtonSegment(
                    value: WeekendType.saturday,
                    label: Text(language.pick('Sat', 'शनि')),
                  ),
                  ButtonSegment(
                    value: WeekendType.saturdayAndSunday,
                    label: Text(language.pick('Sat + Sun', 'शनि + आइत')),
                  ),
                ],
                selected: {_weekendType},
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                onSelectionChanged: (selection) =>
                    setState(() => _weekendType = selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The day's agenda, driven by an O(1) lookup into the event index.
  Widget _buildAgenda(BuildContext context, ThemeData theme) {
    final events = _index.eventsOn(_selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            widget.language.date(_selected),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (events.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 40,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.language
                        .pick('Nothing scheduled', 'कुनै कार्यक्रम छैन'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              itemCount: events.length,
              itemBuilder: (context, index) =>
                  EventTile(event: events[index], language: widget.language),
            ),
          ),
      ],
    );
  }
}
