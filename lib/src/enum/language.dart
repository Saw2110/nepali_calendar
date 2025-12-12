/// Specifies the available languages for localization.
///
/// This enum defines the supported languages in the application.
@Deprecated('Use CalendarLocale instead. This will be removed in the next major version.')
typedef Language = CalendarLocale;

/// Specifies the available locales for calendar localization.
///
/// This enum defines the supported locales for displaying calendar content.
enum CalendarLocale {
  /// Represents the English language.
  english,

  /// Represents the Nepali language.
  nepali,
}
