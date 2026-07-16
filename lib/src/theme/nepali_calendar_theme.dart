import 'package:flutter/material.dart';

import '../src.dart';

/// Colours and typography for the Nepali calendar widgets.
///
/// Supply this through a [NepaliCalendarTheme] to style every calendar widget
/// beneath it at once, including in dark mode:
///
/// ```dart
/// NepaliCalendarTheme(
///   data: NepaliCalendarThemeData.dark(),
///   child: NepaliCalendar(),
/// )
/// ```
///
/// Most apps should use [NepaliCalendarThemeData.fromContext], which derives
/// the palette from the ambient Material [ColorScheme] and so follows the
/// app's light/dark mode automatically:
///
/// ```dart
/// NepaliCalendarTheme(
///   data: NepaliCalendarThemeData.fromContext(context),
///   child: NepaliCalendar(),
/// )
/// ```
///
/// ## Relationship to [NepaliCalendarStyle]
///
/// [NepaliCalendarStyle] takes precedence when it is passed explicitly to a
/// widget. A theme only applies where no explicit style was given, so adding a
/// theme never changes the appearance of a widget that was already styled by
/// hand. See [NepaliCalendarTheme] for the full resolution order.
@immutable
class NepaliCalendarThemeData {
  /// Background colour of today's cell.
  final Color todayColor;

  /// Background colour of the selected cell.
  final Color selectedColor;

  /// Text colour for weekend days, and for holiday event indicators.
  final Color weekendColor;

  /// Colour of the indicator dot on dates that have events.
  final Color eventDotColor;

  /// Text colour for ordinary dates.
  final Color dateTextColor;

  /// Text colour used on top of the [todayColor] and [selectedColor]
  /// highlights. Must contrast with both.
  final Color onHighlightColor;

  /// Text colour for dates from the previous or next month.
  final Color dimmedDateTextColor;

  /// Text colour for the small English date shown when `showEnglishDate` is
  /// enabled.
  final Color englishDateColor;

  /// Colour of the cell borders drawn when `showBorder` is enabled.
  final Color borderColor;

  /// Text style for the date numbers.
  final TextStyle dayStyle;

  /// Text style for the weekday names above the grid.
  final TextStyle weekHeaderStyle;

  /// Text style for the month name in the header.
  final TextStyle monthHeaderStyle;

  /// Text style for the year in the header.
  final TextStyle yearHeaderStyle;

  const NepaliCalendarThemeData({
    required this.todayColor,
    required this.selectedColor,
    required this.weekendColor,
    required this.eventDotColor,
    required this.dateTextColor,
    required this.onHighlightColor,
    required this.dimmedDateTextColor,
    required this.englishDateColor,
    required this.borderColor,
    required this.dayStyle,
    required this.weekHeaderStyle,
    required this.monthHeaderStyle,
    required this.yearHeaderStyle,
  });

  /// The palette used by every version up to 0.0.8, when no theme was
  /// involved.
  ///
  /// Useful as a starting point for a custom light theme, or to opt a subtree
  /// back into the original look.
  factory NepaliCalendarThemeData.legacy() {
    const cells = CellStyle();
    const headers = HeaderStyle();

    return NepaliCalendarThemeData(
      todayColor: cells.todayColor,
      selectedColor: cells.selectedColor,
      weekendColor: cells.weekDayColor,
      eventDotColor: cells.dotColor,
      dateTextColor: cells.dateTextColor,
      onHighlightColor: cells.onHighlightColor,
      dimmedDateTextColor: cells.dimmedDateTextColor,
      englishDateColor: cells.baseLineDateColor,
      borderColor: cells.borderColor,
      dayStyle: cells.dayStyle,
      weekHeaderStyle: headers.weekHeaderStyle,
      monthHeaderStyle: headers.monthHeaderStyle,
      yearHeaderStyle: headers.yearHeaderStyle,
    );
  }

  /// A light theme.
  ///
  /// Pass a [ColorScheme] to tie the calendar to your own palette; otherwise a
  /// sensible light default is used.
  factory NepaliCalendarThemeData.light({ColorScheme? colorScheme}) {
    return NepaliCalendarThemeData.fromColorScheme(
      colorScheme ?? ColorScheme.fromSeed(seedColor: Colors.blue),
    );
  }

  /// A dark theme.
  ///
  /// Pass a [ColorScheme] to tie the calendar to your own palette; otherwise a
  /// sensible dark default is used.
  factory NepaliCalendarThemeData.dark({ColorScheme? colorScheme}) {
    return NepaliCalendarThemeData.fromColorScheme(
      colorScheme ??
          ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
    );
  }

