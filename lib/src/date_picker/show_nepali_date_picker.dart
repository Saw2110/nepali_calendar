import 'package:flutter/material.dart';

import '../src.dart';
import 'internal/date_picker_layout.dart';
import 'internal/picker_shared.dart';

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
/// The [initialMode] decides which view the picker opens on. Use
/// [NepaliDatePickerMode.year] for dates far from today, such as a birthday.
/// The picker returns a full date regardless.
///
/// [minDate] and [maxDate] bound the selection. Dates outside the range are
/// shown but dimmed and unselectable, and month/year navigation will not leave
/// it. Both are clamped to the range the bundled calendar data covers
/// (BS 1969-2250), and an [initialDate] outside the range is pulled to the
/// nearest date inside it rather than throwing.
///
/// By default ([autoConfirm]) tapping a date returns it straight away, and
/// Close -- or tapping outside the picker -- returns `null`. Set
/// [autoConfirm] to false to keep the selection pending until the user
/// presses OK, which then appears beside Cancel.
///
/// [pickerBuilder] replaces parts of the picker with custom designs; see
/// [DatePickerBuilder].
///
/// [weekdayFormat] sets how the weekday names are written: initials
/// (`आ सो मं`) by default, or [TitleFormat.half] / [TitleFormat.full] for
/// longer names, which shrink to fit rather than being cut off.
///
/// [confirmText] and [cancelText] override those action labels, which
/// otherwise follow the configured [Language].
///
/// The picker is shown in a plain, untitled [AlertDialog], so it inherits the
/// app's `dialogTheme` and sits beside the app's other alerts rather than
/// announcing itself as a special case.
Future<NepaliDateTime?> showNepaliDatePicker({
  required BuildContext context,
  NepaliDateTime? initialDate,
  NepaliCalendarStyle calendarStyle = const NepaliCalendarStyle(),
  bool barrierDismissible = true,
  Color? barrierColor,
  NepaliDatePickerMode initialMode = NepaliDatePickerMode.day,
  NepaliDateTime? minDate,
  NepaliDateTime? maxDate,
  String? confirmText,
  String? cancelText,
  bool autoConfirm = true,
  TitleFormat? weekdayFormat,
  DatePickerBuilder? pickerBuilder,
}) {
  return showPickerDialog<NepaliDateTime>(
    context: context,
    // Wider on a screen too short for the title band on top: it then sits
    // beside the grid.
    preferredWidth: datePickerDialogWidth(
      MediaQuery.sizeOf(context),
      withActions: true,
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    contentPadding: datePickerDialogPadding,
    builder: (context) {
      final style = NepaliCalendarTheme.resolve(context, calendarStyle);
      final nepali = style.effectiveConfig.language == Language.nepali;
      // An English picker says what the app's other dialogs say -- Flutter
      // ships these labels for every locale it supports. Flutter has no
      // Nepali MaterialLocalizations, so a Nepali picker keeps its own.
      final localizations =
          nepali ? null : pickerMaterialLocalizations(context);

      return NepaliDatePicker(
        initialDate: initialDate,
        calendarStyle: calendarStyle,
        initialMode: initialMode,
        minDate: minDate,
        maxDate: maxDate,
        autoConfirm: autoConfirm,
        weekdayFormat: weekdayFormat,
        pickerBuilder: pickerBuilder,
        confirmText: confirmText ?? localizations?.okButtonLabel,
        // Close when it is the only action; Cancel when it sits beside OK.
        cancelText: cancelText ??
            (autoConfirm
                ? localizations?.closeButtonLabel
                : localizations?.cancelButtonLabel),
        onDateSelected: (_) {},
        onConfirm: (date) => Navigator.of(context).pop(date),
        onCancel: () => Navigator.of(context).pop(),
      );
    },
  );
}
