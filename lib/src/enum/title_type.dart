/// Specifies the format for displaying titles.
///
/// This enum is used to determine whether to show the full title (e.g., "Sunday")
/// or an abbreviated version (e.g., "Sun").
@Deprecated('Use WeekdayFormat instead. This will be removed in the next major version.')
typedef TitleFormat = WeekdayFormat;

/// Specifies the format for displaying weekday names.
///
/// This enum determines whether to show the full weekday name (e.g., "Sunday")
/// or an abbreviated version (e.g., "Sun").
enum WeekdayFormat {
  /// Represents the full weekday name (e.g., "Sunday").
  full,

  /// Represents the abbreviated weekday name (e.g., "Sun").
  abbreviated,

  /// @Deprecated: Use 'abbreviated' instead.
  /// Kept for backward compatibility.
  @Deprecated('Use abbreviated instead. This will be removed in the next major version.')
  half,
}
