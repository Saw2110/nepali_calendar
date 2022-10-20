part of nepali_calendar;

typedef _SelectedDayCallback = void Function(NepaliDateTime day, {bool runCallback});

class NepaliCalendarController {
  NepaliDateTime get selectedDay => _selectedDay;
  late NepaliDateTime _selectedDay;
  late _SelectedDayCallback _selectedDayCallback;

  void _init({
    required _SelectedDayCallback selectedDayCallback,
    required NepaliDateTime initialDay,
  }) {
    assert(initialDay != null);
    assert(selectedDayCallback != null);
    _selectedDayCallback = selectedDayCallback;
    _selectedDay = initialDay;
  }

  void setSelectedDay(
    NepaliDateTime value, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  }) {
    _selectedDay = value;

    if (isProgrammatic && _selectedDayCallback != null) {
      _selectedDayCallback(value, runCallback: runCallback);
    }
  }
}
