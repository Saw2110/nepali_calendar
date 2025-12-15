import 'package:flutter/material.dart';

import '../src.dart';

/// @Deprecated: Use CalendarTheme instead
@Deprecated(
  'Use CalendarTheme instead. This will be removed in the next major version.',
)
typedef NepaliCalendarStyle = CalendarTheme;

/// A comprehensive theme configuration for the Nepali Calendar.
///
/// This class provides extensive customization options for the calendar appearance,
/// including date display, cell styling, header styling, and various visual properties.
///
/// Example usage:
/// ```dart
/// final theme = CalendarTheme(
///   cellTheme: CellTheme(
///     eventIndicatorColor: Colors.red,
///     selectionColor: Colors.blue,
///   ),
/// );
/// ```
class CalendarTheme {
  /// @Deprecated: Use cellTheme.showEnglishDate instead
  @Deprecated(
    'Use cellTheme.showEnglishDate instead. This will be removed in the next major version.',
  )
  bool get showEnglishDate => cellTheme.showEnglishDate;

  /// @Deprecated: Use cellTheme.showBorder instead
  @Deprecated(
    'Use cellTheme.showBorder instead. This will be removed in the next major version.',
  )
  bool get showBorder => cellTheme.showBorder;

  /// @Deprecated: Use locale instead
  @Deprecated(
    'Use locale instead. This will be removed in the next major version.',
  )
  CalendarLocale get language => locale;

  /// @Deprecated: Use cellTheme instead
  @Deprecated(
    'Use cellTheme instead. This will be removed in the next major version.',
  )
  CellTheme get cellsStyle => cellTheme;

  /// @Deprecated: Use headerTheme instead
  @Deprecated(
    'Use headerTheme instead. This will be removed in the next major version.',
  )
  HeaderTheme get headersStyle => headerTheme;

  /// Specifies the locale to be used for displaying calendar content.
  ///
  /// This determines whether the calendar uses Nepali or English text.
  final CalendarLocale locale;

  /// Theme configuration for calendar cells, including dates and selection indicators.
  ///
  /// Manages styles for individual date cells, today's date, selected dates,
  /// and event indicators.
  final CellTheme cellTheme;

  /// Theme configuration for calendar headers.
  ///
  /// Controls the appearance of week names, month names, and year display.
  final HeaderTheme headerTheme;

  /// Overall padding for the calendar widget.
  ///
  /// Defines the padding around the entire calendar. Default is EdgeInsets.all(8.0).
  final EdgeInsets calendarPadding;

  /// Background color for the entire calendar.
  ///
  /// Sets the background color of the calendar widget. Default is Colors.white.
  final Color backgroundColor;

  // New sub-theme properties

  /// Color scheme for the calendar.
  ///
  /// Provides semantic colors for all calendar states and elements.
  /// When null, default colors from individual themes are used.
  final CalendarColorScheme colorScheme;

  /// Spacing configuration for the calendar.
  ///
  /// Controls the spacing and padding throughout the calendar.
  final CalendarSpacing spacing;

  /// Border configuration for the calendar.
  ///
  /// Controls borders and dividers throughout the calendar.
  final CalendarBorders borders;

  /// Animation configuration for the calendar.
  ///
  /// Controls animation timing and curves for transitions.
  final CalendarAnimations animations;

  /// Theme configuration for weekday labels.
  ///
  /// Controls the appearance of the weekday labels row.
  final WeekdayTheme weekdayTheme;

