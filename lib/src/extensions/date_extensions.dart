import '../src.dart';

/// Extension to convert standard [DateTime] to [NepaliDateTime].
///
/// This extension provides a method to convert a standard [DateTime] object
/// into a [NepaliDateTime] object, which represents the date and time in the
/// Nepali calendar system.
extension DateTimeExtension on DateTime {
  /// Converts the [DateTime] to [NepaliDateTime].
  ///
  /// This method calculates the corresponding Nepali date and time based on
  /// the provided [DateTime] object. It accounts for the time zone offset of
  /// Nepal (UTC+5:45) and adjusts for historical anomalies in the time zone
  /// offset after 1986.
  ///
  /// Throws [ArgumentError] if the date is before April 13, 1913 (BS 1970/1/1).
  NepaliDateTime toNepaliDateTime() {
    // Nepal's time zone offset is UTC+5:45.
    final nepalTzOffset = Duration(hours: 5, minutes: 45);
    final minSupportedDate = DateTime(1913, 4, 13);

    // Throw if date is before the minimum supported date
    if (isBefore(minSupportedDate)) {
      throw ArgumentError(
          'Date must be on or after April 13, 1913 (BS 1970/1/1)');
    }

    // Convert the current DateTime to UTC and add Nepal's time zone offset.
    final now = toUtc().add(nepalTzOffset);

    // Reference point: January 1, 1970 (English date) corresponds to
    // Bikram Sambat (BS) 1970/1/1, which is April 13, 1913 (English date).
    var nepaliYear = 1970; // Initial Nepali year (BS 1970).
    var nepaliMonth = 1; // Initial Nepali month.
    var nepaliDay = 1; // Initial Nepali day.

    // Normalize the time to avoid issues with date difference calculations.
    // This removes the time component, focusing only on the date.
    final date = DateTime(now.year, now.month, now.day);

    // Calculate the difference in days between the provided date and the
    // reference date (April 13, 1913).
    var difference = date.difference(minSupportedDate).inDays;

    // Compensate for the time zone offset anomaly that occurred after 1986.
    // If the date is after 1986 and the time zone offset matches Nepal's,
    // add an extra day to the difference.
    if (date.timeZoneOffset.inMinutes == nepalTzOffset.inMinutes &&
        date.isAfter(DateTime(1986))) {
      difference += 1;
    }

    // Calculate the Nepali year by iterating through the Nepali calendar data.
    // Each entry in [CalendarUtils.nepaliYears] contains the total days in the
    // year and the days in each month.

    // First, handle years before 1970 if needed
    if (difference < 0) {
      // Go backwards from 1970
      nepaliYear = 1969; // Start from the previous year
      var remainingDays = -difference;

      while (remainingDays > 0 &&
          CalendarUtils.nepaliYears.containsKey(nepaliYear)) {
        final daysInYear = CalendarUtils.nepaliYears[nepaliYear]!.first;
        if (remainingDays >= daysInYear) {
          remainingDays -= daysInYear;
          nepaliYear--;
        } else {
          difference = daysInYear - remainingDays;
          remainingDays = 0;
          nepaliYear++;
        }
      }

      // If we went below the minimum supported year, throw an error
      if (remainingDays > 0) {
        throw ArgumentError(
            'Date conversion not supported for dates before the minimum supported year');
      }
    } else {
      // Original forward calculation for years 1970 and after
      var daysInYear = CalendarUtils.nepaliYears[nepaliYear]!.first;
      while (difference >= daysInYear &&
          CalendarUtils.nepaliYears.containsKey(nepaliYear + 1)) {
        difference -= daysInYear; // Subtract the days of the current year.
        nepaliYear += 1; // Move to the next Nepali year.
        daysInYear = CalendarUtils.nepaliYears[nepaliYear]!.first;
      }
    }

    // Calculate the Nepali month by iterating through the months of the current year.
    var daysInMonth = CalendarUtils.nepaliYears[nepaliYear]![nepaliMonth];
    while (difference >= daysInMonth) {
      difference -= daysInMonth; // Subtract the days of the current month.
      nepaliMonth += 1; // Move to the next month.

      // Update days in the new month.
      daysInMonth = CalendarUtils.nepaliYears[nepaliYear]![nepaliMonth];
    }

    // The remaining difference is the day in the current month.
    nepaliDay += difference;

    // Create and return a [NepaliDateTime] object with the calculated values.
    return NepaliDateTime(
      year: nepaliYear,
      month: nepaliMonth,
      day: nepaliDay,
      hour: now.hour,
      minute: now.minute,
      second: now.second,
      millisecond: now.millisecond,
      microsecond: now.microsecond,
    );
  }
}
