import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src.dart';
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
/// (BS 1970-2100), and an [initialDate] outside the range is pulled to the
/// nearest date inside it rather than throwing.
///
/// By default ([autoConfirm]) tapping a date returns it straight away, and
/// tapping outside the picker returns `null`. Set [autoConfirm] to false to
/// keep the selection pending until the user presses OK; a Cancel / OK row
/// then appears below the footer.
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
        autoConfirm: autoConfirm,
      );
    },
  );
}

/// The picker's modal presentation.
///
/// A plain [AlertDialog] with no title and no action area of its own: it
/// brings no surface, radius or elevation either, so it picks up whatever
/// `dialogTheme` the app already uses. The picker draws its own footer and
/// reports back through [NepaliDatePicker.onConfirm] and
/// [NepaliDatePicker.onCancel], so the dialog does the popping.
class _NepaliDatePickerAlert extends StatelessWidget {
  final NepaliDateTime? initialDate;
  final NepaliCalendarStyle calendarStyle;
  final NepaliDatePickerMode initialMode;
  final NepaliDateTime? minDate;
  final NepaliDateTime? maxDate;
  final String? confirmText;
  final String? cancelText;
  final bool autoConfirm;

  const _NepaliDatePickerAlert({
    this.initialDate,
    required this.calendarStyle,
    required this.initialMode,
    this.minDate,
    this.maxDate,
    this.confirmText,
    this.cancelText,
    required this.autoConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final style = NepaliCalendarTheme.resolve(context, calendarStyle);
    final nepali = style.effectiveConfig.language == Language.nepali;

    return AlertDialog(
      // Deliberately no backgroundColor or elevation: the point of this layout
      // is that it looks like the app's other alerts. The shape is the one
      // exception -- Material 3's default 28dp radius made the compact picker
      // look like a bubble -- and it still defers to a dialogTheme shape.
      shape: DialogTheme.of(context).shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pickerDialogRadius),
          ),
      contentPadding: const EdgeInsets.only(top: 8, bottom: 4),
      // AlertDialog's default 40dp side insets leave a small phone only ~295dp
      // of content, which is not enough for the grid. Colours, shape and
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
          initialDate: initialDate,
          calendarStyle: calendarStyle,
          initialMode: initialMode,
          minDate: minDate,
          maxDate: maxDate,
          autoConfirm: autoConfirm,
          confirmText: confirmText ?? _confirmLabel(context, nepali),
          cancelText: cancelText ?? _cancelLabel(context, nepali),
          onDateSelected: (_) {},
          onConfirm: (date) => Navigator.of(context).pop(date),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// The cancel label, preferring the app's own.
  ///
  /// An English picker inside a localized app should say what that app's other
  /// dialogs say -- Flutter ships translations of these two labels for every
  /// locale it supports, and borrowing them keeps the picker from being the
  /// one dialog with hand-written buttons. A Nepali picker keeps its own
  /// labels: Flutter has no Nepali `MaterialLocalizations`.
  String _cancelLabel(BuildContext context, bool nepali) {
    if (nepali) return 'रद्द गर्नुहोस्';
    return _materialLocalizations(context)?.cancelButtonLabel ?? 'Cancel';
  }

  /// The confirm label, preferring the app's own. See [_cancelLabel].
  String _confirmLabel(BuildContext context, bool nepali) {
    if (nepali) return 'ठीक छ';
    return _materialLocalizations(context)?.okButtonLabel ?? 'OK';
  }

  /// The ambient [MaterialLocalizations], or null outside a [MaterialApp].
  ///
  /// Looked up rather than required: the picker is usable under a bare
  /// [WidgetsApp], and `MaterialLocalizations.of` would throw there.
  MaterialLocalizations? _materialLocalizations(BuildContext context) =>
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
}
