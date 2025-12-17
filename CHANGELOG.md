# CHANGELOG

## 0.0.6

### 🎉 New Features & Improvements

#### **NepaliCalendarController**

Introduced comprehensive state management for calendar navigation and control.

**Methods:**
- `jumpToToday()` - Navigate to current date
- `previousMonth()` - Go to previous month
- `nextMonth()` - Go to next month
- `jumpToDate(NepaliDateTime date)` - Navigate to specific date
- `selectedDate` - Get currently selected date

**Usage:**
```dart
final controller = NepaliCalendarController();

NepaliCalendar(
  controller: controller,
  onDayChanged: (date) => print('Selected: $date'),
)

// Programmatic navigation
controller.jumpToToday();
controller.jumpToDate(NepaliDateTime(2080, 1, 1));
```

#### **CalendarBuilder<T>**

Added powerful customization system for all calendar components.

**Builders:**
- `eventBuilder` - Custom event list item rendering
- `cellBuilder` - Custom calendar cell rendering
- `weekdayBuilder` - Custom weekday header rendering
- `headerBuilder` - Custom calendar header rendering

**Usage:**
```dart
NepaliCalendar<MyEvent>(
  calendarBuilder: CalendarBuilder<MyEvent>(
    eventBuilder: (context, index, date, event) {
      return MyCustomEventWidget(event: event);
    },
    cellBuilder: (data) {
      return MyCustomCell(data: data);
    },
  ),
)
```

#### **CalendarConfig**

Introduced centralized configuration model for better organization and consistency.

**Properties:**
- `showEnglishDate` - Display English dates below Nepali dates
- `showBorder` - Show borders around calendar cells
- `language` - Calendar language (Nepali/English)
- `weekendType` - Weekend day configuration
- `weekStartType` - Week start day configuration
- `weekTitleType` - Weekday title format

**Usage:**
```dart
NepaliCalendarStyle(
  config: CalendarConfig(
    showEnglishDate: true,
    language: Language.nepali,
    weekendType: WeekendType.saturdayAndSunday,
    weekStartType: WeekStartType.monday,
  ),
)
```

#### **Weekend & Week Configuration**

Added flexible weekend and week start configuration.

**WeekendType enum:**
- `saturdayAndSunday` - Both Saturday and Sunday
- `fridayAndSaturday` - Both Friday and Saturday
- `saturday` - Only Saturday (Nepal standard)
- `sunday` - Only Sunday

**WeekStartType enum:**
- `sunday` - Week starts on Sunday (default)
- `monday` - Week starts on Monday

**Usage:**
```dart
config: CalendarConfig(
  weekendType: WeekendType.saturdayAndSunday,
  weekStartType: WeekStartType.monday,
)
```

#### **Display Enhancements**

- Calendar now displays previous and next month days in dimmed style
- Improved event card styling with better visual hierarchy
- Enhanced date cell rendering with better state management

### ⚠️ Deprecations

The following properties are deprecated and will be removed in version 1.0.0. Please migrate to the new `CalendarConfig` approach.

#### In `NepaliCalendarStyle`:

| Deprecated Property | Replacement | Migration |
|---------------------|-------------|-----------|
| `showEnglishDate` | `config.showEnglishDate` | Move to `CalendarConfig` |
| `showBorder` | `config.showBorder` | Move to `CalendarConfig` |
| `language` | `config.language` | Move to `CalendarConfig` |

**Before (Deprecated):**
```dart
NepaliCalendarStyle(
  showEnglishDate: true,
  showBorder: true,
  language: Language.nepali,
)
```

**After (Recommended):**
```dart
NepaliCalendarStyle(
  config: CalendarConfig(
    showEnglishDate: true,
    showBorder: true,
    language: Language.nepali,
  ),
)
```

#### In `HeaderStyle`:

| Deprecated Property | Replacement | Migration |
|---------------------|-------------|-----------|
| `weekTitleType` | `config.weekTitleType` | Move to `CalendarConfig` |

**Before (Deprecated):**
```dart
NepaliCalendarStyle(
  headersStyle: HeaderStyle(
    weekTitleType: TitleFormat.half,
  ),
)
```

**After (Recommended):**
```dart
NepaliCalendarStyle(
  config: CalendarConfig(
    weekTitleType: TitleFormat.half,
  ),
  headersStyle: HeaderStyle(),
)
```

### 📝 Migration Guide

#### Step 1: Update Calendar Style

Replace individual configuration properties with `CalendarConfig`:

