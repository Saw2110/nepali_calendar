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
/// bundled calendar data covers (BS 1969-2250). [maxDays] caps the length,
/// both ends counted: once a start is picked, later dates beyond it are
/// dimmed. An [initialRange] outside the bounds, or longer than [maxDays],
/// is ignored: the picker opens with nothing selected.
///
/// [barrierDismissible] and [barrierColor] apply to the dialog layout only.
/// On a phone the picker is a full-screen page, closed with its close button
/// or the system Back gesture rather than by tapping outside.
///
/// [pickerBuilder] replaces parts of the picker with custom designs; see
/// [DatePickerBuilder].
///
/// [weekdayFormat] sets how the weekday names are written: initials
/// (`आ सो मं`) by default, or [TitleFormat.half] / [TitleFormat.full] for
/// longer names, which shrink to fit rather than being cut off.
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
  TitleFormat? weekdayFormat,
  DatePickerBuilder? pickerBuilder,
}) {
  Widget picker(BuildContext context) {
    final style = NepaliCalendarTheme.resolve(context, calendarStyle);
    final nepali = style.effectiveConfig.language == Language.nepali;
    // An English picker says what the app's other dialogs say; Flutter has
    // no Nepali MaterialLocalizations, so a Nepali one keeps its own.
    final localizations = nepali ? null : pickerMaterialLocalizations(context);

    return NepaliDateRangePicker(
      initialRange: initialRange,
      minDate: minDate,
      maxDate: maxDate,
      maxDays: maxDays,
      calendarStyle: calendarStyle,
      weekdayFormat: weekdayFormat,
      pickerBuilder: pickerBuilder,
      confirmText: confirmText ?? localizations?.saveButtonLabel,
      cancelText: cancelText ?? localizations?.cancelButtonLabel,
      onConfirm: (range) => Navigator.of(context).pop(range),
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  final width = MediaQuery.sizeOf(context).width;

  if (width < pickerWideBreakpoint) {
    return Navigator.of(context).push<NepaliDateTimeRange>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: SafeArea(child: picker(context)),
        ),
      ),
    );
  }

  return showPickerDialog<NepaliDateTimeRange>(
    context: context,
    preferredWidth: NepaliDateRangePicker.preferredWideWidth,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: picker,
  );
}
