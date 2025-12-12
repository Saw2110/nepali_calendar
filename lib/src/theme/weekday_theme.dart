import 'package:flutter/material.dart';

import '../enum/title_type.dart';

/// Theme configuration for weekday labels row.
///
/// This class provides comprehensive customization options for the
/// weekday labels displayed above the calendar grid.
///
/// Example usage:
/// ```dart
/// final weekdayTheme = WeekdayTheme(
///   format: WeekdayFormat.abbreviated,
///   show: true,
///   textStyle: TextStyle(
///     fontSize: 12,
///     fontWeight: FontWeight.w500,
///   ),
///   weekendTextStyle: TextStyle(
///     fontSize: 12,
///     fontWeight: FontWeight.w500,
///     color: Colors.red,
///   ),
/// );
/// ```
class WeekdayTheme {
  /// Format for weekday names.
  ///
  /// Controls how weekday names are displayed:
  /// - [WeekdayFormat.full]: Full names (e.g., "Sunday")
  /// - [WeekdayFormat.abbreviated]: Short names (e.g., "Sun")
  ///
  /// Default is [WeekdayFormat.abbreviated].
  final WeekdayFormat format;

  /// Whether to show weekday labels.
  ///
  /// When false, the weekday row is hidden entirely.
  /// Default is true.
  final bool show;

  /// Text style for weekday labels.
  ///
  /// Applied to all weekday labels except weekends when
  /// [weekendTextStyle] is specified.
  final TextStyle? textStyle;

  /// Text style for weekend day labels.
  ///
  /// Applied specifically to Saturday (and optionally Sunday
  /// depending on locale). If null, [textStyle] is used.
  final TextStyle? weekendTextStyle;

  /// Height of the weekday row.
  ///
  /// If null, the row height is determined by content.
  final double? height;

  /// Padding around weekday labels.
  ///
  /// Controls the internal padding of the weekday row.
  final EdgeInsets? padding;

  /// Alignment of weekday labels.
  ///
  /// Controls how weekday labels are distributed horizontally.
  /// Default is [MainAxisAlignment.spaceAround].
  final MainAxisAlignment alignment;

  /// Decoration for the weekday row.
  ///
  /// Allows adding background, border, or other decorations
  /// to the entire weekday row.
  final BoxDecoration? decoration;

  /// Background color for the weekday row.
  ///
  /// Convenience property for setting a simple background color.
  /// If [decoration] is also specified, this is ignored.
  final Color? backgroundColor;

  /// Custom labels for weekdays.
  ///
  /// When provided, overrides the [format] setting.
  /// Must contain exactly 7 strings, starting from Sunday.
  ///
  /// Example:
  /// ```dart
  /// customLabels: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
  /// ```
  final List<String>? customLabels;

  /// Creates a [WeekdayTheme] with the specified configuration.
  ///
  /// All parameters have sensible default values.
  const WeekdayTheme({
    this.format = WeekdayFormat.abbreviated,
    this.show = true,
    this.textStyle,
    this.weekendTextStyle,
    this.height,
    this.padding,
    this.alignment = MainAxisAlignment.spaceAround,
    this.decoration,
    this.backgroundColor,
    this.customLabels,
  });

  /// Creates a copy of this weekday theme with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newTheme = weekdayTheme.copyWith(
  ///   format: WeekdayFormat.full,
  ///   show: false,
  /// );
  /// ```
  WeekdayTheme copyWith({
    WeekdayFormat? format,
    bool? show,
    TextStyle? textStyle,
    TextStyle? weekendTextStyle,
    double? height,
    EdgeInsets? padding,
    MainAxisAlignment? alignment,
    BoxDecoration? decoration,
    Color? backgroundColor,
    List<String>? customLabels,
  }) {
    return WeekdayTheme(
      format: format ?? this.format,
      show: show ?? this.show,
      textStyle: textStyle ?? this.textStyle,
      weekendTextStyle: weekendTextStyle ?? this.weekendTextStyle,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      decoration: decoration ?? this.decoration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      customLabels: customLabels ?? this.customLabels,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WeekdayTheme) return false;

    // Compare lists element by element
    bool listsEqual = true;
    if (customLabels != null && other.customLabels != null) {
      if (customLabels!.length != other.customLabels!.length) {
        listsEqual = false;
      } else {
        for (int i = 0; i < customLabels!.length; i++) {
          if (customLabels![i] != other.customLabels![i]) {
            listsEqual = false;
            break;
          }
        }
      }
    } else if (customLabels != other.customLabels) {
      listsEqual = false;
    }

    return other.format == format &&
        other.show == show &&
        other.textStyle == textStyle &&
        other.weekendTextStyle == weekendTextStyle &&
        other.height == height &&
        other.padding == padding &&
        other.alignment == alignment &&
        other.decoration == decoration &&
        other.backgroundColor == backgroundColor &&
        listsEqual;
  }

  @override
  int get hashCode {
    return Object.hash(
      format,
      show,
      textStyle,
      weekendTextStyle,
      height,
      padding,
      alignment,
      decoration,
      backgroundColor,
      customLabels != null ? Object.hashAll(customLabels!) : null,
    );
  }

  /// Converts this weekday theme to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'format': format.name,
      'show': show,
      'alignment': alignment.name,
      if (height != null) 'height': height,
      if (customLabels != null) 'customLabels': customLabels,
      if (backgroundColor != null)
        'backgroundColor':
            '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0')}',
    };
  }

  /// Creates a [WeekdayTheme] from a JSON map.
  factory WeekdayTheme.fromJson(Map<String, dynamic> json) {
    WeekdayFormat format = WeekdayFormat.abbreviated;
    if (json['format'] != null) {
      final formatStr = json['format'] as String;
      format = WeekdayFormat.values.firstWhere(
        (e) => e.name == formatStr,
        orElse: () => WeekdayFormat.abbreviated,
      );
    }

    MainAxisAlignment alignment = MainAxisAlignment.spaceAround;
    if (json['alignment'] != null) {
      final alignStr = json['alignment'] as String;
      alignment = MainAxisAlignment.values.firstWhere(
        (e) => e.name == alignStr,
        orElse: () => MainAxisAlignment.spaceAround,
      );
    }

    Color? backgroundColor;
    if (json['backgroundColor'] != null) {
      final colorStr = json['backgroundColor'] as String;
      if (colorStr.startsWith('#')) {
        backgroundColor = Color(int.parse(colorStr.substring(1), radix: 16));
      }
    }

    return WeekdayTheme(
      format: format,
      show: json['show'] as bool? ?? true,
      alignment: alignment,
      height: (json['height'] as num?)?.toDouble(),
      customLabels: (json['customLabels'] as List<dynamic>?)?.cast<String>(),
      backgroundColor: backgroundColor,
    );
  }
}