  /// Derives a theme from the ambient Material theme.
  ///
  /// This is usually what you want: the calendar then follows your app's
  /// light/dark mode and colour scheme with no further configuration.
  factory NepaliCalendarThemeData.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    return NepaliCalendarThemeData.fromColorScheme(
      theme.colorScheme,
      textTheme: theme.textTheme,
    );
  }

  /// Derives a theme from a [ColorScheme], and optionally a [TextTheme].
  factory NepaliCalendarThemeData.fromColorScheme(
    ColorScheme colorScheme, {
    TextTheme? textTheme,
  }) {
    final onSurface = colorScheme.onSurface;

    return NepaliCalendarThemeData(
      todayColor: colorScheme.primary,
      selectedColor: colorScheme.primary,
      weekendColor: colorScheme.error,
      eventDotColor: colorScheme.primary,
      dateTextColor: onSurface,
      // Sits on top of todayColor/selectedColor, both of which are `primary`.
      onHighlightColor: colorScheme.onPrimary,
      dimmedDateTextColor: onSurface.withValues(alpha: 0.5),
      englishDateColor: onSurface.withValues(alpha: 0.6),
      borderColor: colorScheme.outlineVariant,
      dayStyle: textTheme?.bodyMedium ??
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      weekHeaderStyle: (textTheme?.labelLarge ??
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
          .copyWith(color: onSurface.withValues(alpha: 0.8)),
      monthHeaderStyle: (textTheme?.titleMedium ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          .copyWith(color: onSurface),
      yearHeaderStyle: (textTheme?.titleLarge ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          .copyWith(color: onSurface),
    );
  }

  /// Projects this theme onto a [NepaliCalendarStyle], preserving [config].
  ///
  /// Every widget renders from a [NepaliCalendarStyle], so this is how a theme
  /// reaches them.
  NepaliCalendarStyle toStyle({CalendarConfig? config}) {
    return NepaliCalendarStyle(
      config: config,
      cellsStyle: CellStyle(
        dayStyle: dayStyle,
        dotColor: eventDotColor,
        baseLineDateColor: englishDateColor,
        todayColor: todayColor,
        selectedColor: selectedColor,
        weekDayColor: weekendColor,
        dateTextColor: dateTextColor,
        onHighlightColor: onHighlightColor,
        dimmedDateTextColor: dimmedDateTextColor,
        borderColor: borderColor,
      ),
      headersStyle: HeaderStyle(
        weekHeaderStyle: weekHeaderStyle,
        monthHeaderStyle: monthHeaderStyle,
        yearHeaderStyle: yearHeaderStyle,
      ),
    );
  }

  NepaliCalendarThemeData copyWith({
    Color? todayColor,
    Color? selectedColor,
    Color? weekendColor,
    Color? eventDotColor,
    Color? dateTextColor,
    Color? onHighlightColor,
    Color? dimmedDateTextColor,
    Color? englishDateColor,
    Color? borderColor,
    TextStyle? dayStyle,
    TextStyle? weekHeaderStyle,
    TextStyle? monthHeaderStyle,
    TextStyle? yearHeaderStyle,
  }) {
    return NepaliCalendarThemeData(
      todayColor: todayColor ?? this.todayColor,
      selectedColor: selectedColor ?? this.selectedColor,
      weekendColor: weekendColor ?? this.weekendColor,
      eventDotColor: eventDotColor ?? this.eventDotColor,
      dateTextColor: dateTextColor ?? this.dateTextColor,
      onHighlightColor: onHighlightColor ?? this.onHighlightColor,
      dimmedDateTextColor: dimmedDateTextColor ?? this.dimmedDateTextColor,
      englishDateColor: englishDateColor ?? this.englishDateColor,
      borderColor: borderColor ?? this.borderColor,
      dayStyle: dayStyle ?? this.dayStyle,
      weekHeaderStyle: weekHeaderStyle ?? this.weekHeaderStyle,
      monthHeaderStyle: monthHeaderStyle ?? this.monthHeaderStyle,
      yearHeaderStyle: yearHeaderStyle ?? this.yearHeaderStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NepaliCalendarThemeData &&
        other.todayColor == todayColor &&
        other.selectedColor == selectedColor &&
        other.weekendColor == weekendColor &&
        other.eventDotColor == eventDotColor &&
        other.dateTextColor == dateTextColor &&
        other.onHighlightColor == onHighlightColor &&
        other.dimmedDateTextColor == dimmedDateTextColor &&
        other.englishDateColor == englishDateColor &&
        other.borderColor == borderColor &&
        other.dayStyle == dayStyle &&
        other.weekHeaderStyle == weekHeaderStyle &&
        other.monthHeaderStyle == monthHeaderStyle &&
        other.yearHeaderStyle == yearHeaderStyle;
  }

  @override
  int get hashCode => Object.hash(
        todayColor,
        selectedColor,
        weekendColor,
        eventDotColor,
        dateTextColor,
        onHighlightColor,
        dimmedDateTextColor,
        englishDateColor,
        borderColor,
        dayStyle,
        weekHeaderStyle,
        monthHeaderStyle,
        yearHeaderStyle,
      );
}

/// Applies a [NepaliCalendarThemeData] to the calendar widgets beneath it.
///
/// ```dart
/// NepaliCalendarTheme(
///   data: NepaliCalendarThemeData.fromContext(context),
///   child: NepaliCalendar(),
/// )
/// ```
///
/// ## Where to put it
///
/// For app-wide theming, place it **above the Navigator** -- most simply in
/// `MaterialApp.builder`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => NepaliCalendarTheme(
///     data: NepaliCalendarThemeData.fromContext(context),
///     child: child!,
///   ),
///   home: const HomePage(),
/// )
/// ```
///
/// Placed inside `home:` instead, it covers that subtree and any dialog opened
/// from it -- including [showNepaliDatePicker], because Flutter captures
/// [InheritedTheme]s across a dialog boundary -- but **not** a route pushed
/// with `Navigator.push`, since the new route is a sibling under the Navigator
/// rather than a descendant of `home:`. That is ordinary Flutter behaviour and
/// applies to Material's own `Theme` in the same position.
///
/// ## Resolution order
///
/// Each widget picks its style as follows, first match winning:
///
/// 1. an explicit `calendarStyle` passed to the widget;
/// 2. the nearest enclosing [NepaliCalendarTheme];
/// 3. the built-in defaults used by every version up to 0.0.8.
///
/// Theming is therefore opt-in and additive. A widget that already passes
/// `calendarStyle` is untouched by a theme, and a widget with neither looks
/// exactly as it did before this class existed.
///
/// The reason an explicit style wins outright, rather than merging field by
/// field with the theme, is that [CellStyle]'s fields are non-nullable with
/// const defaults: there is no way to tell a colour the caller chose from one
/// that merely defaulted. To combine a theme with a tweak, use
/// [NepaliCalendarThemeData.copyWith] rather than passing a style:
///
/// ```dart
/// NepaliCalendarTheme(
///   data: NepaliCalendarThemeData.fromContext(context)
///       .copyWith(todayColor: Colors.orange),
///   child: NepaliCalendar(),
/// )
/// ```
/// It extends [InheritedTheme] rather than [InheritedWidget] so that it
/// survives a route boundary. `showDialog` and friends insert their content
/// into the Navigator's overlay, whose ancestors are the Navigator and the app
/// -- not whatever sits in `home:`. A plain InheritedWidget placed there would
/// be invisible to [showNepaliDatePicker]. Flutter captures and re-injects
/// [InheritedTheme]s across that boundary, so being one is what lets a theme
/// declared anywhere above the call site reach a dialog.
class NepaliCalendarTheme extends InheritedTheme {
  /// The colours and typography to apply.
  final NepaliCalendarThemeData data;

  const NepaliCalendarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NepaliCalendarTheme(data: data, child: child);
  }

  /// The nearest enclosing theme, or `null` if there is none.
  static NepaliCalendarThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NepaliCalendarTheme>()
        ?.data;
  }

  /// The nearest enclosing theme, falling back to the legacy palette.
  ///
  /// Prefer [maybeOf] when you need to know whether a theme was actually
  /// provided.
  static NepaliCalendarThemeData of(BuildContext context) {
    return maybeOf(context) ?? NepaliCalendarThemeData.legacy();
  }

  /// Resolves the style a widget should render with.
  ///
  /// Applies the order documented on [NepaliCalendarTheme]. [style] is the
  /// value passed to the widget.
  ///
  /// Only the *appearance* of a style suppresses the theme. Configuration --
  /// language, weekend days, week start, whether to show English dates -- is
  /// behaviour rather than appearance, so it is carried across and a caller
  /// who passes a style purely to set the language still gets themed colours.
  static NepaliCalendarStyle resolve(
    BuildContext context,
    NepaliCalendarStyle? style,
  ) {
    final theme = maybeOf(context);
    final effective = style ?? const NepaliCalendarStyle();

    // No theme in the tree: render exactly as before this class existed.
    if (theme == null) return effective;

    // A style whose appearance was customised wins outright.
    //
    // The identity check works because the defaults are canonical const
    // instances: an untouched style holds the very same object. There is no
    // finer-grained test available -- CellStyle's fields are non-nullable with
    // const defaults, so a colour the caller chose is indistinguishable from
    // one that merely defaulted.
    final hasCustomAppearance =
        !identical(effective.cellsStyle, const CellStyle()) ||
            !identical(effective.headersStyle, const HeaderStyle());
    if (hasCustomAppearance) return effective;

    // `effectiveConfig` rather than `config`, so the deprecated top-level
    // properties (showEnglishDate, showBorder, language) survive the switch to
    // a themed style. Reading `config` alone would silently drop them.
    return theme.toStyle(config: effective.effectiveConfig);
  }

  @override
  bool updateShouldNotify(NepaliCalendarTheme oldWidget) =>
      data != oldWidget.data;
}
