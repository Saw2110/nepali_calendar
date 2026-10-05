import '../src.dart';

/// The AD date of BS 1969-01-01, the first day of the bundled calendar data.
///
/// Mirrored in `date_extensions.dart`, which converts the other way; the two
/// must agree or dates stop round-tripping.
final DateTime _dataStartAd = DateTime.utc(1912, 4, 12);

/// BS 1969-01-01, built once: [NepaliDateTime.toDateTime] counts from it for
/// every date the calendars draw.
final NepaliDateTime _dataStart =
    NepaliDateTime(year: CalendarUtils.calenderyearStart);

/// Represents a date and time in the Nepali calendar system (BS - Bikram Sambat)
class NepaliDateTime implements Comparable<NepaliDateTime> {
  /// Constructs a NepaliDateTime instance
  NepaliDateTime({
    required this.year,
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
    this.microsecond = 0,
  }) {
    _validateInput();
  }

  /// Rejects a date the calendar cannot represent.
  ///
  /// Throws a [RangeError] -- an [ArgumentError] -- naming the field and its
  /// valid range. The day is checked against the real length of that month,
  /// not just 1-32: Jestha 2083 has 31 days, so day 32 is rejected. These
  /// are checks, not asserts, so they hold in release builds too.
  void _validateInput() {
    const years = CalendarUtils.nepaliYears;
    RangeError.checkValueInInterval(
      year,
      years.keys.first,
      years.keys.last,
      'year',
      'The calendar has data for BS ${years.keys.first} to '
          'BS ${years.keys.last}',
    );
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    final daysInMonth = years[year]![month];
    RangeError.checkValueInInterval(
      day,
      1,
      daysInMonth,
      'day',
      'BS $year-$month has $daysInMonth days',
    );
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    RangeError.checkValueInInterval(second, 0, 59, 'second');
    RangeError.checkValueInInterval(millisecond, 0, 999, 'millisecond');
    RangeError.checkValueInInterval(microsecond, 0, 999, 'microsecond');
  }

  /// Nepal Standard Time's fixed offset from UTC. Nepal does not observe
  /// daylight saving, so this never varies.
  static const Duration nepalTimeZoneOffset = Duration(hours: 5, minutes: 45);

  /// Constructs a [NepaliDateTime] for the current date and time in Nepal.
  ///
  /// The current instant is resolved against Nepal Standard Time (UTC+5:45),
  /// so this returns the same Nepali date regardless of where the device is.
  /// A user in Tokyo just past midnight will therefore still see Nepal's
  /// current date, which is the date a Nepali calendar is expected to show.
  factory NepaliDateTime.now() {
    // Shifting the absolute instant by Nepal's offset yields a value whose
    // year/month/day/hour fields are Nepal's wall clock.
    final nepalNow = DateTime.now().toUtc().add(nepalTimeZoneOffset);
    return nepalNow.toNepaliDateTime();
  }

  /// This date in the Gregorian (AD) calendar, as a local [DateTime] with the
  /// same time of day.
  ///
  /// Counts the days since the first day of the bundled data, BS 1969-01-01
  /// (AD 1912-04-12), and adds them in UTC, where every day is exactly 24
  /// hours.
  DateTime toDateTime() {
    // The difference reads only year, month and day, so `this` will do.
    final daysSinceStart = CalendarUtils.nepaliDateDifference(this, _dataStart);
    final ad = _dataStartAd.add(Duration(days: daysSinceStart));

    return DateTime(
      ad.year,
      ad.month,
      ad.day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;

  @override
  String toString() {
    final String twoDigitMonth = _padLeft(month.toString(), 2);
    final String twoDigitDay = _padLeft(day.toString(), 2);
    final String twoDigitHour = _padLeft(hour.toString(), 2);
    final String twoDigitMinute = _padLeft(minute.toString(), 2);
    final String twoDigitSecond = _padLeft(second.toString(), 2);
    final String threeDigitMillisecond = _padLeft(millisecond.toString(), 3);
    final String threeDigitMicrosecond = _padLeft(microsecond.toString(), 3);

    return '$year-$twoDigitMonth-$twoDigitDay $twoDigitHour:$twoDigitMinute:$twoDigitSecond.$threeDigitMillisecond$threeDigitMicrosecond';
  }

  String toDateFormat() {
    final String twoDigitMonth = _padLeft(month.toString(), 2);
    final String twoDigitDay = _padLeft(day.toString(), 2);
    return '$year-$twoDigitMonth-$twoDigitDay';
  }

  String toTimeFormat() {
    final String twoDigitHour = _padLeft(hour.toString(), 2);
    final String twoDigitMinute = _padLeft(minute.toString(), 2);
    final String twoDigitSecond = _padLeft(second.toString(), 2);
    final String threeDigitMillisecond = _padLeft(millisecond.toString(), 3);
    final String threeDigitMicrosecond = _padLeft(microsecond.toString(), 3);

    return '$twoDigitHour:$twoDigitMinute:$twoDigitSecond.$threeDigitMillisecond$threeDigitMicrosecond';
  }

  /// Helper method to pad a string with leading zeros
  String _padLeft(String value, int padValue) {
    return value.padLeft(padValue, '0');
  }

  int get weekday => _weekDay();
  int _weekDay() {
    final date = toDateTime();
    // Dart's DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // Calendar format: 0=Sunday, 1=Monday, ..., 6=Saturday
    // Convert: Sunday (7) -> 0, Monday (1) -> 1, ..., Saturday (6) -> 6
    return date.weekday % 7;
  }

  NepaliDateTime add(Duration duration) {
    final date = toDateTime();
    return date.add(duration).toNepaliDateTime();
  }

  NepaliDateTime subtract(Duration duration) {
    final date = toDateTime();
    return date.subtract(duration).toNepaliDateTime();
  }

  /// Implement the compareTo method for sorting
  @override
  int compareTo(NepaliDateTime other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    if (day != other.day) {
      return day.compareTo(other.day);
    }
    if (hour != other.hour) {
      return hour.compareTo(other.hour);
    }
    if (minute != other.minute) {
      return minute.compareTo(other.minute);
    }
    if (second != other.second) {
      return second.compareTo(other.second);
    }
    if (millisecond != other.millisecond) {
      return millisecond.compareTo(other.millisecond);
    }
    return microsecond.compareTo(other.microsecond);
  }

  /// Whether [other] falls on the same calendar day, ignoring the time.
  ///
  /// Use this instead of [==] when the time components are irrelevant:
  ///
  /// ```dart
  /// final a = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 9);
  /// final b = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 17);
  /// a == b;              // false -- the hours differ
  /// a.isSameDayAs(b);    // true
  /// ```
  bool isSameDayAs(NepaliDateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// This date with the time components stripped to midnight.
  ///
  /// Useful as a stable map key when grouping values by day.
  NepaliDateTime get dateOnly =>
      NepaliDateTime(year: year, month: month, day: day);

  /// Value equality across every component, including time.
  ///
  /// Two instances holding the same date and time are equal; use
  /// `identical(a, b)` for identity.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NepaliDateTime &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.millisecond == millisecond &&
        other.microsecond == microsecond;
  }

  @override
  int get hashCode => Object.hash(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
}
