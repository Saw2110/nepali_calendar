# Nepali Calendar Plus

[![Pub Version](https://img.shields.io/pub/v/nepali_calendar_plus.svg)](https://pub.dev/packages/nepali_calendar_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A feature-rich Flutter package for implementing Nepali (Bikram Sambat) calendar in your applications with extensive customization options, event management, and bilingual support.

## Preview

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/1.jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/2.jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/3.jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/4.jpg" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/5.jpg" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/6.png" width="200"/></td>
  </tr>
</table>

## Features

- ✅ Full Nepali (Bikram Sambat) calendar support
- ✅ Modal date picker dialog
- ✅ Horizontal and vertical calendar views
- ✅ Bilingual support (Nepali/English)
- ✅ Event management with custom types
- ✅ Holiday highlighting
- ✅ Programmatic navigation with controller
- ✅ Customizable weekend patterns
- ✅ Week start configuration (Sunday/Monday)
- ✅ Custom builders for complete UI control
- ✅ English date conversion display
- ✅ Extensive styling options
- ✅ Today's date highlighting
- ✅ Previous/next month day display

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  nepali_calendar_plus: ^latest_version
```

Or install it from the command line:

```bash
flutter pub add nepali_calendar_plus
```

## Usage

### Basic Calendar

```dart
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
      language: Language.nepali,
    ),
  ),
  onDayChanged: (date) {
    print('Selected: $date');
  },
)
```

### Horizontal Calendar

```dart
HorizontalNepaliCalendar(
  initialDate: NepaliDateTime.now(),
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      language: Language.english,
    ),
  ),
  onDateSelected: (date) {
    print('Selected: $date');
  },
)
```

### With Controller

```dart
final controller = NepaliCalendarController();

NepaliCalendar(
  controller: controller,
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
    ),
  ),
)

// Navigate programmatically
controller.jumpToToday();
controller.nextMonth();
controller.previousMonth();
controller.jumpToDate(NepaliDateTime(2080, 1, 1));
```

### Date Picker Dialog

Show a modal date picker dialog for easy date selection:

```dart
Future<void> _selectDate(BuildContext context) async {
  final selectedDate = await showNepaliDatePicker(
    context: context,
    initialDate: NepaliDateTime.now(),
    calendarStyle: NepaliCalendarStyle(
      config: CalendarConfig(
        language: Language.nepali,
        weekTitleType: TitleFormat.half,
      ),
      cellsStyle: CellStyle(
        selectedColor: Colors.blue,
        todayColor: Colors.green,
      ),
    ),
  );

  if (selectedDate != null) {
    print('Selected date: $selectedDate');
  }
}

// Use in your widget
ElevatedButton(
  onPressed: () => _selectDate(context),
  child: Text('Pick Date'),
)
```

### Customization

```dart
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
      showBorder: true,
      language: Language.nepali,
      weekendType: WeekendType.saturday,
      weekStartType: WeekStartType.sunday,
      weekTitleType: TitleFormat.half,
    ),
    cellsStyle: CellStyle(
      todayColor: Colors.green,
      selectedColor: Colors.blue,
      weekDayColor: Colors.red,
    ),
    headersStyle: HeaderStyle(
      monthHeaderStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

### Event Management

```dart
class MyEvent {
  final String title;
  final String description;
  
  MyEvent(this.title, this.description);
}

final events = [
  CalendarEvent<MyEvent>(
    date: NepaliDateTime(2082, 9, 10),
    isHoliday: true,
    additionalInfo: MyEvent("Christmas", "Holiday"),
  ),
];

NepaliCalendar<MyEvent>(
  eventList: events,
  checkIsHoliday: (event) => event.isHoliday,
  onDayChanged: (date) => print('Selected: $date'),
  onMonthChanged: (date) => print('Month: ${date.month}'),
)
```



### Custom Builders

```dart
NepaliCalendar(
  calendarBuilder: CalendarBuilder(
    // Custom event widget
    eventBuilder: (context, index, date, event) {
      return Container(
        padding: EdgeInsets.all(8),
        child: Text(event.additionalInfo?.title ?? ''),
      );
    },
    
    // Custom cell widget
    cellBuilder: (data) {
      return Container(
        decoration: BoxDecoration(
          color: data.isToday ? Colors.blue : null,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text('${data.day}')),
      );
    },
    
    // Custom header
    headerBuilder: (date, controller) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: controller.previousMonth,
          ),
          Text('${date.month}/${date.year}'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: controller.nextMonth,
          ),
        ],
      );
    },
  ),
)
```

## Example Project

Check out the [example folder](https://github.com/Saw2110/nepali_calendar/tree/main/example) for a complete working example with all features demonstrated.


## API Reference

For detailed API documentation, visit [pub.dev documentation](https://pub.dev/documentation/nepali_calendar_plus/latest/).

### Key Components

- **NepaliCalendar** - Main calendar widget with full month view
- **HorizontalNepaliCalendar** - Horizontal scrolling date picker
- **showNepaliDatePicker** - Modal date picker dialog
- **NepaliCalendarController** - Programmatic navigation control
- **CalendarConfig** - Centralized configuration
- **CalendarBuilder** - Custom component builders
- **CalendarEvent** - Event model with generic type support

### Configuration Options

- **Language**: `Language.nepali`, `Language.english`
- **WeekendType**: `saturday`, `sunday`, `saturdayAndSunday`, `fridayAndSaturday`
- **WeekStartType**: `sunday`, `monday`
- **TitleFormat**: `full`, `half`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Contact

- **Issues**: [Report Issues](https://github.com/Saw2110/nepali_calendar/issues)
- **Email**: work.sabinghimire@gmail.com

