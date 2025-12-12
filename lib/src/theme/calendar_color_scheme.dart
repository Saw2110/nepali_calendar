import 'package:flutter/material.dart';

/// Color scheme for the calendar following Material Design principles.
///
/// Provides semantic colors for all calendar states and elements.
/// This class offers factory constructors for common themes and
/// integration with Material Theme.
///
/// Example usage:
/// ```dart
/// // Use pre-configured light theme
/// final lightScheme = CalendarColorScheme.light();
///
/// // Use pre-configured dark theme
/// final darkScheme = CalendarColorScheme.dark();
///
/// // Create from Material theme
/// final materialScheme = CalendarColorScheme.fromMaterialTheme(Theme.of(context));
///
/// // Custom color scheme
/// final customScheme = CalendarColorScheme(
///   primary: Colors.purple,
///   onPrimary: Colors.white,
///   // ... other colors
/// );
/// ```
class CalendarColorScheme {
  /// Primary color used for selected dates and main accents.
  final Color primary;

  /// Color for content on primary color backgrounds.
  final Color onPrimary;

  /// Secondary color for less prominent elements.
  final Color secondary;

  /// Color for content on secondary color backgrounds.
  final Color onSecondary;

  /// Surface color for calendar background.
  final Color surface;

  /// Color for content on surface backgrounds.
  final Color onSurface;

  /// Error color for invalid states.
  final Color error;

  /// Color for content on error backgrounds.
  final Color onError;

  /// Color for disabled dates.
  final Color disabled;

  /// Color for weekend dates (Saturday).
  final Color weekend;

  /// Color for holiday dates.
  final Color holiday;

  /// Background color for today's date.
  final Color today;

  /// Background color for selected date.
  final Color selectedDate;

  /// Background color for range selection.
  final Color rangeSelection;

