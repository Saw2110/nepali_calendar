# Nepali Calendar Flutter Package

[![Pub Version](https://img.shields.io/pub/v/nepali_calendar_plus.svg)](https://pub.dev/packages/nepali_calendar_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A feature-rich Flutter package for implementing a Nepali calendar system in your applications. This provides a highly customizable calendar widget with support for Nepali (Bikram Sambat) and extensive styling options.

## 📱 Preview

| ![Image](https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/1.jpg) | ![Image](https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/2.jpg) | ![Image](https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/3.jpg) | ![Image](https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/4.jpg)| ![Image](https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/5.jpg) |
| ------------- |:-------------:|:-------------:|:-------------:|-----:|

## ✨ Key Features

- **Dual Calendar System**
  - Nepali dates `(Bikram Sambat)` display
  - Optional English date conversion and display
  - Automatic today's date highlighting
  
- **Horizontal Calendar System**
  - Nepali dates `(Bikram Sambat)` display
  - Automatic today's date highlighting
  
- **Navigation & Selection**
  - Smooth month and year navigation
  - Date selection with customizable highlighting
  - Month and year picker dialogs
  
- **Events & Holidays**
  - Event indicators
  - Holiday highlighting support
  
- **Localization**
  - Bilingual support (Nepali/English)
  
- **Customization**
  - Extensive styling options for all components
  - Custom themes support
  - Configurable layouts and views

## 📦 Installation

Run this command:

With Dart:

```yaml
 dart pub add nepali_calendar_plus
 ```

With Flutter:

```yaml
 flutter pub add nepali_calendar_plus
 ```

This will add a line like this to your package's pubspec.yaml

```yaml
dependencies:
  nepali_calendar_plus: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 🎯 Quick Start

1.Import the package:

```dart
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';
```

2.Add the calendar widget to your app:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NepaliCalendar(
        calendarStyle: NepaliCalendarStyle(
          showEnglishDate: true,
          showBorder: true,
        ),
      ),
    );
  }
}
```

## 🎨 Styling & Customization

### Calendar Style Configuration

```dart
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    // Basic Configuration
    showEnglishDate: true,
    showBorder: true,
    language: Language.nepali,
    
    // Cell Styling
    cellsStyle: CellStyle(
      width: 45.0,
      height: 45.0,
      dayStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      todayColor: Colors.green.shade300,
      selectedColor: Colors.blue.shade400,
      dotColor: Colors.red,
      holidayColor: Colors.red.shade100,
    ),
    
    // Header Styling
    headersStyle: HeaderStyle(
      weekHeaderStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      monthHeaderStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
      yearHeaderStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

### Event Management

```dart
// Define events
final eventList = [
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
];

// Add to calendar
NepaliCalendar(
  events: events,
  onDaySelected: (date, events) {
    // Handle date selection
    print('Selected date: $date');
    print('Events on this date: ${events.length}');
  },
)
```

## 🎮 Controllers

```dart
final calendarController = NepaliCalendarController();

NepaliCalendar(
  controller: calendarController,
)

// Navigate to specific date
calendarController.jumpToDate(NepaliDateTime(2080, 5, 15));

// Navigate to today
calendarController.jumpToToday();

// Get selected date
final selectedDate = calendarController.selectedDate;
```

## Horizontal Calender System

```dart
HorizontalNepaliCalendar(
  initialDate: NepaliDateTime.now(),
  calendarStyle: NepaliCalendarStyle(
    language: Language.nepali,
  ),
  onDateSelected: (date) {
    debugPrint("sad Date $date");
  },
),
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For any queries or support, please:

- Create an issue on GitHub
- Email: <work.sabinghimire@gmail.com>
