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

  /// Creates a [CalendarBorders] with the specified border configuration.
  ///
  /// All parameters have sensible default values with dividers disabled.
  const CalendarBorders({
    this.calendarBorder,
    this.calendarBorderRadius,
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
  }) {
    return CalendarBorders(
      calendarBorder: calendarBorder ?? this.calendarBorder,
      calendarBorderRadius: calendarBorderRadius ?? this.calendarBorderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarBorders &&
        other.calendarBorder == calendarBorder &&
        other.calendarBorderRadius == calendarBorderRadius;
  }

  @override
  int get hashCode {
    return Object.hash(
      calendarBorder,
      calendarBorderRadius,
    );
  }

  /// Converts the [CalendarBorders] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'calendarBorder': calendarBorder?.toString(),
      'calendarBorderRadius': calendarBorderRadius?.toString(),
    };
  }

  /// Creates a [CalendarBorders] from a JSON map.
  factory CalendarBorders.fromJson(Map<String, dynamic> json) {
    return CalendarBorders(
      calendarBorder: json['calendarBorder'],
      calendarBorderRadius: json['calendarBorderRadius'],
    );
  }
}
