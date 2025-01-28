import '../src.dart';

/// Represents an event in the Nepali calendar.
///
/// This class is used to define events associated with specific dates in the
/// Nepali calendar. It can include additional information and indicate whether
/// the date is a holiday.
///
/// Example usage: 1
/// ```dart
/// final event = CalendarEvent(
///   date: NepaliDateTime(2080, 1, 1),
///   isHoliday: true,
///   additionalInfo: 'New Year',
/// );
/// Example usage: 2
/// ```dart
/// final event = CalendarEvent(
///   date: NepaliDateTime(2080, 1, 1),
///   isHoliday: true,
///   additionalInfo: {},
/// );
/// ```
class CalendarEvent<T> {
  /// The date associated with this event in the Nepali calendar.
  ///
  /// This is the primary identifier for the event.
  final NepaliDateTime date;

  /// Indicates whether the date is a holiday.
  ///
  /// When `true`, the date is marked as a holiday in the calendar.
  /// Default is `false`.
  final bool isHoliday;

  /// Additional information associated with the event.
  ///
  /// This can be used to store custom data related to the event, such as
  /// event descriptions, tags, or metadata.
  final T? additionalInfo;

  /// Creates a [CalendarEvent] instance.
  ///
  /// - [date]: The Nepali date associated with the event.
  /// - [isHoliday]: Whether the date is a holiday. Default is `false`.
  /// - [additionalInfo]: Optional additional information about the event.
  CalendarEvent({
    required this.date,
    this.isHoliday = false,
    this.additionalInfo,
  });
}
