// Import required Flutter material package
import 'package:flutter/material.dart';
// Import the Nepali Calendar package
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'main.dart';

/// Example screen demonstrating the NEW theme system
/// This showcases the modern API with CalendarTheme, CellTheme, HeaderTheme, etc.
class NewThemeExampleScreen extends StatelessWidget {
  const NewThemeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Theme System Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Light Theme (Factory Constructor)'),
              _buildLightThemeCalendar(),
              const SizedBox(height: 32.0),
              _buildSectionTitle('2. Dark Theme (Factory Constructor)'),
              _buildDarkThemeCalendar(),
              const SizedBox(height: 32.0),
              _buildSectionTitle('3. Material Theme Integration'),
              _buildMaterialThemeCalendar(context),
              const SizedBox(height: 32.0),
              _buildSectionTitle('4. Custom Theme with New Properties'),
              _buildCustomThemeCalendar(),
              const SizedBox(height: 32.0),
              _buildSectionTitle('5. Horizontal Calendar with New Theme'),
              _buildHorizontalCalendar(),
              const SizedBox(height: 32.0),
              _buildSectionTitle('6. Theme with Custom Cell Shapes'),
              _buildCellShapeExamples(),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  /// Example 1: Using CalendarTheme.light() factory constructor
  Widget _buildLightThemeCalendar() {
    return SizedBox(
      height: 400,
      child: NepaliCalendar(
        controller: NepaliCalendarController(),

        ///
        // Pass the sorted list of events
        eventList: sortedList,
        checkIsHoliday: (event) => event.isHoliday,

        ///
        ///
        // NEW: Using factory constructor for light theme
        // ignore: deprecated_member_use
        theme: CalendarTheme.light().copyWith(
            displayEnglishDate: true,
            locale: CalendarLocale.nepali,
            backgroundColor: Colors.blue),
        onDayChanged: (date) => debugPrint('Light theme: $date'),
      ),
    );
  }

