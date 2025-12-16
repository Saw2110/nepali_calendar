import 'package:flutter/material.dart';

/// Spacing configuration for calendar layout.
///
/// This class provides control over the spacing and padding
/// throughout the calendar widget, allowing for consistent
/// layout density customization.
///
/// Example usage:
/// ```dart
/// final spacing = CalendarSpacing(
///   cellHorizontalSpacing: 4.0,
///   cellVerticalSpacing: 4.0,
///   calendarPadding: EdgeInsets.all(16.0),
/// );
/// ```
class CalendarSpacing {
  /// Padding around the entire calendar.
  ///
  /// Defines the padding around the calendar widget.
  /// Default is EdgeInsets.all(8.0).
  final EdgeInsets calendarPadding;

  /// Spacing between header and weekday labels.
  ///
  /// Controls the vertical gap between the month/year header
  /// and the weekday labels row.
  /// Default is 8.0.
  final double headerToWeekdaysSpacing;

  /// Spacing between weekday labels and date cells.
  ///
  /// Controls the vertical gap between the weekday labels row
  /// and the first row of date cells.
  /// Default is 8.0.
  final double weekdaysToCellsSpacing;

  /// Creates a [CalendarSpacing] with the specified spacing values.
  ///
  /// All parameters have sensible default values.
  const CalendarSpacing({
    this.calendarPadding = const EdgeInsets.all(8.0),
    this.headerToWeekdaysSpacing = 8.0,
    this.weekdaysToCellsSpacing = 8.0,
  });

  /// Creates a copy of this spacing configuration with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newSpacing = spacing.copyWith(
  ///   cellHorizontalSpacing: 4.0,
  ///   calendarPadding: EdgeInsets.all(16.0),
  /// );
  /// ```
  CalendarSpacing copyWith({
    EdgeInsets? calendarPadding,
    double? headerToWeekdaysSpacing,
    double? weekdaysToCellsSpacing,
  }) {
    return CalendarSpacing(
      calendarPadding: calendarPadding ?? this.calendarPadding,
      headerToWeekdaysSpacing:
          headerToWeekdaysSpacing ?? this.headerToWeekdaysSpacing,
      weekdaysToCellsSpacing:
          weekdaysToCellsSpacing ?? this.weekdaysToCellsSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarSpacing &&
        other.calendarPadding == calendarPadding &&
        other.headerToWeekdaysSpacing == headerToWeekdaysSpacing &&
        other.weekdaysToCellsSpacing == weekdaysToCellsSpacing;
  }

  @override
  int get hashCode {
    return Object.hash(
      calendarPadding,
      headerToWeekdaysSpacing,
      weekdaysToCellsSpacing,
    );
  }

  /// Converts this spacing configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'calendarPadding': {
        'left': calendarPadding.left,
        'top': calendarPadding.top,
        'right': calendarPadding.right,
        'bottom': calendarPadding.bottom,
      },
      'headerToWeekdaysSpacing': headerToWeekdaysSpacing,
      'weekdaysToCellsSpacing': weekdaysToCellsSpacing,
    };
  }

  /// Creates a [CalendarSpacing] from a JSON map.
  factory CalendarSpacing.fromJson(Map<String, dynamic> json) {
    EdgeInsets padding = const EdgeInsets.all(8.0);
    if (json['calendarPadding'] != null) {
      final p = json['calendarPadding'] as Map<String, dynamic>;
      padding = EdgeInsets.only(
        left: (p['left'] as num?)?.toDouble() ?? 8.0,
        top: (p['top'] as num?)?.toDouble() ?? 8.0,
        right: (p['right'] as num?)?.toDouble() ?? 8.0,
        bottom: (p['bottom'] as num?)?.toDouble() ?? 8.0,
      );
    }

    return CalendarSpacing(
      calendarPadding: padding,
      headerToWeekdaysSpacing:
          (json['headerToWeekdaysSpacing'] as num?)?.toDouble() ?? 8.0,
      weekdaysToCellsSpacing:
          (json['weekdaysToCellsSpacing'] as num?)?.toDouble() ?? 8.0,
    );
  }
}
