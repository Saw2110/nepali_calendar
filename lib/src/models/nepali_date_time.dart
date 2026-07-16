import '../src.dart';

/// Represents a date and time in the Nepali calendar system (BS - Bikram Sambat)
// class NepaliDateTime implements DateTime {
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

  /// Validates input parameters
  void _validateInput() {
    assert(year >= 1969 && year <= 2250, 'Supported year is 1970-2250');
    assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');
    assert(day >= 1 && day <= 32, 'Day must be between 1 and 32');
    assert(hour >= 0 && hour < 24, 'Hour must be between 0 and 23');
    assert(minute >= 0 && minute < 60, 'Minute must be between 0 and 59');
    assert(second >= 0 && second < 60, 'Second must be between 0 and 59');
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

  DateTime toDateTime() {
    // Setting english reference to 1913/1/1, which converts to 1969/9/18
    var englishYear = 1913;
    var englishMonth = 1;
    var englishDay = 1;

    var difference = CalendarUtils.nepaliDateDifference(
      NepaliDateTime(year: year, month: month, day: day),
      NepaliDateTime(year: 1969, month: 9, day: 18),
    );

    // Getting english year until the difference remains less than 365
    while (difference >= (CalendarUtils.isLeapYear(englishYear) ? 366 : 365)) {
      difference =
          difference - (CalendarUtils.isLeapYear(englishYear) ? 366 : 365);
      englishYear++;
    }

    // Getting english month until the difference remains less than 31
    final monthDays = CalendarUtils.isLeapYear(englishYear)
        ? CalendarUtils.englishLeapMonths
        : CalendarUtils.englishMonths;
    var i = 0;
    while (difference >= monthDays[i]) {
      englishMonth++;
      difference -= monthDays[i];
      i++;
    }

    // Remaining days is the nepaliDateTime;
    englishDay += difference;

    return DateTime(
      englishYear,
      englishMonth,
      englishDay,
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
  /// ## Behaviour change in 0.1.0
  ///
  /// Up to 0.0.7 this class inherited identity equality, so two separately
  /// constructed instances of the same date compared unequal:
  ///
  /// ```dart
  /// NepaliDateTime(year: 2081, month: 1, day: 1) ==
  ///     NepaliDateTime(year: 2081, month: 1, day: 1); // was false, now true
  /// ```
  ///
  /// That also made [NepaliDateTime] unusable as a `Map` key or in a `Set`.
  /// If you relied on identity comparison, switch to `identical(a, b)`.
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

  // int get getDaysInMonth => getDaysInMonth();
  // int getDaysInMonth() {
  //   assert(year >= 1969 && year <= 2250, 'Supported year is 1970-2250');
  //   assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');

  //   // The list for each year contains days of months, with the first element being the total days in the year
  //   // The subsequent elements represent days in each month, so we can access the month's days directly
  //   return CalendarUtils.nepaliYears[year]![month];
  // }
}
