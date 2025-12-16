import '../src.dart';

/// Utility class for handling month-related operations and data.
///
/// This class provides methods and data for:
/// * Formatting month names in Nepali or English.
/// * Accessing predefined month names in Nepali and English formats.
class MonthUtils {
  /// Returns the formatted month name for the given month number.
  ///
  /// - [month]: The month number (1 for Baisakh, 12 for Chaitra).
  /// - [locale]: The locale in which the month name should be returned.
  ///   If not provided, defaults to English.
  ///
  /// Throws an [ArgumentError] if the month number is outside the valid range (1-12).
  static String formattedMonth(int month, [CalendarLocale? locale]) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    // Determine if the locale is English.
    final isEnglish =
        (locale ?? CalendarLocale.english) == CalendarLocale.english;

    // Return the month name in the appropriate locale.
    if (isEnglish) {
      return _nepaliENMonths[month - 1];
    } else {
      return _nepaliMonths[month - 1];
    }
  }

  /// List of Nepali month names in Nepali script.
  static final List<String> _nepaliMonths = [
    "बैशाख",
    "जेठ",
    "असार",
    "साउन",
    "भदौ",
    "असोज",
    "कार्तिक",
    "मंसिर",
    "पुष",
    "माघ",
    "फागुन",
    "चैत",
  ];

  /// List of Nepali month names in English script.
  static final List<String> _nepaliENMonths = [
    "Baisakh",
    "Jestha",
    "Asar",
    "Shrawan",
    "Bhadra",
    "Ashoj",
    "Kartik",
    "Mangsir",
    "Poush",
    "Magh",
    "Falgun",
    "Chaitra",
  ];
}
