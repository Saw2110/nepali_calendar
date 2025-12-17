import '../src.dart';

/// A class that manages calendar configuration settings.
///
/// This class centralizes all calendar behavior configuration including:
/// * Display options (English dates, borders)
/// * Language settings
/// * Weekend configuration
/// * Week start day configuration
///
/// Example usage:
/// ```dart
/// final config = CalendarConfig(
///   showEnglishDate: true,
///   language: Language.nepali,
///   weekendType: WeekendType.saturdayAndSunday,
///   weekStartType: WeekStartType.monday,
/// );
/// ```
class CalendarConfig {
  /// Controls whether to display the corresponding English date below Nepali dates.
  ///
  /// When set to `true`, each cell will show both Nepali and English dates.
  /// Default is `false`.
  final bool showEnglishDate;

  /// Controls whether to display a border around each day cell.
  ///
  /// When set to `true`, each cell will have a border.
  /// Default is `false`.
  final bool showBorder;

  /// Specifies the language to be used for displaying calendar content.
  ///
  /// This determines whether the calendar uses Nepali or English text.
  /// Default is [Language.nepali].
  final Language language;

  /// Specifies which days are considered weekend days.
  ///
  /// This determines which days will be highlighted with the weekend color.
  /// Default is [WeekendType.saturday].
  final WeekendType weekendType;

  /// Specifies which day the week starts on.
  ///
  /// This determines the order of days in the calendar header and grid.
  /// Default is [WeekStartType.sunday].
  final WeekStartType weekStartType;

  /// Specifies the format for displaying weekday titles (e.g., "Sunday" or "Sun").
  ///
  /// Determines whether to show the full weekday name or an abbreviated version.
  /// Default is [TitleFormat.half].
  final TitleFormat weekTitleType;

  /// Creates a [CalendarConfig] instance with customizable configuration options.
  ///
  /// All parameters are optional and have default values.
  const CalendarConfig({
    this.showEnglishDate = false,
    this.showBorder = false,
    this.language = Language.nepali,
    this.weekendType = WeekendType.saturday,
    this.weekStartType = WeekStartType.sunday,
    this.weekTitleType = TitleFormat.half,
  });

  /// Creates a copy of this config with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newConfig = currentConfig.copyWith(
  ///   showEnglishDate: true,
  ///   weekendType: WeekendType.saturdayAndSunday,
  /// );
  /// ```
  CalendarConfig copyWith({
    bool? showEnglishDate,
    bool? showBorder,
    Language? language,
    WeekendType? weekendType,
    WeekStartType? weekStartType,
    TitleFormat? weekTitleType,
  }) {
    return CalendarConfig(
      showEnglishDate: showEnglishDate ?? this.showEnglishDate,
      showBorder: showBorder ?? this.showBorder,
      language: language ?? this.language,
      weekendType: weekendType ?? this.weekendType,
      weekStartType: weekStartType ?? this.weekStartType,
      weekTitleType: weekTitleType ?? this.weekTitleType,
    );
  }
}
