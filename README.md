# Nepali Calendar Flutter App

A Flutter application that displays a Nepali calendar with support for events, holidays, and customizable styles. The app allows users to navigate through months and years, view events, and mark holidays.

## Features

- **Nepali Calendar**: Displays dates in the Nepali calendar format.
- **Event Management**: Add and display events on specific dates.
- **Holiday Marking**: Mark specific dates as holidays.
- **Customizable Styles**: Customize the appearance of the calendar, including colors and text styles.
- **Responsive Design**: Works on both mobile and tablet devices.

## Folder Structure

``` dart
lib
├─ nepalicalender.dart
└─ src
   ├─ calendar_widget.dart
   ├─ extensions
   │  └─ date_extensions.dart
   ├─ models
   │  ├─ calendar_style.dart
   │  ├─ event.dart
   │  └─ nepali_date_time.dart
   ├─ src.dart
   ├─ utils
   │  └─ calendar_utils.dart
   └─ widgets
      ├─ calendar_cell.dart
      ├─ calendar_grid.dart
      ├─ calendar_header.dart
      ├─ calendar_month_view.dart
      ├─ empty_cell.dart
      ├─ event_list.dart
      └─ weekday_header.dart
```

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- An IDE like Android Studio or VS Code with the Flutter plugin installed.

### Installation

1. **Add the dependency**:

   Add the following to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     mycalendar:
       path: https://github.com/Saw2110/nepali_calendar.git
   ```

2. **Install dependencies**:

   Run the following command to install the dependencies:

   ```bash
   flutter pub get
   ```

3. **Run the app**:

   Use the following command to run the app:

   ```bash
   flutter run
   ```

## Usage

- **Navigating the Calendar**: Use the left and right arrow buttons to navigate between months and years.
- **Adding Events**: Modify the `eventList` in the `HomeScreen` to add events to specific dates.
- **Marking Holidays**: Use the `checkIsHoliday` function to mark specific events as holidays.

## Customization

You can customize the appearance of the calendar by modifying the `MyCalendarStyle` class. Available customization options include:

- `selectedDateColor`: Color for the selected date.
- `selectedTextColor`: Text color for the selected date.
- `todayColor`: Color for today's date.
- `holidayColor`: Color for holidays.
- `headerTextStyle`: Text style for the calendar header.
- `defaultTextColor`: Default text color for dates.
- `weekendColor`: Color for weekends.
- `eventColor`: Color for event indicators.
- `todayTextColor`: Text color for today's date.
- `dayTextStyle`: Text style for dates.

## Example

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NepaliCalendar(
          initialDate: NepaliDateTime(year: 2080, month: 9),
          calendarStyle: NepaliCalenderStyle(
            selectedDateColor: Colors.blueAccent,
            selectedTextColor: Colors.yellow,
            todayColor: Colors.greenAccent,
            holidayColor: Colors.redAccent,
            headerTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue if you find any bugs or have suggestions for improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework.
- Nepali calendar data sources for providing the necessary date information.

---

Feel free to customize this README file further to suit your project's needs. Happy coding! 🚀
