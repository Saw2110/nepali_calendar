import 'package:flutter/material.dart';

import '../src.dart';

/// Shows a modal Nepali date picker dialog.
///
/// This is a convenience function that displays a [NepaliDatePicker] in a modal
/// overlay with backdrop dismiss functionality. It returns a [Future] that completes
/// with the selected date when the user picks a date, or `null` if the user
/// dismisses the picker.
///
/// The [context] argument is used to look up the [Navigator] for the dialog.
///
/// The [initialDate] is the date that will be displayed when the picker is first shown.
/// If not provided, defaults to the current Nepali date.
///
/// The [calendarStyle] allows customization of the date picker's appearance and behavior,
/// including colors, text styles, language, weekend types, and week start day.
/// Defaults to [NepaliCalendarStyle()] with default settings.
///
/// The [barrierDismissible] determines whether tapping outside the picker dismisses it.
/// Defaults to `true`.
///
/// The [barrierColor] is the color of the modal barrier that appears behind the picker.
/// Defaults to semi-transparent black.
///
/// Example usage:
/// ```dart
/// final selectedDate = await showNepaliDatePicker(
///   context: context,
///   initialDate: NepaliDateTime.now(),
///   calendarStyle: NepaliCalendarStyle(
///     config: CalendarConfig(language: Language.nepali),
///     cellsStyle: CellStyle(selectedColor: Colors.blue),
///   ),
/// );
///
/// if (selectedDate != null) {
///   print('Selected: $selectedDate');
/// }
/// ```
///
/// Returns a [Future] that resolves to the selected [NepaliDateTime] or `null`
/// if the picker was dismissed without selecting a date.
Future<NepaliDateTime?> showNepaliDatePicker({
  required BuildContext context,
  NepaliDateTime? initialDate,
  NepaliCalendarStyle calendarStyle = const NepaliCalendarStyle(),
  bool barrierDismissible = true,
  Color? barrierColor,
}) async {
  return showDialog<NepaliDateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    builder: (BuildContext context) {
      return _NepaliDatePickerDialog(
        initialDate: initialDate,
        calendarStyle: calendarStyle,
      );
    },
  );
}

/// Internal dialog widget that wraps the NepaliDatePicker
class _NepaliDatePickerDialog extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final NepaliCalendarStyle calendarStyle;

  const _NepaliDatePickerDialog({
    this.initialDate,
    required this.calendarStyle,
  });

  @override
  State<_NepaliDatePickerDialog> createState() =>
      _NepaliDatePickerDialogState();
}

class _NepaliDatePickerDialogState extends State<_NepaliDatePickerDialog> {
  late NepaliDateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? NepaliDateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: NepaliDatePicker(
          initialDate: widget.initialDate,
          calendarStyle: widget.calendarStyle,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
          },
        ),
      ),
    );
  }
}
