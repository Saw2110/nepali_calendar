import 'package:flutter/material.dart';

import '../src.dart';

/// A class that handles all the styling configuration for the Nepali Calendar.
///
/// This class allows you to customize various aspects of the calendar, including:
/// * Whether to show English dates
/// * Cell styles (colors, text styles for dates)
/// * Header styles (text styles for week, month, and year headers)
///
/// Example usage:
/// ```dart
/// final calendarStyle = NepaliCalendarStyle(
///   showEnglishDate: true,
///   cellsStyle: CellStyle(
///     dotColor: Colors.red,
///     selectedColor: Colors.blue,
///   ),
/// );
/// ```
class NepaliCalendarStyle {
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

  /// Creates a [NepaliCalendarStyle] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  const NepaliCalendarStyle({
    this.showEnglishDate = false,
    this.showBorder = false,
    this.language = Language.nepali,
    this.cellsStyle = const CellStyle(),
    this.headersStyle = const HeaderStyle(),
    this.weekendType = WeekendType.saturday,
    this.weekStartType = WeekStartType.sunday,
  });

  /// Creates a copy of this style with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newStyle = currentStyle.copyWith(
  ///   showEnglishDate: true,
  ///   cellsStyle: CellStyle(...),
  /// );
  /// ```
  NepaliCalendarStyle copyWith({
    bool? showEnglishDate,
    bool? showBorder,
    Language? language,
    CellStyle? cellsStyle,
    HeaderStyle? headersStyle,
    WeekendType? weekendType,
    WeekStartType? weekStartType,
  }) {
    return NepaliCalendarStyle(
      showEnglishDate: showEnglishDate ?? this.showEnglishDate,
      showBorder: showBorder ?? this.showBorder,
      language: language ?? this.language,
      cellsStyle: cellsStyle ?? this.cellsStyle,
      headersStyle: headersStyle ?? this.headersStyle,
      weekendType: weekendType ?? this.weekendType,
      weekStartType: weekStartType ?? this.weekStartType,
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
