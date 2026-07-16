# CHANGELOG

## 0.1.0

Theming, a year view, and a rewritten event engine. Additive throughout: no
APIs were removed and no existing calendar changes appearance. Some members are
now deprecated and will be removed in 1.0.0.

Builds on the correctness fixes in 0.0.8 — if you are upgrading from 0.0.7 or
earlier, read that section too, as it changes the dates you get in Nepal.

### Added — theming, including dark mode

`NepaliCalendarTheme` styles every calendar widget beneath it:

```dart
NepaliCalendarTheme(
  data: NepaliCalendarThemeData.fromContext(context), // follows your app
  child: NepaliCalendar(),
)
```

`fromContext` derives colours and typography from the ambient Material
`ColorScheme` and `TextTheme`, so the calendar follows your app's light/dark
mode with no further configuration. `NepaliCalendarThemeData.light()`,
`.dark()`, `.legacy()` and `.fromColorScheme()` are also available, and
`copyWith` adjusts individual values.

**Resolution order**, first match winning:

1. an explicit `calendarStyle` passed to the widget;
2. the nearest enclosing `NepaliCalendarTheme`;
3. the built-in defaults used up to 0.0.8.

So theming is opt-in and additive: a widget that already passes
`calendarStyle` is untouched by a theme, and a widget with neither looks
exactly as before. A style passed purely to set *behaviour* — language,
weekend days, week start — does not count as appearance and still receives
themed colours.

An explicit style wins outright rather than merging field by field with the
theme, because `CellStyle`'s fields are non-nullable with const defaults:
there is no way to distinguish a colour the caller chose from one that merely
defaulted. To combine a theme with a tweak, use `copyWith` on the theme data
rather than passing a style.

### Added — `NepaliYearCalendar`

A whole year on one screen, as a scrollable grid of compact months:

```dart
NepaliYearCalendar(
  year: 2081,
  eventList: events,
  onDaySelected: (date) => print(date),
)
```

Two months per row by default (`monthsPerRow`), responsive from phone to
desktop, with today, the selected date, event dots and holiday indicators.
Supports `onYearChanged`, `jumpToSelectedMonth`, `headerBuilder` and
`monthTitleBuilder`, and follows the same theme as every other widget. Year
navigation is clamped to the range the calendar has data for.

### Added — a date can now have more than one event

`CalendarEventIndex` replaces the linear per-cell event scan with a date-keyed
index. Lookups are O(1) and every event on a date is kept:

```dart
final index = CalendarEventIndex.fromList(events);
index.eventsOn(date);        // every event that day
index.eventsInMonth(y, m);   // every event that month
index.isHoliday(date);       // true if *any* event that day is a holiday
```

Up to 0.0.8 each of a month's 42 cells searched the whole event list with
`firstWhere`, catching the not-found exception as control flow, and kept only
the *first* event on a date. That also meant a date carrying an ordinary event
ahead of a holiday did not register as a holiday — now fixed, since `isHoliday`
considers every event on the date.

`CalendarCellData` gains `events`, `hasEvents` and `isHoliday`. The index is
built once per event-list change rather than once per month page.

### Added

- `CellStyle.dateTextColor`, `.onHighlightColor`, `.dimmedDateTextColor` and
  `.borderColor`. These colours were previously hard-coded inside the widgets,
  which made a dark theme impossible. Defaults are unchanged.

### Deprecated

- `NepaliCalendar.checkIsHoliday` — **unused**. Its return value has never been
  read; holidays come from `CalendarEvent.isHoliday`. It was mandatory whenever
  `eventList` was given, enforced by an assertion. That assertion has been
  dropped, so the parameter is now optional and ignored. Set
  `CalendarEvent.isHoliday` on the event instead.
- `CalendarCellData.event` and `CalendarCell.event` — a date can have several
  events and these expose only the first. Use `events`. Existing
  `cellBuilder`s that read `data.event` keep working.
