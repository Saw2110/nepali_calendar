import 'package:flutter/material.dart';

/// Color scheme for the calendar following Material Design principles.
///
/// Provides semantic colors for all calendar states and elements.
/// This is the **Single Source of Truth** for all calendar colors.
///
/// All calendar components (NepaliCalendar, DatePicker, HorizontalCalendar)
/// use this color scheme as the primary source for colors. Individual theme
/// properties (like CellTheme colors) act as overrides when specified.
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
///   surface: Colors.white,
///   onSurface: Colors.black,
///   disabled: Colors.grey,
/// );
/// ```
class CalendarColorScheme {
  /// Primary color used for selected dates and main accents.
  ///
  /// Used for:
  /// - Selected date background
  /// - Active navigation elements
  /// - Primary interactive elements
  final Color primary;

  /// Color for content on primary color backgrounds.
  ///
  /// Used for:
  /// - Text on selected dates
  /// - Icons on primary backgrounds
  final Color onPrimary;

  /// Surface color for calendar background.
  ///
  /// Used for:
  /// - Calendar container background
  /// - Cell backgrounds
  /// - Header backgrounds
  final Color surface;

  /// Color for content on surface backgrounds.
  ///
  /// Used for:
  /// - Default date text
  /// - Header text
  /// - Weekday labels
  final Color onSurface;

  /// Color for disabled/inactive dates.
  ///
  /// Used for:
  /// - Disabled date text
  /// - Adjacent month dates
  /// - Inactive navigation buttons
  final Color disabled;

  /// Color for today's date highlight.
  ///
  /// Used for:
  /// - Today's date background
  /// - Today indicator
  final Color today;

  /// Color for text on today's date.
  ///
  /// Used for:
  /// - Text displayed on today's date background
  final Color onToday;

  /// Color for weekend dates (Saturday/Sunday).
  ///
  /// Used for:
  /// - Weekend date text
  /// - Weekend weekday labels
  final Color weekend;

  /// Creates a [CalendarColorScheme] with the specified colors.
  ///
  /// All parameters are required to ensure a complete color scheme.
  const CalendarColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.disabled,
    required this.today,
    required this.onToday,
    required this.weekend,
  });

  /// Creates a pre-configured light theme color scheme.
  ///
  /// Uses Material Design light theme colors as defaults.
  factory CalendarColorScheme.light() {
    return const CalendarColorScheme(
      primary: Color(0xFF2196F3), // Blue
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      disabled: Color(0xFF9E9E9E), // Grey
      today: Color(0xFF4CAF50), // Green
      onToday: Colors.white,
      weekend: Color(0xFFF44336), // Red
    );
  }

  /// Creates a pre-configured dark theme color scheme.
  ///
  /// Uses Material Design dark theme colors as defaults.
  factory CalendarColorScheme.dark() {
    return const CalendarColorScheme(
      primary: Color(0xFF90CAF9), // Light Blue
      onPrimary: Colors.black,
      surface: Color(0xFF121212), // Dark surface
      onSurface: Colors.white,
      disabled: Color(0xFF757575), // Grey
      today: Color(0xFF81C784), // Light Green
      onToday: Colors.black,
      weekend: Color(0xFFEF5350), // Light Red
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
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      disabled: isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
      today: isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
      onToday: isDark ? Colors.black : Colors.white,
      weekend: isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336),
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
    Color? surface,
    Color? onSurface,
    Color? disabled,
    Color? today,
    Color? onToday,
    Color? weekend,
  }) {
    return CalendarColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      disabled: disabled ?? this.disabled,
      today: today ?? this.today,
      onToday: onToday ?? this.onToday,
      weekend: weekend ?? this.weekend,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarColorScheme &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.disabled == disabled &&
        other.today == today &&
        other.onToday == onToday &&
        other.weekend == weekend;
  }

  @override
  int get hashCode {
    return Object.hash(
      primary,
      onPrimary,
      surface,
      onSurface,
      disabled,
      today,
      onToday,
      weekend,
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
      'surface': _colorToHex(surface),
      'onSurface': _colorToHex(onSurface),
      'disabled': _colorToHex(disabled),
      'today': _colorToHex(today),
      'onToday': _colorToHex(onToday),
      'weekend': _colorToHex(weekend),
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
      surface: json['surface'] != null
          ? _hexToColor(json['surface'] as String)
          : defaults.surface,
      onSurface: json['onSurface'] != null
          ? _hexToColor(json['onSurface'] as String)
          : defaults.onSurface,
      disabled: json['disabled'] != null
          ? _hexToColor(json['disabled'] as String)
          : defaults.disabled,
      today: json['today'] != null
          ? _hexToColor(json['today'] as String)
          : defaults.today,
      onToday: json['onToday'] != null
          ? _hexToColor(json['onToday'] as String)
          : defaults.onToday,
      weekend: json['weekend'] != null
          ? _hexToColor(json['weekend'] as String)
          : defaults.weekend,
    );
  }
}
