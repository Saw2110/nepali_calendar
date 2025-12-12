/// Enums for the calendar theme system.
///
/// This library provides enums for configuring calendar cell shapes,
/// header layouts, week start days, and weekend configurations.
library;

/// Shape options for calendar cells.
///
/// This enum defines the available shapes for rendering calendar date cells.
/// The shape affects how selection highlights and decorations are displayed.
enum CellShape {
  /// Circular cell shape.
  ///
  /// Creates a perfectly round selection indicator.
  /// Best suited for compact calendar layouts.
  circle,

  /// Rounded square cell shape.
  ///
  /// Creates a square with rounded corners.
  /// The corner radius can be customized via [CellTheme.borderRadius].
  roundedSquare,

  /// Square cell shape.
  ///
  /// Creates a square selection indicator with sharp corners.
  /// Best suited for grid-style calendar layouts.
  square,
}

/// Layout options for calendar header.
///
/// This enum defines the available layout styles for the calendar header,
/// controlling the arrangement and spacing of header elements.
enum HeaderLayout {
  /// Standard header layout.
  ///
  /// Default layout with balanced spacing between elements.
  standard,

  /// Compact header layout.
  ///
  /// Reduced height and tighter spacing for space-constrained UIs.
  compact,

  /// Expanded header layout.
  ///
  /// Additional vertical space and larger touch targets.
  /// Suitable for accessibility-focused designs.
  expanded,
}

/// Specifies which day the week starts on.
///
/// This enum allows configuring the first day of the week in calendar displays.
/// Different regions have different conventions for week start days.
enum WeekStart {
  /// Week starts on Sunday (common in Nepal, USA, etc.)
  ///
  /// Display order: Sun, Mon, Tue, Wed, Thu, Fri, Sat
  sunday,

  /// Week starts on Monday (common in Europe, ISO 8601 standard)
  ///
  /// Display order: Mon, Tue, Wed, Thu, Fri, Sat, Sun
  monday,

  /// Week starts on Tuesday
  ///
  /// Display order: Tue, Wed, Thu, Fri, Sat, Sun, Mon
  tuesday,

  /// Week starts on Wednesday
  ///
  /// Display order: Wed, Thu, Fri, Sat, Sun, Mon, Tue
  wednesday,

  /// Week starts on Thursday
  ///
  /// Display order: Thu, Fri, Sat, Sun, Mon, Tue, Wed
  thursday,

  /// Week starts on Friday
  ///
  /// Display order: Fri, Sat, Sun, Mon, Tue, Wed, Thu
  friday,

  /// Week starts on Saturday (common in some Middle Eastern countries)
  ///
  /// Display order: Sat, Sun, Mon, Tue, Wed, Thu, Fri
  saturday,
}

/// Specifies which days are considered weekends.
///
/// This enum allows configuring weekend days for proper styling
/// and potentially for business logic (e.g., disabling weekend selection).
enum Weekend {
  /// Only Saturday is a weekend day.
  ///
  /// Common in Nepal and some other countries.
  saturday,

  /// Only Sunday is a weekend day.
  sunday,

  /// Only Friday is a weekend day.
  friday,

  /// Saturday and Sunday are weekend days.
  ///
  /// Common in most Western countries.
  saturdayAndSunday,

  /// Friday and Saturday are weekend days.
  ///
  /// Common in some Middle Eastern countries.
  fridayAndSaturday,

  /// No weekend days.
  none,
}

/// Extension methods for [WeekStart] enum.
extension WeekStartExtension on WeekStart {
  /// Returns the weekday order starting from this day.
  ///
  /// Returns a list of 7 integers representing weekday indices (0-6),
  /// where 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
  List<int> get weekdayOrder {
    // Standard order: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
    final startIndex = index; // sunday=0, monday=1, ..., saturday=6
    return List.generate(7, (i) => (startIndex + i) % 7);
  }

  /// Returns the offset needed to calculate the first day position in a month grid.
  ///
  /// Given a weekday (1=Sunday, 2=Monday, ..., 7=Saturday from NepaliDateTime),
  /// returns the column position (0-6) in the calendar grid.
  int getGridOffset(int weekday) {
    // NepaliDateTime.weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
    // Convert to 0-based: 0=Sunday, 1=Monday, ..., 6=Saturday
    final dayIndex = weekday == 7 ? 6 : weekday - 1;
    // Calculate offset based on week start
    return (dayIndex - index + 7) % 7;
  }
}

/// Extension methods for [Weekend] enum.
extension WeekendExtension on Weekend {
  /// Checks if the given weekday is a weekend day.
  ///
  /// [weekday] should be from NepaliDateTime.weekday which is (DateTime.weekday + 1):
  /// - 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday, 8=Sunday
  /// Note: Sunday wraps to 1 when DateTime.weekday is 7 (7+1=8, but some implementations use 1)
  bool isWeekend(int weekday) {
    // NepaliDateTime.weekday = DateTime.weekday + 1
    // DateTime: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    // NepaliDateTime: 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat, 8=Sun (or 1 if wrapped)
    //
    // Convert to 0-based index where 0=Sunday, 6=Saturday
    int dayIndex;
    if (weekday == 8 || weekday == 1) {
      dayIndex = 0; // Sunday
    } else {
      // weekday 2-7 maps to Monday-Saturday (index 1-6)
      dayIndex = weekday - 1;
    }

    switch (this) {
      case Weekend.saturday:
        return dayIndex == 6; // Saturday
      case Weekend.sunday:
        return dayIndex == 0; // Sunday
      case Weekend.friday:
        return dayIndex == 5; // Friday
      case Weekend.saturdayAndSunday:
        return dayIndex == 0 || dayIndex == 6; // Sunday or Saturday
      case Weekend.fridayAndSaturday:
        return dayIndex == 5 || dayIndex == 6; // Friday or Saturday
      case Weekend.none:
        return false;
    }
  }

  /// Returns the list of weekend day indices (0=Sunday, ..., 6=Saturday).
  List<int> get weekendDays {
    switch (this) {
      case Weekend.saturday:
        return [6];
      case Weekend.sunday:
        return [0];
      case Weekend.friday:
        return [5];
      case Weekend.saturdayAndSunday:
        return [0, 6];
      case Weekend.fridayAndSaturday:
        return [5, 6];
      case Weekend.none:
        return [];
    }
  }
}
