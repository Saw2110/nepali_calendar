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
- ✅ Full-year view — twelve months on one screen
- ✅ Theming with light/dark mode, following your app's `ColorScheme`
- ✅ Multiple events per date

## Theming and dark mode

Wrap any calendar in a `NepaliCalendarTheme`:

```dart
NepaliCalendarTheme(
  data: NepaliCalendarThemeData.fromContext(context),
  child: NepaliCalendar(),
)
```

For app-wide theming, put it **above the Navigator** — `MaterialApp.builder` is
the simplest place:

```dart
MaterialApp(
  builder: (context, child) => NepaliCalendarTheme(
    data: NepaliCalendarThemeData.fromContext(context),
    child: child!,
  ),
  home: const HomePage(),
)
```

Placed inside `home:` it covers that subtree and any dialog opened from it
(including `showNepaliDatePicker`), but not a route pushed with
`Navigator.push` — the pushed route is a sibling under the Navigator, not a
descendant of `home:`. This is ordinary Flutter behaviour and applies equally
to Material's own `Theme`.

`fromContext` derives the palette and typography from your app's Material
`ColorScheme` and `TextTheme`, so the calendar follows your light/dark mode
automatically. You can also use `NepaliCalendarThemeData.light()`, `.dark()`,
or `.fromColorScheme(scheme)`, and adjust individual values with `copyWith`:

```dart
NepaliCalendarTheme(
  data: NepaliCalendarThemeData.fromContext(context)
      .copyWith(todayColor: Colors.orange),
  child: NepaliCalendar(),
)
```

Styling resolves in this order, first match winning:

1. an explicit `calendarStyle` passed to the widget;
2. the nearest enclosing `NepaliCalendarTheme`;
3. the built-in defaults.

Theming is therefore opt-in: existing code that passes `calendarStyle`, or
passes nothing at all, looks exactly as it did before. Prefer `copyWith` on the
theme over passing a `calendarStyle`, since an explicit style replaces the
theme rather than merging with it.

## Year view

```dart
NepaliYearCalendar(
  year: 2081,
  eventList: events,
  onDaySelected: (date) => print(date),
)
```

Twelve months in a scrollable grid, two per row by default (`monthsPerRow`),
responsive from phone to desktop, with today, the selected date, event dots and
holiday indicators. Also supports `onYearChanged`, `jumpToSelectedMonth`,
`headerBuilder` and `monthTitleBuilder`, and picks up `NepaliCalendarTheme`
like everything else.

## Events

A date may carry any number of events. Mark holidays with
`CalendarEvent.isHoliday`:

```dart
NepaliCalendar<String>(
  eventList: [
    CalendarEvent(date: date, additionalInfo: 'Standup'),
    CalendarEvent(date: date, isHoliday: true, additionalInfo: 'Dashain'),
  ],
  calendarBuilder: CalendarBuilder<String>(
    cellBuilder: (data) => MyCell(
      events: data.events,       // every event that day
      isHoliday: data.isHoliday, // true if any of them is a holiday
    ),
  ),
)
```

`checkIsHoliday` is deprecated and no longer required — it was never read.

## Upgrading to 0.0.8

0.0.8 is a correctness release. It adds no features and removes no APIs, but it
does fix behaviour you may have worked around. See the
[CHANGELOG](CHANGELOG.md) for the full list.

**Dates were wrong for users in Nepal.** `toNepaliDateTime()` added an extra
day whenever the device's timezone was exactly UTC+5:45 and the date fell after
1986 — so it was wrong in Nepal and only in Nepal:

```dart
// 0.0.7, on a device in Nepal
DateTime(2024, 4, 13).toNepaliDateTime(); // BS 2081-01-02  ✗
// 0.0.8, on any device
DateTime(2024, 4, 13).toNepaliDateTime(); // BS 2081-01-01  ✓
```

Since `NepaliDateTime.now()` uses this path, today's-date highlighting was
wrong in every widget. **If you compensated with your own `-1` day adjustment,
remove it.**

Also fixed: `HorizontalNepaliCalendar` ignored taps on phones, the date picker
could not select the 30th or 31st of a month, and both the calendar and the
picker overflowed on several common screen sizes. `NepaliDateTime` now has
value equality, so it works as a `Map` key — if you relied on identity
comparison, switch to `identical(a, b)`.

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
      // Months are drawn at the height they need -- five or six week rows
      // depending on the weekday they start on -- and the calendar resizes as
      // you swipe between them. Set this to pad every month out to six rows
      // instead, so the calendar keeps a constant height.
      sixWeekMonthsEnforced: false,
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

