import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart' as picker;
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Calendar Plus Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExamplesTabScreen(),
    );
  }
}

/// Main screen with tabs for different examples
class ExamplesTabScreen extends StatefulWidget {
  const ExamplesTabScreen({super.key});

  @override
  State<ExamplesTabScreen> createState() => _ExamplesTabScreenState();
}

class _ExamplesTabScreenState extends State<ExamplesTabScreen> {
  Language currentLanguage = Language.nepali;

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == Language.nepali
          ? Language.english
          : Language.nepali;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nepali Calendar Plus Examples'),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _toggleLanguage,
              tooltip: 'Toggle Language',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: 'Basic'),
              Tab(icon: Icon(Icons.date_range), text: 'Date Picker'),
              Tab(icon: Icon(Icons.brush), text: 'Custom Builders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BasicCalendarExample(language: currentLanguage),
            DatePickerExample(language: currentLanguage),
            CustomBuildersExample(language: currentLanguage),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. BASIC CALENDAR EXAMPLE
// ============================================================================

/// Demonstrates basic calendar usage with controller and events
class BasicCalendarExample extends StatefulWidget {
  const BasicCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<BasicCalendarExample> createState() => _BasicCalendarExampleState();
}

class _BasicCalendarExampleState extends State<BasicCalendarExample> {
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20.0,
          children: [
            const SizedBox(height: 1),

            // Horizontal Calendar
            HorizontalNepaliCalendar(
              initialDate: NepaliDateTime.now(),
              calendarStyle: NepaliCalendarStyle(
                config: CalendarConfig(
                  language: widget.language,
                  weekendType: WeekendType.saturday,
                ),
              ),
              onDateSelected: (date) {
                debugPrint("Selected Date: $date");
              },
            ),
            SizedBox(height: 4.0),
            // Controller buttons
            ColoredBox(
              color: Colors.black12,
              child: Wrap(
                spacing: 5.0,
                children: [
                  ElevatedButton.icon(
                    onPressed: _jumpToToday,
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Today'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('Prev'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('Next'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _jumpToBaishakMonth,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Baishak 2080'),
                  ),
                ],
              ),
            ),

            // Main Calendar with Events
            SizedBox(
              height: MediaQuery.sizeOf(context).height,
              child: NepaliCalendar(
                controller: _calendarController,
                eventList: _sortedList(),
                checkIsHoliday: (event) => event.isHoliday,
                calendarBuilder: CalendarBuilder<Events>(
                  eventBuilder: (context, index, date, event) {
                    return EventWidget(event: event);
                  },
                ),
                onDayChanged: (date) {
                  debugPrint("Day Changed: $date");
                },
                onMonthChanged: (date) {
                  debugPrint("Month Changed: ${date.month}/${date.year}");
                },
                calendarStyle: NepaliCalendarStyle(
                  config: CalendarConfig(
                    showEnglishDate: true,
                    showBorder: true,
                    language: widget.language,
                    weekendType: WeekendType.saturdayAndSunday,
                    weekStartType: WeekStartType.monday,
                    weekTitleType: TitleFormat.half,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CalendarEvent<Events>> _sortedList() {
    final sortedList = List<CalendarEvent<Events>>.from(eventList);
    sortedList.sort((a, b) => a.date.compareTo(b.date));
    return sortedList;
  }
}

// ============================================================================
// 2. DATE PICKER EXAMPLE
// ============================================================================

/// Demonstrates the modal date picker dialog
class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key, required this.language});

  final Language language;

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  NepaliDateTime? selectedDate;

  Future<void> _showDatePickerDialog() async {
    final selected = await picker.showNepaliDatePicker(
      context: context,
      initialDate: selectedDate,
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(
          language: widget.language,
          weekTitleType: TitleFormat.half,
        ),
        cellsStyle: const CellStyle(
          selectedColor: Color(0xFF6366F1),
          todayColor: Colors.green,
          weekDayColor: Colors.red,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  String _formatDate(NepaliDateTime date) {
    final monthName = MonthUtils.formattedMonth(date.month, widget.language);
    final day = widget.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.day.toString())
        : date.day.toString();
    final year = widget.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.year.toString())
        : date.year.toString();
    return '$monthName $day, $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.language == Language.nepali
              ? 'नेपाली मिति चयनकर्ता'
              : 'Nepali Date Picker',
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.language == Language.nepali
                    ? 'मिति छान्नुहोस्'
                    : 'Select a Date',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : widget.language == Language.nepali
                        ? 'कुनै मिति चयन गरिएको छैन'
                        : 'No date selected',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showDatePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.language == Language.nepali
                          ? 'मिति छान्नुहोस्'
                          : 'Choose Date',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                  child: Text(
                    widget.language == Language.nepali
                        ? 'चयन हटाउनुहोस्'
                        : 'Clear Selection',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. CUSTOM BUILDERS EXAMPLE
// ============================================================================

/// Demonstrates custom builders for complete UI customization
class CustomBuildersExample extends StatelessWidget {
  const CustomBuildersExample({super.key, required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    return NepaliCalendar<Events>(
      eventList: eventList,
      checkIsHoliday: (event) => event.isHoliday,
      calendarBuilder: CalendarBuilder<Events>(
        // Custom cell builder
        cellBuilder: (data) => _customCellBuilder(data, language),
        // Custom weekday builder
        weekdayBuilder: (data) => _customWeekdayBuilder(data, language),
        // Custom header builder
        headerBuilder: (date, controller) =>
            _customHeaderBuilder(date, controller, language),
        // Custom event builder
        eventBuilder: (context, index, date, event) {
          return EventWidget(event: event);
        },
      ),
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(
          showEnglishDate: true,
          language: language,
          weekendType: WeekendType.saturday,
        ),
      ),
    );
  }

  Widget _customCellBuilder(CalendarCellData<Events> data, Language language) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: data.isToday
              ? Colors.blue.withValues(alpha: 0.2)
              : data.isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : data.isDimmed
                      ? Colors.grey.shade300
                      : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border:
              data.isToday ? Border.all(color: Colors.blue, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              NepaliNumberConverter.formattedNumber(data.day.toString(),
                  language: language),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: data.isToday ? FontWeight.bold : FontWeight.w600,
                color: data.isToday
                    ? Colors.blue
                    : data.isWeekend
                        ? Colors.red
                        : data.isDimmed
                            ? Colors.grey
                            : Colors.black,
              ),
            ),
            if (data.event != null)
              Icon(
                Icons.star,
                color: data.event!.isHoliday ? Colors.red : Colors.blue,
                size: 12.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _customWeekdayBuilder(WeekdayData data, Language language) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              WeekUtils.formattedWeekDay(
                data.weekday,
                language,
                data.format,
              ),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: data.isWeekend ? Colors.red : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              WeekUtils.formattedWeekDay(
                data.weekday,
                language == Language.nepali
                    ? Language.english
                    : Language.nepali,
                TitleFormat.half,
              ),
              style: TextStyle(
                fontSize: 10.0,
                color: data.isWeekend
                    ? Colors.red.withValues(alpha: 0.7)
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _customHeaderBuilder(
      NepaliDateTime date, PageController controller, Language language) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.blue, size: 28),
            onPressed: () {
              if (controller.hasClients) {
                controller.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  MonthUtils.formattedMonth(date.month, language),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  language == Language.nepali
                      ? NepaliNumberConverter.englishToNepali(
                          date.year.toString())
                      : date.year.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.blue, size: 28),
            onPressed: () {
              if (controller.hasClients) {
                controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS & DATA
// ============================================================================

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
