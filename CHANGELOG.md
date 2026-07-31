# Changelog

## 0.1.0

> **Minor version, not a patch.** This release changes behaviour that existing
> apps depend on. The date conversion fix below can change which day your app
> displays. Please read it before upgrading.

### ⚠️ Breaking: date conversion no longer depends on the device's timezone

**If you added a manual day-offset to work around the old conversion, remove it 
or your dates will now be wrong in the other direction.**

Up to 0.0.7, `DateTime.toNepaliDateTime()` shifted the value into Nepal Standard
Time before converting, then added an extra day whenever the *device's* timezone
was exactly UTC+5:45. The result depended on where the user was standing:

| Device location | Result up to 0.0.7 |
| --------------- | ------------------ |
| Nepal (UTC+5:45) | **one day later** than the true date, for any date after 1986 |
| East of Nepal | could be **one day earlier** |
| Elsewhere | correct |

Conversion is now timezone-independent and round-trips exactly.

```dart
// Before  workaround for the old off-by-one
final nepali = date.toNepaliDateTime().subtract(const Duration(days: 1));

// After
final nepali = date.toNepaliDateTime();
```

Search your project for `Duration(days: 1)` near any date conversion. If you
never added a workaround, no action is needed  your dates are simply correct
now.

Relatedly, `CalendarUtils.isToday` now resolves "today" against Nepal Standard
Time, matching `NepaliDateTime.now()`. The two previously disagreed for part of
each day outside Nepal, so a calendar could highlight one day while `.now()`
reported another. Users inside Nepal are unaffected.

See [doc/MIGRATION.md](doc/MIGRATION.md) for the full upgrade guide.

### Added

* Theme system with automatic Material light/dark mode support
* `NepaliYearCalendar` widget
* Support for multiple events on the same date
* `CalendarEventIndex` for faster event lookup
* Additional calendar cell color customization
* `CalendarConfig.sixWeekMonthsEnforced` to pad every month out to six week rows
* `CalendarUtils.weekRowsInMonth` and `CalendarUtils.maxWeekRowsInMonth`
* `WeekUtils.normalizeWeekday`
* `NepaliDateTime.isSameDayAs()`
* `NepaliDateTime.dateOnly`
* `NepaliDateTime.nepalTimeZoneOffset`

### Changed

* `NepaliCalendar` draws each month at the number of week rows it needs, five or
  six, instead of always six; its height follows the month on screen and
  interpolates while swiping between the two
* Improved event rendering performance
* Improved date conversion accuracy
* Improved responsive layouts across all calendar widgets
* Improved holiday detection
* Better theme integration with existing widgets

### Fixed

* Nepal timezone date conversion  see the breaking-change note above
* Five-week months showed a whole trailing row of the next month's dates
* Event list floated in the middle of the space below the calendar when a month
  had too few events to fill it; it now starts directly under the grid
* `NepaliCalendarStyle.copyWith` accepted `weekendType` and `weekStartType` and
  silently discarded them; both now take effect via `config`
* With `showBorder: true`, table rules were painted behind each cell, so an
  opaque cell background covered them. Today's cell erased its own right and
  bottom rules and a selected cell tinted them, while the weekday header row,
  having no background, kept all of its. The rules now draw over the cells
* Cell size was derived from the full width rather than the width left after
  the month view's padding, so every row was slightly shorter than the layout
  budget assumed and each month page ended with an unused strip
* Horizontal calendar tap detection
* Date picker missing last week of some months
* Date picker overflow and responsive layout issues
* Invalid year selection near supported date limits
* Calendar overflow
* `NepaliDateTime` equality comparison
* General stability and performance improvements

### Removed

* `EventListData`  declared but never used by any builder or widget. Use
  `CalendarBuilder.eventBuilder` to render event rows.

### Deprecated

The following APIs are deprecated and will be removed in **v1.0.0**:

* `NepaliCalendar.checkIsHoliday`
* `CalendarCellData.event`
* `CalendarCell.event`
* Internal rendering widgets:

  * `CalendarCell`
  * `CalendarGrid`
  * `CalendarHeader`
  * `CalendarMonthView`
  * `EmptyCell`
  * `EventList`
  * `WeekdayHeader`
  * `CalendarItem`
* `HorizontalNepaliCalendar.textColor`
* `HorizontalNepaliCalendar.selectedColor`
* Style properties superseded by `CalendarConfig`:

  * `NepaliCalendarStyle.showEnglishDate`
  * `NepaliCalendarStyle.showBorder`
  * `NepaliCalendarStyle.language`
  * `HeaderStyle.weekTitleType`
* Builder parameters superseded by `CalendarBuilder`:

  * `NepaliCalendar.headerBuilder`
  * `NepaliCalendar.eventBuilder`


### Migration Notes

If upgrading from **v0.0.7** or earlier:

* Remove any manual `-1 day` workaround previously used for Nepali date conversion.
* Replace deprecated event APIs with the new multiple-event APIs where applicable.
* Prefer `CalendarEvent.isHoliday` instead of `checkIsHoliday`.
* Migrate custom event rendering to use `CalendarCellData.events`.
* Set `CalendarConfig.sixWeekMonthsEnforced: true` if `NepaliCalendar` must keep
  a constant height, as it did previously  relevant when it sits above content
  that should not shift as the user pages through months. `NepaliYearCalendar`
  and `NepaliDatePicker` are unaffected and always use six rows.

---

## 0.0.7

### Added

* Modal date picker with `showNepaliDatePicker()`
* Day, month, and year selection views
* Today shortcut and quick year navigation
* Support for existing calendar configuration and styling

---

## 0.0.6

### Added

* `CalendarBuilder` for custom widget rendering
* `CalendarConfig` for centralized configuration
* Configurable weekend support
* Configurable week start day
* Previous and next month date display

### Deprecated

* `NepaliCalendarStyle.showEnglishDate` → `CalendarConfig.showEnglishDate`
* `NepaliCalendarStyle.showBorder` → `CalendarConfig.showBorder`
* `NepaliCalendarStyle.language` → `CalendarConfig.language`
* `HeaderStyle.weekTitleType` → `CalendarConfig.weekTitleType`

### Fixed

* Improved event rendering performance
* Weekend highlighting issues
* Month and year navigation stability

---

## 0.0.5

### Added

* `HorizontalNepaliCalendar`
* Compact date picker widget

### Changed

* Improved date conversion
* Improved widget performance

---

## 0.0.4

### Changed

* Added README preview images
* Improved documentation

---

## 0.0.3

### Changed

* Improved README structure
* Added more examples

---

## 0.0.2

### Changed

* Improved API documentation
* Added additional usage examples

---

## 0.0.1

### Added

* Nepali calendar widget
* Bikram Sambat date support
* Nepali and English date conversion
* Event management
* Customizable calendar styling
* Nepali and English language support
* Date selection and navigation
