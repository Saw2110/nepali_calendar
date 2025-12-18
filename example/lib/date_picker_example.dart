import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Example demonstrating the Nepali Date Picker widget
class NepaliDatePickerExample extends StatefulWidget {
  const NepaliDatePickerExample({super.key});

  @override
  State<NepaliDatePickerExample> createState() =>
      _NepaliDatePickerExampleState();
}

class _NepaliDatePickerExampleState extends State<NepaliDatePickerExample> {
  NepaliDateTime? selectedDate;
  Language currentLanguage = Language.nepali;

  Future<void> _showDatePickerDialog() async {
    final selected = await showNepaliDatePicker(
      context: context,
      initialDate: selectedDate,
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(
          // language: currentLanguage,
          // weekendType: WeekendType.saturdayAndSunday,
          // weekStartType: WeekStartType.monday,
          weekTitleType: TitleFormat.half,
        ),
        cellsStyle: const CellStyle(
          selectedColor: Color(0xFF6366F1),
          todayColor: Colors.green,
          weekDayColor: Colors.red,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == Language.nepali
          ? Language.english
          : Language.nepali;
    });
  }

  String _formatDate(NepaliDateTime date) {
    final monthName = MonthUtils.formattedMonth(date.month, currentLanguage);
    final day = currentLanguage == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.day.toString())
        : date.day.toString();
    final year = currentLanguage == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.year.toString())
        : date.year.toString();

    return '$monthName $day, $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          currentLanguage == Language.nepali
              ? 'नेपाली मिति चयनकर्ता'
              : 'Nepali Date Picker',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: currentLanguage == Language.nepali
                ? 'Switch to English'
                : 'नेपालीमा स्विच गर्नुहोस्',
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                currentLanguage == Language.nepali
                    ? 'मिति छान्नुहोस्'
                    : 'Select a Date',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : currentLanguage == Language.nepali
                        ? 'कुनै मिति चयन गरिएको छैन'
                        : 'No date selected',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showDatePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      currentLanguage == Language.nepali
                          ? 'मिति छान्नुहोस्'
                          : 'Choose Date',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                  ),
                  child: Text(
                    currentLanguage == Language.nepali
                        ? 'चयन हटाउनुहोस्'
                        : 'Clear Selection',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
