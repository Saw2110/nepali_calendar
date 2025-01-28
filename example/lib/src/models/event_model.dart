// import '../../nepalicalender.dart';

// class MyEvent<T> {
//   final NepaliDateTime date;
//   final T events;

//   MyEvent({required this.date, required this.events});
// }

import 'package:nepalicalendar/nepalicalendar.dart';

class Events {
  Events({
    required this.title,
    required this.description,
    required this.additionalInfo,
    required this.eventType,
    required this.date,
  });

  final String title;
  final String description;
  final String additionalInfo;
  final String eventType;
  final String date;

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      additionalInfo: json["additionalInfo"] ?? "",
      eventType: json["eventType"] ?? "",
      date: json["date"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "additionalInfo": additionalInfo,
        "eventType": eventType,
        "date": date,
      };
}

List<CalendarEvent<Events>> eventList = [
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 1),
    events: Events.fromJson(
      {
        "title": "Dashain Festival",
        "description": "The biggest Hindu festival in Nepal.",
        "additionalInfo": "Public holiday",
        "eventType": "holiday",
        "date": "2081/10/01"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 18),
    events: Events.fromJson(
      {
        "title": "Tihar Festival",
        "description": "The festival of lights.",
        "additionalInfo": "Public holiday",
        "eventType": "holiday",
        "date": "2081/10/18"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 09, day: 11),
    events: Events.fromJson(
      {
        "title": "Constitution Day",
        "description": "Celebration of Nepal's constitution.",
        "additionalInfo": "Public holiday",
        "eventType": "holiday",
        "date": "2081/10/11"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 10),
    events: Events.fromJson(
      {
        "title": "Team Meeting",
        "description": "Monthly team meeting to discuss progress.",
        "additionalInfo": "Office event",
        "eventType": "notHoliday",
        "date": "2081/10/10"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 09, day: 25),
    events: Events.fromJson(
      {
        "title": "Project Deadline",
        "description": "Deadline for submitting the project report.",
        "additionalInfo": "Work-related",
        "eventType": "notHoliday",
        "date": "2081/10/25"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 11, day: 10),
    events: Events.fromJson(
      {
        "title": "New Year Celebration",
        "description": "Celebration of the new year.",
        "additionalInfo": "Public holiday",
        "eventType": "holiday",
        "date": "2081/10/10"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 20),
    events: Events.fromJson(
      {
        "title": "Client Presentation",
        "description": "Presentation for the new client.",
        "additionalInfo": "Work-related",
        "eventType": "notHoliday",
        "date": "2081/10/20"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 27),
    events: Events.fromJson(
      {
        "title": "TODAY",
        "description": "TODAY TODAY TODAY TODAY TODAY TODAY .",
        "additionalInfo": "TODAY TODAY TODAY TODAY TODAY TODAY TODAY TODAY ",
        "eventType": "notHoliday",
        "date": "2081/10/27"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 28),
    events: Events.fromJson(
      {
        "title": "TODAY",
        "description": "TODAY TODAY TODAY TODAY TODAY TODAY .",
        "additionalInfo": "TODAY TODAY TODAY TODAY TODAY TODAY TODAY TODAY ",
        "eventType": "holiday",
        "date": "2081/10/28"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 29),
    events: Events.fromJson(
      {
        "title": "TODAY",
        "description": "TODAY TODAY TODAY TODAY TODAY TODAY .",
        "additionalInfo": "TODAY TODAY TODAY TODAY TODAY TODAY TODAY TODAY ",
        "eventType": "notHoliday",
        "date": "2081/10/29"
      },
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 15),
    events: Events.fromJson(
      {
        "title": "TODAY",
        "description": "TODAY TODAY TODAY TODAY TODAY TODAY .",
        "additionalInfo": "TODAY TODAY TODAY TODAY TODAY TODAY TODAY TODAY ",
        "eventType": "holiday",
        "date": "2081/10/15"
      },
    ),
  ),
];
