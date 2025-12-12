import 'package:flutter/material.dart';

/// Border and divider configuration for calendar.
///
/// This class provides control over the borders and dividers
/// throughout the calendar widget, allowing for visual separation
/// of calendar elements.
///
/// Example usage:
/// ```dart
/// final borders = CalendarBorders(
///   calendarBorder: Border.all(color: Colors.grey),
///   calendarBorderRadius: BorderRadius.circular(8.0),
///   showHorizontalDividers: true,
///   dividerColor: Colors.grey.shade300,
/// );
/// ```
class CalendarBorders {
  /// Border around the entire calendar.
  ///
  /// Defines the border style for the calendar container.
  /// Default is null (no border).
  final Border? calendarBorder;

  /// Border radius for the calendar container.
  ///
  /// Defines the corner radius for the calendar container.
  /// Default is null (no radius).
  final BorderRadius? calendarBorderRadius;

  /// Whether to show horizontal dividers between rows.
  ///
  /// When true, horizontal lines are drawn between each row of date cells.
  /// Default is false.
  final bool showHorizontalDividers;

  /// Whether to show vertical dividers between columns.
  ///
  /// When true, vertical lines are drawn between each column of date cells.
  /// Default is false.
  final bool showVerticalDividers;

  /// Color for dividers.
  ///
  /// Sets the color of horizontal and vertical dividers.
  /// Default is null (uses theme default).
  final Color? dividerColor;

  /// Thickness of dividers.
  ///
  /// Sets the thickness of horizontal and vertical dividers.
  /// Default is null (uses theme default, typically 1.0).
  final double? dividerThickness;

  /// Creates a [CalendarBorders] with the specified border configuration.
  ///
  /// All parameters have sensible default values with dividers disabled.
  const CalendarBorders({
    this.calendarBorder,
    this.calendarBorderRadius,
    this.showHorizontalDividers = false,
    this.showVerticalDividers = false,
    this.dividerColor,
    this.dividerThickness,
  });

  /// Creates a copy of this border configuration with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newBorders = borders.copyWith(
  ///   showHorizontalDividers: true,
  ///   dividerColor: Colors.grey,
  /// );
  /// ```
  CalendarBorders copyWith({
    Border? calendarBorder,
    BorderRadius? calendarBorderRadius,
    bool? showHorizontalDividers,
    bool? showVerticalDividers,
    Color? dividerColor,
    double? dividerThickness,
  }) {
    return CalendarBorders(
      calendarBorder: calendarBorder ?? this.calendarBorder,
      calendarBorderRadius: calendarBorderRadius ?? this.calendarBorderRadius,
      showHorizontalDividers:
          showHorizontalDividers ?? this.showHorizontalDividers,
      showVerticalDividers: showVerticalDividers ?? this.showVerticalDividers,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarBorders &&
        other.calendarBorder == calendarBorder &&
        other.calendarBorderRadius == calendarBorderRadius &&
        other.showHorizontalDividers == showHorizontalDividers &&
        other.showVerticalDividers == showVerticalDividers &&
        other.dividerColor == dividerColor &&
        other.dividerThickness == dividerThickness;
  }

  @override
  int get hashCode {
    return Object.hash(
      calendarBorder,
      calendarBorderRadius,
      showHorizontalDividers,
      showVerticalDividers,
      dividerColor,
      dividerThickness,
    );
  }

  /// Converts this border configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'showHorizontalDividers': showHorizontalDividers,
      'showVerticalDividers': showVerticalDividers,
      if (dividerColor != null)
        'dividerColor':
            '#${dividerColor!.value.toRadixString(16).padLeft(8, '0')}',
      if (dividerThickness != null) 'dividerThickness': dividerThickness,
    };
  }

  /// Creates a [CalendarBorders] from a JSON map.
  factory CalendarBorders.fromJson(Map<String, dynamic> json) {
    Color? dividerColor;
    if (json['dividerColor'] != null) {
      final colorStr = json['dividerColor'] as String;
      if (colorStr.startsWith('#')) {
        dividerColor = Color(int.parse(colorStr.substring(1), radix: 16));
      }
    }

    return CalendarBorders(
      showHorizontalDividers: json['showHorizontalDividers'] as bool? ?? false,
      showVerticalDividers: json['showVerticalDividers'] as bool? ?? false,
      dividerColor: dividerColor,
      dividerThickness: (json['dividerThickness'] as num?)?.toDouble(),
    );
  }
}
