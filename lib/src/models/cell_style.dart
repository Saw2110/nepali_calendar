import 'package:flutter/material.dart';

import '../src.dart';

/// @Deprecated: Use CellTheme instead
@Deprecated(
  'Use CellTheme instead. This will be removed in the next major version.',
)
typedef CellStyle = CellTheme;

/// Comprehensive theme configuration for individual calendar cells.
///
/// This class provides extensive customization for calendar date cells, including:
/// * Date text appearance with multiple states
/// * Event indicators with customizable styles
/// * Selection and hover effects
/// * Today's date highlighting
/// * Disabled and weekend date styling
class CellTheme {
  /// @Deprecated: Use defaultTextStyle instead
  @Deprecated(
    'Use defaultTextStyle instead. This will be removed in the next major version.',
  )
  TextStyle get dayStyle => defaultTextStyle;

  /// @Deprecated: Use eventIndicatorColor instead
  @Deprecated(
    'Use eventIndicatorColor instead. This will be removed in the next major version.',
  )
  Color get dotColor => eventIndicatorColor;

  /// @Deprecated: Use englishDateColor instead
  @Deprecated(
    'Use englishDateColor instead. This will be removed in the next major version.',
  )
  Color get baseLineDateColor => englishDateColor;

  /// @Deprecated: Use todayBackgroundColor instead
  @Deprecated(
    'Use todayBackgroundColor instead. This will be removed in the next major version.',
  )
  Color get todayColor => todayBackgroundColor;

  /// @Deprecated: Use selectionColor instead
  @Deprecated(
    'Use selectionColor instead. This will be removed in the next major version.',
  )
  Color get selectedColor => selectionColor;

  /// @Deprecated: Use weekendTextColor instead
  @Deprecated(
    'Use weekendTextColor instead. This will be removed in the next major version.',
  )
  Color get weekDayColor => weekendTextColor;

  /// @Deprecated: Use weekendTextColor instead
  ///
  /// This property was misnamed - it controls weekend date text color, not weekday labels.
  @Deprecated(
    'Use weekendTextColor instead. This will be removed in the next major version.',
  )
  Color get weekdayTextColor => weekendTextColor;

  /// Whether to show border around each cell.
  ///
  /// When true, cells will have a border defined by [cellBorder].
  final bool showBorder;

  /// Whether to show English date in cells.
  ///
  /// When true, the corresponding English date is displayed in each cell.
  final bool showEnglishDate;

  /// Default text style for date numbers in each cell.
  ///
  /// This style is applied to all date numbers unless overridden by specific states.
  final TextStyle defaultTextStyle;

  /// Text style for today's date.
  ///
  /// Overrides the default style for the current date.
  final TextStyle? todayTextStyle;

  /// Text style for selected dates.
  ///
  /// Applied when a user selects a date.
  final TextStyle? selectedTextStyle;

  /// Text style for disabled dates.
  ///
  /// Applied to dates that are not selectable.
  final TextStyle? disabledTextStyle;

  /// Text style for weekend dates.
  ///
  /// Applied to Saturday and Sunday dates.
  final TextStyle? weekendTextStyle;

  /// Text style for dates with events.
  ///
  /// Applied to dates that have associated events.
  final TextStyle? eventDateTextStyle;

  /// Color for the event indicator that appears on dates with events.
  ///
  /// This indicator shows that the date has associated events.
  final Color eventIndicatorColor;

  /// Size of the event indicator dot.
  ///
  /// Controls the diameter of the event indicator. Default is 4.0.
  final double eventIndicatorSize;

  /// @Deprecated: This property is not implemented.
  ///
  /// Position of the event indicator relative to the date.
  /// The event indicator position is currently hardcoded to bottom center.
  /// This property will be removed in the next major version.
  @Deprecated(
    'This property is not implemented. Event indicator position is hardcoded. '
    'This will be removed in the next major version.',
  )
  final AlignmentGeometry eventIndicatorAlignment;

  /// Color for the English date text when displayed.
  ///
  /// This affects the small English date number shown below the Nepali date.
  final Color englishDateColor;

  /// Background color for highlighting today's date.
  ///
  /// This color is used to make the current date stand out.
  final Color todayBackgroundColor;

  /// Text color for today's date.
  ///
  /// Overrides the default text color for the current date.
  final Color? todayTextColor;

  /// Background color for the selected date.
  ///
  /// Applied when a user selects a date.
  final Color selectionColor;

  /// Text color for the selected date.
  ///
  /// Overrides the default text color for selected dates.
  final Color? selectedTextColor;

