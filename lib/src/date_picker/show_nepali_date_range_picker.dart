import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src.dart';
import 'internal/picker_shared.dart';

/// Shows a Nepali date range picker and returns the range the user saves, or
/// `null` if they cancel or dismiss it.
///
/// The presentation follows the screen, as Material's range picker does:
///
/// * on a phone (narrower than 600dp), a full-screen page with every month
///   in one vertical list, a close button and Save;
/// * on a tablet or desktop, a dialog with two months side by side.
///
/// The first tap picks the start, the second the end, and a third starts
/// over. Save is enabled once both ends are set; nothing is returned before
/// then.
///
/// [minDate] and [maxDate] bound the selection, clamped to the range the
/// bundled calendar data covers (BS 1969-2100). [maxDays] caps the length,
/// both ends counted: once a start is picked, later dates beyond it are
/// dimmed. An [initialRange] outside the bounds is ignored.
///
/// [confirmText] and [cancelText] override the action labels, which
/// otherwise follow the configured [Language].
///
/// ```dart
/// final range = await showNepaliDateRangePicker(
///   context: context,
///   maxDays: 30,
/// );
/// if (range != null) print('${range.days} days');
/// ```
Future<NepaliDateTimeRange?> showNepaliDateRangePicker({
  required BuildContext context,
  NepaliDateTimeRange? initialRange,
  NepaliDateTime? minDate,
  NepaliDateTime? maxDate,
  int? maxDays,
  NepaliCalendarStyle calendarStyle = const NepaliCalendarStyle(),
  String? confirmText,
  String? cancelText,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  Widget picker(BuildContext context) {
    final style = NepaliCalendarTheme.resolve(context, calendarStyle);
    final nepali = style.effectiveConfig.language == Language.nepali;
    final localizations = pickerMaterialLocalizations(context);

    return NepaliDateRangePicker(
      initialRange: initialRange,
      minDate: minDate,
      maxDate: maxDate,
      maxDays: maxDays,
      calendarStyle: calendarStyle,
      // An English picker says what the app's other dialogs say; Flutter has
      // no Nepali MaterialLocalizations, so a Nepali one keeps its own.
      confirmText:
          confirmText ?? (nepali ? null : localizations?.saveButtonLabel),
      cancelText:
          cancelText ?? (nepali ? null : localizations?.cancelButtonLabel),
      onConfirm: (range) => Navigator.of(context).pop(range),
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  final width = MediaQuery.sizeOf(context).width;

  if (width < 600) {
    return Navigator.of(context).push<NepaliDateTimeRange>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: SafeArea(child: Builder(builder: picker)),
        ),
      ),
    );
  }

  return showDialog<NepaliDateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    builder: (context) => AlertDialog(
      // Like showNepaliDatePicker: the app's dialogTheme colours, a compact
      // radius unless the theme sets a shape of its own.
      shape: DialogTheme.of(context).shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pickerDialogRadius),
          ),
      contentPadding: const EdgeInsets.only(top: 8, bottom: 4),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      // A tight width: AlertDialog measures its content's intrinsic width,
      // which the picker's LayoutBuilder cannot report.
      content: SizedBox(
        width: math.min(
          NepaliDateRangePicker.preferredWideWidth,
          MediaQuery.sizeOf(context).width - 32,
        ),
        child: Builder(builder: picker),
      ),
    ),
  );
}
