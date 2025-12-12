import 'package:flutter/material.dart';

import '../src.dart';

/// @Deprecated: Use CalendarTheme instead
@Deprecated(
  'Use CalendarTheme instead. This will be removed in the next major version.',
)
typedef NepaliCalendarStyle = CalendarTheme;

/// A comprehensive theme configuration for the Nepali Calendar.
///
/// This class provides extensive customization options for the calendar appearance,
/// including date display, cell styling, header styling, and various visual properties.
///
/// Example usage:
/// ```dart
/// final theme = CalendarTheme(
///   displayEnglishDate: true,
///   cellTheme: CellTheme(
///     eventIndicatorColor: Colors.red,
///     selectionColor: Colors.blue,
///   ),
/// );
/// ```
class CalendarTheme {
  /// @Deprecated: Use cellTheme.showEnglishDate instead
  @Deprecated(
    'Use cellTheme.showEnglishDate instead. This will be removed in the next major version.',
  )
  bool get showEnglishDate => cellTheme.showEnglishDate;

  /// @Deprecated: Use cellTheme.showBorder instead
  @Deprecated(
    'Use cellTheme.showBorder instead. This will be removed in the next major version.',
  )
  bool get showBorder => cellTheme.showBorder;

  /// @Deprecated: Use locale instead
  @Deprecated(
    'Use locale instead. This will be removed in the next major version.',
  )
  CalendarLocale get language => locale;

  /// @Deprecated: Use cellTheme instead
  @Deprecated(
    'Use cellTheme instead. This will be removed in the next major version.',
  )
  CellTheme get cellsStyle => cellTheme;

  /// @Deprecated: Use headerTheme instead
  @Deprecated(
    'Use headerTheme instead. This will be removed in the next major version.',
  )
  HeaderTheme get headersStyle => headerTheme;

  /// Specifies the locale to be used for displaying calendar content.
  ///
  /// This determines whether the calendar uses Nepali or English text.
  final CalendarLocale locale;

  /// Theme configuration for calendar cells, including dates and selection indicators.
  ///
  /// Manages styles for individual date cells, today's date, selected dates,
  /// and event indicators.
  final CellTheme cellTheme;

  /// Theme configuration for calendar headers.
  ///
  /// Controls the appearance of week names, month names, and year display.
  final HeaderTheme headerTheme;

  /// Overall padding for the calendar widget.
  ///
  /// Defines the padding around the entire calendar. Default is EdgeInsets.all(8.0).
  final EdgeInsets calendarPadding;

  /// Background color for the entire calendar.
  ///
  /// Sets the background color of the calendar widget. Default is Colors.white.
  final Color backgroundColor;

  // New sub-theme properties

  /// Color scheme for the calendar.
  ///
  /// Provides semantic colors for all calendar states and elements.
  /// When null, default colors from individual themes are used.
  final CalendarColorScheme colorScheme;

  /// Spacing configuration for the calendar.
  ///
  /// Controls the spacing and padding throughout the calendar.
  final CalendarSpacing spacing;

  /// Border configuration for the calendar.
  ///
  /// Controls borders and dividers throughout the calendar.
  final CalendarBorders borders;

  /// Animation configuration for the calendar.
  ///
  /// Controls animation timing and curves for transitions.
  final CalendarAnimations animations;

  /// Theme configuration for weekday labels.
  ///
  /// Controls the appearance of the weekday labels row.
  final WeekdayTheme weekdayTheme;

