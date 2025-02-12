import '../src.dart';

/// Utility class for calendar-related calculations and operations.
///
/// This class provides methods for:
/// * Checking if a date is today.
/// * Calculating the difference between two Nepali dates.
/// * Counting total days in Nepali calendar years.
/// * Checking if a year is a leap year.
/// * Accessing predefined English and Nepali calendar data.
class CalendarUtils {
  /// Checks if the given [date] is the current day.
  ///
  /// Compares the provided [date] with the current system date.
  /// Returns `true` if the year, month, and day match; otherwise, `false`.
  static bool isToday(DateTime date) {
    final DateTime today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

   
  /// Calculates the difference in days between two Nepali dates.
  ///
  /// - [date]: The first Nepali date.
  /// - [refDate]: The second Nepali date to compare against.
  /// Returns the absolute difference in days between the two dates.
  static int nepaliDateDifference(NepaliDateTime date, NepaliDateTime refDate) {
    final difference = _countTotalNepaliDays(date.year, date.month, date.day) -
        _countTotalNepaliDays(refDate.year, refDate.month, refDate.day);
    return (difference < 0 ? -difference : difference);
  }

  /// Counts the total number of days from the start of the Nepali calendar
  /// to the given Nepali date.
  ///
  /// - [year]: The Nepali year.
  /// - [month]: The Nepali month.
  /// - [day]: The Nepali day.
  /// Returns the total number of days.
  static int _countTotalNepaliDays(int year, int month, int day) {
    var total = 0;

    // If the year is before the start of the predefined Nepali calendar data,
    // return 0.
    if (year < calenderyearStart) return 0;

    // Get the Nepali year data for the given year.
    final yearData = nepaliYears[year]!;

    // Add the days from the given day.
    total += day - 1;

    // Add the days from all previous months in the given year.
    for (var i = 1; i < month; i++) {
      total += yearData[i];
    }

    // Add the days from all previous years.
    for (var i = calenderyearStart; i < year; i++) {
      total += nepaliYears[i]!.first;
    }

    return total;
  }

  /// Checks if the given [year] is a leap year.
  ///
  /// A leap year is divisible by 4 but not by 100, unless it is also divisible by 400.
  /// Returns `true` if the year is a leap year; otherwise, `false`.
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  /// Returns a list of days in each month for a non-leap English year.
  ///
  /// The list contains the number of days in each month from January to December.
  static List<int> get englishMonths =>
      [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns a list of days in each month for a leap English year.
  ///
  /// The list contains the number of days in each month from January to December.
  static List<int> get englishLeapMonths =>
      [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// The starting year of the predefined Nepali calendar data.
  static int calenderyearStart = 1969;

  /// Predefined Nepali calendar year data.
  ///
  /// This map contains the total number of days in each Nepali year and the
  /// number of days in each month for that year.
    static final Map<int, List<int>> nepaliYears = {
      calenderyearStart: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
      1970: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
      1971: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
      1972: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1973: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1974: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1975: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1976: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1977: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    1978: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1979: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1980: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1981: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    1982: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1983: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1984: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1985: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    1986: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1987: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1988: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1989: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1990: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1991: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1992: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1993: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1994: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1995: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1996: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1997: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1998: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    1999: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2000: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2001: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2002: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2003: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2004: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2005: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2006: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2007: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2008: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2009: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2010: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2011: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2012: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2013: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2014: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2015: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2016: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2017: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2018: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2019: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2020: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2021: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2022: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2023: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2024: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2025: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2026: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2027: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2028: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2029: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2030: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2031: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2032: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2033: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2034: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2035: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2036: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2037: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2038: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2039: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2040: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2041: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2042: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2043: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2044: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2045: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2046: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2047: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2048: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2049: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2050: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2051: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2052: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2053: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2054: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2055: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2056: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2057: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2058: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2059: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2060: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2061: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2062: [365, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
    2063: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2064: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2065: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2066: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2067: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2068: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2069: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2070: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2071: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2072: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2073: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2074: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2075: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2076: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2077: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2078: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2079: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2080: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2081: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2082: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2083: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2084: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2085: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2086: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2087: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2088: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2089: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2090: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2091: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2092: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2093: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2094: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2095: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2096: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2097: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2098: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2099: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2100: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2101: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2102: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2103: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2104: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2105: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2106: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2107: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2108: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2109: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2110: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2111: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2112: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2113: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2114: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2115: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2116: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2117: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2118: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2119: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2120: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2121: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2122: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2123: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2124: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2125: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2126: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2127: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2128: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2129: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2130: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2131: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2132: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2133: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2134: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2135: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2136: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2137: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2138: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2139: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2140: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2141: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2142: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2143: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2144: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2145: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2146: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2147: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2148: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2149: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2150: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2151: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2152: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2153: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2154: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2155: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2156: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2157: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2158: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2159: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2160: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2161: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2162: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2163: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2164: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2165: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2166: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2167: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2168: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2169: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2170: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2171: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2172: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2173: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2174: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2175: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2176: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2177: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2178: [365, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2179: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2180: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2181: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2182: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2183: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2184: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2185: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2186: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2187: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2188: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2189: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2190: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2191: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2192: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2193: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2194: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2195: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2196: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2197: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2198: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2199: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2200: [372, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31],
    2201: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2202: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2203: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2204: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2205: [365, 31, 31, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
    2206: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2207: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2208: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2209: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2210: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2211: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2212: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2213: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2214: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2215: [365, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2216: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2217: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2218: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2219: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2220: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2221: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2222: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2223: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2224: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2225: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2226: [365, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2227: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2228: [365, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2229: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2230: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2231: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2232: [365, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
    2233: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2234: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2235: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2236: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2237: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2238: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2239: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2240: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2241: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2242: [365, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2243: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2244: [365, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2245: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2246: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2247: [366, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2248: [365, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2249: [365, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2250: [365, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  };
}