  /// Creates a [CalendarColorScheme] with the specified colors.
  ///
  /// All parameters are required to ensure a complete color scheme.
  const CalendarColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.disabled,
    required this.weekend,
    required this.holiday,
    required this.today,
    required this.selectedDate,
    required this.rangeSelection,
  });

  /// Creates a pre-configured light theme color scheme.
  ///
  /// Uses Material Design light theme colors as defaults.
  factory CalendarColorScheme.light() {
    return const CalendarColorScheme(
      primary: Color(0xFF2196F3), // Blue
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6), // Teal
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFFB00020), // Red
      onError: Colors.white,
      disabled: Color(0xFF9E9E9E), // Grey
      weekend: Color(0xFFF44336), // Red
      holiday: Color(0xFFE91E63), // Pink
      today: Color(0xFF4CAF50), // Green
      selectedDate: Color(0xFF2196F3), // Blue
      rangeSelection: Color(0xFFBBDEFB), // Light Blue
    );
  }

  /// Creates a pre-configured dark theme color scheme.
  ///
  /// Uses Material Design dark theme colors as defaults.
  factory CalendarColorScheme.dark() {
    return const CalendarColorScheme(
      primary: Color(0xFF90CAF9), // Light Blue
      onPrimary: Colors.black,
      secondary: Color(0xFF03DAC6), // Teal
      onSecondary: Colors.black,
      surface: Color(0xFF121212), // Dark surface
      onSurface: Colors.white,
      error: Color(0xFFCF6679), // Light Red
      onError: Colors.black,
      disabled: Color(0xFF757575), // Grey
      weekend: Color(0xFFEF5350), // Light Red
      holiday: Color(0xFFF48FB1), // Light Pink
      today: Color(0xFF81C784), // Light Green
      selectedDate: Color(0xFF90CAF9), // Light Blue
      rangeSelection: Color(0xFF1E3A5F), // Dark Blue
    );
  }

  /// Creates a color scheme from a Material [ThemeData].
  ///
  /// Extracts and maps colors from the provided Material theme
  /// to create a consistent calendar color scheme.
  ///
  /// Example:
  /// ```dart
  /// final scheme = CalendarColorScheme.fromMaterialTheme(Theme.of(context));
  /// ```
  factory CalendarColorScheme.fromMaterialTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return CalendarColorScheme(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      secondary: colorScheme.secondary,
      onSecondary: colorScheme.onSecondary,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      error: colorScheme.error,
      onError: colorScheme.onError,
      disabled: isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
      weekend: isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336),
      holiday: isDark ? const Color(0xFFF48FB1) : const Color(0xFFE91E63),
      today: isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
      selectedDate: colorScheme.primary,
      rangeSelection: colorScheme.primary.withValues(alpha: 0.2),
    );
  }

  /// Creates a copy of this color scheme with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newScheme = scheme.copyWith(
  ///   primary: Colors.purple,
  ///   weekend: Colors.orange,
  /// );
  /// ```
  CalendarColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? disabled,
    Color? weekend,
    Color? holiday,
    Color? today,
    Color? selectedDate,
    Color? rangeSelection,
  }) {
    return CalendarColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      disabled: disabled ?? this.disabled,
      weekend: weekend ?? this.weekend,
      holiday: holiday ?? this.holiday,
      today: today ?? this.today,
      selectedDate: selectedDate ?? this.selectedDate,
      rangeSelection: rangeSelection ?? this.rangeSelection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarColorScheme &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.secondary == secondary &&
        other.onSecondary == onSecondary &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.error == error &&
        other.onError == onError &&
        other.disabled == disabled &&
        other.weekend == weekend &&
        other.holiday == holiday &&
        other.today == today &&
        other.selectedDate == selectedDate &&
        other.rangeSelection == rangeSelection;
  }

  @override
  int get hashCode {
    return Object.hash(
      primary,
      onPrimary,
      secondary,
      onSecondary,
      surface,
      onSurface,
      error,
      onError,
      disabled,
      weekend,
      holiday,
      today,
      selectedDate,
      rangeSelection,
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

  /// Converts this color scheme to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'primary': _colorToHex(primary),
      'onPrimary': _colorToHex(onPrimary),
      'secondary': _colorToHex(secondary),
      'onSecondary': _colorToHex(onSecondary),
      'surface': _colorToHex(surface),
      'onSurface': _colorToHex(onSurface),
      'error': _colorToHex(error),
      'onError': _colorToHex(onError),
      'disabled': _colorToHex(disabled),
      'weekend': _colorToHex(weekend),
      'holiday': _colorToHex(holiday),
      'today': _colorToHex(today),
      'selectedDate': _colorToHex(selectedDate),
      'rangeSelection': _colorToHex(rangeSelection),
    };
  }

  /// Creates a [CalendarColorScheme] from a JSON map.
  ///
  /// Uses default light theme colors for any missing properties.
  factory CalendarColorScheme.fromJson(Map<String, dynamic> json) {
    final defaults = CalendarColorScheme.light();

    return CalendarColorScheme(
      primary: json['primary'] != null
          ? _hexToColor(json['primary'] as String)
          : defaults.primary,
      onPrimary: json['onPrimary'] != null
          ? _hexToColor(json['onPrimary'] as String)
          : defaults.onPrimary,
      secondary: json['secondary'] != null
          ? _hexToColor(json['secondary'] as String)
          : defaults.secondary,
      onSecondary: json['onSecondary'] != null
          ? _hexToColor(json['onSecondary'] as String)
          : defaults.onSecondary,
      surface: json['surface'] != null
          ? _hexToColor(json['surface'] as String)
          : defaults.surface,
      onSurface: json['onSurface'] != null
          ? _hexToColor(json['onSurface'] as String)
          : defaults.onSurface,
      error: json['error'] != null
          ? _hexToColor(json['error'] as String)
          : defaults.error,
      onError: json['onError'] != null
          ? _hexToColor(json['onError'] as String)
          : defaults.onError,
      disabled: json['disabled'] != null
          ? _hexToColor(json['disabled'] as String)
          : defaults.disabled,
      weekend: json['weekend'] != null
          ? _hexToColor(json['weekend'] as String)
          : defaults.weekend,
      holiday: json['holiday'] != null
          ? _hexToColor(json['holiday'] as String)
          : defaults.holiday,
      today: json['today'] != null
          ? _hexToColor(json['today'] as String)
          : defaults.today,
      selectedDate: json['selectedDate'] != null
          ? _hexToColor(json['selectedDate'] as String)
          : defaults.selectedDate,
      rangeSelection: json['rangeSelection'] != null
          ? _hexToColor(json['rangeSelection'] as String)
          : defaults.rangeSelection,
    );
  }
}
