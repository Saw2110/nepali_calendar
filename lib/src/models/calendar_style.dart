import 'package:flutter/material.dart';

import '../src.dart';

/// A class that handles all the styling configuration for the Nepali Calendar.
///
/// This class allows you to customize various aspects of the calendar, including:
/// * Calendar configuration (via [config] or deprecated individual properties)
/// * Cell styles (colors, text styles for dates)
/// * Header styles (text styles for week, month, and year headers)
///
/// Example usage:
/// ```dart
/// final calendarStyle = NepaliCalendarStyle(
///   config: CalendarConfig(
///     showEnglishDate: true,
///     language: Language.nepali,
///     weekendType: WeekendType.saturdayAndSunday,
///   ),
///   cellsStyle: CellStyle(
///     dotColor: Colors.red,
///     selectedColor: Colors.blue,
///   ),
/// );
/// ```
class NepaliCalendarStyle {
  /// Calendar configuration settings.
  ///
  /// This is the recommended way to configure calendar behavior.
  /// If not provided, configuration will be built from deprecated individual properties.
  final CalendarConfig? config;

  /// Controls whether to display the corresponding English date below Nepali dates.
  ///
  /// When set to `true`, each cell will show both Nepali and English dates.
  /// Default is `false`.
  ///
  /// **Deprecated:** Use [config] with [CalendarConfig.showEnglishDate] instead.
  @Deprecated(
    'Use config.showEnglishDate instead. This will be removed in a future version.',
  )
  final bool showEnglishDate;

  /// Controls whether to display a border around each day cell.
  ///
  /// When set to `true`, each cell will have a border.
  /// Default is `false`.
  ///
  /// **Deprecated:** Use [config] with [CalendarConfig.showBorder] instead.
  @Deprecated(
    'Use config.showBorder instead. This will be removed in a future version.',
  )
  final bool showBorder;

  /// Specifies the language to be used for displaying calendar content.
  ///
  /// This determines whether the calendar uses Nepali or English text.
  ///
  /// **Deprecated:** Use [config] with [CalendarConfig.language] instead.
  @Deprecated(
    'Use config.language instead. This will be removed in a future version.',
  )
  final Language language;

  /// Styling configuration for calendar cells, including dates and selection indicators.
  ///
  /// Manages styles for individual date cells, today's date, selected dates,
  /// and event indicators.
  final CellStyle cellsStyle;

  /// Styling configuration for calendar headers.
  ///
  /// Controls the appearance of week names, month names, and year display.
  final HeaderStyle headersStyle;

  /// Creates a [NepaliCalendarStyle] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  ///
  /// **Recommended:** Use [config] parameter for better organization:
  /// ```dart
  /// NepaliCalendarStyle(
  ///   config: CalendarConfig(
  ///     showEnglishDate: true,
  ///     language: Language.nepali,
  ///   ),
  /// )
  /// ```
  const NepaliCalendarStyle({
    this.config,
    @Deprecated('Use config.showEnglishDate instead')
    this.showEnglishDate = false,
    @Deprecated('Use config.showBorder instead') this.showBorder = false,
    @Deprecated('Use config.language instead') this.language = Language.nepali,
    this.cellsStyle = const CellStyle(),
    this.headersStyle = const HeaderStyle(),
  });

  /// Gets the effective calendar configuration.
  ///
  /// Returns [config] if provided, otherwise creates a config from deprecated properties.
  CalendarConfig get effectiveConfig {
    return config ??
        CalendarConfig(
          showEnglishDate: showEnglishDate,
          showBorder: showBorder,
          language: language,
          weekTitleType: headersStyle.weekTitleType,
        );
  }

  /// Creates a copy of this style with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newStyle = currentStyle.copyWith(
  ///   config: CalendarConfig(showEnglishDate: true),
  ///   cellsStyle: CellStyle(...),
  /// );
  /// ```
  NepaliCalendarStyle copyWith({
    CalendarConfig? config,
    bool? showEnglishDate,
    bool? showBorder,
    Language? language,
    CellStyle? cellsStyle,
    HeaderStyle? headersStyle,
    WeekendType? weekendType,
    WeekStartType? weekStartType,
  }) {
    return NepaliCalendarStyle(
      config: config ?? this.config,
      showEnglishDate: showEnglishDate ?? this.showEnglishDate,
      showBorder: showBorder ?? this.showBorder,
      language: language ?? this.language,
      cellsStyle: cellsStyle ?? this.cellsStyle,
      headersStyle: headersStyle ?? this.headersStyle,
    );
  }
}

