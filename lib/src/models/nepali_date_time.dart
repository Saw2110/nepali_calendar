import '../src.dart';

/// Represents a date and time in the Nepali calendar system (BS - Bikram Sambat)
// class NepaliDateTime implements DateTime {
class NepaliDateTime {
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

  /// Constructs a DateTime instance with current date and time
  factory NepaliDateTime.now() => DateTime.now().toNepaliDateTime();

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
    return '$year-$month-$day $hour:$minute:$second.$millisecond';
  }

  int get weekday => _weekDay();
  int _weekDay() {
    final date = toDateTime();
    return date.weekday +1;
  }

  NepaliDateTime add(Duration duration) {
    final date = toDateTime();
    return date.add(duration).toNepaliDateTime();
  }

  NepaliDateTime subtract(Duration duration) {
    final date = toDateTime();
    return date.subtract(duration).toNepaliDateTime();
  }
}
