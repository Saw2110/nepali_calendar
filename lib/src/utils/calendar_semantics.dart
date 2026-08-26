import '../src.dart';

/// Builds the strings screen readers announce for calendar dates.
///
/// Internal: deliberately not exported from `src.dart`. It exists so that
/// [NepaliCalendar], [NepaliYearCalendar] and [NepaliDatePicker] announce
/// dates identically rather than each inventing a phrasing.
///
/// A bare day number tells a screen reader user nothing -- "१५" could be any
/// month of any year -- so every date is spelled out in full.
class CalendarSemantics {
  const CalendarSemantics._();

  /// What a screen reader announces for a single date.
  ///
  /// The leading four components are always month, day, year and weekday, in
  /// that order, followed by whichever states apply:
  ///
  /// ```
  /// Baisakh, 15, 2081, Saturday, Today, Holiday, 2 events
  /// बैशाख, १५, २०८१, शनिबार, आज, बिदा, २ कार्यक्रम
  /// ```
  ///
  /// Numbers follow [language], so a Nepali calendar announces Devanagari
  /// digits to a Nepali screen reader rather than Latin ones.
  static String dayLabel(
    NepaliDateTime date, {
    required Language language,
    bool isToday = false,
    bool isHoliday = false,
    bool isDisabled = false,
    bool isOtherMonth = false,
    int eventCount = 0,
  }) {
    final nepali = language == Language.nepali;

    return [
      MonthUtils.formattedMonth(date.month, language),
      NepaliNumberConverter.formattedNumber('${date.day}', language: language),
      NepaliNumberConverter.formattedNumber('${date.year}', language: language),
      WeekUtils.formattedWeekDay(date.weekday, language),
      if (isToday) nepali ? 'आज' : 'Today',
      if (isHoliday) nepali ? 'बिदा' : 'Holiday',
      if (eventCount > 0) _events(eventCount, language),
      // Announced last, because it qualifies everything before it.
      if (isOtherMonth) nepali ? 'अर्को महिना' : 'Other month',
      if (isDisabled) nepali ? 'उपलब्ध छैन' : 'Unavailable',
    ].join(', ');
  }

  /// "2 events" / "२ कार्यक्रम".
  ///
  /// Nepali does not inflect the noun for plurality here, so only the English
  /// form takes a suffix.
  static String _events(int count, Language language) {
    final formatted = NepaliNumberConverter.formattedNumber(
      '$count',
      language: language,
    );
    if (language == Language.nepali) return '$formatted कार्यक्रम';
    return count == 1 ? '$formatted event' : '$formatted events';
  }

  /// The label for the previous-month navigation control.
  static String previousMonth(Language language) =>
      language == Language.nepali ? 'अघिल्लो महिना' : 'Previous month';

  /// The label for the next-month navigation control.
  static String nextMonth(Language language) =>
      language == Language.nepali ? 'अर्को महिना' : 'Next month';

  /// The label announced for the header, which names the month on screen.
  static String monthHeader(NepaliDateTime date, Language language) {
    return [
      MonthUtils.formattedMonth(date.month, language),
      NepaliNumberConverter.formattedNumber('${date.year}', language: language),
    ].join(' ');
  }
}
