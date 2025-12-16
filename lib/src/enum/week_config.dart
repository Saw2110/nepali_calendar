/// Specifies the weekend days for calendar configuration.
///
/// This enum is used to determine which days are considered weekend days
/// in the calendar. Different regions and cultures have different weekend
/// conventions.
enum WeekendType {
  /// Saturday and Sunday are weekend days.
  ///
  /// Common in most Western countries.
  saturdayAndSunday,

  /// Friday and Saturday are weekend days.
  ///
  /// Common in Middle Eastern countries.
  fridayAndSaturday,

  /// Only Saturday is a weekend day.
  saturday,

  /// Only Sunday is a weekend day.
  sunday,
}

/// Specifies the starting day of the week for calendar configuration.
///
/// This enum is used to determine which day the calendar week begins on.
/// Different regions have different conventions for the first day of the week.
enum WeekStartType {
  /// Week starts on Sunday.
  ///
  /// Common in the United States, Canada, and some other countries.
  sunday,

  /// Week starts on Monday.
  ///
  /// Common in most European countries and ISO 8601 standard.
  monday,
}
