import '../src.dart';

/// Represents an event in the Nepali calendar.
///
/// This class is used to define events associated with specific dates in the
/// Nepali calendar. It can include additional information and indicate whether
/// the date is a holiday.
///
/// Example usage with new naming convention:
/// ```dart
/// final event = CalendarEvent(
///   eventDate: NepaliDateTime(2080, 1, 1),
///   isHoliday: true,
///   eventMetadata: 'New Year',
/// );
/// ```
/// 
/// Example with complex metadata:
/// ```dart
/// final event = CalendarEvent(
///   eventDate: NepaliDateTime(2080, 1, 1),
///   isHoliday: true,
///   eventMetadata: {
///     'title': 'New Year',
///     'description': 'Nepali New Year celebration',
///   },
/// );
/// ```
/// 
/// Legacy usage (deprecated but still supported):
/// ```dart
/// final event = CalendarEvent(
///   date: NepaliDateTime(2080, 1, 1), // deprecated
///   isHoliday: true,
///   additionalInfo: 'New Year', // deprecated
/// );
/// ```
class CalendarEvent<T> {
  /// The date associated with this event in the Nepali calendar.
  ///
  /// This is the primary identifier for the event.
  final NepaliDateTime eventDate;

  /// Indicates whether the date is a holiday.
  ///
  /// When `true`, the date is marked as a holiday in the calendar.
  /// Default is `false`.
  final bool isHoliday;

  /// Additional information associated with the event.
  ///
  /// This can be used to store custom data related to the event, such as
  /// event descriptions, tags, or metadata.
  final T? eventMetadata;

  // Deprecated properties for backward compatibility
  
  /// The date associated with this event in the Nepali calendar.
  ///
  /// This is the primary identifier for the event.
  @Deprecated('Use eventDate instead. This will be removed in the next major version.')
  NepaliDateTime get date => eventDate;

  /// Additional information associated with the event.
  ///
  /// This can be used to store custom data related to the event, such as
  /// event descriptions, tags, or metadata.
  @Deprecated('Use eventMetadata instead. This will be removed in the next major version.')
  T? get additionalInfo => eventMetadata;

  /// Creates a [CalendarEvent] instance.
  ///
  /// - [eventDate]: The Nepali date associated with the event.
  /// - [date]: Deprecated. Use [eventDate] instead.
  /// - [isHoliday]: Whether the date is a holiday. Default is `false`.
  /// - [eventMetadata]: Optional additional information about the event.
  /// - [additionalInfo]: Deprecated. Use [eventMetadata] instead.
  CalendarEvent({
    NepaliDateTime? eventDate,
    @Deprecated('Use eventDate parameter instead. This will be removed in the next major version.')
    NepaliDateTime? date,
    this.isHoliday = false,
    T? eventMetadata,
    @Deprecated('Use eventMetadata parameter instead. This will be removed in the next major version.')
    T? additionalInfo,
  })  : assert(
          eventDate != null || date != null,
          'Either eventDate or date (deprecated) must be provided',
        ),
        eventDate = eventDate ?? date!,
        eventMetadata = eventMetadata ?? additionalInfo;
}