  /// Creates a [CalendarTheme] instance with customizable styling options.
  ///
  /// All parameters are optional and have default values.
  /// Supports both new and deprecated parameter names for backward compatibility.
  ///
  /// **Deprecated parameters** (will be removed in next major version):
  /// - `displayEnglishDate` → Use `cellTheme.showEnglishDate` instead
  /// - `displayCellBorder` → Use `cellTheme.showBorder` instead
  /// - `showEnglishDate` → Use `cellTheme.showEnglishDate` instead
  /// - `showBorder` → Use `cellTheme.showBorder` instead
  /// - `language` → Use `locale` instead
  /// - `cellsStyle` → Use `cellTheme` instead
  /// - `headersStyle` → Use `headerTheme` instead
  CalendarTheme({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    this.calendarPadding = const EdgeInsets.all(8.0),
    this.backgroundColor = Colors.white,
    this.colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFFB00020),
      onError: Colors.white,
      disabled: Color(0xFF9E9E9E),
      weekend: Color(0xFFF44336),
      holiday: Color(0xFFE91E63),
      today: Color(0xFF4CAF50),
      selectedDate: Color(0xFF2196F3),
      rangeSelection: Color(0xFFBBDEFB),
    ),
    this.spacing = const CalendarSpacing(),
    this.borders = const CalendarBorders(),
    this.animations = const CalendarAnimations(),
    this.weekdayTheme = const WeekdayTheme(),
    @Deprecated(
      'Use cellTheme: CellTheme(showEnglishDate: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? showEnglishDate,
    @Deprecated(
      'Use cellTheme: CellTheme(showBorder: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? showBorder,
    @Deprecated(
      'Use locale instead. '
      'This parameter will be removed in the next major version.',
    )
    CalendarLocale? language,
    @Deprecated(
      'Use cellTheme instead. '
      'This parameter will be removed in the next major version.',
    )
    CellTheme? cellsStyle,
    @Deprecated(
      'Use headerTheme instead. '
      'This parameter will be removed in the next major version.',
    )
    HeaderTheme? headersStyle,
  })  : locale = locale ?? language ?? CalendarLocale.nepali,
        headerTheme = headerTheme ?? headersStyle ?? const HeaderTheme(),
        cellTheme = _buildCellTheme(
          cellTheme: cellTheme ?? cellsStyle,
          showEnglishDate: showEnglishDate,
          showBorder: showBorder,
        );

  /// Helper to build CellTheme with deprecated parameter support.
  static CellTheme _buildCellTheme({
    CellTheme? cellTheme,
    bool? showEnglishDate,
    bool? showBorder,
  }) {
    final base = cellTheme ?? const CellTheme();
    if (showEnglishDate == null && showBorder == null) {
      return base;
    }
    return base.copyWith(
      showEnglishDate: showEnglishDate ?? base.showEnglishDate,
      showBorder: showBorder ?? base.showBorder,
    );
  }