  /// Creates a [CalendarTheme] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  /// Supports both new and deprecated parameter names for backward compatibility.
  ///
  /// **Deprecated parameters** (will be removed in next major version):
  /// - `showEnglishDate` → Use `cellTheme.showEnglishDate` instead
  /// - `showBorder` → Use `cellTheme.showBorder` instead
  /// - `language` → Use `locale` instead
  /// - `cellsStyle` → Use `cellTheme` instead
  /// - `headersStyle` → Use `headerTheme` instead
  CalendarTheme({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    this.calendarPadding = const EdgeInsets.all(8.0),
    this.backgroundColor = Colors.white,
    this.colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      disabled: Color(0xFF9E9E9E),
      today: Color(0xFF4CAF50),
      onToday: Colors.white,
      weekend: Color(0xFFF44336),
    ),
    this.spacing = const CalendarSpacing(),
    this.borders = const CalendarBorders(),
    this.animations = const CalendarAnimations(),
    this.weekdayTheme = const WeekdayTheme(),
    @Deprecated(
      'Use cellTheme: CellTheme(showEnglishDate: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? showEnglishDate,
    @Deprecated(
      'Use cellTheme: CellTheme(showBorder: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? showBorder,
    @Deprecated(
      'Use locale instead. '
      'This parameter will be removed in the next major version.',
    )
    CalendarLocale? language,
    @Deprecated(
      'Use cellTheme instead. '
      'This parameter will be removed in the next major version.',
    )
    CellTheme? cellsStyle,
    @Deprecated(
      'Use headerTheme instead. '
      'This parameter will be removed in the next major version.',
    )
    HeaderTheme? headersStyle,
  })  : locale = locale ?? language ?? CalendarLocale.nepali,
        headerTheme = headerTheme ?? headersStyle ?? const HeaderTheme(),
        cellTheme = _buildCellTheme(
          cellTheme: cellTheme ?? cellsStyle,
          showEnglishDate: showEnglishDate,
          showBorder: showBorder,
        );

  /// Helper to build CellTheme with deprecated parameter support.
  static CellTheme _buildCellTheme({
    CellTheme? cellTheme,
    bool? showEnglishDate,
    bool? showBorder,
  }) {
    final base = cellTheme ?? const CellTheme();
    if (showEnglishDate == null && showBorder == null) {
      return base;
    }
    return base.copyWith(
      showEnglishDate: showEnglishDate ?? base.showEnglishDate,
      showBorder: showBorder ?? base.showBorder,
    );
  }

  /// Creates a const [CalendarTheme] with default values.
  ///
  /// Use this when you need a const theme without deprecated parameters.
  const CalendarTheme.defaults({
    this.locale = CalendarLocale.nepali,
    this.cellTheme = const CellTheme(),
    this.headerTheme = const HeaderTheme(),
    this.calendarPadding = const EdgeInsets.all(8.0),
    this.backgroundColor = Colors.white,
    this.colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      disabled: Color(0xFF9E9E9E),
      today: Color(0xFF4CAF50),
      onToday: Colors.white,
      weekend: Color(0xFFF44336),
    ),
    this.spacing = const CalendarSpacing(),
    this.borders = const CalendarBorders(),
    this.animations = const CalendarAnimations(),
    this.weekdayTheme = const WeekdayTheme(),
  });

