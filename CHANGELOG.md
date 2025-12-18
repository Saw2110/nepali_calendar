# CHANGELOG

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