  /// Creates a const [CalendarTheme] with default values.
  ///
  /// Use this when you need a const theme without deprecated parameters.
  const CalendarTheme.defaults({
    this.locale = CalendarLocale.nepali,
    this.cellTheme = const CellTheme(),
    this.headerTheme = const HeaderTheme(),
    this.calendarPadding = const EdgeInsets.all(8.0),
    this.backgroundColor = Colors.white,
    this.colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFFB00020),
      onError: Colors.white,
      disabled: Color(0xFF9E9E9E),
      weekend: Color(0xFFF44336),
      holiday: Color(0xFFE91E63),
      today: Color(0xFF4CAF50),
      selectedDate: Color(0xFF2196F3),
      rangeSelection: Color(0xFFBBDEFB),
    ),
    this.spacing = const CalendarSpacing(),
    this.borders = const CalendarBorders(),
    this.animations = const CalendarAnimations(),
    this.weekdayTheme = const WeekdayTheme(),
  });

  /// @Deprecated: Use CalendarTheme() constructor directly.
  ///
  /// This factory was created for migration but is no longer needed
  /// since the main constructor now supports deprecated parameters.
  @Deprecated(
    'Use CalendarTheme() constructor directly. '
    'This factory will be removed in the next major version.',
  )
  factory CalendarTheme.withDeprecatedParams({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    EdgeInsets calendarPadding = const EdgeInsets.all(8.0),
    Color backgroundColor = Colors.white,
    CalendarColorScheme colorScheme = const CalendarColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFFB00020),
      onError: Colors.white,
      disabled: Color(0xFF9E9E9E),
      weekend: Color(0xFFF44336),
      holiday: Color(0xFFE91E63),
      today: Color(0xFF4CAF50),
      selectedDate: Color(0xFF2196F3),
      rangeSelection: Color(0xFFBBDEFB),
    ),
    CalendarSpacing spacing = const CalendarSpacing(),
    CalendarBorders borders = const CalendarBorders(),
    CalendarAnimations animations = const CalendarAnimations(),
    WeekdayTheme weekdayTheme = const WeekdayTheme(),
    @Deprecated('Use cellTheme.showEnglishDate instead') bool? showEnglishDate,
    @Deprecated('Use cellTheme.showBorder instead') bool? showBorder,
    @Deprecated('Use locale instead') CalendarLocale? language,
    @Deprecated('Use cellTheme instead') CellTheme? cellsStyle,
    @Deprecated('Use headerTheme instead') HeaderTheme? headersStyle,
  }) {
    return CalendarTheme(
      locale: locale,
      cellTheme: cellTheme,
      headerTheme: headerTheme,
      calendarPadding: calendarPadding,
      backgroundColor: backgroundColor,
      colorScheme: colorScheme,
      spacing: spacing,
      borders: borders,
      animations: animations,
      weekdayTheme: weekdayTheme,
      showEnglishDate: showEnglishDate,
      showBorder: showBorder,
      language: language,
      cellsStyle: cellsStyle,
      headersStyle: headersStyle,
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  ///
  /// Example:
  /// ```dart
  /// final newTheme = currentTheme.copyWith(
  ///   cellTheme: CellTheme(showEnglishDate: true),
  /// );
  /// ```
  ///
  /// **Deprecated parameters** (will be removed in next major version):
  /// - `displayEnglishDate` → Use `cellTheme: CellTheme(showEnglishDate: true)` instead
  /// - `displayCellBorder` → Use `cellTheme: CellTheme(showBorder: true)` instead
  CalendarTheme copyWith({
    CalendarLocale? locale,
    CellTheme? cellTheme,
    HeaderTheme? headerTheme,
    EdgeInsets? calendarPadding,
    Color? backgroundColor,
    // New sub-theme properties
    CalendarColorScheme? colorScheme,
    CalendarSpacing? spacing,
    CalendarBorders? borders,
    CalendarAnimations? animations,
    WeekdayTheme? weekdayTheme,
    // Deprecated parameters - kept for backward compatibility
    @Deprecated(
      'Use cellTheme: CellTheme(showEnglishDate: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? displayEnglishDate,
    @Deprecated(
      'Use cellTheme: CellTheme(showBorder: true) instead. '
      'This parameter will be removed in the next major version.',
    )
    bool? displayCellBorder,
  }) {
    // Handle deprecated parameters by merging with cellTheme
    CellTheme resolvedCellTheme = cellTheme ?? this.cellTheme;
    if (displayEnglishDate != null || displayCellBorder != null) {
      resolvedCellTheme = resolvedCellTheme.copyWith(
        showEnglishDate:
            displayEnglishDate ?? resolvedCellTheme.showEnglishDate,
        showBorder: displayCellBorder ?? resolvedCellTheme.showBorder,
      );
    }

    return CalendarTheme(
      locale: locale ?? this.locale,
      cellTheme: resolvedCellTheme,
      headerTheme: headerTheme ?? this.headerTheme,
      calendarPadding: calendarPadding ?? this.calendarPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      // New sub-theme properties
      colorScheme: colorScheme ?? this.colorScheme,
      spacing: spacing ?? this.spacing,
      borders: borders ?? this.borders,
      animations: animations ?? this.animations,
      weekdayTheme: weekdayTheme ?? this.weekdayTheme,
    );
  }

  /// Creates a fully configured light theme.
  ///
  /// Returns a [CalendarTheme] with coordinated light sub-themes
  /// suitable for light mode applications.
  ///
  /// Example:
  /// ```dart
  /// final lightTheme = CalendarTheme.light();
  /// ```
  factory CalendarTheme.light() {
    final colorScheme = CalendarColorScheme.light();
    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        selectionColor: colorScheme.selectedDate,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        yearTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        weekendTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
    );
  }

  /// Creates a fully configured dark theme.
  ///
  /// Returns a [CalendarTheme] with coordinated dark sub-themes
  /// suitable for dark mode applications.
  ///
  /// Example:
  /// ```dart
  /// final darkTheme = CalendarTheme.dark();
  /// ```
  factory CalendarTheme.dark() {
    final colorScheme = CalendarColorScheme.dark();
    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        selectionColor: colorScheme.selectedDate,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
        defaultTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        yearTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        weekendTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
    );
  }

  /// Creates a theme from a Material [ThemeData].
  ///
  /// Extracts colors and styles from the provided Material theme
  /// to create a consistent calendar theme.
  ///
  /// Example:
  /// ```dart
  /// final theme = CalendarTheme.fromMaterialTheme(Theme.of(context));
  /// ```
  factory CalendarTheme.fromMaterialTheme(ThemeData theme) {
    final colorScheme = CalendarColorScheme.fromMaterialTheme(theme);
    final isDark = theme.brightness == Brightness.dark;

    return CalendarTheme(
      locale: CalendarLocale.nepali,
      backgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      cellTheme: CellTheme(
        todayBackgroundColor: colorScheme.today,
        selectionColor: colorScheme.selectedDate,
        weekendTextColor: colorScheme.weekend,
        englishDateColor: colorScheme.disabled,
        defaultTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      ),
      headerTheme: HeaderTheme(
        monthTextStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
        yearTextStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
        headerBackgroundColor: isDark ? colorScheme.surface : null,
      ),
      weekdayTheme: WeekdayTheme(
        textStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.weekend,
        ),
      ),
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

  /// Converts this calendar theme to a JSON map.
  ///
  /// Aggregates all sub-theme configurations into a single JSON structure.
  Map<String, dynamic> toJson() {
    return {
      'locale': locale.name,
      'backgroundColor': _colorToHex(backgroundColor),
      'colorScheme': colorScheme.toJson(),
      'spacing': spacing.toJson(),
      'borders': borders.toJson(),
      'animations': animations.toJson(),
      'cellTheme': cellTheme.toJson(),
      'headerTheme': headerTheme.toJson(),
      'weekdayTheme': weekdayTheme.toJson(),
    };
  }

  /// Creates a [CalendarTheme] from a JSON map.
  ///
  /// Uses default values for any missing properties.
  factory CalendarTheme.fromJson(Map<String, dynamic> json) {
    CalendarLocale locale = CalendarLocale.nepali;
    if (json['locale'] != null) {
      final localeStr = json['locale'] as String;
      locale = CalendarLocale.values.firstWhere(
        (e) => e.name == localeStr,
        orElse: () => CalendarLocale.nepali,
      );
    }

    // Parse cellTheme first, then apply legacy displayEnglishDate/displayCellBorder if present
    CellTheme cellTheme = json['cellTheme'] != null
        ? CellTheme.fromJson(json['cellTheme'] as Map<String, dynamic>)
        : const CellTheme();

    // Support legacy JSON keys for backward compatibility
    final legacyShowEnglishDate = json['displayEnglishDate'] as bool?;
    final legacyShowBorder = json['displayCellBorder'] as bool?;
    if (legacyShowEnglishDate != null || legacyShowBorder != null) {
      cellTheme = cellTheme.copyWith(
        showEnglishDate: legacyShowEnglishDate ?? cellTheme.showEnglishDate,
        showBorder: legacyShowBorder ?? cellTheme.showBorder,
      );
    }

    return CalendarTheme(
      locale: locale,
      backgroundColor: json['backgroundColor'] != null
          ? _hexToColor(json['backgroundColor'] as String)
          : Colors.white,
      colorScheme: json['colorScheme'] != null
          ? CalendarColorScheme.fromJson(
              json['colorScheme'] as Map<String, dynamic>,
            )
          : CalendarColorScheme.light(),
      spacing: json['spacing'] != null
          ? CalendarSpacing.fromJson(json['spacing'] as Map<String, dynamic>)
          : const CalendarSpacing(),
      borders: json['borders'] != null
          ? CalendarBorders.fromJson(json['borders'] as Map<String, dynamic>)
          : const CalendarBorders(),
      animations: json['animations'] != null
          ? CalendarAnimations.fromJson(
              json['animations'] as Map<String, dynamic>,
            )
          : const CalendarAnimations(),
      cellTheme: cellTheme,
      headerTheme: json['headerTheme'] != null
          ? HeaderTheme.fromJson(json['headerTheme'] as Map<String, dynamic>)
          : const HeaderTheme(),
      weekdayTheme: json['weekdayTheme'] != null
          ? WeekdayTheme.fromJson(json['weekdayTheme'] as Map<String, dynamic>)
          : const WeekdayTheme(),
    );
  }
}

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

  /// Position of the event indicator relative to the date.
  ///
  /// Can be bottom, top, or overlay. Default is bottom.
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

  /// Background color for hovered date.
  ///
  /// Applied when hovering over a date (desktop/web).
  final Color? hoverColor;

  /// Background color for disabled dates.
  ///
  /// Applied to dates that cannot be selected.
  final Color? disabledBackgroundColor;

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

  /// Border configuration for cells.
  ///
  /// Defines the border style for date cells.
  final Border? cellBorder;

  /// Padding inside each cell.
  ///
  /// Controls the internal spacing of date cells.
  final EdgeInsets cellPadding;

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
    this.hoverColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.weekendBackgroundColor,
    this.weekendTextColor = Colors.red,
    this.cellBorder,
    this.cellPadding = const EdgeInsets.all(4.0),
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
    Border? cellBorder,
    EdgeInsets? cellPadding,
    EdgeInsets? cellMargin,
    double? cellHeight,
    double? cellWidth,
    CellShape? shape,
    double? borderRadius,
  }) {
    return CellTheme(
      showBorder: showBorder ?? this.showBorder,
      showEnglishDate: showEnglishDate ?? this.showEnglishDate,
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
      hoverColor: hoverColor ?? this.hoverColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      weekendBackgroundColor:
          weekendBackgroundColor ?? this.weekendBackgroundColor,
      weekendTextColor: weekendTextColor ?? this.weekendTextColor,
      cellBorder: cellBorder ?? this.cellBorder,
      cellPadding: cellPadding ?? this.cellPadding,
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
      if (hoverColor != null) 'hoverColor': _colorToHex(hoverColor!),
      if (disabledBackgroundColor != null)
        'disabledBackgroundColor': _colorToHex(disabledBackgroundColor!),
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
      hoverColor: json['hoverColor'] != null
          ? _hexToColor(json['hoverColor'] as String)
          : null,
      disabledBackgroundColor: json['disabledBackgroundColor'] != null
          ? _hexToColor(json['disabledBackgroundColor'] as String)
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

  /// TextStyle for navigation buttons (previous/next month).
  ///
  /// Controls the appearance of navigation arrows or buttons.
  final TextStyle? navigationButtonTextStyle;

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

  /// Alignment of the month/year text in the header.
  ///
  /// Controls the positioning of the month and year text.
  final AlignmentGeometry headerTextAlignment;

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
    this.navigationButtonTextStyle,
    this.navigationIconColor,
    this.navigationIconSize = 24.0,
    this.showNavigationButtons = true,
    this.headerTextAlignment = Alignment.center,
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
    TextStyle? navigationButtonTextStyle,
    Color? navigationIconColor,
    double? navigationIconSize,
    bool? showNavigationButtons,
    AlignmentGeometry? headerTextAlignment,
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
      navigationButtonTextStyle:
          navigationButtonTextStyle ?? this.navigationButtonTextStyle,
      navigationIconColor: navigationIconColor ?? this.navigationIconColor,
      navigationIconSize: navigationIconSize ?? this.navigationIconSize,
      showNavigationButtons:
          showNavigationButtons ?? this.showNavigationButtons,
      headerTextAlignment: headerTextAlignment ?? this.headerTextAlignment,
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
