import 'package:flutter/material.dart';

import '../src.dart';

/// @Deprecated: Use HeaderTheme instead
@Deprecated(
  'Use HeaderTheme instead. This will be removed in the next major version.',
)
typedef HeaderStyle = HeaderTheme;

/// Comprehensive theme configuration for calendar headers.
///
/// This class provides extensive customization for all header elements,
/// including week names, month names, year display, and navigation controls.
class HeaderTheme {
  /// @Deprecated: Use weekdayTextStyle instead
  @Deprecated(
    'Use weekdayTextStyle instead. This will be removed in the next major version.',
  )
  TextStyle get weekHeaderStyle => weekdayTextStyle;

  /// @Deprecated: Use weekdayFormat instead
  @Deprecated(
    'Use weekdayFormat instead. This will be removed in the next major version.',
  )
  WeekdayFormat get weekTitleType => weekdayFormat;

  /// @Deprecated: Use monthTextStyle instead
  @Deprecated(
    'Use monthTextStyle instead. This will be removed in the next major version.',
  )
  TextStyle get monthHeaderStyle => monthTextStyle;

  /// @Deprecated: Use yearTextStyle instead
  @Deprecated(
    'Use yearTextStyle instead. This will be removed in the next major version.',
  )
  TextStyle get yearHeaderStyle => yearTextStyle;

  /// @Deprecated: Use WeekdayTheme.textStyle instead
  ///
  /// TextStyle for the weekday names in the calendar header.
  /// This property is deprecated. Use [WeekdayTheme.textStyle] for weekday label styling.
  @Deprecated(
    'Use WeekdayTheme.textStyle instead. This will be removed in the next major version.',
  )
  final TextStyle weekdayTextStyle;

  /// @Deprecated: Use WeekdayTheme.format instead
  ///
  /// Specifies the format for displaying weekday titles.
  /// This property is deprecated. Use [WeekdayTheme.format] for weekday format.
  @Deprecated(
    'Use WeekdayTheme.format instead. This will be removed in the next major version.',
  )
  final WeekdayFormat weekdayFormat;

  /// TextStyle for the month name displayed in the calendar header.
  ///
  /// Controls the appearance of the current month name (e.g., Baisakh, Jestha).
  final TextStyle monthTextStyle;

  /// TextStyle for the year displayed in the calendar header.
  ///
  /// Controls the appearance of the Nepali year number.
  final TextStyle yearTextStyle;

  /// Background color for the header section.
  ///
  /// Sets the background color of the entire header area.
  final Color? headerBackgroundColor;

  /// Height of the header section.
  ///
  /// Defines the fixed height for the header area. Default is 48.0.
  final double headerHeight;

  /// Padding for the header section.
  ///
  /// Controls the internal spacing of the header area.
  final EdgeInsets headerPadding;

  /// Color for navigation icons.
  ///
  /// Sets the color of previous/next month navigation icons.
  final Color? navigationIconColor;

  /// Size of navigation icons.
  ///
  /// Controls the size of navigation arrow icons. Default is 24.0.
  final double navigationIconSize;

  /// Whether to show navigation buttons.
  ///
  /// Controls visibility of month navigation controls. Default is true.
  final bool showNavigationButtons;

  /// Whether to show the year in the header.
  ///
  /// Controls visibility of the year display. Default is true.
  final bool showYear;

  /// Whether to show the month in the header.
  ///
  /// Controls visibility of the month display. Default is true.
  final bool showMonth;

  /// Separator between month and year text.
  ///
  /// The string used to separate month and year. Default is " ".
  final String monthYearSeparator;

  /// Border configuration for the header.
  ///
  /// Defines the border style for the header section.
  final Border? headerBorder;

  // Layout and transition properties

  /// Layout style for the header.
  ///
  /// Controls the arrangement and spacing of header elements.
  /// Default is [HeaderLayout.standard].
  final HeaderLayout layout;

  /// Custom widget for the leading position in the header.
  ///
  /// Typically used for a back button or menu icon.
  /// When null, the default navigation button is shown.
  final Widget? leading;

  /// Custom widget for the trailing position in the header.
  ///
  /// Typically used for action buttons or icons.
  /// When null, the default navigation button is shown.
  final Widget? trailing;

  /// Additional action widgets for the header.
  ///
  /// These widgets are displayed after the trailing widget.
  final List<Widget>? actions;

  /// Whether to enable fade transition for month changes.
  ///
  /// When true, month text fades in/out during transitions.
  /// Default is true.
  final bool enableFadeTransition;

  /// Duration for header transitions.
  ///
  /// Controls how long the fade transition takes.
  /// Default is 200 milliseconds.
  final Duration transitionDuration;

  /// Curve for header transitions.
  ///
  /// Controls the animation curve for fade transitions.
  /// Default is [Curves.easeInOut].
  final Curve transitionCurve;

  /// Text style for subtitle (English date) in the header.
  ///
  /// Used when displaying the English date below the Nepali date in the header.
  final TextStyle? subtitleTextStyle;

