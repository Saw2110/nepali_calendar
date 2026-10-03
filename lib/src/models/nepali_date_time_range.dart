import 'package:flutter/material.dart';

import '../utils/calendar_utils.dart';
import 'nepali_date_time.dart';

/// A span of Nepali (Bikram Sambat) dates, both ends included.
///
/// The BS counterpart of Flutter's [DateTimeRange], and what
/// [showNepaliDateRangePicker] returns:
///
/// ```dart
/// final range = NepaliDateTimeRange(
///   start: NepaliDateTime(year: 2083, month: 6, day: 10),
///   end: NepaliDateTime(year: 2083, month: 6, day: 16),
/// );
/// range.days; // 7
/// ```
///
/// Only the calendar date matters: the time of day on either end is ignored
/// by [days] and [contains].
@immutable
class NepaliDateTimeRange {
  /// The first day of the range.
  final NepaliDateTime start;

  /// The last day of the range. Never before [start].
  final NepaliDateTime end;

  NepaliDateTimeRange({required this.start, required this.end})
      : assert(
          start.dateOnly.compareTo(end.dateOnly) <= 0,
          'start ($start) must not be after end ($end)',
        );

  /// How many days the range covers, both ends included: a range that starts
  /// and ends on the same day is one day long.
  int get days =>
      CalendarUtils.nepaliDateDifference(start.dateOnly, end.dateOnly) + 1;

  /// Whether [date] falls on any day of the range, ends included.
  bool contains(NepaliDateTime date) {
    final day = date.dateOnly;
    return day.compareTo(start.dateOnly) >= 0 &&
        day.compareTo(end.dateOnly) <= 0;
  }

  /// The same range in the Gregorian (AD) calendar.
  DateTimeRange toDateTimeRange() =>
      DateTimeRange(start: start.toDateTime(), end: end.toDateTime());

  @override
  bool operator ==(Object other) =>
      other is NepaliDateTimeRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'NepaliDateTimeRange($start – $end)';
}
