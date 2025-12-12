import 'package:flutter/material.dart';

/// Animation configuration for calendar transitions.
///
/// This class provides control over the animation timing and curves
/// for various calendar interactions, including month transitions
/// and date selection.
///
/// Example usage:
/// ```dart
/// final animations = CalendarAnimations(
///   monthTransitionDuration: Duration(milliseconds: 400),
///   monthTransitionCurve: Curves.easeInOutCubic,
///   enableCellAnimation: true,
/// );
/// ```
class CalendarAnimations {
  /// Duration for month transition animations.
  ///
  /// Controls how long the animation takes when navigating
  /// between months.
  /// Default is 300 milliseconds.
  final Duration monthTransitionDuration;

  /// Curve for month transition animations.
  ///
  /// Controls the easing curve for month navigation animations.
  /// Default is Curves.easeInOut.
  final Curve monthTransitionCurve;

  /// Duration for selection animations.
  ///
  /// Controls how long the animation takes when selecting a date.
  /// Default is 200 milliseconds.
  final Duration selectionAnimationDuration;

  /// Curve for selection animations.
  ///
  /// Controls the easing curve for date selection animations.
  /// Default is Curves.easeOut.
  final Curve selectionAnimationCurve;

  /// Whether to animate cell state changes.
  ///
  /// When true, cells animate when their state changes
  /// (e.g., selected, hovered).
  /// Default is true.
  final bool enableCellAnimation;

  /// Whether to animate header changes.
  ///
  /// When true, the header animates when the month/year changes.
  /// Default is true.
  final bool enableHeaderAnimation;

  /// Creates a [CalendarAnimations] with the specified animation configuration.
  ///
  /// All parameters have sensible default values.
  const CalendarAnimations({
    this.monthTransitionDuration = const Duration(milliseconds: 300),
    this.monthTransitionCurve = Curves.easeInOut,
    this.selectionAnimationDuration = const Duration(milliseconds: 200),
    this.selectionAnimationCurve = Curves.easeOut,
    this.enableCellAnimation = true,
    this.enableHeaderAnimation = true,
  });

  /// Creates a copy of this animation configuration with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newAnimations = animations.copyWith(
  ///   monthTransitionDuration: Duration(milliseconds: 500),
  ///   enableCellAnimation: false,
  /// );
  /// ```
  CalendarAnimations copyWith({
    Duration? monthTransitionDuration,
    Curve? monthTransitionCurve,
    Duration? selectionAnimationDuration,
    Curve? selectionAnimationCurve,
    bool? enableCellAnimation,
    bool? enableHeaderAnimation,
  }) {
    return CalendarAnimations(
      monthTransitionDuration:
          monthTransitionDuration ?? this.monthTransitionDuration,
      monthTransitionCurve: monthTransitionCurve ?? this.monthTransitionCurve,
      selectionAnimationDuration:
          selectionAnimationDuration ?? this.selectionAnimationDuration,
      selectionAnimationCurve:
          selectionAnimationCurve ?? this.selectionAnimationCurve,
      enableCellAnimation: enableCellAnimation ?? this.enableCellAnimation,
      enableHeaderAnimation:
          enableHeaderAnimation ?? this.enableHeaderAnimation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarAnimations &&
        other.monthTransitionDuration == monthTransitionDuration &&
        other.monthTransitionCurve == monthTransitionCurve &&
        other.selectionAnimationDuration == selectionAnimationDuration &&
        other.selectionAnimationCurve == selectionAnimationCurve &&
        other.enableCellAnimation == enableCellAnimation &&
        other.enableHeaderAnimation == enableHeaderAnimation;
  }

  @override
  int get hashCode {
    return Object.hash(
      monthTransitionDuration,
      monthTransitionCurve,
      selectionAnimationDuration,
      selectionAnimationCurve,
      enableCellAnimation,
      enableHeaderAnimation,
    );
  }

  /// Converts this animation configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'monthTransitionDuration': monthTransitionDuration.inMilliseconds,
      'selectionAnimationDuration': selectionAnimationDuration.inMilliseconds,
      'enableCellAnimation': enableCellAnimation,
      'enableHeaderAnimation': enableHeaderAnimation,
    };
  }

  /// Creates a [CalendarAnimations] from a JSON map.
  factory CalendarAnimations.fromJson(Map<String, dynamic> json) {
    return CalendarAnimations(
      monthTransitionDuration: Duration(
        milliseconds: json['monthTransitionDuration'] as int? ?? 300,
      ),
      selectionAnimationDuration: Duration(
        milliseconds: json['selectionAnimationDuration'] as int? ?? 200,
      ),
      enableCellAnimation: json['enableCellAnimation'] as bool? ?? true,
      enableHeaderAnimation: json['enableHeaderAnimation'] as bool? ?? true,
    );
  }
}