```dart
// Old approach
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    showEnglishDate: true,
    showBorder: true,
    language: Language.nepali,
    headersStyle: HeaderStyle(
      weekTitleType: TitleFormat.half,
    ),
  ),
)

// New approach
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
      showBorder: true,
      language: Language.nepali,
      weekTitleType: TitleFormat.half,
      weekendType: WeekendType.saturday,
      weekStartType: WeekStartType.sunday,
    ),
    headersStyle: HeaderStyle(),
  ),
)
```

#### Step 2: Add Controller (Optional)

If you need programmatic control:

```dart
class _MyWidgetState extends State<MyWidget> {
  late final NepaliCalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NepaliCalendarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NepaliCalendar(
      controller: _controller,
      // ... other properties
    );
  }
}
```

#### Step 3: Use CalendarBuilder for Customization (Optional)

Replace custom event rendering:

```dart
NepaliCalendar<MyEvent>(
  eventList: events,
  calendarBuilder: CalendarBuilder<MyEvent>(
    eventBuilder: (context, index, date, event) {
      return MyCustomEventWidget(event: event);
    },
  ),
)
```

### 🛠 Bug Fixes

- Fixed date selection state management
- Improved performance for large event lists
- Fixed weekend highlighting with custom weekend types
- Resolved issues with month navigation edge cases
- Enhanced month/year navigation stability

### 💡 Best Practices

For new projects, always use the new `CalendarConfig` approach:

```dart
// ✅ Recommended
NepaliCalendar(
  controller: NepaliCalendarController(),
  calendarStyle: NepaliCalendarStyle(
    config: CalendarConfig(
      showEnglishDate: true,
      language: Language.nepali,
      weekendType: WeekendType.saturday,
    ),
  ),
)

// ❌ Deprecated (still works but will be removed)
NepaliCalendar(
  calendarStyle: NepaliCalendarStyle(
    showEnglishDate: true,
    language: Language.nepali,
  ),
)
```

### 📦 What's Next?

Planned for future releases:
- Date range selection
- Multi-date selection
- Custom event colors per event type
- Swipe gestures for month navigation
- Accessibility improvements

---

## 0.0.5

### Features

* **Horizontal Calendar**
  * Introduced a horizontal calendar layout for enhanced user experience
  * Compact date picker perfect for forms and dialogs
  * Smooth scrolling navigation

### Improvements

* Fixed various minor issues to improve stability and usability
* Enhanced date conversion accuracy
* Improved widget performance

---

## 0.0.4

### Documentation

* Added preview images of Nepali calendar features to `README.md` for better visualization
* Enhanced documentation with visual examples

---

## 0.0.3

### Documentation

* Fixed minor formatting issues in documentation
* Improved `README.md` formatting and structure
* Added better code examples

---

## 0.0.2

### Documentation

* Improved documentation for better clarity and usage guidance
* Enhanced API documentation
* Added more usage examples

---

## 0.0.1

### Initial Release

* **Core Features**
  * Nepali calendar widget with Bikram Sambat support
  * Nepali ↔ English date conversion
  * Basic event management
  * Customizable styling options
  * Month and year navigation
  * Date selection functionality

* **Localization**
  * Nepali language support
  * English language support

* **Styling**
  * Customizable colors
  * Configurable text styles
  * Border options

---

## Version Compatibility

| Package Version | Flutter SDK | Dart SDK |
|----------------|-------------|----------|
| 0.0.6 | >=1.17.0 | ^3.6.0 |
| 0.0.5 | >=1.17.0 | ^3.0.0 |
| 0.0.4 | >=1.17.0 | ^3.0.0 |
| 0.0.3 | >=1.17.0 | ^3.0.0 |
| 0.0.2 | >=1.17.0 | ^3.0.0 |
| 0.0.1 | >=1.17.0 | ^3.0.0 |

## Upgrade Path

### From 0.0.5 → 0.0.6
- **Action Required**: Update to use `CalendarConfig` to avoid deprecation warnings
- **Breaking Changes**: None (deprecated APIs still work)
- **New Features**: Controller, CalendarBuilder, weekend/week configuration

### From 0.0.4 → 0.0.5
- **Action Required**: None
- **Breaking Changes**: None
- **New Features**: Horizontal calendar

### From 0.0.3 → 0.0.4
- **Action Required**: None
- **Breaking Changes**: None
- **New Features**: Documentation improvements

### From 0.0.1-0.0.2 → 0.0.3+
- **Action Required**: None
- **Breaking Changes**: None
- **New Features**: Better documentation