  /// Text color for disabled dates.
  ///
  /// Applied to dates that cannot be selected.
  final Color? disabledTextColor;

  /// Background color for weekend dates.
  ///
  /// Applied to Saturday and Sunday.
  final Color? weekendBackgroundColor;

  /// Text color for weekend dates (Saturday).
  ///
  /// Applied to date numbers on weekend days.
  final Color weekendTextColor;

  /// Whether to show adjacent month days in empty cells.
  ///
  /// When true, previous and next month days are shown in light grey
  /// to fill the calendar grid. These days are not tappable.
  /// Default is true.
  final bool showAdjacentMonthDays;

  /// Text color for adjacent month days (previous/next month).
  ///
  /// Applied to dates from previous and next months shown in empty cells.
  /// Only used when [showAdjacentMonthDays] is true.
  final Color adjacentMonthTextColor;

  /// Border configuration for cells.
  ///
  /// Defines the border style for date cells.
  final Border? cellBorder;

  /// Margin around each cell.
  ///
  /// Controls the external spacing of date cells.
  final EdgeInsets cellMargin;

  /// Height of each cell.
  ///
  /// Defines the fixed height for date cells. Default is 40.0.
  final double cellHeight;

  /// Width of each cell.
  ///
  /// Defines the fixed width for date cells. Default is 40.0.
  final double cellWidth;

  /// Shape of the cell for selection and decoration rendering.
  ///
  /// Determines how selection highlights and decorations are shaped.
  /// Default is [CellShape.circle].
  final CellShape shape;

  /// Custom border radius for cells.
  ///
  /// Used when [shape] is [CellShape.roundedSquare] to define corner radius.
  /// When null, a default radius of 8.0 is used for rounded squares.
  final double borderRadius;

  /// Creates a [CellTheme] instance with comprehensive styling options.
  ///
  /// All parameters are optional and have default values.
  const CellTheme({
    this.showBorder = false,
    this.showEnglishDate = false,
    this.showAdjacentMonthDays = true,
    this.defaultTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    this.todayTextStyle,
    this.selectedTextStyle,
    this.disabledTextStyle,
    this.weekendTextStyle,
    this.eventDateTextStyle,
    this.eventIndicatorColor = Colors.blue,
    this.eventIndicatorSize = 4.0,
    this.eventIndicatorAlignment = Alignment.bottomCenter,
    this.englishDateColor = Colors.grey,
    this.todayBackgroundColor = Colors.green,
    this.todayTextColor,
    this.selectionColor = Colors.blue,
    this.selectedTextColor,
    this.disabledTextColor,
    this.weekendBackgroundColor,
    this.weekendTextColor = Colors.red,
    this.adjacentMonthTextColor = const Color(0xFFBDBDBD),
    this.cellBorder,
    this.cellMargin = const EdgeInsets.all(2.0),
    this.cellHeight = 40.0,
    this.cellWidth = 40.0,
    this.shape = CellShape.roundedSquare,
    this.borderRadius = 8.0,
  });