  /// Creates a [HeaderTheme] instance with comprehensive styling options.
  ///
  /// All parameters are optional and have default values.
  const HeaderTheme({
    this.weekdayFormat = WeekdayFormat.abbreviated,
    this.weekdayTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    this.monthTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    this.yearTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.headerBackgroundColor,
    this.headerHeight = 48.0,
    this.headerPadding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.navigationIconColor,
    this.navigationIconSize = 24.0,
    this.showNavigationButtons = true,
    this.showYear = true,
    this.showMonth = true,
    this.monthYearSeparator = " ",
    this.headerBorder,
    // Layout and transition properties
    this.layout = HeaderLayout.standard,
    this.leading,
    this.trailing,
    this.actions,
    this.enableFadeTransition = true,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionCurve = Curves.easeInOut,
    this.subtitleTextStyle,
  });

  /// Creates a copy of this theme with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newHeaderTheme = currentHeaderTheme.copyWith(
  ///   monthTextStyle: TextStyle(fontSize: 20, color: Colors.purple),
  /// );
  /// ```
  HeaderTheme copyWith({
    TextStyle? weekdayTextStyle,
    WeekdayFormat? weekdayFormat,
    TextStyle? monthTextStyle,
    TextStyle? yearTextStyle,
    Color? headerBackgroundColor,
    double? headerHeight,
    EdgeInsets? headerPadding,
    Color? navigationIconColor,
    double? navigationIconSize,
    bool? showNavigationButtons,
    bool? showYear,
    bool? showMonth,
    String? monthYearSeparator,
    Border? headerBorder,
    // Layout and transition properties
    HeaderLayout? layout,
    Widget? leading,
    Widget? trailing,
    List<Widget>? actions,
    bool? enableFadeTransition,
    Duration? transitionDuration,
    Curve? transitionCurve,
    TextStyle? subtitleTextStyle,
  }) {
    return HeaderTheme(
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      weekdayFormat: weekdayFormat ?? this.weekdayFormat,
      monthTextStyle: monthTextStyle ?? this.monthTextStyle,
      yearTextStyle: yearTextStyle ?? this.yearTextStyle,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerHeight: headerHeight ?? this.headerHeight,
      headerPadding: headerPadding ?? this.headerPadding,

      navigationIconColor: navigationIconColor ?? this.navigationIconColor,
      navigationIconSize: navigationIconSize ?? this.navigationIconSize,
      showNavigationButtons:
          showNavigationButtons ?? this.showNavigationButtons,
      showYear: showYear ?? this.showYear,
      showMonth: showMonth ?? this.showMonth,
      monthYearSeparator: monthYearSeparator ?? this.monthYearSeparator,
      headerBorder: headerBorder ?? this.headerBorder,
      // Layout and transition properties
      layout: layout ?? this.layout,
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      actions: actions ?? this.actions,
      enableFadeTransition: enableFadeTransition ?? this.enableFadeTransition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
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

  /// Converts this header theme to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'weekdayFormat': weekdayFormat.name,
      'headerHeight': headerHeight,
      'navigationIconSize': navigationIconSize,
      'showNavigationButtons': showNavigationButtons,
      'showYear': showYear,
      'showMonth': showMonth,
      'monthYearSeparator': monthYearSeparator,
      'layout': layout.name,
      'enableFadeTransition': enableFadeTransition,
      'transitionDuration': transitionDuration.inMilliseconds,
      if (headerBackgroundColor != null)
        'headerBackgroundColor': _colorToHex(headerBackgroundColor!),
      if (navigationIconColor != null)
        'navigationIconColor': _colorToHex(navigationIconColor!),
    };
  }

  /// Creates a [HeaderTheme] from a JSON map.
  factory HeaderTheme.fromJson(Map<String, dynamic> json) {
    WeekdayFormat weekdayFormat = WeekdayFormat.abbreviated;
    if (json['weekdayFormat'] != null) {
      final formatStr = json['weekdayFormat'] as String;
      weekdayFormat = WeekdayFormat.values.firstWhere(
        (e) => e.name == formatStr,
        orElse: () => WeekdayFormat.abbreviated,
      );
    }

    HeaderLayout layout = HeaderLayout.standard;
    if (json['layout'] != null) {
      final layoutStr = json['layout'] as String;
      layout = HeaderLayout.values.firstWhere(
        (e) => e.name == layoutStr,
        orElse: () => HeaderLayout.standard,
      );
    }

    return HeaderTheme(
      weekdayFormat: weekdayFormat,
      headerHeight: (json['headerHeight'] as num?)?.toDouble() ?? 48.0,
      navigationIconSize:
          (json['navigationIconSize'] as num?)?.toDouble() ?? 24.0,
      showNavigationButtons: json['showNavigationButtons'] as bool? ?? true,
      showYear: json['showYear'] as bool? ?? true,
      showMonth: json['showMonth'] as bool? ?? true,
      monthYearSeparator: json['monthYearSeparator'] as String? ?? ' ',
      layout: layout,
      enableFadeTransition: json['enableFadeTransition'] as bool? ?? true,
      transitionDuration: Duration(
        milliseconds: json['transitionDuration'] as int? ?? 200,
      ),
      headerBackgroundColor: json['headerBackgroundColor'] != null
          ? _hexToColor(json['headerBackgroundColor'] as String)
          : null,
      navigationIconColor: json['navigationIconColor'] != null
          ? _hexToColor(json['navigationIconColor'] as String)
          : null,
    );
  }
}
