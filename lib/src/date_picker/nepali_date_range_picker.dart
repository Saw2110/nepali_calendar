// Explicit values are kept where they state intent: `day: 1` for the first of
// a month, and the grid's row gap beside its zero column gap.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_semantics.dart';
import 'internal/picker_shared.dart';
import 'internal/range_selection.dart';

// ---------------------------------------------------------------------------
// Dimensions
// ---------------------------------------------------------------------------

/// From this width up the picker shows two months side by side; below it,
/// every month in one vertical list. Material's range picker switches at the
/// same width.
const double _wideBreakpoint = 600.0;

/// Width the side-by-side layout takes when there is room.
const double _wideWidth = 640.0;

/// Horizontal padding inside the picker.
const double _gutter = 12.0;

/// Gap between the two months of the side-by-side layout.
const double _monthGap = 24.0;

/// Row height of a month grid in the side-by-side layout.
const double _wideRow = 40.0;

/// Row height of a month grid in the vertical list, where a phone screen has
/// the room for more comfortable rows.
const double _listRow = 44.0;

/// Gap between rows of a month grid.
const double _rowGap = 2.0;

/// Height of the month title above each month in the vertical list.
const double _listMonthTitle = 44.0;

/// Space below each month in the vertical list.
const double _listMonthSpacing = 8.0;

/// Height of the side-by-side layout's navigation header.
const double _headerHeight = 44.0;

/// Height of the weekday row.
const double _weekdayHeight = 20.0;

/// Height of the side-by-side layout's footer: divider and actions.
const double _footerHeight = 49.0;

/// The range band's opacity over the selection colour.
const double _bandOpacity = 0.16;

// ---------------------------------------------------------------------------
// The picker
// ---------------------------------------------------------------------------

/// A Nepali (Bikram Sambat) date range picker.
///
/// The first tap picks the start, the second the end, and a third starts a
/// new range; tapping a date before the start moves the start there. The
/// range is only handed over when the user presses Save.
///
/// Lays itself out to the space it is given:
///
/// * narrower than 600dp -- a phone -- every month in one vertical list under
///   a header showing the range, the way Material's full-screen range picker
///   does. Give it a bounded height: a [Scaffold] body, for instance.
/// * 600dp and wider, two months side by side with arrows between them, and
///   the actions in a footer.
///
/// Colours and typography follow an ambient [NepaliCalendarTheme] unless an
/// explicit [calendarStyle] is given.
///
/// ```dart
/// NepaliDateRangePicker(
///   onConfirm: (range) => print('${range.start} – ${range.end}'),
///   onCancel: () {},
/// )
/// ```
///
/// For a modal, see [showNepaliDateRangePicker].
class NepaliDateRangePicker extends StatefulWidget {
  /// The width the side-by-side layout takes when there is room for it.
  ///
  /// Exposed for hosts that must give the picker a tight width, as
  /// [AlertDialog] does.
  static const double preferredWideWidth = _wideWidth;

  /// The range to open with, if any.
  final NepaliDateTimeRange? initialRange;

  /// Earliest selectable date. Clamped to the bundled calendar data.
  final NepaliDateTime? minDate;

  /// Latest selectable date. Clamped to the bundled calendar data.
  final NepaliDateTime? maxDate;

  /// The longest range allowed, in days, both ends counted.
  ///
  /// Once a start is picked, later dates beyond this are dimmed and inert.
  /// Null for no limit.
  final int? maxDays;

  /// Explicit styling. Leave unset to follow an ambient [NepaliCalendarTheme].
  final NepaliCalendarStyle calendarStyle;

  /// Called whenever the selection changes: with the range once both ends
  /// are set, and with null while one is still missing.
  final ValueChanged<NepaliDateTimeRange?>? onRangeChanged;

