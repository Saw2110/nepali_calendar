// Import required Flutter material package
import 'package:flutter/material.dart';
// Import the Nepali Calendar package
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

// Import the new theme example screen
import 'new_theme_example.dart';

// Main entry point of the application
void main() {
  runApp(const MainApp());
}

// Root widget of the application
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleSelectionScreen(),
    );
  }
}

/// Screen to select between old and new API examples
class ExampleSelectionScreen extends StatelessWidget {
  const ExampleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nepali Calendar Plus'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Legacy API Example'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NewThemeExampleScreen()),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('New Theme System Example'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///
              HorizontalNepaliCalendar(
                initialDate: NepaliDateTime.now(),
                theme: CalendarTheme(
                  locale: CalendarLocale.nepali,
                ),
                onDateSelected: (date) {
                  debugPrint("sad Date $date");
                },
              ),

              ///
              SizedBox(height: 50.0),

              ///
              SizedBox(
                height: 450,
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
                  // Customize calendar appearance (using deprecated params for backward compatibility)
                  theme: CalendarTheme(
                    showEnglishDate: true,
                    showBorder: false,
                  ),
                ),
              ),

              ///
              SizedBox(height: 50.0),

              ///
              SizedBox(
                height: 450,
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
                  // Customize calendar appearance (NEW API - recommended)
                  theme: CalendarTheme(
                    showBorder: true,
                    showEnglishDate: true,
                    cellTheme: const CellTheme(
                      showEnglishDate: true,
                      showBorder: false,
                    ),
                  ),
                ),
              ),

              ///
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper method to sort events by date
List<CalendarEvent<Events>> get sortedList => _sortedList();
List<CalendarEvent<Events>> _sortedList() {
  final sortedList = List<CalendarEvent<Events>>.from(eventList);
  sortedList.sort((a, b) => a.date.compareTo(b.date));
  return sortedList;
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
    date: NepaliDateTime(year: 2082, month: 07, day: 03),
    isHoliday: true,
    additionalInfo: Events(
      title: "Tihar Festival",
      description:
          "लक्ष्मी पूजा/कुकुर तिहार/महाकवि लक्ष्मीप्रसाद देवकोटाको जन्म जयन्ती/नरक चतुर्दशी/सुखरात्री",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 07, day: 04),
    isHoliday: true,
    additionalInfo: Events(
      title: "Tihar Festival",
      description: "तिहार बिदा",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 07, day: 05),
    isHoliday: true,
    additionalInfo: Events(
      title: "Tihar Festival",
      description:
          "गोवर्धन पूजा/गाईगोरु पूजा/म्हपूजा/हलि तिहार/नेपाल सम्वत ११४६ प्रारम्भ",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 07, day: 05),
    isHoliday: true,
    additionalInfo: Events(
      title: "Tihar Festival",
      description: "भाइटीका/किजा पूजा",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 08, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "Festival",
      description:
          "उँधौली पर्व/य:मरि पुन्हि/ज्यापु दिवस/पूर्णिमा व्रत/धान्यपुर्णिमा",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 09, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "Christmas Day",
      description: "क्रिसमस-डे",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 09, day: 15),
    isHoliday: false,
    additionalInfo: Events(
      title: "Festival",
      description: "तमु ल्होसार/कवि शिरोमणि लेखनाथ जयन्ती/पुत्रदा एकादशी व्रत",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
];
