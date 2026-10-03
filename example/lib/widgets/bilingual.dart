import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Small helpers so example text follows the language toggle without an `if`
/// at every string.
extension Bilingual on Language {
  bool get isNepali => this == Language.nepali;

  /// [english] or [nepali], whichever this language is.
  String pick(String english, String nepali) => isNepali ? nepali : english;

  /// [n] in this language's digits.
  String number(int n) =>
      NepaliNumberConverter.formattedNumber('$n', language: this);

  /// A BS date in words: "Ashoj 16, 2083" / "असोज १६, २०८३".
  String date(NepaliDateTime date) =>
      '${MonthUtils.formattedMonth(date.month, this)} '
      '${number(date.day)}, ${number(date.year)}';

  /// "7 days" / "७ दिन".
  String days(int count) => isNepali
      ? '${number(count)} दिन'
      : '$count ${count == 1 ? 'day' : 'days'}';
}

/// [date] in the Gregorian calendar: "02 Oct 2026".
String adDate(NepaliDateTime date) {
  final ad = date.toDateTime();
  return '${ad.day.toString().padLeft(2, '0')} '
      '${MonthUtils.englishMonthsShort[ad.month - 1]} ${ad.year}';
}