  /// @Deprecated: Use CalendarTheme() constructor directly.
  ///
  /// This factory was created for migration but is no longer needed
  /// since the main constructor now supports deprecated parameters.
  @Deprecated(
    'Use CalendarTheme() constructor directly. '
    'This factory will be removed in the next major version.',
  )
  factory CalendarTheme.withDeprecatedParams({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    EdgeInsets calendarPadding = const EdgeInsets.all(8.0),
    Color backgroundColor = Colors.white,
    CalendarColorScheme colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      disabled: Color(0xFF9E9E9E),
      today: Color(0xFF4CAF50),
      onToday: Colors.white,
      weekend: Color(0xFFF44336),
    ),
    CalendarSpacing spacing = const CalendarSpacing(),
    CalendarBorders borders = const CalendarBorders(),
    CalendarAnimations animations = const CalendarAnimations(),
    WeekdayTheme weekdayTheme = const WeekdayTheme(),
    @Deprecated('Use cellTheme.showEnglishDate instead') bool? showEnglishDate,
    @Deprecated('Use cellTheme.showBorder instead') bool? showBorder,
    @Deprecated('Use locale instead') CalendarLocale? language,
    @Deprecated('Use cellTheme instead') CellTheme? cellsStyle,
    @Deprecated('Use headerTheme instead') HeaderTheme? headersStyle,
  }) {
    return CalendarTheme(
      locale: locale,
      cellTheme: cellTheme,
      headerTheme: headerTheme,
      calendarPadding: calendarPadding,
      backgroundColor: backgroundColor,
      colorScheme: colorScheme,
      spacing: spacing,
      borders: borders,
      animations: animations,
      weekdayTheme: weekdayTheme,
      showEnglishDate: showEnglishDate,
      showBorder: showBorder,
      language: language,
      cellsStyle: cellsStyle,
      headersStyle: headersStyle,
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newTheme = currentTheme.copyWith(
  ///   cellTheme: CellTheme(showEnglishDate: true),
  /// );
  /// ```
  ///
  CalendarTheme copyWith({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    EdgeInsets? calendarPadding,
    Color? backgroundColor,
    // New sub-theme properties
    CalendarColorScheme? colorScheme,
    CalendarSpacing? spacing,
    CalendarBorders? borders,
    CalendarAnimations? animations,
    WeekdayTheme? weekdayTheme,
  }) {
    return CalendarTheme(
      locale: locale ?? this.locale,
      cellTheme: cellTheme ?? this.cellTheme,
      headerTheme: headerTheme ?? this.headerTheme,
      calendarPadding: calendarPadding ?? this.calendarPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      // New sub-theme properties
      colorScheme: colorScheme ?? this.colorScheme,
      spacing: spacing ?? this.spacing,
      borders: borders ?? this.borders,
      animations: animations ?? this.animations,
      weekdayTheme: weekdayTheme ?? this.weekdayTheme,
    );
  }

  // ============================================================================
  // Color Resolution Helpers
  // ============================================================================
  // These methods implement the Single Source of Truth pattern:
  // Priority: Explicit CellTheme property > ColorScheme > Default fallback
  // ============================================================================

  /// Resolves the selection background color.
  /// Priority: cellTheme.selectionColor > colorScheme.primary > default
  Color get resolvedSelectionColor {
    return cellTheme.selectionColor;
  }

  /// Resolves the selection text color.
  /// Priority: cellTheme.selectedTextColor > colorScheme.onPrimary > default
  Color get resolvedSelectionTextColor {
    return cellTheme.selectedTextColor ?? colorScheme.onPrimary;
  }

  /// Resolves today's background color.
  /// Priority: cellTheme.todayBackgroundColor > colorScheme.today > default
  Color get resolvedTodayBackgroundColor {
    return cellTheme.todayBackgroundColor;
  }

  /// Resolves today's text color.
  /// Priority: cellTheme.todayTextColor > colorScheme.onToday > default
  Color get resolvedTodayTextColor {
    return cellTheme.todayTextColor ?? colorScheme.onToday;
  }

  /// Resolves weekend text color.
  /// Priority: cellTheme.weekendTextColor > colorScheme.weekend > default
  Color get resolvedWeekendTextColor {
    return cellTheme.weekendTextColor;
  }

  /// Resolves disabled/adjacent month text color.
  /// Priority: cellTheme.adjacentMonthTextColor > colorScheme.disabled > default
  Color get resolvedDisabledTextColor {
    return cellTheme.adjacentMonthTextColor;
  }

  /// Resolves default text color.
  /// Priority: cellTheme.defaultTextStyle.color > colorScheme.onSurface > default
  Color get resolvedDefaultTextColor {
    return cellTheme.defaultTextStyle.color ?? colorScheme.onSurface;
  }

  /// Creates a fully configured light theme.
  ///
  /// Returns a [CalendarTheme] with coordinated light sub-themes
  /// suitable for light mode applications.
  ///
  /// Example:
  /// ```dart
  /// final lightTheme = CalendarTheme.light();
  /// ```
  factory CalendarTheme.light() {
    final colorScheme = CalendarColorScheme.light();
    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        todayTextColor: colorScheme.onToday,
        selectionColor: colorScheme.primary,
        selectedTextColor: colorScheme.onPrimary,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
        defaultTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        yearTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        weekendTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
    );
  }

  /// Creates a fully configured dark theme.
  ///
  /// Returns a [CalendarTheme] with coordinated dark sub-themes
  /// suitable for dark mode applications.
  ///
  /// Example:
  /// ```dart
  /// final darkTheme = CalendarTheme.dark();
  /// ```
  factory CalendarTheme.dark() {
    final colorScheme = CalendarColorScheme.dark();
    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        todayTextColor: colorScheme.onToday,
        selectionColor: colorScheme.primary,
        selectedTextColor: colorScheme.onPrimary,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
        defaultTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        yearTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        weekendTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
    );
  }

  /// Creates a theme from a Material [ThemeData].
  ///
  /// Extracts colors and styles from the provided Material theme
  /// to create a consistent calendar theme.
  ///
  /// Example:
  /// ```dart
  /// final theme = CalendarTheme.fromMaterialTheme(Theme.of(context));
  /// ```
  factory CalendarTheme.fromMaterialTheme(ThemeData theme) {
    final colorScheme = CalendarColorScheme.fromMaterialTheme(theme);
    final isDark = theme.brightness == Brightness.dark;

    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        todayTextColor: colorScheme.onToday,
        selectionColor: colorScheme.primary,
        selectedTextColor: colorScheme.onPrimary,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
        defaultTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
        yearTextStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
        headerBackgroundColor: isDark ? colorScheme.surface : null,
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
    );
  }

  /// Converts a Color to a hex string.
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  /// Parses a hex string to a Color.
  static Color _hexToColor(String hex) {
    if (hex.startsWith('#')) {
      return Color(int.parse(hex.substring(1), radix: 16));
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Converts this calendar theme to a JSON map.
  ///
  /// Aggregates all sub-theme configurations into a single JSON structure.
  Map<String, dynamic> toJson() {
    return {
      'locale': locale.name,
      'backgroundColor': _colorToHex(backgroundColor),
      'colorScheme': colorScheme.toJson(),
      'spacing': spacing.toJson(),
      'borders': borders.toJson(),
      'animations': animations.toJson(),
      'cellTheme': cellTheme.toJson(),
      'headerTheme': headerTheme.toJson(),
      'weekdayTheme': weekdayTheme.toJson(),
    };
  }

  /// Creates a [CalendarTheme] from a JSON map.
  ///
  /// Uses default values for any missing properties.
  factory CalendarTheme.fromJson(Map<String, dynamic> json) {
    CalendarLocale locale = CalendarLocale.nepali;
    if (json['locale'] != null) {
      final localeStr = json['locale'] as String;
      locale = CalendarLocale.values.firstWhere(
        (e) => e.name == localeStr,
        orElse: () => CalendarLocale.nepali,
      );
    }

    final CellTheme cellTheme = json['cellTheme'] != null
        ? CellTheme.fromJson(json['cellTheme'] as Map<String, dynamic>)
        : const CellTheme();

    return CalendarTheme(
      locale: locale,
      backgroundColor: json['backgroundColor'] != null
          ? _hexToColor(json['backgroundColor'] as String)
          : Colors.white,
      colorScheme: json['colorScheme'] != null
          ? CalendarColorScheme.fromJson(
              json['colorScheme'] as Map<String, dynamic>,
            )
          : CalendarColorScheme.light(),
      spacing: json['spacing'] != null
          ? CalendarSpacing.fromJson(json['spacing'] as Map<String, dynamic>)
          : const CalendarSpacing(),
      borders: json['borders'] != null
          ? CalendarBorders.fromJson(json['borders'] as Map<String, dynamic>)
          : const CalendarBorders(),
      animations: json['animations'] != null
          ? CalendarAnimations.fromJson(
              json['animations'] as Map<String, dynamic>,
            )
          : const CalendarAnimations(),
      cellTheme: cellTheme,
      headerTheme: json['headerTheme'] != null
          ? HeaderTheme.fromJson(json['headerTheme'] as Map<String, dynamic>)
          : const HeaderTheme(),
      weekdayTheme: json['weekdayTheme'] != null
          ? WeekdayTheme.fromJson(json['weekdayTheme'] as Map<String, dynamic>)
          : const WeekdayTheme(),
    );
  }
}
