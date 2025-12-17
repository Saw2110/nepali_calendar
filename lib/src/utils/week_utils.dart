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
    Language? language,
    TitleFormat? titleType,
  ]) {
    if (day < 0 || day > 6) {
      throw ArgumentError('Day must be between 0 and 6.');
    }

    // Determine if the language is English.
    final isEnglish = (language ?? Language.english) == Language.english;

    // Return the weekday name in the appropriate language and format.
    if (isEnglish) {
      if (titleType == TitleFormat.half) return _englishHalfWeeks[day];
      return _englishWeeks[day];
    } else {
      if (titleType == TitleFormat.half) return _nepaliHalfWeeks[day];
      return _nepaliWeeks[day];
    }
  }

  /// Returns the formatted short weekday name for the given day number.
  ///
  /// - [day]: The day number (0 for Sunday/आइतबार, 6 for Saturday/शनिबार).
  /// - [language]: The language in which the short weekday name should be returned.
  ///   If not provided, defaults to English.
  ///
  /// Throws an [ArgumentError] if the day number is outside the valid range (0-6).
  static String formattedShortWeekDay(int day, [Language? language]) {
    if (day < 0 || day > 6) {
      throw ArgumentError('Day must be between 0 and 6.');
    }

    // Determine if the language is English.
    final isEnglish = (language ?? Language.english) == Language.english;

    // Return the short weekday name in the appropriate language.
    if (isEnglish) {
      return _englishWeeksShort[day];
    } else {
      return _nepaliWeeksShort[day];
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

  /// List of short Nepali weekday names (single or double characters).
  static final List<String> _nepaliWeeksShort = [
    "आ",
    "सो",
    "मं",
    "बु",
    "बि",
    "शु",
    "श",
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

  /// List of short English weekday names (single character).
  static final List<String> _englishWeeksShort = [
    "S",
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
  ];

  /// Checks if the given weekday is a weekend based on the weekend type.
  ///
  /// - [weekday]: The weekday number (0=Sunday, 1=Monday, ..., 6=Saturday).
  /// - [weekendType]: The type of weekend configuration.
  ///
  /// Returns `true` if the weekday is a weekend; otherwise, `false`.
  ///
  /// Throws an [ArgumentError] if the weekday number is outside the valid range (0-6).
  static bool isWeekend(int weekday, WeekendType weekendType) {
    if (weekday < 0 || weekday > 6) {
      throw ArgumentError('Weekday must be between 0 and 6.');
    }

    // weekday: 0=Sunday, 1=Monday, 2=Tuesday, ..., 6=Saturday
    switch (weekendType) {
      case WeekendType.saturdayAndSunday:
        return weekday == 0 || weekday == 6;
      case WeekendType.fridayAndSaturday:
        return weekday == 5 || weekday == 6;
      case WeekendType.saturday:
        return weekday == 6;
      case WeekendType.sunday:
        return weekday == 0;
    }
  }
}
