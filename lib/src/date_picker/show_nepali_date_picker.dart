import 'dart:math' as math;

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
/// The [initialMode] decides which view the picker opens on. Use
/// [NepaliDatePickerMode.year] for dates far from today, such as a birthday.
/// The picker returns a full date regardless.
///
/// [minDate] and [maxDate] bound the selection. Dates outside the range are
/// shown but dimmed and unselectable, and month/year navigation will not leave
/// it. Both are clamped to the range the bundled calendar data covers
/// (BS 1970-2100), and an [initialDate] outside the range is pulled to the
/// nearest date inside it rather than throwing.
///
/// [confirmText] and [cancelText] override the action labels, which otherwise
/// follow the configured [Language].
///
/// The picker is shown as a plain [AlertDialog], so it inherits the app's
/// `dialogTheme` and sits beside the app's other alerts rather than announcing
/// itself as a special case.
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
}) async {
  return showDialog<NepaliDateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    builder: (BuildContext context) {
      return _NepaliDatePickerAlert(
        initialDate: initialDate,
        calendarStyle: calendarStyle,
        initialMode: initialMode,
        minDate: minDate,
        maxDate: maxDate,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    },
  );
}

/// The picker's modal presentation.
///
/// A plain [AlertDialog]: it brings no surface, radius or elevation of its
/// own, so it picks up whatever `dialogTheme` the app already uses and sits
/// beside the app's other alerts rather than announcing itself.
///
/// Stateful because the actions live outside the picker here -- the dialog has
/// to hold the selection to hand back on confirm.
class _NepaliDatePickerAlert extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final NepaliCalendarStyle calendarStyle;
  final NepaliDatePickerMode initialMode;
  final NepaliDateTime? minDate;
  final NepaliDateTime? maxDate;
  final String? confirmText;
  final String? cancelText;

  const _NepaliDatePickerAlert({
    this.initialDate,
    required this.calendarStyle,
    required this.initialMode,
    this.minDate,
    this.maxDate,
    this.confirmText,
    this.cancelText,
  });

  @override
  State<_NepaliDatePickerAlert> createState() => _NepaliDatePickerAlertState();
}

class _NepaliDatePickerAlertState extends State<_NepaliDatePickerAlert> {
  NepaliDateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);
    final language = style.effectiveConfig.language;
    final nepali = language == Language.nepali;
    final selected = _selected ?? widget.initialDate ?? NepaliDateTime.now();

    return AlertDialog(
      // Deliberately no backgroundColor, shape or elevation: the point of this
      // layout is that it looks like the app's other alerts.
      title: Text(
        nepali ? 'मिति छान्नुहोस्' : 'Select date',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      // AlertDialog's default 40dp side insets leave a small phone only ~295dp
      // of content, which is not enough for the header. Colours, shape and
      // elevation still come from the app's dialogTheme -- only the position
      // is nudged.
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      // A tight width, on purpose. AlertDialog measures its content's
      // intrinsic width, and the picker's root is a LayoutBuilder, which
      // cannot report one -- laying it out speculatively could mutate the live
      // tree, so Flutter refuses. A tight width short-circuits that query.
      // `- 32` matches the insetPadding set above.
      content: SizedBox(
        width: math.min(
          NepaliDatePicker.preferredWidth,
          MediaQuery.sizeOf(context).width - 32,
        ),
        child: NepaliDatePicker(
          initialDate: widget.initialDate,
          calendarStyle: widget.calendarStyle,
          initialMode: widget.initialMode,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          // The AlertDialog owns the action area, so the picker does not draw
          // one -- and therefore never touches the Navigator either.
          showActions: false,
          onDateSelected: (date) => setState(() => _selected = date),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelText ?? (nepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: Text(widget.confirmText ?? (nepali ? 'ठीक छ' : 'OK')),
        ),
      ],
    );
  }
}