/// Defines the styling for individual calendar cells.
///
/// This class handles all visual aspects of calendar date cells, including:
/// * Date text appearance
/// * Event indicators
/// * Selection highlighting
/// * Today's date highlighting
class CellStyle {
  /// TextStyle for the date numbers in each cell.
  ///
  /// This style is applied to all date numbers except for today's date
  /// and selected dates.
  final TextStyle dayStyle;

  /// Color for the event indicator dot that appears below dates with events.
  ///
  /// This dot indicates that the date has associated events.
  final Color dotColor;

  /// Color for the English date text that appears when [showEnglishDate] is `true`.
  ///
  /// This affects the small English date number shown below the Nepali date.
  final Color baseLineDateColor;

  /// Background color for highlighting today's date.
  ///
  /// This color is used to make the current date stand out in the calendar.
  final Color todayColor;

  /// Background color for the user-selected date.
  ///
  /// This color is applied when a user selects a date in the calendar.
  final Color selectedColor;

  /// Text color for the weekday names in the calendar header.
  ///
  /// This affects the display of day names (Sun, Mon, etc.).
  final Color weekDayColor;

  /// Creates a [CellStyle] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  const CellStyle({
    this.dayStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    this.dotColor = Colors.blue,
    this.baseLineDateColor = Colors.grey,
    this.todayColor = Colors.green,
    this.selectedColor = Colors.blue,
    this.weekDayColor = Colors.red,
  });

  /// Creates a copy of this style with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newCellStyle = currentCellStyle.copyWith(
  ///   dotColor: Colors.red,
  ///   selectedColor: Colors.blue,
  /// );
  /// ```
  CellStyle copyWith({
    TextStyle? dayStyle,
    Color? dotColor,
    Color? baseLineDateColor,
    Color? todayColor,
    Color? selectedColor,
    Color? weekDayColor,
  }) {
    return CellStyle(
      dayStyle: dayStyle ?? this.dayStyle,
      dotColor: dotColor ?? this.dotColor,
      baseLineDateColor: baseLineDateColor ?? this.baseLineDateColor,
      todayColor: todayColor ?? this.todayColor,
      selectedColor: selectedColor ?? this.selectedColor,
      weekDayColor: weekDayColor ?? this.weekDayColor,
    );
  }
}

/// Defines the styling for calendar headers.
///
/// This class manages the appearance of all text elements in the calendar header,
/// including week names, month names, and year display.
class HeaderStyle {
  /// TextStyle for the weekday names in the calendar header.
  ///
  /// Controls the appearance of day names (Sun, Mon, etc.) at the top of each column.
  final TextStyle weekHeaderStyle;

  /// Specifies the format for displaying weekday titles (e.g., "Sunday" or "Sun").
  ///
  /// Determines whether to show the full weekday name or an abbreviated version.
  ///
  /// **Deprecated:** Use [config] with [CalendarConfig.weekTitleType] instead.
  @Deprecated(
    'Use config.weekTitleType instead. This will be removed in a future version.',
  )
  final TitleFormat weekTitleType;

  /// TextStyle for the month name displayed in the calendar header.
  ///
  /// Controls the appearance of the current month name (e.g., Baisakh, Jestha).
  final TextStyle monthHeaderStyle;

  /// TextStyle for the year displayed in the calendar header.
  ///
  /// Controls the appearance of the Nepali year number.
  final TextStyle yearHeaderStyle;

  /// Creates a [HeaderStyle] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  const HeaderStyle({
    @Deprecated('Use config.weekTitleType instead')
    this.weekTitleType = TitleFormat.half,
    this.weekHeaderStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    this.monthHeaderStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    this.yearHeaderStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  });

  /// Creates a copy of this style with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newHeaderStyle = currentHeaderStyle.copyWith(
  ///   monthHeaderStyle: TextStyle(fontSize: 20, color: Colors.purple),
  /// );
  /// ```
  HeaderStyle copyWith({
    TextStyle? weekHeaderStyle,
    TitleFormat? weekTitleType,
    TextStyle? monthHeaderStyle,
    TextStyle? yearHeaderStyle,
  }) {
    return HeaderStyle(
      weekHeaderStyle: weekHeaderStyle ?? this.weekHeaderStyle,
      weekTitleType: weekTitleType ?? this.weekTitleType,
      monthHeaderStyle: monthHeaderStyle ?? this.monthHeaderStyle,
      yearHeaderStyle: yearHeaderStyle ?? this.yearHeaderStyle,
    );
  }
}
