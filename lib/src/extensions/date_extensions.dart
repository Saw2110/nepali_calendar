import '../src.dart';

/// Extension to convert standard [DateTime] to [NepaliDateTime].
///
/// This extension provides a method to convert a standard [DateTime] object
/// into a [NepaliDateTime] object, which represents the date and time in the
/// Nepali calendar system.
extension DateTimeExtension on DateTime {
  /// Converts this [DateTime] to a [NepaliDateTime].
  ///
  /// The calendar date (`year`, `month`, `day`) is converted as-is; the time
  /// components are carried across unchanged. The result depends only on the
  /// calendar date, never on the device's timezone.
  ///
  /// ```dart
  /// DateTime(2024, 4, 13).toNepaliDateTime().toDateFormat(); // 2081-01-01
  /// ```
  ///
  /// To get the current date in Nepal, prefer [NepaliDateTime.now], which
  /// resolves the current instant against Nepal Standard Time (UTC+5:45)
  /// before converting.
  ///
  /// Throws an [ArgumentError] if the date falls outside the supported range
  /// (AD 1913-04-13 to roughly AD 2044, i.e. BS 1970 to BS 2100).
  ///
  /// ## Behaviour change in 0.1.0
  ///
  /// Versions up to 0.0.7 shifted the value into Nepal Standard Time before
  /// converting, and then added an extra day when the *device* timezone was
  /// exactly UTC+5:45. That made the result depend on where the user was: a
  /// device in Nepal produced a date one day later than the true date for any
  /// date after 1986, while a device east of Nepal could produce one a day
  /// earlier. Conversion is now timezone-independent and round-trips exactly.
  NepaliDateTime toNepaliDateTime() {
    // Reference point: BS 1970-01-01 corresponds to AD 1913-04-13.
    //
    // Both sides of the subtraction are UTC so that the result cannot be
    // perturbed by the device's timezone or by a daylight-saving transition
    // shortening a local day to 23 hours (which would truncate `inDays`).
    final date = DateTime.utc(year, month, day);
    var difference = date.difference(DateTime.utc(1913, 4, 13)).inDays;

    if (difference < 0) {
      throw ArgumentError(
        'Date is before the start of the supported range. '
        'The earliest supported date is AD 1913-04-13 (BS 1970-01-01), '
        'but got AD ${date.year}-${date.month}-${date.day}.',
      );
    }

    // Walk forward year by year while a whole Nepali year still fits in the
    // remaining difference. Index 0 of each entry holds the year's total days.
    var nepaliYear = 1970;
    var daysInYear = CalendarUtils.nepaliYears[nepaliYear]!.first;
    while (difference >= daysInYear) {
      nepaliYear++;
      difference -= daysInYear;

      final nextYear = CalendarUtils.nepaliYears[nepaliYear];
      if (nextYear == null) {
        throw ArgumentError(
          'Date is beyond the end of the supported range. '
          'The calendar has data up to BS ${CalendarUtils.nepaliYears.keys.last}, '
          'but AD ${date.year}-${date.month}-${date.day} falls past it.',
        );
      }
      daysInYear = nextYear.first;
    }

    // Then walk forward month by month within that year.
    var nepaliMonth = 1;
    var daysInMonth = CalendarUtils.nepaliYears[nepaliYear]![nepaliMonth];
    while (difference >= daysInMonth) {
      difference -= daysInMonth;
      nepaliMonth++;
      daysInMonth = CalendarUtils.nepaliYears[nepaliYear]![nepaliMonth];
    }

    // Whatever remains is the zero-based offset into the month.
    return NepaliDateTime(
      year: nepaliYear,
      month: nepaliMonth,
      day: 1 + difference,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
      microsecond: microsecond,
    );
  }
}
