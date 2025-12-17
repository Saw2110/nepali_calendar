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

/// Example screen demonstrating the usage of NepaliCalendar widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NepaliCalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = NepaliCalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _jumpToToday() {
    _calendarController.jumpToToday();
  }

  void _previousMonth() {
    _calendarController.previousMonth();
  }

  void _nextMonth() {
    _calendarController.nextMonth();
  }

  void _jumpToBaishakMonth() {
    _calendarController.jumpToDate(NepaliDateTime(year: 2080, month: 01));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///
      ///
      body: SafeArea(
        // Implementation of NepaliCalendar with various customization options
        child: Column(
          spacing: 20.0,
          children: [
            ///
            SizedBox(height: 1.0),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _jumpToToday,
                    icon: const Icon(Icons.today),
                    label: const Text('Today'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _jumpToBaishakMonth,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Baishak 2080'),
                  ),
                ],
              ),
            ),

            ///
            ///

            HorizontalNepaliCalendar(
              initialDate: NepaliDateTime.now(),
              calendarStyle: NepaliCalendarStyle(
                // Recommended: Use CalendarConfig for better organization
                config: CalendarConfig(
                  language: Language.nepali,
                  weekendType: WeekendType.saturday,
                ),
              ),
              onDateSelected: (date) {
                debugPrint("sad Date $date");
              },
            ),
            SizedBox(height: 1.0),

            ///
            Expanded(
              child: NepaliCalendar(
                controller: _calendarController,

                // Pass the sorted list of events
                eventList: _sortedList(),
                // Define function to check if an event is a holiday
                checkIsHoliday: (event) => event.isHoliday,
                // NEW: Use NepaliCalendarBuilder for custom components
                calendarBuilder: CalendarBuilder<Events>(
                  // Custom event builder
                  eventBuilder: (context, index, date, event) {
                    return EventWidget(event: event);
                  },
                  // cellBuilder: customCellExample,
                  // weekdayBuilder: customWeekDayExample,
                  // headerBuilder: customHeaderExample,
                ),
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
                  // Recommended: Use CalendarConfig for better organization
                  headersStyle: HeaderStyle(),
                  cellsStyle: CellStyle(),
                  config: CalendarConfig(
                    showEnglishDate: true,
                    showBorder: true,
                    language: Language.english,
                    // Configure weekend days (default: WeekendType.saturday)
                    // Options: saturdayAndSunday, fridayAndSaturday, saturday, sunday
                    weekendType: WeekendType.saturdayAndSunday,
                    // Configure week start day (default: WeekStartType.sunday)
                    // Options: sunday, monday
                   weekStartType: WeekStartType.monday,
                    // Configure weekday title format (default: TitleFormat.half)
                    // Options: full, half, short
                    weekTitleType: TitleFormat.half,
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Row(
          children: [
            // Colored accent bar on the left
            Container(
              width: 4,
              height: 100,
              color: event.isHoliday ? Colors.red : Colors.blue,
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with date and badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(event.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (event.isHoliday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'Holiday',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Event title
                    Text(
                      event.additionalInfo!.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Event description
                    Text(
                      event.additionalInfo!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(NepaliDateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    date: NepaliDateTime(year: 2082, month: 8, day: 17),
    isHoliday: false,
    additionalInfo: Events(
      title: "अन्तर्राष्ट्रिय अपाङ्ग दिवस",
      description:
          "International Day of Persons with Disabilities (only for specially-abled employees).",
      additionalInfo: "Special capacity employees only",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 8, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "उँधौली पर्व / य:मरि पुन्हि / ज्यापु दिवस",
      description:
          "Udhauli festival, Yomari Punhi, Jyapu Day, Purnima fast, Dhanya Purnima.",
      additionalInfo: "Cultural & religious events",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "क्रिसमस डे",
      description: "Christmas Day celebration.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "तमु ल्होसार / लेखनाथ जयन्ती",
      description:
          "Tamu Lhosar, Poet Shiromani Lekhnath Jayanti, Putrada Ekadashi fast.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 19),
    isHoliday: false,
    additionalInfo: Events(
      title: "श्री स्वस्थानी व्रत कथा प्रारम्भ",
      description:
          "Start of Shree Swasthani Brata Katha, Magh Snan, Purnima fast.",
      additionalInfo: "Religious observance",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 27),
    isHoliday: false,
    additionalInfo: Events(
      title: "पृथ्वी जयन्ती / राष्ट्रिय एकता दिवस",
      description: "Prithvi Jayanti, National Unity Day, Gorakhkali Puja.",
      additionalInfo: "National & religious observance",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "माघे संक्रान्ति",
      description: "Maghe Sankranti, Ghyu-Chaku Khane Din, Uttarayan begins.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 5),
    isHoliday: true,
    additionalInfo: Events(
      title: "सोनाम ल्होसार",
      description: "Sonam Lhosar and Shri Ballabh Jayanti.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "वसन्तपञ्चमी / सरस्वती पूजा",
      description:
          "Basant Panchami and Saraswati Puja (holiday for educational institutions only).",
      additionalInfo: "Educational institutions holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 16),
    isHoliday: false,
    additionalInfo: Events(
      title: "शहीद दिवस",
      description: "Martyrs' Day and Pradosh fast.",
      additionalInfo: "National observance",
      eventType: "notHoliday",
    ),
  ),
];
