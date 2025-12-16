import '../src.dart';

/// Utility class for handling week-related operations and data.
///
/// This class provides methods for:
/// * Formatting weekday names in Nepali or English.
/// * Formatting short weekday names in Nepali or English.
/// * Accessing predefined weekday names in full, half, and short formats.
class WeekUtils {
  /// Returns the formatted weekday name for the given day number.
  ///
  /// - [day]: The day number (0 for Sunday/आइतबार, 6 for Saturday/शनिबार).
  /// - [language]: The language in which the weekday name should be returned.
  ///   If not provided, defaults to English.
  /// - [titleType]: The format of the weekday name (full or half).
  ///   If not provided, defaults to full format.
  ///
  /// Throws an [ArgumentError] if the day number is outside the valid range (0-6).
  static String formattedWeekDay(
    int day, [
    CalendarLocale? language,
    WeekdayFormat? titleType,
  ]) {
    if (day < 0 || day > 6) {
      throw ArgumentError('Day must be between 0 and 6.');
    }

    // Determine if the language is English.
    final isEnglish =
        (language ?? CalendarLocale.english) == CalendarLocale.english;

    // Check if abbreviated format is requested
    // Both 'abbreviated' and deprecated 'half' should return abbreviated names
    final isAbbreviated = titleType == WeekdayFormat.abbreviated ||
        titleType == WeekdayFormat.half;

    // Return the weekday name in the appropriate language and format.
    if (isEnglish) {
      if (isAbbreviated) return _englishHalfWeeks[day];
      return _englishWeeks[day];
    } else {
      if (isAbbreviated) return _nepaliHalfWeeks[day];
      return _nepaliWeeks[day];
    }
  }

  /// List of full Nepali weekday names.
  static final List<String> _nepaliWeeks = [
    "आइतबार",
    "सोमबार",
    "मंगलबार",
    "बुधबार",
    "बिहिबार",
    "शुक्रबार",
    "शनिबार",
  ];

  /// List of half Nepali weekday names (abbreviated).
  static final List<String> _nepaliHalfWeeks = [
    "आइत",
    "सोम",
    "मंगल",
    "बुध",
    "बिहि",
    "शुक्र",
    "शनि",
  ];

  /// List of full English weekday names.
  static final List<String> _englishWeeks = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  /// List of half English weekday names (abbreviated).
  static final List<String> _englishHalfWeeks = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];
}
