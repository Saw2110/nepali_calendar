import '../src.dart';

class CalendarEvent<T> {
  final NepaliDateTime date;
  final T events;

  CalendarEvent({required this.date, required this.events});
}
