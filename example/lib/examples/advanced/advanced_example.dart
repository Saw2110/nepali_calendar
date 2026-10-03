import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'custom_builders_example.dart';
import 'event_index_example.dart';

/// The two examples for going beyond the defaults: a fully custom design, and
/// the event index on its own.
class AdvancedExample extends StatefulWidget {
  const AdvancedExample({super.key, required this.language});

  final Language language;

  @override
  State<AdvancedExample> createState() => _AdvancedExampleState();
}

enum _Section { customBuilders, eventIndex }

class _AdvancedExampleState extends State<AdvancedExample> {
  _Section _section = _Section.customBuilders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<_Section>(
              segments: const [
                ButtonSegment(
                  value: _Section.customBuilders,
                  icon: Icon(Icons.brush_outlined),
                  label: Text('Custom builders'),
                ),
                ButtonSegment(
                  value: _Section.eventIndex,
                  icon: Icon(Icons.bolt_outlined),
                  label: Text('Event index'),
                ),
              ],
              selected: {_section},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _section = selection.first),
            ),
          ),
        ),
        Expanded(
          // Both stay alive, so switching back keeps the chosen design and
          // the queried date.
          child: IndexedStack(
            index: _section.index,
            children: [
              CustomBuildersExample(language: widget.language),
              EventIndexExample(language: widget.language),
            ],
          ),
        ),
      ],
    );
  }
}
