# Changelog

## 0.0.8

### Added

* Theme system with automatic Material light/dark mode support
* `NepaliYearCalendar` widget
* Support for multiple events on the same date
* `CalendarEventIndex` for faster event lookup
* Additional calendar cell color customization
* `NepaliDateTime.isSameDayAs()`
* `NepaliDateTime.dateOnly`
* `NepaliDateTime.nepalTimeZoneOffset`

### Changed

* Improved event rendering performance
* Improved date conversion accuracy
* Improved responsive layouts across all calendar widgets
* Improved holiday detection
* Better theme integration with existing widgets

### Fixed

* Nepal timezone date conversion issues
* Incorrect "Today" highlighting
* Horizontal calendar tap detection
* Date picker missing last week of some months
* Date picker overflow and responsive layout issues
* Invalid year selection near supported date limits
* Calendar overflow on desktop, tablet, and web
* `NepaliDateTime` equality comparison
* General stability and performance improvements

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
* `HorizontalNepaliCalendar.textColor`
* `HorizontalNepaliCalendar.selectedColor`

### Migration Notes

If upgrading from **v0.0.7** or earlier:

* Remove any manual `-1 day` workaround previously used for Nepali date conversion.
* Replace deprecated event APIs with the new multiple-event APIs where applicable.
* Prefer `CalendarEvent.isHoliday` instead of `checkIsHoliday`.
* Migrate custom event rendering to use `CalendarCellData.events`.

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