  /// Called when the user presses Save.
  ///
  /// When null the picker pops the enclosing route with the range, which is
  /// what [showNepaliDateRangePicker] relies on. Supply this to embed the
  /// picker in a page: it then leaves the [Navigator] alone.
  final ValueChanged<NepaliDateTimeRange>? onConfirm;

  /// Called when the user cancels. See [onConfirm] for the pop behaviour.
  final VoidCallback? onCancel;

  /// Label for the confirm action. Defaults to "Save" / "ठीक छ".
  final String? confirmText;

  /// Label for the cancel action. Defaults to "Cancel" / "रद्द गर्नुहोस्".
  final String? cancelText;

  const NepaliDateRangePicker({
    super.key,
    this.initialRange,
    this.minDate,
    this.maxDate,
    this.maxDays,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onRangeChanged,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
  }) : assert(maxDays == null || maxDays > 0, 'maxDays must be positive');

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<NepaliDateTimeRange>(
          'initialRange',
          initialRange,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<NepaliDateTime>(
          'minDate',
          minDate,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<NepaliDateTime>(
          'maxDate',
          maxDate,
          defaultValue: null,
        ),
      )
      ..add(IntProperty('maxDays', maxDays, defaultValue: null));
  }

  @override
  State<NepaliDateRangePicker> createState() => _NepaliDateRangePickerState();
}

class _NepaliDateRangePickerState extends State<NepaliDateRangePicker> {
  late RangeSelection _selection;

  /// The left-hand month of the side-by-side layout.
  late NepaliDateTime _firstShown;

  PickerBounds get _bounds =>
      PickerBounds.from(min: widget.minDate, max: widget.maxDate);

  @override
  void initState() {
    super.initState();
    final bounds = _bounds;
    final initial = widget.initialRange;
    // A stored range drifts out of bounds easily; drop it rather than throw.
    _selection = initial != null &&
            bounds.contains(initial.start) &&
            bounds.contains(initial.end)
        ? RangeSelection.from(initial)
        : const RangeSelection();
    final anchor = _selection.start ?? bounds.clamp(NepaliDateTime.now());
    _firstShown = _firstOfMonth(anchor);
    // Keep the right-hand month in range too.
    if (_monthOffset(_firstShown, 1) == null) {
      _firstShown = _monthOffset(_firstShown, -1) ?? _firstShown;
    }
  }

  // --- actions -------------------------------------------------------------

  void _tap(NepaliDateTime date) {
    final next = _selection.tap(date, _bounds, maxDays: widget.maxDays);
    if (next == _selection) return;
    setState(() => _selection = next);
    widget.onRangeChanged?.call(next.range);
  }

