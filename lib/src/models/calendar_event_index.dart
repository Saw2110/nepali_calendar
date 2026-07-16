import 'package:flutter/foundation.dart';

import '../src.dart';

/// An immutable, date-keyed index over a list of [CalendarEvent]s.
///
/// Looking events up by day or by month is O(1), and every event on a date is
/// retained rather than only the first.
///
/// ## Why this exists
///
/// Up to 0.0.8 each cell searched the whole event list with `firstWhere`,
/// catching the "not found" exception as control flow. A month view is 42
/// cells, so drawing one month was O(42 x events) and rebuilding on every
/// scroll frame. It also silently kept only the *first* event on a date, which
/// made it impossible to show more than one event or to mark a date that has
/// both an ordinary event and a holiday.
///
/// ```dart
/// final index = CalendarEventIndex.fromList(events);
/// index.eventsOn(NepaliDateTime(year: 2081, month: 1, day: 1)); // O(1)
/// ```
@immutable
class CalendarEventIndex<T> {
  final Map<int, List<CalendarEvent<T>>> _byDay;
  final Map<int, List<CalendarEvent<T>>> _byMonth;

  const CalendarEventIndex._(this._byDay, this._byMonth);

  /// An index with no events.
  factory CalendarEventIndex.empty() =>
      CalendarEventIndex<T>._(const {}, const {});

  /// Builds an index from [events]. A null or empty list yields an empty index.
  ///
  /// Insertion order is preserved within each day and month, so events render
  /// in the order they were supplied.
  factory CalendarEventIndex.fromList(List<CalendarEvent<T>>? events) {
    if (events == null || events.isEmpty) return CalendarEventIndex<T>.empty();

    final byDay = <int, List<CalendarEvent<T>>>{};
    final byMonth = <int, List<CalendarEvent<T>>>{};

    for (final event in events) {
      final date = event.date;
      byDay
          .putIfAbsent(_dayKey(date.year, date.month, date.day), () => [])
          .add(event);
      byMonth
          .putIfAbsent(_monthKey(date.year, date.month), () => [])
          .add(event);
    }

    return CalendarEventIndex<T>._(byDay, byMonth);
  }

  // Packed integer keys: cheaper to hash than a string, and unambiguous
  // because month and day are each at most two digits.
  static int _dayKey(int year, int month, int day) =>
      ((year * 100) + month) * 100 + day;

  static int _monthKey(int year, int month) => (year * 100) + month;

  /// Every event on [date], ignoring the time. Empty if there are none.
  ///
  /// The returned list is unmodifiable.
  List<CalendarEvent<T>> eventsOn(NepaliDateTime date) {
    final events = _byDay[_dayKey(date.year, date.month, date.day)];
    return events == null ? const [] : List.unmodifiable(events);
  }

  /// Every event in [month] of [year], in the order supplied.
  ///
  /// The returned list is unmodifiable.
  List<CalendarEvent<T>> eventsInMonth(int year, int month) {
    final events = _byMonth[_monthKey(year, month)];
    return events == null ? const [] : List.unmodifiable(events);
  }

  /// The first event on [date], or null.
  ///
  /// Provided for the cell APIs that predate multi-event support. Prefer
  /// [eventsOn], which does not discard the rest.
  CalendarEvent<T>? firstEventOn(NepaliDateTime date) {
    final events = _byDay[_dayKey(date.year, date.month, date.day)];
    return (events == null || events.isEmpty) ? null : events.first;
  }

  /// Whether [date] has any event at all.
  bool hasEventsOn(NepaliDateTime date) =>
      _byDay.containsKey(_dayKey(date.year, date.month, date.day));

  /// Whether any event on [date] is marked as a holiday.
  bool isHoliday(NepaliDateTime date) {
    final events = _byDay[_dayKey(date.year, date.month, date.day)];
    if (events == null) return false;
    return events.any((event) => event.isHoliday);
  }

  /// Whether the index holds no events.
  bool get isEmpty => _byDay.isEmpty;

  /// Whether the index holds at least one event.
  bool get isNotEmpty => _byDay.isNotEmpty;
}
