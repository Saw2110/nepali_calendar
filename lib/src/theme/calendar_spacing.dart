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
  /// Horizontal spacing between cells.
  ///
  /// Controls the gap between adjacent date cells in a row.
  /// Default is 2.0.
  final double cellHorizontalSpacing;

  /// Vertical spacing between cells.
  ///
  /// Controls the gap between rows of date cells.
  /// Default is 2.0.
  final double cellVerticalSpacing;

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
    this.cellHorizontalSpacing = 2.0,
    this.cellVerticalSpacing = 2.0,
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
    double? cellHorizontalSpacing,
    double? cellVerticalSpacing,
    EdgeInsets? calendarPadding,
    double? headerToWeekdaysSpacing,
    double? weekdaysToCellsSpacing,
  }) {
    return CalendarSpacing(
      cellHorizontalSpacing:
          cellHorizontalSpacing ?? this.cellHorizontalSpacing,
      cellVerticalSpacing: cellVerticalSpacing ?? this.cellVerticalSpacing,
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
        other.cellHorizontalSpacing == cellHorizontalSpacing &&
        other.cellVerticalSpacing == cellVerticalSpacing &&
        other.calendarPadding == calendarPadding &&
        other.headerToWeekdaysSpacing == headerToWeekdaysSpacing &&
        other.weekdaysToCellsSpacing == weekdaysToCellsSpacing;
  }

  @override
  int get hashCode {
    return Object.hash(
      cellHorizontalSpacing,
      cellVerticalSpacing,
      calendarPadding,
      headerToWeekdaysSpacing,
      weekdaysToCellsSpacing,
    );
  }

  /// Converts this spacing configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'cellHorizontalSpacing': cellHorizontalSpacing,
      'cellVerticalSpacing': cellVerticalSpacing,
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
      cellHorizontalSpacing:
          (json['cellHorizontalSpacing'] as num?)?.toDouble() ?? 2.0,
      cellVerticalSpacing:
          (json['cellVerticalSpacing'] as num?)?.toDouble() ?? 2.0,
      calendarPadding: padding,
      headerToWeekdaysSpacing:
          (json['headerToWeekdaysSpacing'] as num?)?.toDouble() ?? 8.0,
      weekdaysToCellsSpacing:
          (json['weekdaysToCellsSpacing'] as num?)?.toDouble() ?? 8.0,
    );
  }
}