  void _confirm() {
    final range = _selection.range;
    if (range == null) return;
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      onConfirm(range);
      return;
    }
    Navigator.of(context).pop(range);
  }

  void _cancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
      return;
    }
    Navigator.of(context).pop();
  }

  void _step(int delta) {
    final next = _monthOffset(_firstShown, delta);
    if (next == null || _monthOffset(next, 1) == null) return;
    setState(() => _firstShown = next);
  }

  bool _canStep(int delta) {
    final next = _monthOffset(_firstShown, delta);
    return next != null && _monthOffset(next, 1) != null;
  }

  /// The month [delta] after [month], or null if none of it is selectable.
  NepaliDateTime? _monthOffset(NepaliDateTime month, int delta) {
    var year = month.year;
    var m = month.month + delta;
    while (m < 1) {
      m += 12;
      year -= 1;
    }
    while (m > 12) {
      m -= 12;
      year += 1;
    }
    if (!_bounds.containsAnyOf(year, m)) return null;
    return NepaliDateTime(year: year, month: m, day: 1);
  }

  static NepaliDateTime _firstOfMonth(NepaliDateTime date) =>
      NepaliDateTime(year: date.year, month: date.month, day: 1);

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > the Material theme, the
    // same order as NepaliDatePicker.
    final style = NepaliCalendarTheme.resolve(
      context,
      widget.calendarStyle,
      fallback: NepaliCalendarThemeData.fromContext(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final maxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return width >= _wideBreakpoint
            ? _buildWide(
                context,
                style,
                math.min(width, _wideWidth),
                maxHeight,
              )
            : _buildList(context, style);
      },
    );
  }

  /// The labels both layouts share.
  _Labels _labels(BuildContext context, NepaliCalendarStyle style) {
    final nepali = style.effectiveConfig.language == Language.nepali;
    return _Labels(
      nepali: nepali,
      confirm: widget.confirmText ?? (nepali ? 'ठीक छ' : 'Save'),
      cancel: widget.cancelText ?? (nepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
    );
  }

  _RangeCell _cell(
    NepaliCalendarStyle style,
    NepaliDateTime date,
    NepaliDateTime month,
    NepaliDateTime today, {
    required bool showOtherMonths,
  }) {
    final inMonth = date.year == month.year && date.month == month.month;
    return _RangeCell(
      style: style,
      date: date,
      isCurrentMonth: inMonth,
      showOtherMonths: showOtherMonths,
      isToday: date.isSameDayAs(today),
      isDisabled: !_selection.isSelectable(
        date,
        _bounds,
        maxDays: widget.maxDays,
      ),
      position: inMonth ? _selection.positionOf(date) : RangePosition.none,
      onTap: () => _tap(date),
    );
  }

  // --- vertical list (phones) ---------------------------------------------

  Widget _buildList(BuildContext context, NepaliCalendarStyle style) {
    final labels = _labels(context, style);
    final config = style.effectiveConfig;
    final months = _bounds.months;
    final today = NepaliDateTime.now();

    double extentOf(NepaliDateTime month) {
      final weeks = pickerWeeksIn(month, config.weekStartType);
      return _listMonthTitle +
          (weeks * _listRow) +
          ((weeks - 1) * _rowGap) +
          _listMonthSpacing;
    }

    return Column(
      children: [
        _ListHeader(
          style: style,
          labels: labels,
          selection: _selection,
          onClose: _cancel,
          onSave: _selection.isComplete ? _confirm : null,
        ),
        const Divider(height: 1),
        SizedBox(
          height: _weekdayHeight + 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Center(child: PickerWeekdayRow(style: style)),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _MonthList(
            months: months,
            extentOf: extentOf,
            initialMonth: _firstOfMonth(
              _selection.start ?? _bounds.clamp(today),
            ),
            itemBuilder: (context, month) {
              final weeks = pickerWeeksIn(month, config.weekStartType);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: _gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _listMonthTitle,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: Text(
                            _monthTitle(month, config.language),
                            style: style.headersStyle.monthHeaderStyle.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: (weeks * _listRow) + ((weeks - 1) * _rowGap),
                      child: PickerMonthGrid(
                        dates: pickerMonthDates(month, config.weekStartType),
                        rows: weeks,
                        rowGap: _rowGap,
                        columnGap: 0,
                        // Blank, not dimmed: in a list of months, last
                        // month's days repeated at the top of this one read
                        // as a second copy of them.
                        cellBuilder: (date) => _cell(
                          style,
                          date,
                          month,
                          today,
                          showOtherMonths: false,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- side by side (tablets, desktop) ------------------------------------

  Widget _buildWide(
    BuildContext context,
    NepaliCalendarStyle style,
    double width,
    double maxHeight,
  ) {
    final labels = _labels(context, style);
    final config = style.effectiveConfig;
    final second = _monthOffset(_firstShown, 1) ?? _firstShown;
    final today = NepaliDateTime.now();
    const chrome = _headerHeight + _weekdayHeight + 4 + 8 + _footerHeight;
    const gaps = (pickerRows - 1) * _rowGap;
    // A short viewport -- a phone in landscape is wide enough for this layout
    // but not tall -- shrinks the rows rather than overflowing.
    final row = math.min(_wideRow, (maxHeight - chrome - gaps) / pickerRows);
    final gridHeight = math.max(0.0, (pickerRows * row) + gaps);
    final monthWidth = (width - (_gutter * 2) - _monthGap) / 2;

    Widget month(NepaliDateTime month) => SizedBox(
          width: monthWidth,
          child: Column(
            children: [
              SizedBox(
                height: _weekdayHeight,
                child: PickerWeekdayRow(style: style),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: gridHeight,
                child: PickerMonthGrid(
                  dates: pickerMonthDates(month, config.weekStartType),
                  rowGap: _rowGap,
                  columnGap: 0,
                  // Blank here too: with two months side by side, dimmed
                  // repeats would show the same date twice at once.
                  cellBuilder: (date) => _cell(
                    style,
                    date,
                    month,
                    today,
                    showOtherMonths: false,
                  ),
                ),
              ),
            ],
          ),
        );

    return SizedBox(
      width: width,
      height: chrome + gridHeight,
      child: Column(
        children: [
          SizedBox(
            height: _headerHeight,
            child: _WideHeader(
              style: style,
              labels: labels,
              first: _firstShown,
              second: second,
              onPrevious: _canStep(-1) ? () => _step(-1) : null,
              onNext: _canStep(1) ? () => _step(1) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                month(_firstShown),
                const SizedBox(width: _monthGap),
                month(second),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: _footerHeight,
            child: _WideFooter(
              style: style,
              labels: labels,
              selection: _selection,
              onCancel: _cancel,
              onSave: _selection.isComplete ? _confirm : null,
            ),
          ),
        ],
      ),
    );
  }

  static String _monthTitle(NepaliDateTime month, Language language) =>
      '${MonthUtils.formattedMonth(month.month, language)} '
      '${NepaliNumberConverter.formattedNumber('${month.year}', language: language)}';
}

// ---------------------------------------------------------------------------
// Labels
// ---------------------------------------------------------------------------

@immutable
class _Labels {
  final bool nepali;
  final String confirm;
  final String cancel;

  const _Labels({
    required this.nepali,
    required this.confirm,
    required this.cancel,
  });

  String get title => nepali ? 'मिति दायरा छान्नुहोस्' : 'Select range';
  String get startPlaceholder => nepali ? 'सुरु मिति' : 'Start date';
  String get endPlaceholder => nepali ? 'अन्तिम मिति' : 'End date';
  String get close => nepali ? 'बन्द गर्नुहोस्' : 'Close';
  String get previous => nepali ? 'अघिल्लो महिना' : 'Previous month';
  String get next => nepali ? 'अर्को महिना' : 'Next month';

  /// "7 days" / "७ दिन".
  String days(int count) {
    if (nepali) {
      return '${NepaliNumberConverter.englishToNepali('$count')} दिन';
    }
    return count == 1 ? '1 day' : '$count days';
  }

  Language get language => nepali ? Language.nepali : Language.english;

  /// The BS range, without repeating the year when both ends share it:
  /// "Ashoj 10 – Kartik 2, 2083".
  String bsRange(RangeSelection selection) {
    final start = selection.start;
    final end = selection.end;
    String md(NepaliDateTime d) =>
        '${MonthUtils.formattedMonth(d.month, language)} '
        '${NepaliNumberConverter.formattedNumber('${d.day}', language: language)}';
    String year(NepaliDateTime d) =>
        NepaliNumberConverter.formattedNumber('${d.year}', language: language);

    if (start == null) return '$startPlaceholder – $endPlaceholder';
    if (end == null) {
      return '${pickerBsLabel(start, language)} – $endPlaceholder';
    }
    if (start.year == end.year) {
      return '${md(start)} – ${md(end)}, ${year(end)}';
    }
    return '${pickerBsLabel(start, language)} – ${pickerBsLabel(end, language)}';
  }

  /// The AD range and its length, or null until the range is complete.
  String? adSummary(RangeSelection selection) {
    final range = selection.range;
    if (range == null) return null;
    return '${pickerAdRangeLabel(range.start, range.end)} · ${days(range.days)}';
  }
}

// ---------------------------------------------------------------------------
// Vertical layout pieces
// ---------------------------------------------------------------------------

/// Close and Save, then the title and the range as picked so far.
class _ListHeader extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Labels labels;
  final RangeSelection selection;
  final VoidCallback onClose;
  final VoidCallback? onSave;

  const _ListHeader({
    required this.style,
    required this.labels,
    required this.selection,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = labels.adSummary(selection);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                tooltip: labels.close,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(pickerRadius),
                  ),
                ),
                child: Text(labels.confirm),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels.bsRange(selection),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Laid out even while empty, so the header does not jump
                // when the range completes.
                Text(
                  summary ?? ' ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Every month in range in one scrolling list, opened on [initialMonth].
///
/// Each month's height is known up front, so the list can open on any month
/// without laying out the ones before it.
class _MonthList extends StatefulWidget {
  final List<NepaliDateTime> months;
  final double Function(NepaliDateTime month) extentOf;
  final NepaliDateTime initialMonth;
  final Widget Function(BuildContext context, NepaliDateTime month) itemBuilder;

  const _MonthList({
    required this.months,
    required this.extentOf,
    required this.initialMonth,
    required this.itemBuilder,
  });

  @override
  State<_MonthList> createState() => _MonthListState();
}

class _MonthListState extends State<_MonthList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    var offset = 0.0;
    for (final month in widget.months) {
      if (month.year == widget.initialMonth.year &&
          month.month == widget.initialMonth.month) {
        break;
      }
      offset += widget.extentOf(month);
    }
    _controller = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      padding: EdgeInsets.zero,
      itemCount: widget.months.length,
      itemExtentBuilder: (index, _) => widget.extentOf(widget.months[index]),
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, widget.months[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Side-by-side layout pieces
// ---------------------------------------------------------------------------

/// `‹  Month Year        Month Year  ›`.
class _WideHeader extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Labels labels;
  final NepaliDateTime first;
  final NepaliDateTime second;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _WideHeader({
    required this.style,
    required this.labels,
    required this.first,
    required this.second,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = style.headersStyle.monthHeaderStyle.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    final language = labels.language;

    Widget title(NepaliDateTime month) => Expanded(
          child: Center(
            child: Text(
              _NepaliDateRangePickerState._monthTitle(month, language),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: titleStyle,
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded, size: 22),
            tooltip: labels.previous,
            visualDensity: VisualDensity.compact,
          ),
          title(first),
          title(second),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, size: 22),
            tooltip: labels.next,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// The range in AD and its length on the left; Cancel and Save on the right.
class _WideFooter extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Labels labels;
  final RangeSelection selection;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  const _WideFooter({
    required this.style,
    required this.labels,
    required this.selection,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
          indent: _gutter,
          endIndent: _gutter,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: _gutter, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    labels.adSummary(selection) ?? labels.bsRange(selection),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(onPressed: onCancel, child: Text(labels.cancel)),
                TextButton(onPressed: onSave, child: Text(labels.confirm)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Day cell
// ---------------------------------------------------------------------------

/// A date, with its part of the range band.
///
/// The band is a tinted strip behind the dates between the ends; the ends
/// are filled squares like the single picker's selection, with the band
/// reaching from them towards the middle so the range reads as one shape
/// across a week.
class _RangeCell extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDateTime date;
  final bool isCurrentMonth;
  final bool showOtherMonths;
  final bool isToday;
  final bool isDisabled;
  final RangePosition position;
  final VoidCallback onTap;

  const _RangeCell({
    required this.style,
    required this.date,
    required this.isCurrentMonth,
    required this.showOtherMonths,
    required this.isToday,
    required this.isDisabled,
    required this.position,
    required this.onTap,
  });

  bool get _isEnd =>
      position == RangePosition.start ||
      position == RangePosition.end ||
      position == RangePosition.single;

  @override
  Widget build(BuildContext context) {
    if (!isCurrentMonth && !showOtherMonths) return const SizedBox.expand();

    final cells = style.cellsStyle;
    final config = style.effectiveConfig;
    final isWeekend = WeekUtils.isWeekend(date.weekday, config.weekendType);
    final inert = isDisabled || !isCurrentMonth;
    final directionality = Directionality.of(context);

    return Semantics(
      button: !inert,
      enabled: !inert,
      selected: position != RangePosition.none,
      label: _semanticLabel(config.language),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.min(constraints.maxWidth, constraints.maxHeight);
          final inset = (constraints.maxHeight - side) / 2;
          final band = cells.selectedColor.withValues(alpha: _bandOpacity);

          return InkResponse(
            onTap: inert
                ? null
                : () {
                    config.hapticFeedback.perform();
                    onTap();
                  },
            containedInkWell: true,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(pickerRadius),
            ),
            child: Stack(
              children: [
                if (_bandAlignment(directionality) case final alignment?)
                  Positioned.fill(
                    top: inset,
                    bottom: inset,
                    child: FractionallySizedBox(
                      alignment: alignment,
                      widthFactor: position == RangePosition.middle ? 1.0 : 0.5,
                      child: ColoredBox(color: band),
                    ),
                  ),
                Center(
                  child: SizedBox.square(
                    dimension: side,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _isEnd ? cells.selectedColor : null,
                        borderRadius: BorderRadius.circular(pickerRadius),
                        border: isToday && !_isEnd
                            ? Border.all(color: cells.todayColor, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              NepaliNumberConverter.formattedNumber(
                                '${date.day}',
                                language: config.language,
                              ),
                              style: cells.dayStyle.copyWith(
                                fontSize: 14,
                                fontWeight: _isEnd || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _foreground(cells, isWeekend),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Which side of the cell the band covers, or null for no band.
  ///
  /// A start reaches towards the end of the week, an end towards its start;
  /// mirrored for right-to-left.
  Alignment? _bandAlignment(TextDirection direction) {
    final ltr = direction == TextDirection.ltr;
    switch (position) {
      case RangePosition.middle:
        return Alignment.center;
      case RangePosition.start:
        return ltr ? Alignment.centerRight : Alignment.centerLeft;
      case RangePosition.end:
        return ltr ? Alignment.centerLeft : Alignment.centerRight;
      case RangePosition.none:
      case RangePosition.single:
        return null;
    }
  }

  Color _foreground(CellStyle cells, bool isWeekend) {
    if (_isEnd) return cells.onHighlightColor;
    if (!isCurrentMonth) {
      return cells.dimmedDateTextColor.withValues(alpha: 0.4);
    }
    if (isDisabled) {
      return (isWeekend ? cells.weekDayColor : cells.dateTextColor)
          .withValues(alpha: 0.3);
    }
    if (isToday) return cells.todayColor;
    if (isWeekend) return cells.weekDayColor;
    return cells.dateTextColor;
  }

  /// The full date, as the single picker announces it, plus its part in the
  /// range.
  String _semanticLabel(Language language) {
    final base = CalendarSemantics.dayLabel(
      date,
      language: language,
      isToday: isToday,
      isDisabled: isDisabled,
      isOtherMonth: !isCurrentMonth,
    );
    final nepali = language == Language.nepali;
    final role = switch (position) {
      RangePosition.start => nepali ? 'सुरु मिति' : 'Start date',
      RangePosition.end => nepali ? 'अन्तिम मिति' : 'End date',
      RangePosition.single => nepali ? 'सुरु मिति' : 'Start date',
      RangePosition.middle => nepali ? 'दायरामा' : 'In range',
      RangePosition.none => null,
    };
    return role == null ? base : '$base, $role';
  }
}
