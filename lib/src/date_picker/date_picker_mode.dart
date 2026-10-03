/// Enum representing the different view modes of the Nepali Date Picker.
///
/// The date picker can display three different views:
/// * [day] - Calendar grid view for selecting a specific day
/// * [month] - All twelve months on one 4x3 page
/// * [year] - 4x3 pages of years
enum NepaliDatePickerMode {
  /// Day selection view with calendar grid showing days of the month
  day,

  /// Month selection view: the 12 months on one 4x3 page
  month,

  /// Year selection view: the supported years, twelve to a 4x3 page
  year,
}
