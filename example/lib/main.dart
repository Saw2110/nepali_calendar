// Import required Flutter material package
import 'package:flutter/material.dart';
// Import the Nepali Calendar package
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

// Main entry point of the application
void main() {
  runApp(const MainApp());
}

// Root widget of the application
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

final calendarController = NepaliCalendarController();

/// Example screen demonstrating the usage of NepaliCalendar widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///
      ///
      body: SafeArea(
        // Implementation of NepaliCalendar with various customization options
        child: Column(
          children: [
            ///
            HorizontalNepaliCalendar(
              initialDate: NepaliDateTime.now(),
              calendarStyle: NepaliCalendarStyle(
                language: Language.nepali,
                // You can also configure weekend for horizontal calendar
                weekendType: WeekendType.saturday,
              ),
              onDateSelected: (date) {
                debugPrint("sad Date $date");
              },
            ),

            ///
            SizedBox(height: 50.0),

            ///
            Expanded(
              child: NepaliCalendar(
                controller: calendarController,

                // Pass the sorted list of events
                eventList: _sortedList(),
                // Define function to check if an event is a holiday
                checkIsHoliday: (event) => event.isHoliday,
                // Custom builder for event list items
                eventBuilder: (context, index, _, event) {
                  return EventWidget(event: event);
                },
                // Callback when selected day changes
                onDayChanged: (nepaliDateTime) {
                  debugPrint("ON DAY CHANGE => $nepaliDateTime");
                },
                // Callback when month changes
                onMonthChanged: (nepaliDateTime) {
                  debugPrint("ON MONTH CHANGE => $nepaliDateTime");
                },
                // Customize calendar appearance
                calendarStyle: const NepaliCalendarStyle(
                  showEnglishDate: true,
                  showBorder: false,
                  // Configure weekend days (default: WeekendType.saturday)
                  // Options: saturdayAndSunday, fridayAndSaturday, saturday, sunday
                  weekendType: WeekendType.saturdayAndSunday,
                  // Configure week start day (default: WeekStartType.sunday)
                  // Options: sunday, monday
                  weekStartType: WeekStartType.monday,
                ),
              ),
            ),

            ///
          ],
        ),
      ),
    );
  }

  /// Helper method to sort events by date
  List<CalendarEvent<Events>> _sortedList() {
    final sortedList = List<CalendarEvent<Events>>.from(eventList);
    sortedList.sort((a, b) => a.date.compareTo(b.date));
    return sortedList;
  }
}

/// Custom widget to display individual events in the list
/// Shows event date, holiday status, title and description
class EventWidget extends StatelessWidget {
  final CalendarEvent<Events> event;

  const EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        // Different background colors for holidays and regular events
        color: event.isHoliday ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.date.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            event.isHoliday ? "Holiday" : "Not Holiday",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            event.additionalInfo!.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            event.additionalInfo!.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Custom model class for event details
/// Used as additional information in CalendarEvent
class Events {
  const Events({
    required this.title,
    required this.description,
    required this.additionalInfo,
    required this.eventType,
  });

  final String title;
  final String description;
  final String additionalInfo;
  final String eventType;
}

/// Sample event data showing how to create calendar events
/// Each event includes date, holiday status, and additional information
final List<CalendarEvent<Events>> eventList = [
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "Dashain Festival",
      description: "The biggest Hindu festival in Nepal.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "Tihar Festival",
      description: "The festival of lights.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 9, day: 11),
    isHoliday: true,
    additionalInfo: Events(
      title: "Constitution Day",
      description: "Celebration of Nepal's constitution.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 10, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "Team Meeting",
      description: "Monthly team meeting to discuss progress.",
      additionalInfo: "Office event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2081, month: 9, day: 25),
    isHoliday: false,
    additionalInfo: Events(
      title: "Project Deadline",
      description: "Deadline for submitting the project report.",
      additionalInfo: "Work-related",
      eventType: "notHoliday",
    ),
  ),
  // You can add more events following the same pattern
];