- **The internal rendering widgets**, all scheduled for removal in 1.0.0:
  `CalendarCell`, `CalendarGrid`, `CalendarHeader`, `CalendarMonthView`,
  `EmptyCell`, `EventList` and `WeekdayHeader`.

  These were never intended as public API — they became public because the
  package exported every internal file. They still work and are unchanged; the
  deprecation is notice, not removal. Use `NepaliCalendar`,
  `NepaliYearCalendar` and `CalendarBuilder` instead, or
  `CalendarEventIndex.eventsInMonth` to build your own event list. (`EmptyCell`
  is unused even inside the package: it renders a `SizedBox.shrink()`.)

  If you rely on one of these, please open an issue before 1.0.0.

  Everything else stays public: the widgets, controllers, models, theme,
  enums, and the formatting utilities `MonthUtils`, `WeekUtils`,
  `NepaliNumberConverter` and `CalendarUtils`.

### Changed

- `NepaliCalendar` no longer asserts that `checkIsHoliday` accompanies
  `eventList`. Removing a constraint cannot break a caller that satisfied it.
- `CalendarUtils.calenderyearStart` is now `const` rather than a mutable
  static. Reading it is unaffected. **Assigning to it is now a compile error**
  — but doing so corrupted every date calculation in the package at once, so
  there was never a working reason to.

---

## 0.0.8

A correctness release. Every change below fixes behaviour that was broken in
0.0.7 or earlier. There are no new features and no API removals — upgrading
should be a drop-in, with the exceptions called out under **Action required**.

Each fix ships with regression tests; the package now has a test suite where it
previously had none.

### Fixed — dates were wrong in Nepal

`DateTime.toNepaliDateTime()` added an extra day whenever the *device's*
timezone was exactly UTC+5:45 and the date fell after 1986. In other words it
was wrong for users in Nepal, and only for users in Nepal — the same code gave
a different answer abroad.

```dart
// 0.0.7, on a device in Nepal
DateTime(2024, 4, 13).toNepaliDateTime(); // BS 2081-01-02  ✗
// 0.0.8, on any device
DateTime(2024, 4, 13).toNepaliDateTime(); // BS 2081-01-01  ✓ (Nepali New Year)
```

Because `NepaliDateTime.now()` goes through this path, today's-date
highlighting was wrong in every widget, and the date picker opened on the wrong
day. Conversion is now timezone-independent, round-trips exactly across the
supported range (BS 1970–2100), and is immune to daylight-saving transitions.

**Action required:** if you compensated for this with your own `-1` day
adjustment, remove it.

### Fixed — the horizontal calendar ignored taps on phones

`HorizontalNepaliCalendar` pinned itself to 8% of the viewport height. With
`showMonth: true` (the default) the date strip was pushed outside that fixed
box, and Flutter does not hit-test children painted outside their parent's
bounds — so `onDateSelected` never fired. It looked completely normal.

Affected every common phone (iPhone SE, iPhone 14, Pixel 7) in the default
configuration. Tablets were unaffected, as was `showMonth: false`.

The widget now sizes to its content and scales with the user's text size.

**Action required:** none, but note the widget is now slightly taller than the
old fixed 8%, and it no longer clips its own content.

### Fixed — the date picker could not select the 30th or 31st

The day grid needed six rows but was given room for five. A `GridView` only
builds what its viewport covers, and scrolling was disabled, so the last row
was never built: the final days of the month did not exist and could not be
tapped. No error was raised — the month simply ended early.

### Fixed — the date picker overflowed

Two independent causes:

* the header `Row` was rigid, and English month names are wider than their
  Nepali equivalents ("Baisakh 2081" vs "बैशाख २०८१"), so **in English the
  picker overflowed at every screen size**, desktop included;
* the picker was pinned to 420×480 regardless of the screen, so it overflowed
  any phone narrower than 420 logical pixels.

It now adapts to the space available, and long labels shrink rather than
overflow.

### Fixed — the date picker's year grid offered unusable years

The year list ran `displayYear - 15 .. displayYear + 14` with no clamping to
the range the calendar has data for. Near either end it offered years that
threw a null-check error when picked. The window is now clamped, and slides
rather than truncating, so a full set of years is always offered.

### Fixed — the calendar overflowed on tablet, desktop and web

