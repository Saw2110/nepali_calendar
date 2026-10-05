import 'package:flutter/foundation.dart';

import '../src.dart';

/// An immutable, date-keyed index over a list of [CalendarEvent]s.
///
/// Looking events up by day or by month is O(1), and every event on a date is
/// retained rather than only the first. A month view asks after 42 dates on
/// every build, so searching the event list per cell would cost
/// O(42 x events) a frame.
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
      byDay.putIfAbsent(_dayKey(event.date), () => []).add(event);
      byMonth
          .putIfAbsent(_monthKey(event.date.year, event.date.month), () => [])
          .add(event);
    }

    // Frozen once here, so reads hand the same unmodifiable list back instead
    // of copying it -- eventsOn runs for every cell of every month drawn.
    return CalendarEventIndex<T>._(_frozen(byDay), _frozen(byMonth));
  }

  static Map<int, List<CalendarEvent<T>>> _frozen<T>(
    Map<int, List<CalendarEvent<T>>> lists,
  ) =>
      lists.map((key, list) => MapEntry(key, List.unmodifiable(list)));

  // Packed integer keys: cheaper to hash than a string, and unambiguous
  // because month and day are each at most two digits.
  static int _dayKey(NepaliDateTime date) =>
      ((date.year * 100) + date.month) * 100 + date.day;

  static int _monthKey(int year, int month) => (year * 100) + month;

  /// Every event on [date], ignoring the time. Empty if there are none.
  ///
  /// The returned list is unmodifiable.
  List<CalendarEvent<T>> eventsOn(NepaliDateTime date) =>
      _byDay[_dayKey(date)] ?? const [];

  /// Every event in [month] of [year], in the order supplied.
  ///
  /// The returned list is unmodifiable.
  List<CalendarEvent<T>> eventsInMonth(int year, int month) =>
      _byMonth[_monthKey(year, month)] ?? const [];

  /// The first event on [date], or null.
  ///
  /// Provided for the cell APIs that predate multi-event support. Prefer
  /// [eventsOn], which does not discard the rest.
  CalendarEvent<T>? firstEventOn(NepaliDateTime date) =>
      _byDay[_dayKey(date)]?.first;

  /// Whether [date] has any event at all.
  bool hasEventsOn(NepaliDateTime date) => _byDay.containsKey(_dayKey(date));

  /// Whether any event on [date] is marked as a holiday.
  bool isHoliday(NepaliDateTime date) =>
      _byDay[_dayKey(date)]?.any((event) => event.isHoliday) ?? false;

  /// Whether the index holds no events.
  bool get isEmpty => _byDay.isEmpty;

  /// Whether the index holds at least one event.
  bool get isNotEmpty => _byDay.isNotEmpty;
}