  /// Creates a copy of this theme with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newCellTheme = currentCellTheme.copyWith(
  ///   eventIndicatorColor: Colors.red,
  ///   selectionColor: Colors.blue,
  /// );
  /// ```
  CellTheme copyWith({
    bool? showBorder,
    bool? showEnglishDate,
    bool? showAdjacentMonthDays,
    TextStyle? defaultTextStyle,
    TextStyle? todayTextStyle,
    TextStyle? selectedTextStyle,
    TextStyle? disabledTextStyle,
    TextStyle? weekendTextStyle,
    TextStyle? eventDateTextStyle,
    Color? eventIndicatorColor,
    double? eventIndicatorSize,
    AlignmentGeometry? eventIndicatorAlignment,
    Color? englishDateColor,
    Color? todayBackgroundColor,
    Color? todayTextColor,
    Color? selectionColor,
    Color? selectedTextColor,
    Color? hoverColor,
    Color? disabledBackgroundColor,
    Color? disabledTextColor,
    Color? weekendBackgroundColor,
    Color? weekendTextColor,
    Color? adjacentMonthTextColor,
    Border? cellBorder,
    EdgeInsets? cellMargin,
    double? cellHeight,
    double? cellWidth,
    CellShape? shape,
    double? borderRadius,
  }) {
    return CellTheme(
      showBorder: showBorder ?? this.showBorder,
      showEnglishDate: showEnglishDate ?? this.showEnglishDate,
      showAdjacentMonthDays:
          showAdjacentMonthDays ?? this.showAdjacentMonthDays,
      defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      weekendTextStyle: weekendTextStyle ?? this.weekendTextStyle,
      eventDateTextStyle: eventDateTextStyle ?? this.eventDateTextStyle,
      eventIndicatorColor: eventIndicatorColor ?? this.eventIndicatorColor,
      eventIndicatorSize: eventIndicatorSize ?? this.eventIndicatorSize,
      eventIndicatorAlignment:
          eventIndicatorAlignment ?? this.eventIndicatorAlignment,
      englishDateColor: englishDateColor ?? this.englishDateColor,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      todayTextColor: todayTextColor ?? this.todayTextColor,
      selectionColor: selectionColor ?? this.selectionColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      weekendBackgroundColor:
          weekendBackgroundColor ?? this.weekendBackgroundColor,
      weekendTextColor: weekendTextColor ?? this.weekendTextColor,
      adjacentMonthTextColor:
          adjacentMonthTextColor ?? this.adjacentMonthTextColor,
      cellBorder: cellBorder ?? this.cellBorder,
      cellMargin: cellMargin ?? this.cellMargin,
      cellHeight: cellHeight ?? this.cellHeight,
      cellWidth: cellWidth ?? this.cellWidth,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
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

  /// Converts this cell theme to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'showBorder': showBorder,
      'showEnglishDate': showEnglishDate,
      'eventIndicatorColor': _colorToHex(eventIndicatorColor),
      'eventIndicatorSize': eventIndicatorSize,
      'englishDateColor': _colorToHex(englishDateColor),
      'todayBackgroundColor': _colorToHex(todayBackgroundColor),
      'selectionColor': _colorToHex(selectionColor),
      'weekendTextColor': _colorToHex(weekendTextColor),
      'cellHeight': cellHeight,
      'cellWidth': cellWidth,
      'shape': shape.name,
      if (todayTextColor != null)
        'todayTextColor': _colorToHex(todayTextColor!),
      if (selectedTextColor != null)
        'selectedTextColor': _colorToHex(selectedTextColor!),
      if (disabledTextColor != null)
        'disabledTextColor': _colorToHex(disabledTextColor!),
      if (weekendBackgroundColor != null)
        'weekendBackgroundColor': _colorToHex(weekendBackgroundColor!),
      'borderRadius': borderRadius,
    };
  }

  /// Creates a [CellTheme] from a JSON map.
  factory CellTheme.fromJson(Map<String, dynamic> json) {
    CellShape shape = CellShape.circle;
    if (json['shape'] != null) {
      final shapeStr = json['shape'] as String;
      shape = CellShape.values.firstWhere(
        (e) => e.name == shapeStr,
        orElse: () => CellShape.circle,
      );
    }

    return CellTheme(
      showBorder: json['showBorder'] as bool? ?? false,
      showEnglishDate: json['showEnglishDate'] as bool? ?? false,
      eventIndicatorColor: json['eventIndicatorColor'] != null
          ? _hexToColor(json['eventIndicatorColor'] as String)
          : Colors.blue,
      eventIndicatorSize:
          (json['eventIndicatorSize'] as num?)?.toDouble() ?? 4.0,
      englishDateColor: json['englishDateColor'] != null
          ? _hexToColor(json['englishDateColor'] as String)
          : Colors.grey,
      todayBackgroundColor: json['todayBackgroundColor'] != null
          ? _hexToColor(json['todayBackgroundColor'] as String)
          : Colors.green,
      todayTextColor: json['todayTextColor'] != null
          ? _hexToColor(json['todayTextColor'] as String)
          : null,
      selectionColor: json['selectionColor'] != null
          ? _hexToColor(json['selectionColor'] as String)
          : Colors.blue,
      selectedTextColor: json['selectedTextColor'] != null
          ? _hexToColor(json['selectedTextColor'] as String)
          : null,
      disabledTextColor: json['disabledTextColor'] != null
          ? _hexToColor(json['disabledTextColor'] as String)
          : null,
      weekendBackgroundColor: json['weekendBackgroundColor'] != null
          ? _hexToColor(json['weekendBackgroundColor'] as String)
          : null,
      weekendTextColor: json['weekendTextColor'] != null
          ? _hexToColor(json['weekendTextColor'] as String)
          // Support legacy 'weekdayTextColor' key for backward compatibility
          : json['weekdayTextColor'] != null
              ? _hexToColor(json['weekdayTextColor'] as String)
              : Colors.red,
      cellHeight: (json['cellHeight'] as num?)?.toDouble() ?? 40.0,
      cellWidth: (json['cellWidth'] as num?)?.toDouble() ?? 40.0,
      shape: shape,
      borderRadius: (json['borderRadius'] as num?)!.toDouble(),
    );
  }
}
