import '../src.dart';

/// The AD date of BS 1969-01-01, the first day of the bundled calendar data.
///
/// Mirrored in `nepali_date_time.dart`, which converts the other way; the two
/// must agree or dates stop round-tripping.
final DateTime _dataStartAd = DateTime.utc(1912, 4, 12);

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
  /// Throws an [ArgumentError] if the date falls outside the bundled calendar
  /// data: BS 1969-01-01 (AD 1912-04-12) to the end of BS 2250.
  NepaliDateTime toNepaliDateTime() {
    // Reference point: the first day of the bundled data, BS 1969-01-01,
    // which is AD 1912-04-12, so that every day of the data converts.
    //
    // Both sides of the subtraction are UTC so that the result cannot be
    // perturbed by the device's timezone or by a daylight-saving transition
    // shortening a local day to 23 hours (which would truncate `inDays`).
    final date = DateTime.utc(year, month, day);
    var difference = date.difference(_dataStartAd).inDays;

    if (difference < 0) {
      throw ArgumentError(
        'Date is before the start of the supported range. '
        'The earliest supported date is AD 1912-04-12 (BS 1969-01-01), '
        'but got AD ${date.year}-${date.month}-${date.day}.',
      );
    }

    // Walk forward year by year while a whole Nepali year still fits in the
    // remaining difference. Index 0 of each entry holds the year's total days.
    var nepaliYear = CalendarUtils.calenderyearStart;
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
