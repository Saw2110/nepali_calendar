import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Example demonstrating the Nepali Date Picker functionality.
class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key});

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  NepaliDateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nepali Date Picker Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display selected date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Date:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                            : 'No date selected',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button to show date picker dialog
              ElevatedButton.icon(
                onPressed: _showDatePickerDialog,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Date (Dialog)'),
              ),
              const SizedBox(height: 12),

              // Button to show date picker with Nepali locale
              ElevatedButton.icon(
                onPressed: _showNepaliDatePickerDialog,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Select Date (Nepali)'),
              ),
              const SizedBox(height: 12),

              // Button to show date picker with Monday start
              ElevatedButton.icon(
                onPressed: _showMondayStartDatePicker,
                icon: const Icon(Icons.calendar_view_week),
                label: const Text('Week starts Monday'),
              ),
              const SizedBox(height: 12),

              // Button to show date picker with Sat-Sun weekend
              ElevatedButton.icon(
                onPressed: _showSatSunWeekendDatePicker,
                icon: const Icon(Icons.weekend),
                label: const Text('Sat-Sun Weekend'),
              ),
              const SizedBox(height: 12),

              // Info text about year/month picker
              const Card(
                color: Color(0xFFF5F5F5),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Tap on the month/year header to quickly navigate to any month or year!',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Inline date picker
              const Text(
                'Inline Date Picker:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NepaliDatePicker(
                    initialDate: _selectedDate ?? NepaliDateTime.now(),
                    firstDate: NepaliDateTime(year: 2070),
                    lastDate: NepaliDateTime(year: 2090),
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    theme: CalendarTheme.light(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePickerDialog() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(year: 2070),
      lastDate: NepaliDateTime(year: 2090),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showNepaliDatePickerDialog() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(year: 2070),
      lastDate: NepaliDateTime(year: 2090),
      locale: CalendarLocale.nepali,
      helpText: 'मिति छान्नुहोस्',
      cancelText: 'रद्द गर्नुहोस्',
      confirmText: 'ठीक छ',
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showMondayStartDatePicker() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(year: 2070),
      lastDate: NepaliDateTime(year: 2090),
      weekStart: WeekStart.monday, // Week starts from Monday
      weekend: Weekend.saturdayAndSunday, // Sat-Sun are weekends
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showSatSunWeekendDatePicker() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(year: 2070),
      lastDate: NepaliDateTime(year: 2090),

      weekStart: WeekStart.sunday, // Week starts from Sunday
      weekend: Weekend.saturdayAndSunday, // Both Sat and Sun are weekends
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
}
