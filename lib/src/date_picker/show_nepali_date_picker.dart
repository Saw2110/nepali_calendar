import 'package:flutter/material.dart';

import '../src.dart';

/// Shows a Nepali date picker dialog.
///
/// Returns the selected date or null if cancelled.
///
/// Example:
/// ```dart
/// final date = await showNepaliDatePicker(
///   context: context,
///   initialDate: NepaliDateTime.now(),
///   firstDate: NepaliDateTime(year: 2070),
///   lastDate: NepaliDateTime(year: 2090),
/// );
/// if (date != null) {
///   print('Selected: $date');
/// }
/// ```
Future<NepaliDateTime?> showNepaliDatePicker({
  required BuildContext context,
  required NepaliDateTime initialDate,
  required NepaliDateTime firstDate,
  required NepaliDateTime lastDate,

  /// Theme configuration for the picker.
  CalendarTheme? theme,

  /// Help text displayed at the top of the dialog.
  String? helpText,

  /// Text for the cancel button.
  String? cancelText,

  /// Text for the confirm button.
  String? confirmText,

  /// A predicate to determine if a day is selectable.
  NepaliSelectableDayPredicate? selectableDayPredicate,

  /// A builder for customizing the dialog's transition.
  TransitionBuilder? builder,

  /// The locale to use for the picker.
  CalendarLocale? locale,

  /// Specifies which day the week starts on.
  ///
  /// Defaults to [WeekStart.sunday] (common in Nepal).
  WeekStart weekStart = WeekStart.sunday,

  /// Specifies which days are considered weekends.
  ///
  /// Defaults to [Weekend.saturday] (common in Nepal).
  Weekend weekend = Weekend.saturday,
}) async {
  assert(
    !firstDate.toDateTime().isAfter(lastDate.toDateTime()),
    'firstDate must be before or equal to lastDate',
  );
  assert(
    !initialDate.toDateTime().isBefore(firstDate.toDateTime()) &&
        !initialDate.toDateTime().isAfter(lastDate.toDateTime()),
    'initialDate must be between firstDate and lastDate',
  );

  final effectiveTheme =
      theme ?? CalendarTheme.fromMaterialTheme(Theme.of(context));
  final effectiveLocale = locale ?? effectiveTheme.locale;
  final isNepali = effectiveLocale == CalendarLocale.nepali;

  return showDialog<NepaliDateTime>(
    context: context,
    builder: (BuildContext context) {
      Widget dialog = _NepaliDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        theme: effectiveTheme.copyWith(locale: effectiveLocale),
        helpText: helpText ?? (isNepali ? 'मिति छान्नुहोस्' : 'Select Date'),
        cancelText: cancelText ?? (isNepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
        confirmText: confirmText ?? (isNepali ? 'ठीक छ' : 'OK'),
        selectableDayPredicate: selectableDayPredicate,
        weekStart: weekStart,
        weekend: weekend,
      );

      if (builder != null) {
        dialog = builder(context, dialog);
      }

      return dialog;
    },
  );
}

class _NepaliDatePickerDialog extends StatefulWidget {
  final NepaliDateTime initialDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final CalendarTheme theme;
  final String helpText;
  final String cancelText;
  final String confirmText;
  final NepaliSelectableDayPredicate? selectableDayPredicate;
  final WeekStart weekStart;
  final Weekend weekend;

  const _NepaliDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.theme,
    required this.helpText,
    required this.cancelText,
    required this.confirmText,
    this.selectableDayPredicate,
    required this.weekStart,
    required this.weekend,
  });

  @override
  State<_NepaliDatePickerDialog> createState() =>
      _NepaliDatePickerDialogState();
}

class _NepaliDatePickerDialogState extends State<_NepaliDatePickerDialog> {
  late NepaliDateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _handleDateChanged(NepaliDateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleOk() {
    Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.helpText,
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatSelectedDate(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Flexible(
            child: NepaliDatePicker(
              initialDate: widget.initialDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: _handleDateChanged,
              theme: widget.theme,
              selectableDayPredicate: widget.selectableDayPredicate,
              weekStart: widget.weekStart,
              weekend: widget.weekend,
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _handleCancel,
                  child: Text(widget.cancelText),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _handleOk,
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    final isNepali = widget.theme.locale == CalendarLocale.nepali;
    final monthName = MonthUtils.formattedMonth(
      _selectedDate.month,
      isNepali ? CalendarLocale.nepali : CalendarLocale.english,
    );

    if (isNepali) {
      final day =
          NepaliNumberConverter.englishToNepali(_selectedDate.day.toString());
      final year =
          NepaliNumberConverter.englishToNepali(_selectedDate.year.toString());
      return '$monthName $day, $year';
    } else {
      return '$monthName ${_selectedDate.day}, ${_selectedDate.year}';
    }
  }
}
