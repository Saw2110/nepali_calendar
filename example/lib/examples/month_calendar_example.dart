import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../data/sample_events.dart';
import '../widgets/bilingual.dart';
import '../widgets/event_tile.dart';

/// The month view: [NepaliCalendar] driven by a [NepaliCalendarController],
/// with events listed underneath.
class NepaliCalendarExample extends StatefulWidget {
  const NepaliCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<NepaliCalendarExample> createState() => _NepaliCalendarExampleState();
}

class _NepaliCalendarExampleState extends State<NepaliCalendarExample> {
  late final NepaliCalendarController _controller;

  /// Sorted once, not on every build: sorting in `build` would redo the work
  /// on each frame and hand NepaliCalendar a new list identity every time,
  /// forcing it to re-index the events.
  late final List<CalendarEvent<Events>> _events =
      List<CalendarEvent<Events>>.from(eventList)
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  void initState() {
    super.initState();
    _controller = NepaliCalendarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControls(context),
        Expanded(
          // One gutter for the grid and the event list beneath it, so their
          // edges line up.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildCalendar(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return NepaliCalendar<Events>(
      controller: _controller,
      eventList: _events,
      calendarBuilder: CalendarBuilder<Events>(
        eventBuilder: (context, index, date, event) =>
            EventTile(event: event, language: widget.language),
      ),
      onDayChanged: (date) => debugPrint('Day changed: $date'),
      onMonthChanged: (date) =>
          debugPrint('Month changed: ${date.month}/${date.year}'),
      calendarStyle: NepaliCalendarStyle(
        // Config only -- no colours here, so the ambient
        // NepaliCalendarTheme supplies them and dark mode works.
        config: CalendarConfig(
          hapticFeedback: CalendarHaptics.light,
          showEnglishDate: true,
          showBorder: true,
          language: widget.language,
          weekendType: WeekendType.saturdayAndSunday,
          weekStartType: WeekStartType.monday,
          weekTitleType: TitleFormat.half,
        ),
      ),
    );
  }

  /// The controller, driven from outside the calendar: jump to today, jump
  /// to a fixed date, step a month. One row, compact, left to right in order
  /// of how often each is used.
  Widget _buildControls(BuildContext context) {
    final language = widget.language;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Flexible, so on a narrow phone the labels ellipsise rather than
          // pushing the arrows off the edge.
          Flexible(
            child: FilledButton.tonalIcon(
              onPressed: _controller.jumpToToday,
              icon: const Icon(Icons.today_rounded, size: 18),
              label: Text(
                language.pick('Today', 'आज'),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              style: _compact,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: OutlinedButton(
              onPressed: () => _controller
                  .jumpToDate(NepaliDateTime(year: 2080, month: 1, day: 1)),
              style: _compact,
              child: Text(
                '${MonthUtils.formattedMonth(1, language)} '
                '${language.number(2080)}',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
          const Spacer(),
          IconButton.outlined(
            onPressed: _controller.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: language.pick('Previous month', 'अघिल्लो महिना'),
            visualDensity: VisualDensity.compact,
          ),
          IconButton.outlined(
            onPressed: _controller.nextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: language.pick('Next month', 'अर्को महिना'),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  static final _compact = ButtonStyle(
    visualDensity: VisualDensity.compact,
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}
