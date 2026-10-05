# Migration Guide

How to move to `nepali_calendar_plus` **0.1.0** from 0.0.7 or earlier, and what
has changed since. If you are already on 0.1.0, start at
[Changes since 0.1.0](#changes-since-010).

**Nothing has been removed.** Every deprecated API still works in 0.1.0 and will
keep working for the whole 0.x series. You will see analyzer warnings, not
errors, and you can migrate at your own pace.

Deprecated APIs are removed in **1.0.0**. Everything in this guide should be done
before then.

---

## Read this first: dates may shift by one day

**This is the only change that can silently produce wrong dates in your app.**

Up to 0.0.7, `DateTime.toNepaliDateTime()` shifted the value into Nepal Standard
Time before converting, and then added an extra day when the *device's* timezone
happened to be exactly UTC+5:45. The result therefore depended on where the user
was standing:

- A device in Nepal produced a date **one day later** than the true date, for any
  date after 1986.
- A device east of Nepal could produce one **a day earlier**.

Conversion is now timezone-independent and round-trips exactly.

### What to do

If you added a manual correction to compensate  anything of this shape 

```dart
// Before: workaround for the old off-by-one
final nepali = date.toNepaliDateTime().subtract(const Duration(days: 1));
```

remove it:

```dart
// After
final nepali = date.toNepaliDateTime();
```

Search your codebase for `Duration(days: 1)` near any date conversion. If you
never added a workaround, you need to do nothing  your dates are simply correct
now.

### Related

`CalendarUtils.isToday` now resolves "today" against Nepal Standard Time, matching
`NepaliDateTime.now()`. Previously the two disagreed for part of each day outside
Nepal, so a calendar could highlight one day while `.now()` reported another.
Users inside Nepal are unaffected. No action required.

---

## Behaviour changes in 0.1.0

These change what you see without changing any API.

### Months are drawn at the height they need

A Nepali month spans five or six weeks depending on which weekday it starts on.
Up to 0.0.7 every month was padded to six rows, so a five-week month such as
Bhadra 2083 carried a whole trailing row of the *next* month's dates. Each month
is now drawn at its natural height, and the calendar's height follows the month on
screen, interpolating as you swipe.

**If the calendar sits above other content that must not shift**, restore the old
fixed height:

```dart
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(sixWeekMonthsEnforced: true),
  ),
)
```

`NepaliYearCalendar` and `NepaliDatePicker` are unaffected  they always use six
rows, so year tiles stay aligned and the picker dialog does not resize while
paging.

### The event list starts at the top

The list below the calendar was previously centred in its space, so a month with
one or two events appeared to float in the middle. It now begins directly under
the grid. No action required.

### `NepaliDateTime` compares by value

```dart
NepaliDateTime(year: 2081, month: 1, day: 1) ==
    NepaliDateTime(year: 2081, month: 1, day: 1);
// 0.0.7: false    0.1.0: true
```

`NepaliDateTime` can now be used as a `Map` key or in a `Set`, which was
impossible before. If you were relying on identity comparison, switch to
`identical(a, b)`.

Use `isSameDayAs` when the time components are irrelevant:

```dart
final a = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 9);
final b = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 17);
a == b;             // false  the hours differ
a.isSameDayAs(b);   // true
```

### `CalendarUtils.calenderyearStart` is now `const`

Assigning to it is a compile error rather than a silent corruption. It was never
safe to assign  doing so broke every date calculation and page index in the
package at once. Remove any assignment.

### `NepaliCalendarStyle.copyWith` applies `weekendType` and `weekStartType`

Up to 0.0.7 both were accepted and then silently discarded, so
`copyWith(weekStartType: ...)` returned a style identical to the original. They
now take effect. If you were passing either one and relying on it doing nothing,
remove it.

### `EventListData` has been removed

This class was declared and exported but never used by any widget or builder in
the package. If you referenced it, delete the reference  there was nothing it
could do. Use `CalendarBuilder.eventBuilder` to render event rows.

---

## Changes since 0.1.0

No API was removed or changed shape, so these need no code changes -- but each
changes behaviour you may have relied on.

### Invalid dates throw, in release builds too

`NepaliDateTime` checked its fields with `assert`s, which release builds strip.
A released app could build day 32 of a 31-day month -- it converted as the 1st
of the next month -- and a year outside the data failed later with an unhelpful
null-check error. Construction now throws a `RangeError` naming the field, and
the day is checked against the real length of its month. `NepaliDateTimeRange`
likewise throws an `ArgumentError` when its end is before its start.

**What to do:** if your app builds dates from arithmetic (day + 1, a stored day
number moved to another month), clamp the day to the month first:
`CalendarUtils.nepaliYears[year]![month]` is its length.

### `CalendarUtils.nepaliYears` is read-only

It is now a `const` map. Reading it is unchanged; writing to it, or to one of
its lists, throws `UnsupportedError`. Writing to it was never safe -- it broke
every date calculation in the package at once.

### `showNepaliDatePicker` returns on tap

Tapping a date now closes the dialog and returns it, and tapping outside returns
`null`; the Cancel / OK row is gone. Pass `autoConfirm: false` for the old flow.
The `NepaliDatePicker` widget itself is unchanged: placed on a page, it still
waits for OK unless you pass `autoConfirm: true`.

### Haptics are opt-in

`CalendarConfig.hapticFeedback` is new and defaults to `CalendarHaptics.none`,
so nothing changes unless you ask for it. `CalendarHaptics.light` is the
recommended value for date taps.

### BS 1969 and BS 2200 convert correctly

AD dates for most of BS 1969 were wrong, and BS 2200 was a placeholder year
that pushed every AD date after it a week late. See
[Supported date range](#supported-date-range).

---

## Deprecations

### 1. Configuration moves into `CalendarConfig`

**What it was.** `NepaliCalendarStyle` carried behaviour settings 
`showEnglishDate`, `showBorder`, `language`  directly alongside its appearance
settings. `HeaderStyle` carried `weekTitleType`.

**Why that was a problem.** Behaviour and appearance were mixed into one object,
so there was no way to change the language without also handing the widget a
style  which suppresses theming. Related settings lived in unrelated places.

**What replaces it.** `CalendarConfig`, holding every behavioural setting in one
object. `NepaliCalendarStyle` now describes appearance only.

**Migration difficulty: Very Easy.** Mechanical; the field names are unchanged.

```dart
// Before
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    showEnglishDate: true,
    showBorder: true,
    language: Language.nepali,
    headersStyle: HeaderStyle(weekTitleType: TitleFormat.half),
  ),
)
```

```dart
// After
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
      showBorder: true,
      language: Language.nepali,
      weekTitleType: TitleFormat.half,
      // also available here, and not reachable from the old properties:
      weekendType: WeekendType.saturday,
      weekStartType: WeekStartType.sunday,
      sixWeekMonthsEnforced: false,
    ),
  ),
)
```

**Steps**

1. Wrap the behavioural properties in `config: CalendarConfig(...)`.
2. Move `weekTitleType` out of `headersStyle` and into `config`.
3. Leave `cellsStyle` and `headersStyle` where they are  those are appearance.

If you pass both, `config` wins.

---

### 2. Builders move into `CalendarBuilder`

**What it was.** `NepaliCalendar` took `headerBuilder` and `eventBuilder` as
individual parameters.

**Why that was a problem.** Each new customisation point meant another
constructor parameter. There was no single place to see what could be customised,
and no way to pass a customisation set around as one value.

**What replaces it.** `CalendarBuilder`, holding every builder, with `copyWith`.

**Migration difficulty: Very Easy.** The callback signatures are unchanged.

```dart
// Before
NepaliCalendar(
  headerBuilder: (date, controller) => MyHeader(date),
  eventBuilder: (context, index, date, event) => MyEventRow(event),
)
```

```dart
// After
NepaliCalendar(
  calendarBuilder: CalendarBuilder<MyEventType>(
    headerBuilder: (date, controller) => MyHeader(date),
    eventBuilder: (context, index, date, event) => MyEventRow(event),
    // also available, and not reachable from the old parameters:
    cellBuilder: (data) => MyCell(data),
    weekdayBuilder: (data) => MyWeekday(data),
  ),
)
```

> The class is `CalendarBuilder`, not `NepaliCalendarBuilder`. Some 0.0.7 doc
> comments used the wrong name; there has never been a class by that name.

---

### 3. A date can have more than one event

**What it was.** `CalendarCellData.event`  a single nullable event per date.
Internally the package searched the event list with `firstWhere` and kept only the
first match.

**Why that was a problem.** Two real cases were impossible to render: a date with
several events, and a date carrying both an ordinary event and a holiday. In the
second case, if the ordinary event happened to come first in your list, the date
did not read as a holiday at all.

**What replaces it.** `CalendarCellData.events`, plus the derived
`hasEvents` and `isHoliday` getters. `isHoliday` is true if **any** event on the
date is a holiday.

**Migration difficulty: Easy.** A null check becomes a list check.

```dart
// Before
cellBuilder: (data) {
  final event = data.event;
  if (event == null) return PlainCell(data.day);
  return EventCell(data.day, event, isHoliday: event.isHoliday);
}
```

```dart
// After
cellBuilder: (data) {
  if (!data.hasEvents) return PlainCell(data.day);
  return EventCell(data.day, data.events, isHoliday: data.isHoliday);
}
```

`data.event` still returns the first event, so existing builders keep working
untouched until 1.0.0.

---

### 4. `checkIsHoliday` is unused  set `isHoliday` on the event

**What it was.** A required callback on `NepaliCalendar`, mandatory whenever
`eventList` was supplied.

**Why that was a problem.** Its return value was **never read**. The calendar has
always determined holidays from `CalendarEvent.isHoliday`. The callback existed
only to be enforced by an assertion.

**What replaces it.** `CalendarEvent.isHoliday`, which is what was already being
used.

**Migration difficulty: Very Easy.** Delete the parameter.

```dart
// Before
NepaliCalendar(
  eventList: events,
  checkIsHoliday: (event) => event.isHoliday,   // never consulted
)
```

```dart
// After
NepaliCalendar(
  eventList: [
    CalendarEvent(
      date: NepaliDateTime(year: 2081, month: 1, day: 1),
      isHoliday: true,
      additionalInfo: 'New Year',
    ),
  ],
)
```

The assertion requiring `checkIsHoliday` alongside `eventList` is gone, so the
parameter is now optional. Passing it has no effect.

---

### 5. Internal widgets are no longer public API

**What it was.** `CalendarCell`, `CalendarGrid`, `CalendarHeader`,
`CalendarMonthView`, `EmptyCell`, `EventList` and `WeekdayHeader` were all
importable.

**Why that was a problem.** None of them was designed as public API  they became
public because the package exported every internal file. That meant their
constructors could not change without breaking someone, which blocked internal
improvements.

**What replaces it.** The builder hooks, which are designed for this and receive
richer data:

| Instead of using | Use |
|---|---|
| `CalendarCell` | `CalendarBuilder.cellBuilder`  gets a full `CalendarCellData` |
| `CalendarHeader` | `CalendarBuilder.headerBuilder` |
| `WeekdayHeader` | `CalendarBuilder.weekdayBuilder` |
| `EventList` | `CalendarEventIndex.eventsInMonth`, rendered your way |
| `CalendarGrid`, `CalendarMonthView` | `NepaliCalendar` itself |
| `EmptyCell` | nothing  it rendered `SizedBox.shrink()` |

**Migration difficulty: Easy to Medium**, depending on how deeply you reached in.
Replacing `CalendarHeader` or `WeekdayHeader` is straightforward. Rebuilding on
top of `CalendarGrid` or `CalendarMonthView` means moving to `NepaliCalendar` and
expressing the difference through builders.

```dart
// Before  driving the internals directly
CalendarMonthView<String>(
  year: 2081,
  month: 1,
  selectedDate: selected,
  eventList: events,
  calendarStyle: style,
  onDaySelected: onTap,
)
```

```dart
// After
NepaliCalendar<String>(
  initialDate: NepaliDateTime(year: 2081, month: 1, day: 1),
  eventList: events,
  calendarStyle: style,
  onDayChanged: onTap,
  calendarBuilder: CalendarBuilder<String>(
    cellBuilder: (data) => MyCell(data),   // if you were customising cells
  ),
)
```

To render your own event list, query the index directly:

```dart
final index = CalendarEventIndex.fromList(events);
final monthEvents = index.eventsInMonth(2081, 1);   // O(1)
final dayEvents = index.eventsOn(someDate);         // O(1)
```

**If none of the builder hooks covers your case, please open an issue describing
it.** These widgets are not removed until 1.0.0, and a genuine use case is a
reason to add a proper hook before then.

---

### 6. `HorizontalNepaliCalendar.textColor` and `selectedColor`

**What it was.** Two colour parameters on the constructor.

**Why that was a problem.** **Neither was ever read.** They were accepted in every
version up to 0.0.7 and silently ignored, so passing them did nothing.

They are deprecated rather than wired up on purpose: making a long-dead parameter
suddenly take effect would visibly change the appearance of any app that passes
one.

**What replaces it.** `calendarStyle.cellsStyle`.

**Migration difficulty: Very Easy**  but note that your colours will now
**actually apply**, which may be a visible change if you had been passing values
that did nothing.

```dart
// Before  both silently ignored
HorizontalNepaliCalendar(
  textColor: Colors.indigo,
  selectedColor: Colors.amber,
  onDateSelected: onSelect,
)
```

```dart
// After  these take effect
HorizontalNepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    cellsStyle: CellStyle(
      dateTextColor: Colors.indigo,
      selectedColor: Colors.amber,
    ),
  ),
  onDateSelected: onSelect,
)
```

---

## Recommended: adopt the theme system

Not a migration  a new capability in 0.1.0 worth taking up. `NepaliCalendarStyle`
still works exactly as before.

Up to 0.0.7 several colours were hard-coded (`Colors.black` for dates,
`Colors.white` on highlights, grey for dimmed dates and borders), which made a
dark theme impossible. Those are now `CellStyle` fields, and
`NepaliCalendarTheme` styles every calendar widget beneath it at once:

```dart
MaterialApp(
  builder: (context, child) => NepaliCalendarTheme(
    data: NepaliCalendarThemeData.fromContext(context),
    child: child!,
  ),
  home: const HomePage(),
)
```

`fromContext` derives the palette from your Material `ColorScheme`, so the
calendar follows your app's light/dark mode with no further configuration.

### Two things to know

**Place it above the `Navigator`**  `MaterialApp.builder` is the simplest spot.
Inside `home:` it covers that subtree and any dialog opened from it, but *not* a
route pushed with `Navigator.push`. That is ordinary Flutter behaviour and applies
to Material's own `Theme` in the same position.

**An explicit `calendarStyle` beats the theme.** If you pass a style whose
appearance was customised, the theme is ignored for that widget  so adding a
theme never changes a widget you had already styled by hand. To combine them, use
`copyWith` on the theme data rather than passing a style:

```dart
NepaliCalendarTheme(
  data: NepaliCalendarThemeData.fromContext(context)
      .copyWith(todayColor: Colors.orange),
  child: const NepaliCalendar(),
)
```

Configuration is carried across rather than suppressed, so passing a style purely
to set the language still gets you themed colours.

---

## Removal schedule

| Version | Status |
|---|---|
| 0.0.7 | Last release before these deprecations |
| **0.1.0** | All deprecated APIs present and working. Warnings only. |
| 0.x | Deprecated APIs remain available |
| **1.0.0** | All deprecated APIs removed |

To find everything that needs attention in your own project:

```sh
flutter analyze
```

Every deprecated member reports its replacement in the warning text.

---

## Supported date range

The bundled calendar data covers **BS 1969 to BS 2250**, which is
**AD 1912-04-12 to AD 2194-04-15**. Dates outside this range throw an `ArgumentError`
from `toNepaliDateTime()`, and `NepaliDatePicker` and `NepaliDateRangePicker`
clamp `minDate` / `maxDate` into it rather than throwing.

Up to 0.1.0, BS 1969 itself did not convert correctly: `toDateTime()` counted
from BS 1969-09-18 with an absolute difference, so most of the year came out
mirrored onto the wrong side of it (BS 1969-01-01 gave AD 1913-09-22; it is
AD 1912-04-12), and AD -> BS rejected the whole year. Both directions now work
for every day in the range.

BS 2200 was listed as 372 days with every month 31 -- a placeholder inherited
from upstream data -- which pushed every AD date after it a week late. It is now
a 366-day year, so AD dates for BS 2201-2250 are six days earlier than in 0.1.0.
No published calendar reaches that far: years past about BS 2100 are
projections.
