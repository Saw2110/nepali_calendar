import 'package:flutter/material.dart';

import '../src.dart';

/// Corner radius of the modal picker's surface.
const double _dialogCornerRadius = 28.0;

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
/// Internal dialog that hosts a [NepaliDatePicker].
///
/// Stateless on purpose: the picker owns the selection and pops with it, so
/// mirroring the selected date here would be write-only state.
class _NepaliDatePickerDialog extends StatelessWidget {
  final NepaliDateTime? initialDate;
  final NepaliCalendarStyle calendarStyle;

  const _NepaliDatePickerDialog({
    this.initialDate,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    // The surface has to match the palette the picker actually renders with,
    // which is not the same question as "is the app dark?".
    //
    // Up to 0.1.0 this was hard-coded to Colors.white. That was wrong for a
    // dark app, but self-consistent: with no NepaliCalendarTheme the picker
    // draws with the legacy light palette (black text), which needs a light
    // surface. Switching the surface to the Material ColorScheme without
    // regard for the picker's own palette swaps one unreadable combination
    // for another -- black text on a dark sheet.
    //
    // So: themed picker gets a themed surface, legacy picker keeps the legacy
    // white one. Dark mode is opt-in via NepaliCalendarTheme, exactly as it is
    // for every other widget here.
    final calendarTheme = NepaliCalendarTheme.maybeOf(context);
    final surface = calendarTheme == null
        ? Colors.white
        : Theme.of(context).colorScheme.surfaceContainerHigh;

    return Dialog(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogCornerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: NepaliDatePicker(
        initialDate: initialDate,
        calendarStyle: calendarStyle,
        // The picker pops the dialog with the chosen date itself, so nothing
        // needs doing here.
        onDateSelected: (_) {},
      ),
    );
  }
}
