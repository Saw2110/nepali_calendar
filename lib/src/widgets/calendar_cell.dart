// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';

import '../src.dart';

/// A calendar cell is an implementation detail of [NepaliCalendar]. To
/// customise how a date looks, use `CalendarBuilder.cellBuilder`, which gets
/// a [CalendarCellData] describing the cell.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;

  /// The first event on this date, if any.
  ///
  /// **Deprecated:** use [events], which retains every event on the date.
  /// Passing [event] still works and is treated as a single-event list.
  @Deprecated(
    'A date can have more than one event. Use events instead. '
    'Will be removed in 1.0.0.',
  )
  final CalendarEvent<T>? event;

  /// Every event on this date.
  ///
  /// When null, falls back to [event] so existing callers keep working.
  final List<CalendarEvent<T>>? events;

  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;
  final bool isDimmed;
  final Widget Function(CalendarCellData<T>)? cellBuilder;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    @Deprecated('Use events instead') this.event,
    this.events,
    required this.onDaySelected,
    required this.calendarStyle,
    this.isDimmed = false,
    this.cellBuilder,
  });

  /// The events to render, from whichever of [events] or [event] was given.
  List<CalendarEvent<T>> get _effectiveEvents {
    if (events != null) return events!;
    final single = event;
    return single == null ? const [] : [single];
  }

  @override
  Widget build(BuildContext context) {
    final cellEvents = _effectiveEvents;

    // Check if the current date is today
    final isToday = CalendarUtils.isToday(date.toDateTime());
    // Check if the current date is the selected date
    final isSelected = _isSelectedDate(date);
    // A date is a holiday if *any* of its events is one. Up to 0.0.8 only the
    // first event on a date was consulted, so a date carrying an ordinary
    // event ahead of a holiday did not read as a holiday.
    final isHoliday = cellEvents.any((event) => event.isHoliday);
    // Check if the current date is a weekend
    final isWeekend = _isWeekend(date.weekday);

    // If custom cellBuilder is provided, use it
    if (cellBuilder != null) {
      final cellData = CalendarCellData<T>(
        date: date,
        day: day,
        isToday: isToday,
        isSelected: isSelected,
        isDimmed: isDimmed,
        isWeekend: isWeekend,
        // Still populated so existing cellBuilders that read `data.event`
        // keep working.
        event: cellEvents.isEmpty ? null : cellEvents.first,
        events: cellEvents,
        onTap: () => onDaySelected(date),
        style: calendarStyle,
      );
      return cellBuilder!(cellData);
    }

    // Default cell implementation
    // Note: Borders are handled by the grid container, not individual cells
    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Set the background color of the cell based on today and selected state
          color: _getCellColor(isToday, isSelected),
          // Rounded corners only when borders are disabled
          borderRadius: calendarStyle.effectiveConfig.showBorder
              ? null
              : BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                // Display the day in English or Nepali based on the calendar style
                calendarStyle.effectiveConfig.language == Language.english
                    ? "$day"
                    : NepaliNumberConverter.englishToNepali(day.toString()),
                style: calendarStyle.cellsStyle.dayStyle.copyWith(
                  // Set the text color based on today, selected, and weekday
                  color: _getCellTextColor(isToday, isSelected, date.weekday),
                ),
              ),
            ),
            // Show the English date if the calendar style specifies to show it
            if (calendarStyle.effectiveConfig.showEnglishDate)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "${date.toDateTime().day}",
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCellTextColor(
                        isToday,
                        isSelected,
                        date.weekday,
                        isBaseLine: true,
                      ),
                    ),
                  ),
                ),
              ),
            // Show an event indicator if there is an event
            if (cellEvents.isNotEmpty)
              Positioned(
                bottom: 5.0,
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color: _getEventColor(isHoliday, isToday, date.weekday),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Method to get the cell background color based on today and selected state
  Color _getCellColor(bool isToday, bool isSelected) {
    // Dimmed cells should never have background highlighting
    if (isDimmed) return Colors.transparent;
    if (isToday && isSelected) return calendarStyle.cellsStyle.todayColor;
    if (isSelected) {
      return calendarStyle.cellsStyle.selectedColor.withValues(
        alpha: 0.2,
      );
    }
    if (isToday) return calendarStyle.cellsStyle.todayColor;
    return Colors.transparent;
  }

  // Method to get the cell text color based on today, selected, and weekday
  Color _getCellTextColor(
    bool isToday,
    bool isSelected,
    int weekday, {
    bool isBaseLine = false,
  }) {
    final cellsStyle = calendarStyle.cellsStyle;

    if (isDimmed) {
      // Dimmed cells: show dimmed weekend color for weekends, and the dimmed
      // date colour for regular days.
      if (_isWeekend(weekday)) {
        return cellsStyle.weekDayColor.withValues(alpha: 0.4);
      }
      return cellsStyle.dimmedDateTextColor.withValues(alpha: 0.4);
    }
    if (isToday && isSelected) return cellsStyle.onHighlightColor;
    // if (isSelected) return onHighlightColor; // Commented out for now
    if (isToday) return cellsStyle.onHighlightColor;
    if (_isWeekend(weekday)) return cellsStyle.weekDayColor;
    return isBaseLine ? cellsStyle.baseLineDateColor : cellsStyle.dateTextColor;
  }

  // Method to get the event indicator color based on holiday, today, and weekday
  // Priority: Dimmed > Today > Event Type (Holiday/Regular) > Weekend
  Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
    // Dimmed cells should have dimmed event indicators
    if (isDimmed) {
      return calendarStyle.cellsStyle.dimmedDateTextColor
          .withValues(alpha: 0.4);
    }
    // Today's events sit on the highlight, so use the on-highlight colour
    if (isToday) return calendarStyle.cellsStyle.onHighlightColor;
    // Event type takes priority: holidays show weekend color, regular events show dot color
    if (isHoliday) return calendarStyle.cellsStyle.weekDayColor;
    // Regular events show their designated color regardless of weekend
    // This allows users to distinguish event types even on weekends
    return calendarStyle.cellsStyle.dotColor;
  }

  // Method to check if a weekday is a weekend based on the weekend type
  bool _isWeekend(int weekday) {
    return WeekUtils.isWeekend(
      weekday,
      calendarStyle.effectiveConfig.weekendType,
    );
  }

  // Method to check if the current date is the selected date
  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
