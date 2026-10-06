# Nepali Calendar Plus

[![Pub Version](https://img.shields.io/pub/v/nepali_calendar_plus.svg)](https://pub.dev/packages/nepali_calendar_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A feature-rich Flutter package for implementing Nepali (Bikram Sambat) calendar in your applications with extensive customization options, event management, and bilingual support.

## Preview

<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/1.png" width="200" alt="Month calendar with events"/><br/><sub>Month calendar</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/2.png" width="200" alt="Week strip"/><br/><sub>Week strip</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/3.png" width="200" alt="Year view"/><br/><sub>Year view</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/4.png" width="200" alt="Date picker"/><br/><sub>Date picker</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/Saw2110/nepali_calendar/refs/heads/main/assets/5.png" width="200" alt="Date range picker"/><br/><sub>Date range picker</sub></td>
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
- ✅ Screen-reader labels, keyboard navigation and haptics out of the box

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

## Accessibility and platform feel

Every calendar is usable without sight or without a touchscreen, with no extra
configuration.

**Screen readers.** Each date announces itself in full, in the configured
language, rather than as a bare number:

```
बैशाख, १५, २०८१, शनिबार, आज, बिदा, २ कार्यक्रम
Baisakh, 15, 2081, Saturday, Today, Holiday, 2 events
```

The month title is exposed as a header, and the navigation chevrons are
labelled. A custom `cellBuilder` replaces the default cell entirely, including
its semantics — supply your own `Semantics` wrapper if you use one.

**Keyboard.** Date cells take focus, so `Tab` reaches the grid, the arrow keys
move between dates by position, and `Enter` or `Space` selects the focused
date. This matters most on desktop and web, where the calendar was previously
mouse-only.

**Haptics.** Off by default, so upgrading never makes an app start vibrating.
Opt in to have selecting a date answer the tap through touch — `light` is the
recommended value:

```dart
NepaliCalendar(
  calendarStyle: const NepaliCalendarStyle(
    config: CalendarConfig(hapticFeedback: CalendarHaptics.light),
  ),
)
```

| `CalendarHaptics` | Android | iOS |
| --- | --- | --- |
| `none` *(default)* | nothing | nothing |
| `selection` | `CLOCK_TICK` | selection generator |
| `light` *(recommended)* | `VIRTUAL_KEY` | impact, light |
| `medium` | `KEYBOARD_TAP` | impact, medium |
| `heavy` | `CONTEXT_CLICK` | impact, heavy |

> **Testing haptics?** Only a physical phone can render them. Desktop, web and
> the **iOS Simulator** have no haptic hardware, so every value is silently a
> no-op there. On Android they are also gated behind the system's
> touch-feedback setting — if that is off, nothing reaches the user.
>
> `selection` is the subtlest value and on many Android phones cannot be felt
> at all; it maps to the constant meant for a picker wheel passing detents.
> Use `light` or firmer for taps.

**Text scaling.** Cell text follows the system font setting as far as the cell
can hold it, then stops, so a user at 200% gets larger dates rather than a
clipped grid.

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

## Upgrading to 0.1.0

0.1.0 is a correctness release. It removes no APIs, but it does fix behaviour you
may have worked around — which is why it is a minor bump rather than a patch. See
the [migration guide](doc/MIGRATION.md) for step-by-step instructions, or the
[CHANGELOG](CHANGELOG.md) for the full list.

**Dates were wrong for users in Nepal.** `toNepaliDateTime()` added an extra
day whenever the device's timezone was exactly UTC+5:45 and the date fell after
1986 — so it was wrong in Nepal and only in Nepal:

```dart
// 0.0.7, on a device in Nepal
DateTime(2024, 4, 13).toNepaliDateTime(); // BS 2081-01-02  ✗
// 0.1.0, on any device
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
controller.jumpToDate(NepaliDateTime(year: 2080, month: 1, day: 1));
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

A coloured band at the top shows the selected date in BS and in AD. Below it,
`‹ Month ▾ ›  ‹ Year ▾ ›` steps the grid by months or years; tap the month or
the year to pick it from a page of months or a list of years. Today sits at
the bottom left. On a phone in landscape the band moves beside the grid, so
the days stay easy to tap.

The dialog returns as soon as a date is tapped; Close, or tapping outside it,
returns `null`. Pass `autoConfirm: false` to keep the selection pending behind
Cancel / OK instead.

The weekday names above the grid are initials (`आ सो मं`) by default. Pass
`weekdayFormat: TitleFormat.half` (`आइत सोम मंगल`) or `TitleFormat.full` for
longer names; they shrink to fit their column rather than being cut off. The
same option exists on `showNepaliDateRangePicker`.

`NepaliDatePicker` is the same picker as a widget, for embedding in a page. It
waits for OK by default, so a tap never pops your page; pass `onConfirm` and
`onCancel` to receive the result without touching the `Navigator`.

### Date Range Picker

Pick a start and an end date. On a phone the picker opens full screen with
the months in one vertical list; on a tablet or desktop it is a dialog with two
months side by side. The first tap sets the start, the second the end, and a
third starts over. Save is enabled once both ends are set.

```dart
final range = await showNepaliDateRangePicker(
  context: context,
  minDate: NepaliDateTime(year: 2080, month: 1, day: 1),
  maxDate: NepaliDateTime(year: 2090, month: 12, day: 30),
  maxDays: 30, // optional: the longest range, both ends counted
);

if (range != null) {
  print('${range.start} – ${range.end}: ${range.days} days');
  final ad = range.toDateTimeRange(); // the same range as a DateTimeRange
}
```

`NepaliDateRangePicker` is the widget on its own, for embedding in a page:
pass `onConfirm` and `onCancel` and it leaves the `Navigator` alone.

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
    date: NepaliDateTime(year: 2082, month: 9, day: 10),
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

### Custom Picker Design

Both pickers take a `DatePickerBuilder` to redesign any of their parts: the
day cells, the weekday names, the title band, the navigation row, the action
row, and the month and year tiles. Each builder gets a data object with the part's state and callbacks to
call, so the picker still handles dates, bounds, paging and confirming. Return
`null` -- or leave a builder unset -- to keep the default design.

```dart
final date = await showNepaliDatePicker(
  context: context,
  autoConfirm: false,
  pickerBuilder: DatePickerBuilder(
    // Round days; every other day keeps the default look.
    dayBuilder: (day) {
      if (!day.isSelected) return null;
      return GestureDetector(
        onTap: day.onTap,
        child: CircleAvatar(child: Text(day.label)),
      );
    },
    // Your own action row in place of Today and Cancel / OK.
    footerBuilder: (footer) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: footer.onToday, child: const Text('Today')),
        FilledButton(onPressed: footer.onConfirm, child: const Text('Done')),
      ],
    ),
  ),
);
```

Pass the same builder to `showNepaliDateRangePicker`: its days also get a
`rangePosition` (`start`, `middle`, `end`, `single` or `none`) to draw the
range band from. A custom widget fills the same fixed slot as the default
one, so the grid never resizes or scrolls; the picker keeps the screen-reader
label around a custom day.

## Example Project

Check out the [example folder](https://github.com/Saw2110/nepali_calendar/tree/main/example) for a complete working example with all features demonstrated.


## API Reference

For detailed API documentation, visit [pub.dev documentation](https://pub.dev/documentation/nepali_calendar_plus/latest/).

### Key Components

- **NepaliCalendar** - Main calendar widget with full month view
- **HorizontalNepaliCalendar** - Horizontal scrolling date picker
- **showNepaliDatePicker** - Modal date picker dialog
- **showNepaliDateRangePicker** - Date range picker: full screen on phones,
  a two-month dialog on wider screens
- **NepaliDateTimeRange** - A start and end date, both included
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