  /// Example 2: Using CalendarTheme.dark() factory constructor
  Widget _buildDarkThemeCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 400,
        child: NepaliCalendar(
          controller: NepaliCalendarController(),
          // NEW: Using factory constructor for dark theme
          // ignore: deprecated_member_use
          theme: CalendarTheme.dark().copyWith(
            displayEnglishDate: true,
            locale: CalendarLocale.english,
          ),
          onDayChanged: (date) => debugPrint('Dark theme: $date'),
        ),
      ),
    );
  }

  /// Example 3: Using CalendarTheme.fromMaterialTheme()
  Widget _buildMaterialThemeCalendar(BuildContext context) {
    return SizedBox(
      height: 400,
      child: NepaliCalendar(
        controller: NepaliCalendarController(),
        // NEW: Creating theme from Material ThemeData
        // ignore: deprecated_member_use
        theme: CalendarTheme.fromMaterialTheme(Theme.of(context)).copyWith(
          displayEnglishDate: true,
        ),
        onDayChanged: (date) => debugPrint('Material theme: $date'),
      ),
    );
  }

  /// Example 4: Custom theme with all new properties
  Widget _buildCustomThemeCalendar() {
    return SizedBox(
      height: 400,
      child: NepaliCalendar(
        controller: NepaliCalendarController(),
        theme: CalendarTheme(
          locale: CalendarLocale.nepali,
          backgroundColor: Colors.grey.shade50,

          // NEW: CalendarColorScheme for consistent colors
          colorScheme: CalendarColorScheme(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            secondary: Colors.amber,
            onSecondary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black87,
            error: Colors.red,
            onError: Colors.white,
            disabled: Colors.grey.shade400,
            weekend: Colors.red.shade700,
            holiday: Colors.pink,
            today: Colors.green,
            selectedDate: Colors.deepPurple,
            rangeSelection: Colors.deepPurple.shade100,
          ),

          // NEW: CalendarSpacing for layout control
          spacing: const CalendarSpacing(
            cellHorizontalSpacing: 4.0,
            cellVerticalSpacing: 4.0,
            calendarPadding: EdgeInsets.all(12.0),
            headerToWeekdaysSpacing: 12.0,
            weekdaysToCellsSpacing: 8.0,
          ),

          // NEW: CalendarAnimations for transitions
          animations: const CalendarAnimations(
            monthTransitionDuration: Duration(milliseconds: 400),
            monthTransitionCurve: Curves.easeInOutCubic,
            selectionAnimationDuration: Duration(milliseconds: 250),
            enableCellAnimation: true,
            enableHeaderAnimation: true,
          ),

          // Enhanced CellTheme with new properties
          cellTheme: CellTheme(
            showEnglishDate: true,
            showBorder: false,
            defaultTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            todayBackgroundColor: Colors.green,
            selectionColor: Colors.deepPurple,
            weekendTextColor: Colors.red.shade700,
            englishDateColor: Colors.grey.shade600,
            // NEW: Cell shape property
            shape: CellShape.roundedSquare,
            borderRadius: 8.0,
            cellHeight: 44.0,
            cellWidth: 44.0,
          ),

          // Enhanced HeaderTheme with layout options
          headerTheme: const HeaderTheme(
            // NEW: HeaderLayout enum
            layout: HeaderLayout.standard,
            monthTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            yearTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.deepPurple,
            ),
            navigationIconColor: Colors.deepPurple,
            navigationIconSize: 28.0,
            // NEW: Fade transition for month changes
            enableFadeTransition: true,
            transitionDuration: Duration(milliseconds: 300),
          ),

          // NEW: WeekdayTheme for weekday labels
          weekdayTheme: WeekdayTheme(
            show: true,
            height: 32.0,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            weekendTextStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
        ),
        onDayChanged: (date) => debugPrint('Custom theme: $date'),
      ),
    );
  }

  /// Example 5: Horizontal calendar with new theme
  Widget _buildHorizontalCalendar() {
    return HorizontalNepaliCalendar(
      initialDate: NepaliDateTime.now(),
      // NEW: Using 'theme' instead of deprecated 'calendarStyle'
      theme: CalendarTheme(
        // NEW: Using 'locale' instead of deprecated 'language'
        locale: CalendarLocale.nepali,
        cellTheme: const CellTheme(
          todayBackgroundColor: Colors.teal,
          selectionColor: Colors.teal,
          weekendTextColor: Colors.red,
        ),
        headerTheme: const HeaderTheme(
          monthTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        weekdayTheme: const WeekdayTheme(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onDateSelected: (date) => debugPrint('Horizontal: $date'),
    );
  }

  /// Example 6: Different cell shapes
  Widget _buildCellShapeExamples() {
    return Column(
      children: [
        _buildShapeExample('Circle Shape', CellShape.circle),
        const SizedBox(height: 16),
        _buildShapeExample('Rounded Square', CellShape.roundedSquare),
        const SizedBox(height: 16),
        _buildShapeExample('Square Shape', CellShape.square),
      ],
    );
  }

  Widget _buildShapeExample(String label, CellShape shape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 410,
          child: NepaliCalendar(
            controller: NepaliCalendarController(),
            theme: CalendarTheme(
              animations: CalendarAnimations(
                enableCellAnimation: true,
                selectionAnimationCurve: Curves.bounceInOut,
                selectionAnimationDuration: const Duration(milliseconds: 500),
                enableHeaderAnimation: true,
              ),
              locale: CalendarLocale.nepali,
              cellTheme: const CellTheme(
                showEnglishDate: false,
                showBorder: false,
              ),
              borders: CalendarBorders(
                calendarBorder: Border.all(width: 5.0, color: Colors.red),
                calendarBorderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
              ),
              weekdayTheme: WeekdayTheme(format: WeekdayFormat.abbreviated),
              // cellTheme: CellTheme(
              //   shape: shape,
              //   borderRadius: shape == CellShape.roundedSquare ? 10.0 : null,
              //   todayBackgroundColor: Colors.orange,
              //   selectionColor: Colors.blue,
              //   cellHeight: 38.0,
              //   cellWidth: 38.0,
              // ),
              headerTheme: const HeaderTheme(
                layout: HeaderLayout.standard,
                weekdayFormat: WeekdayFormat.abbreviated,
                // monthHeaderStyle:Text(),
              ),
            ),
            onDayChanged: (date) => debugPrint('$label: $date'),
          ),
        ),
      ],
    );
  }
}

/// Demonstrates theme serialization (toJson/fromJson)
class ThemeSerializationExample extends StatelessWidget {
  const ThemeSerializationExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a theme
    // ignore: deprecated_member_use
    final originalTheme = CalendarTheme.light().copyWith(
      displayEnglishDate: true,
      locale: CalendarLocale.nepali,
    );

    // Serialize to JSON
    final json = originalTheme.toJson();
    debugPrint('Theme JSON: $json');

    // Deserialize from JSON
    final restoredTheme = CalendarTheme.fromJson(json);

    return SizedBox(
      height: 400,
      child: NepaliCalendar(
        controller: NepaliCalendarController(),
        theme: restoredTheme,
        onDayChanged: (date) => debugPrint('Serialized theme: $date'),
      ),
    );
  }
}

/// Example showing backward compatibility
/// Old API still works alongside new API
class BackwardCompatibilityExample extends StatelessWidget {
  const BackwardCompatibilityExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Old API (Deprecated but still works):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 350,
          child: NepaliCalendar(
            controller: NepaliCalendarController(),
            // OLD API: Still works but shows deprecation warning
            theme: CalendarTheme(
              showEnglishDate: true,
              showBorder: false,
            ),
            onDayChanged: (date) => debugPrint('Old API: $date'),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'New API (Recommended):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 350,
          child: NepaliCalendar(
            controller: NepaliCalendarController(),
            // NEW API: Recommended approach
            theme: CalendarTheme(
              cellTheme: const CellTheme(
                showEnglishDate: true,
                showBorder: false,
              ),
            ),
            onDayChanged: (date) => debugPrint('New API: $date'),
          ),
        ),
      ],
    );
  }
}
