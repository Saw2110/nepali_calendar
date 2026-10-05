import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../../widgets/bilingual.dart';
import '../../widgets/demo_card.dart';
import 'custom_picker_design.dart';

/// Both pickers, one card each, and the date picker with a custom design.
///
/// The calls below are the whole integration: `showNepaliDatePicker` and
/// `showNepaliDateRangePicker` return the pick, or null if the user backs
/// out. Both pass a config-only `calendarStyle` -- no colours -- so the
/// ambient NepaliCalendarTheme styles them and dark mode works.
class PickersExample extends StatefulWidget {
  const PickersExample({super.key, required this.language});

  final Language language;

  @override
  State<PickersExample> createState() => _PickersExampleState();
}

class _PickersExampleState extends State<PickersExample> {
  NepaliDateTime? _date;
  NepaliDateTimeRange? _range;
  NepaliDateTime? _customDate;

  Language get _language => widget.language;

  /// The same window for both pickers, so the demo stays inside it.
  final _minDate = NepaliDateTime(year: 2070, month: 1, day: 1);
  final _maxDate = NepaliDateTime(year: 2090, month: 12, day: 30);

  NepaliCalendarStyle get _style =>
      NepaliCalendarStyle(config: CalendarConfig(language: _language));

  Future<void> _pickDate() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _date,
      calendarStyle: _style,
      minDate: _minDate,
      maxDate: _maxDate,
      autoConfirm: false,
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickCustom() async {
    final date = await showNepaliDatePicker(
      context: context,
      initialDate: _customDate,
      calendarStyle: _style,
      minDate: _minDate,
      maxDate: _maxDate,
      autoConfirm: false,
      pickerBuilder: customPickerDesign(context, _language),
    );
    if (date != null) setState(() => _customDate = date);
  }

  Future<void> _pickRange() async {
    final range = await showNepaliDateRangePicker(
      context: context,
      // Reopens on the last pick, so it can be adjusted rather than redone.
      initialRange: _range,
      calendarStyle: _style,
      minDate: _minDate,
      maxDate: _maxDate,
      // A leave request, say: at most 30 days, both ends counted. Once a
      // start is picked, later dates beyond that are dimmed.
      maxDays: 30,
    );
    if (range != null) setState(() => _range = range);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        DemoCard(
          icon: Icons.event_rounded,
          title: _language.pick('Date picker', 'मिति चयनकर्ता'),
          description: _language.pick(
            'Tap a date to pick it. Month and year open from the header.',
            'मिति थिच्नुहोस्। महिना र वर्ष शीर्षकबाट छान्नुहोस्।',
          ),
          placeholder:
              _language.pick('No date selected', 'कुनै मिति चयन गरिएको छैन'),
          value: _date == null ? null : _language.date(_date!),
          detail: _date == null ? null : adDate(_date!),
          actionLabel: _language.pick('Choose date', 'मिति छान्नुहोस्'),
          onAction: _pickDate,
          onClear: () => setState(() => _date = null),
        ),
        const SizedBox(height: 16),
        DemoCard(
          icon: Icons.date_range_rounded,
          title: _language.pick('Date range picker', 'मिति दायरा चयनकर्ता'),
          description: _language.pick(
            'Pick a start and an end, up to 30 days. Full screen on phones.',
            'सुरु र अन्तिम मिति छान्नुहोस्, बढीमा ३० दिन।',
          ),
          placeholder:
              _language.pick('No range selected', 'कुनै दायरा चयन गरिएको छैन'),
          value: range == null
              ? null
              : '${_language.date(range.start)} – ${_language.date(range.end)}',
          // The model does the counting.
          detail: range == null ? null : _language.days(range.days),
          actionLabel: _language.pick('Choose range', 'दायरा छान्नुहोस्'),
          onAction: _pickRange,
          onClear: () => setState(() => _range = null),
        ),
        const SizedBox(height: 16),
        DemoCard(
          icon: Icons.palette_outlined,
          title: _language.pick('Custom design', 'आफ्नै डिजाइन'),
          description: _language.pick(
            'The same picker, redrawn with a DatePickerBuilder.',
            'उही चयनकर्ता, DatePickerBuilder ले नयाँ रूपमा।',
          ),
          placeholder:
              _language.pick('No date selected', 'कुनै मिति चयन गरिएको छैन'),
          value: _customDate == null ? null : _language.date(_customDate!),
          detail: _customDate == null ? null : adDate(_customDate!),
          actionLabel: _language.pick('Try custom design', 'डिजाइन हेर्नुहोस्'),
          onAction: _pickCustom,
          onClear: () => setState(() => _customDate = null),
        ),
      ],
    );
  }
}
