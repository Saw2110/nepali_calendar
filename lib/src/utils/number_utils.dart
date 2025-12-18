import '../src.dart';

/// Utility class for converting numbers between Nepali and English formats.
///
/// This class provides methods for:
/// * Converting Nepali numerals to English numerals.
/// * Converting English numerals to Nepali numerals.
/// * Converting numbers to their Nepali ordinal representations.
class NepaliNumberConverter {
  /// Mapping of Nepali numerals to their corresponding English numerals.
  static const Map<String, String> _nepaliToEnglish = {
    '०': '0',
    '१': '1',
    '२': '2',
    '३': '3',
    '४': '4',
    '५': '5',
    '६': '6',
    '७': '7',
    '८': '8',
    '९': '9',
  };

  /// Mapping of English numerals to their corresponding Nepali numerals.
  static const Map<String, String> _englishToNepali = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };

  /// List of Nepali ordinal number representations.
  ///
  /// The index corresponds to the number (e.g., index 1 is "पहिलो" for 1st).
  static const List<String> _ordinalNumbers = [
    'सुन्ना',
    'पहिलो',
    'दोस्रो',
    'तेस्रो',
    'चौथो',
    'पाँचौँ',
    'छैटौँ',
    'सातौँ',
    'आठौँ',
    'नौ',
  ];

  /// Converts a number to its Nepali ordinal representation.
  ///
  /// - [number]: The number to convert (must be between 1 and 9).
  /// Returns the Nepali ordinal representation of the number.
  ///
  /// Throws an [ArgumentError] if the number is outside the valid range (1-9).
  static String toOrdinal(int number) {
    if (number < 1 || number >= _ordinalNumbers.length) {
      throw ArgumentError(
        'Number must be between 1 and 9 for ordinal representation.',
      );
    }
    return _ordinalNumbers[number];
  }

  /// Converts a Nepali number string to an English number string.
  ///
  /// - [nepaliNumber]: The Nepali number string to convert.
  /// Returns the corresponding English number string.
  ///
  /// Example:
  /// ```dart
  /// final englishNumber = NepaliNumberConverter.nepaliToEnglish('१२३');
  /// print(englishNumber); // Output: "123"
  /// ```
  static String nepaliToEnglish(String nepaliNumber) {
    return nepaliNumber
        .split('')
        .map((char) => _nepaliToEnglish[char] ?? char)
        .join();
  }

  /// Converts an English number string to a Nepali number string.
  ///
  /// - [englishNumber]: The English number string to convert.
  /// Returns the corresponding Nepali number string.
  ///
  /// Example:
  /// ```dart
  /// final nepaliNumber = NepaliNumberConverter.englishToNepali('123');
  /// print(nepaliNumber); // Output: "१२३"
  /// ```
  static String englishToNepali(String englishNumber) {
    return englishNumber
        .split('')
        .map((char) => _englishToNepali[char] ?? char)
        .join();
  }

  /// Formats a number string based on the specified language.
  ///
  /// - [number]: The number string to format.
  /// - [language]: The target language (defaults to English).
  /// Returns the formatted number string.
  static String formattedNumber(
    String number, {
    Language language = Language.english,
  }) {
    if (language == Language.english) {
      return number;
    }
    return englishToNepali(number);
  }
}
