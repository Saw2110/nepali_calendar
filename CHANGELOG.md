# Changelog

## 0.1.1

Platform-native polish. Everything here is additive or a fix -- no API was
removed or changed shape, so upgrading from 0.1.0 needs no code changes.

### Added

- **Screen-reader support across every calendar.** Date cells in
  `NepaliCalendar`, `NepaliYearCalendar` and `HorizontalNepaliCalendar` now
  announce the whole date and its state rather than a bare number. A cell that
  read as "१५" now reads as "बैशाख, १५, २०८१, शनिबार, आज, बिदा, २ कार्यक्रम".
  `NepaliDatePicker` already did this; the phrasing is now shared, so all four
  announce a date identically.
- **Ink feedback and keyboard support on date cells.** Day cells are now
  `InkWell`s rather than bare `GestureDetector`s, which gives them the Android
  ripple, a hover highlight on desktop and web, a focus ring, and a pointer
  cursor. It also makes the grid keyboard-navigable: Tab reaches it, the arrow
  keys traverse it by position, and Enter or Space selects the focused date.
- **`CalendarConfig.hapticFeedback`**, taking a `CalendarHaptics` value
  (default `CalendarHaptics.light`). Selecting a date answers the tap through
  touch as well as sight, at a strength you choose: `none`, `selection`,
  `light`, `medium` or `heavy`. `CalendarHaptics.perform()` is public, so a
  custom `cellBuilder` can match the built-in cells.

  The default is `light` rather than `selection` deliberately. On Android
  `selection` maps to `HapticFeedbackConstants.CLOCK_TICK`, which is meant for
  a picker wheel passing detents -- many phones render it too faintly to feel,
  and some not at all. `light` maps to `VIRTUAL_KEY`, the tick the system
  keyboard uses for a keypress, which is both reliably felt and the right
  metaphor for a discrete action like choosing a date.

  Only a physical phone can render any of this: desktop, web and the iOS
  Simulator have no haptic hardware, and Android gates haptics behind the
  system touch-feedback setting.
- **Tooltips and a semantic header on the month bar.** The chevrons carry
  "Previous month" / "अघिल्लो महिना" labels -- they were previously unlabelled
  buttons -- and the month and year read as a single header node.
- **`debugFillProperties` on the public widgets**, so `NepaliCalendar`,
  `NepaliYearCalendar`, `NepaliDatePicker` and `HorizontalNepaliCalendar` show
  their configuration in the Flutter Inspector and in widget diagnostics.

### Fixed

- **A large system font no longer overflows the calendar.** At high text scale
  the weekday header overflowed its row by up to 43px, and day numbers spilled
  out of their cells. Cell text now follows the user's setting as far as the
  cell can hold it and then stops, and the weekday names scale down to fit
  rather than overflowing. Cell geometry is unchanged at normal text sizes.
- **The picker's dialog buttons follow the app's localizations.** An English
  picker now takes its OK and Cancel labels from `MaterialLocalizations`, so it
  matches the app's other dialogs instead of hard-coding English. A Nepali
  picker keeps its own labels, as Flutter ships no Nepali translations. Passing
  `confirmText` or `cancelText` still overrides both.
- **Adjacent-month dates announce themselves as such** in `NepaliDatePicker`,
  which previously gave them the same label as in-month dates.

### Performance

- Each month page is now its own repaint boundary, so swiping re-composites a
  cached raster instead of repainting 42 cells every frame.

### Deprecations

No change. The members deprecated in 0.1.0 still carry their original promise:
they keep working until 1.0.0.

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