`NepaliCalendar` sized its grid as `viewportWidth + 16`, making the calendar as
tall as the window was wide. It overflowed on anything wider than a phone (280
pixels over at 800×600). Cells now cap their height and grow sideways on wide
viewports, and shrink to fit short ones such as a phone in landscape.

### Fixed — `NepaliDateTime` had no value equality

Two instances of the same date compared unequal, and the class could not be
used as a `Map` key or in a `Set`.

```dart
NepaliDateTime(year: 2081, month: 1, day: 1) ==
    NepaliDateTime(year: 2081, month: 1, day: 1); // was false, now true
```

**Action required:** if you relied on identity comparison, use
`identical(a, b)`.

### Fixed — `isToday` disagreed with `now()`

`CalendarUtils.isToday` resolved against the device's local date while
`NepaliDateTime.now()` used Nepal time, so the two disagreed for part of each
day outside Nepal. Both now use Nepal Standard Time. Users in Nepal are
unaffected.

### Added

- `NepaliDateTime.isSameDayAs(other)` — compare dates ignoring the time.
- `NepaliDateTime.dateOnly` — the date with its time stripped, for use as a
  stable map key.
- `NepaliDateTime.nepalTimeZoneOffset` — Nepal's fixed UTC+5:45 offset.
- Out-of-range dates now throw a descriptive `ArgumentError` instead of
  tripping an internal assertion or a null check.

### Deprecated

- `HorizontalNepaliCalendar.textColor` and
  `HorizontalNepaliCalendar.selectedColor` — these have **never had any
  effect**; they were accepted by the constructor and never read. They are
  deprecated rather than wired up, because making a long-dead parameter
  suddenly apply would visibly restyle apps that pass it. Use
  `calendarStyle.cellsStyle` instead. To be removed in 1.0.0.

### Changed

- The `plugin:` block has been removed from `pubspec.yaml`. It declared
  Android/iOS platform support on a package with no platform code, which
  suppressed web and desktop on pub.dev. The package now correctly lists all
  platforms. No code change is required.

---

## 0.0.7

### New Features
- **Modal Date Picker** - `showNepaliDatePicker()` function for dialog-based date selection
- **Three View Modes** - Day, Month, and Year selection views
- **Quick Navigation** - "Today" button and edit mode for fast date selection
- **Fully Configurable** - Works with existing `CalendarConfig` and styling options

---

## 0.0.6

### New Features
- **CalendarBuilder** - Custom builders for events, cells, weekdays, and headers
- **CalendarConfig** - Centralized configuration system
- **Weekend Configuration** - `WeekendType` enum (Saturday, Sunday, both, or Friday-Saturday)
- **Week Start Configuration** - `WeekStartType` enum (Sunday or Monday)
- **Previous/Next Month Days** - Display adjacent month days in dimmed style

### Deprecated
- `NepaliCalendarStyle.showEnglishDate` → Use `CalendarConfig.showEnglishDate`
- `NepaliCalendarStyle.showBorder` → Use `CalendarConfig.showBorder`
- `NepaliCalendarStyle.language` → Use `CalendarConfig.language`
- `HeaderStyle.weekTitleType` → Use `CalendarConfig.weekTitleType`

### Bug Fixes
- Improved performance for large event lists
- Fixed weekend highlighting with custom weekend types
- Enhanced month/year navigation stability

---

## 0.0.5

### New Features
- **HorizontalNepaliCalendar** - Horizontal scrolling calendar widget
- Compact date picker for forms and dialogs

### Improvements
- Enhanced date conversion accuracy
- Improved widget performance

---

## 0.0.4

### Improvements
- Added preview images to README
- Enhanced documentation with visual examples

---

## 0.0.3

### Improvements
- Improved README formatting and structure
- Added better code examples

---

## 0.0.2

### Improvements
- Enhanced API documentation
- Added more usage examples

---

## 0.0.1

### Initial Release
- Nepali calendar widget with Bikram Sambat support
- Nepali ↔ English date conversion
- Event management system
- Customizable styling options
- Bilingual support (Nepali/English)
- Date selection and navigation

