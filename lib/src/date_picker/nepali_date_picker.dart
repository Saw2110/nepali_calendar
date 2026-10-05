// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide it.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_semantics.dart';
import 'internal/date_picker_layout.dart';
import 'internal/picker_shared.dart';

// ---------------------------------------------------------------------------
// Dimensions
//
// The measurements of the parts. Those that decide the picker's overall size
// live in internal/date_picker_layout.dart, which the dialog shares.
// ---------------------------------------------------------------------------

/// Columns of the month page and the year list.
const int _choiceColumns = 3;

/// Rows of the month page. Four rows of three fit all twelve months at once.
const int _choiceRows = 4;

/// Height of the month or year label between its arrows.
const double _fieldHeight = 36.0;

/// Size of the navigation row's arrows.
///
/// Four arrows share the row with two labels, so they are a little under the
/// 44dp the range picker's arrows get; 40 still clears Material's minimum
/// comfortably on a dialog this size.
const double _arrowSize = 40.0;

/// Gap between month or year tiles.
const double _choiceGap = 8.0;

/// Height of a month or year tile. The month page centres it within its slot.
const double _choiceHeight = 40.0;

/// Distance between the tops of two rows in the year list.
const double _yearRowExtent = _choiceHeight + _choiceGap;

/// How long a view change takes.
const Duration _transition = Duration(milliseconds: 200);

// ---------------------------------------------------------------------------
// The picker
// ---------------------------------------------------------------------------

/// A Nepali (Bikram Sambat) date picker.
///
/// A coloured band shows the selected date in BS and in the Gregorian (AD)
/// calendar. Below it, `‹ Month ›  ‹ Year ›` steps
/// the month grid by months or years; tapping the month or the year swaps the
/// grid for a 4x3 page of months or a scrolling list of years. Today sits at
/// the bottom left, Close -- and OK, unless a tap confirms -- at the right. Colours and typography follow an ambient [NepaliCalendarTheme] unless an explicit
/// [calendarStyle] is given, so light and dark work without configuration:
///
/// ```dart
/// NepaliDatePicker(
///   initialDate: NepaliDateTime.now(),
///   onDateSelected: (date) => print(date),
/// )
/// ```
///
/// For a modal, see [showNepaliDatePicker].
class NepaliDatePicker extends StatefulWidget {
  /// The width the picker takes when there is room for it.
  ///
  /// Exposed so a host that must give the picker a tight width can ask for the
  /// right one. [AlertDialog], for instance, measures its content's intrinsic
  /// width, which a [LayoutBuilder] cannot answer -- so it has to be told.
  static const double preferredWidth = datePickerWidth;

  /// Called whenever a date is tapped, before it is confirmed.
  ///
  /// Fires on every tap. For what the user settled on, use [onConfirm] or the
  /// value [showNepaliDatePicker] returns.
  final Function(NepaliDateTime) onDateSelected;

  /// The date to open on. Defaults to today, clamped into range.
  final NepaliDateTime? initialDate;

  /// Explicit styling. Leave unset to follow an ambient [NepaliCalendarTheme].
  final NepaliCalendarStyle calendarStyle;

  /// Which view the picker opens on.
  ///
  /// [NepaliDatePickerMode.year] suits dates far from today, such as a
  /// birthday. The picker returns a full date whatever the mode.
  final NepaliDatePickerMode initialMode;

  /// Earliest selectable date. Earlier dates render dimmed and inert.
  ///
  /// Clamped to the range the bundled calendar data covers.
  final NepaliDateTime? minDate;

  /// Latest selectable date. Later dates render dimmed and inert.
  ///
  /// Clamped to the range the bundled calendar data covers.
  final NepaliDateTime? maxDate;

  /// Called when the user confirms.
  ///
  /// When null the picker pops the enclosing route with the selected date,
  /// which is what [showNepaliDatePicker] relies on. Supply this to embed the
  /// picker in a page: it then leaves the [Navigator] alone.
  final ValueChanged<NepaliDateTime>? onConfirm;

  /// Called when the user cancels. See [onConfirm] for the pop behaviour.
  final VoidCallback? onCancel;

  /// Label for the confirm action. Defaults to "OK" / "ठीक छ".
  ///
  /// Only shown when [autoConfirm] is false.
  final String? confirmText;

  /// Label for the cancel action. Defaults to "Cancel" / "रद्द गर्नुहोस्",
  /// or to "Close" / "बन्द गर्नुहोस्" when [autoConfirm] leaves it alone at
  /// the bottom.
  final String? cancelText;

  /// Whether to render the action row: Today, Close and, without
  /// [autoConfirm], OK.
  ///
  /// Set false when the host supplies its own actions. The picker then never
  /// confirms on its own -- [autoConfirm] is ignored -- so pair it with
  /// [onDateSelected] to receive the selection. The title band stays.
  final bool showActions;

  /// Whether tapping a date (or Today) confirms it straight away.
  ///
  /// When true, a tap selects and confirms in one step, through [onConfirm]
  /// or by popping the route, and only Close is shown at the bottom.
  ///
  /// Off by default here, so a picker embedded in a page behaves as it did in
  /// 0.1.0: a tap only selects, and nothing is confirmed -- or popped -- until
  /// the user presses OK. [showNepaliDatePicker] turns it on, because in a
  /// dialog a tap that closes it is what users expect. Ignored when
  /// [showActions] is false.
  final bool autoConfirm;

  /// How the weekday names above the grid are written.
  ///
  /// Null (the default) shows initials -- `आ सो मं` / `S M T` -- which fit
  /// any phone. [TitleFormat.half] and [TitleFormat.full] show longer names;
  /// a name too wide for its column is scaled down to fit rather than cut
  /// off. Independent of [CalendarConfig.weekTitleType], which the calendars
  /// use.
  final TitleFormat? weekdayFormat;

  /// Custom designs for the picker's parts: the title band, the navigation
  /// row, day cells, weekday names, the action row, and the month and year
  /// tiles. Each part left unset, or whose builder returns null, keeps the
  /// default design.
  ///
  /// A custom footer replaces the action row, and is not shown when
  /// [showActions] is false.
  final DatePickerBuilder? pickerBuilder;

  const NepaliDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.initialMode = NepaliDatePickerMode.day,
    this.minDate,
    this.maxDate,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.showActions = true,
    this.autoConfirm = false,
    this.weekdayFormat,
    this.pickerBuilder,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<NepaliDateTime>(
          'initialDate',
          initialDate,
          defaultValue: null,
        ),
      )
      ..add(EnumProperty<NepaliDatePickerMode>('initialMode', initialMode))
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
      ..add(
        FlagProperty('showActions', value: showActions, ifFalse: 'no actions'),
      )
      ..add(
        FlagProperty(
          'autoConfirm',
          value: autoConfirm,
          ifTrue: 'confirms on tap',
        ),
      )
      ..add(
        EnumProperty<TitleFormat>(
          'weekdayFormat',
          weekdayFormat,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<DatePickerBuilder>(
          'pickerBuilder',
          pickerBuilder,
          defaultValue: null,
        ),
      );
  }

  @override
  State<NepaliDatePicker> createState() => _NepaliDatePickerState();
}

class _NepaliDatePickerState extends State<NepaliDatePicker> {
  late NepaliDateTime _selected;
  late NepaliDateTime _displayed;
  late NepaliDatePickerMode _mode;

  /// Scrolls the year list. It listens too, so the header arrows can disable
  /// at either end of the list.
  final _yearScroll = ScrollController();

  /// The selectable range, built once rather than on every access -- the
  /// grid consults it for each day cell. Rebuilt only when [widget]'s bounds
  /// change.
  late PickerBounds _bounds;

  PickerBounds _computeBounds() =>
      PickerBounds.from(min: widget.minDate, max: widget.maxDate);

  /// Whether a tap confirms by itself. A picker without its footer never
  /// does: the host owns confirmation there.
  bool get _autoConfirms => widget.autoConfirm && widget.showActions;

  @override
  void initState() {
    super.initState();
    _bounds = _computeBounds();
    final initial = _bounds.clamp(widget.initialDate ?? NepaliDateTime.now());
    _selected = initial;
    _displayed = initial;
    _mode = widget.initialMode;
    if (_mode == NepaliDatePickerMode.year) _scrollToYearAfterLayout();
  }

  @override
  void didUpdateWidget(covariant NepaliDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minDate != oldWidget.minDate ||
        widget.maxDate != oldWidget.maxDate) {
      _bounds = _computeBounds();
      // Pull the selection and the month on show into the new range, so the
      // picker never holds a date it would refuse to let the user pick.
      _selected = _bounds.clamp(_selected);
      _displayed = _bounds.clamp(_displayed);
    }
  }

  @override
  void dispose() {
    _yearScroll.dispose();
    super.dispose();
  }

  // --- actions -------------------------------------------------------------

  void _selectDay(NepaliDateTime date) {
    if (!_bounds.contains(date)) return;
    setState(() => _selected = date);
    widget.onDateSelected(date);
    if (_autoConfirms) _confirm();
  }

  void _selectYear(int year) {
    setState(() {
      _displayed = _bounds.clamp(
        NepaliDateTime(year: year, month: _displayed.month, day: 1),
      );
      _mode = NepaliDatePickerMode.month;
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _displayed = _bounds.clamp(
        NepaliDateTime(year: _displayed.year, month: month, day: 1),
      );
      _mode = NepaliDatePickerMode.day;
    });
  }

  void _goToToday() {
    final today = _bounds.clamp(NepaliDateTime.now());
    setState(() {
      _displayed = today;
      _selected = today;
      _mode = NepaliDatePickerMode.day;
    });
    widget.onDateSelected(today);
    if (_autoConfirms) _confirm();
  }

  /// Opens the month page, or returns to the days if it is already open.
  void _toggleMonthView() {
    setState(() {
      if (_mode == NepaliDatePickerMode.month) {
        _mode = NepaliDatePickerMode.day;
      } else {
        _mode = NepaliDatePickerMode.month;
      }
    });
  }

  /// Opens the year list, or returns to the days if it is already open.
  void _toggleYearView() {
    setState(() {
      if (_mode == NepaliDatePickerMode.year) {
        _mode = NepaliDatePickerMode.day;
      } else {
        _mode = NepaliDatePickerMode.year;
        _scrollToYearAfterLayout();
      }
    });
  }

  /// The year list's scroll position, once it is laid out.
  ///
  /// The last one: while the view cross-fades, an outgoing list can still be
  /// attached beside the incoming one.
  ScrollPosition? get _yearPosition =>
      _yearScroll.hasClients ? _yearScroll.positions.last : null;

  /// Centres the displayed year in the list. The list must be laid out before
  /// it can be scrolled, hence after the frame.
  void _scrollToYearAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = _yearPosition;
      if (!mounted || position == null) return;
      final row = (_displayed.year - _bounds.min.year) ~/ _choiceColumns;
      final target = (row * _yearRowExtent) -
          ((position.viewportDimension - _choiceHeight) / 2);
      position.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  /// Steps [delta] in whatever the current view moves through: months in the
  /// day view, years in the month view (all twelve months fit one page) and a
  /// screenful of the year list in the year view. Shared by the header arrows
  /// and the swipe gesture.
  void _step(int delta) {
    if (!_canStep(delta)) return;
    if (_mode == NepaliDatePickerMode.year) {
      // Scrolling, not state: the list's listener rebuilds the arrows.
      final position = _yearPosition!;
      // Whole rows, so a row is never left half on screen.
      final rows = (position.viewportDimension / _yearRowExtent).floor();
      final target =
          position.pixels + delta * math.max(rows, 1) * _yearRowExtent;
      position.animateTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: _transition,
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() {
      _displayed = _mode == NepaliDatePickerMode.day
          ? _bounds.monthOffset(_displayed, delta)!
          : _bounds.clamp(
              NepaliDateTime(
                year: _displayed.year + delta,
                month: _displayed.month,
                day: 1,
              ),
            );
    });
  }

  bool _canStep(int delta) {
    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _bounds.monthOffset(_displayed, delta) != null;
      case NepaliDatePickerMode.month:
        final year = _displayed.year + delta;
        return year >= _bounds.min.year && year <= _bounds.max.year;
      case NepaliDatePickerMode.year:
        final position = _yearPosition;
        if (position == null || !position.hasContentDimensions) return false;
        return delta < 0
            ? position.pixels > position.minScrollExtent
            : position.pixels < position.maxScrollExtent;
    }
  }

  /// Whether the month arrows can step [delta] months. Only in the day view:
  /// the month and year views already show every month.
  bool _canStepMonth(int delta) =>
      _mode == NepaliDatePickerMode.day &&
      _bounds.monthOffset(_displayed, delta) != null;

  void _stepMonth(int delta) {
    if (!_canStepMonth(delta)) return;
    setState(() => _displayed = _bounds.monthOffset(_displayed, delta)!);
  }

  /// Whether the year arrows can step [delta] years -- or, in the year view,
  /// a screenful of the list.
  bool _canStepYear(int delta) {
    if (_mode == NepaliDatePickerMode.year) return _canStep(delta);
    final year = _displayed.year + delta;
    return year >= _bounds.min.year && year <= _bounds.max.year;
  }

  /// Steps [delta] years, keeping the month; a month outside the range is
  /// pulled to its nearest end.
  void _stepYear(int delta) {
    if (!_canStepYear(delta)) return;
    if (_mode == NepaliDatePickerMode.year) return _step(delta);
    setState(() {
      _displayed = _bounds.clamp(
        NepaliDateTime(
          year: _displayed.year + delta,
          month: _displayed.month,
          day: 1,
        ),
      );
    });
  }

  void _confirm() {
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) return onConfirm(_selected);
    Navigator.of(context).pop(_selected);
  }

  void _cancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) return onCancel();
    Navigator.of(context).pop();
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > the Material theme.
    //
    // The picker falls back to the Material theme where the calendar widgets
    // fall back to the legacy palette. Those widgets look as they always did,
    // so their defaults are worth preserving; the picker was rebuilt in 0.1.0
    // and resembles nothing of its old self, so there is no prior appearance
    // to protect -- and the legacy palette is light-only, which would leave a
    // dark app with black dates on a dark alert.
    final style = NepaliCalendarTheme.resolve(
      context,
      widget.calendarStyle,
      fallback: NepaliCalendarThemeData.fromContext(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = DatePickerLayout.measure(
          context,
          constraints,
          withActions: widget.showActions,
        );
        return SizedBox(
          width: layout.width,
          height: layout.height,
          child: _buildBody(style, layout),
        );
      },
    );
  }

  Widget _buildBody(NepaliCalendarStyle style, DatePickerLayout layout) {
    final isDayView = _mode == NepaliDatePickerMode.day;
    final language = style.effectiveConfig.language;

    final todayInRange = _bounds.contains(NepaliDateTime.now());
    final title = PickerTitleData(
      selected: _selected,
      onToday: todayInRange ? _goToToday : null,
      isBesideGrid: layout.sideBand,
      style: style,
      language: language,
    );
    final band = widget.pickerBuilder?.titleBuilder?.call(title) ??
        _TitleBand(data: title);

    final main = <Widget>[
      SizedBox(
        height: datePickerHeaderHeight,
        // Rebuilt on scroll so the arrows disable at the ends of the year
        // list; outside the year view the list is detached and silent.
        child: ListenableBuilder(
          listenable: _yearScroll,
          builder: (context, _) {
            final onPrevious = _canStep(-1) ? () => _step(-1) : null;
            final onNext = _canStep(1) ? () => _step(1) : null;
            final onPreviousYear =
                _canStepYear(-1) ? () => _stepYear(-1) : null;
            final onNextYear = _canStepYear(1) ? () => _stepYear(1) : null;
            final custom = widget.pickerBuilder?.headerBuilder?.call(
              PickerHeaderData(
                month: NepaliDateTime(
                  year: _displayed.year,
                  month: _displayed.month,
                  day: 1,
                ),
                mode: _mode,
                onPrevious: onPrevious,
                onNext: onNext,
                onPreviousYear: onPreviousYear,
                onNextYear: onNextYear,
                onMonthTap: _toggleMonthView,
                onYearTap: _toggleYearView,
                style: style,
                language: language,
              ),
            );
            return custom ??
                _Header(
                  style: style,
                  mode: _mode,
                  monthLabel:
                      MonthUtils.formattedMonth(_displayed.month, language),
                  yearLabel: NepaliNumberConverter.formattedNumber(
                    '${_displayed.year}',
                    language: language,
                  ),
                  onMonthTap: _toggleMonthView,
                  onYearTap: _toggleYearView,
                  onPreviousMonth:
                      _canStepMonth(-1) ? () => _stepMonth(-1) : null,
                  onNextMonth: _canStepMonth(1) ? () => _stepMonth(1) : null,
                  onPreviousYear: onPreviousYear,
                  onNextYear: onNextYear,
                );
          },
        ),
      ),
      // The weekday row means nothing outside the day grid. Total height is
      // fixed regardless, so hiding it gives the space to the grid instead
      // of making the dialog jump.
      if (isDayView) ...[
        SizedBox(height: pickerCellGap),
        SizedBox(
          height: datePickerWeekdayHeight,
          child: Center(
            child: SizedBox(
              width: layout.gridWidth,
              child: PickerWeekdayRow(
                style: style,
                format: widget.weekdayFormat,
                builder: widget.pickerBuilder,
              ),
            ),
          ),
        ),
      ],
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: datePickerVerticalPadding / 2,
            ),
            child: SizedBox(
              width: layout.gridWidth,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -500) _step(1);
                  if (velocity > 500) _step(-1);
                },
                child: AnimatedSwitcher(
                  duration: _transition,
                  child: KeyedSubtree(
                    key: ValueKey(_viewKey),
                    child: _buildView(style, layout),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.showActions)
        SizedBox(height: datePickerActionsHeight, child: _buildActions(style)),
    ];

    if (layout.sideBand) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: datePickerSideBandWidth, child: band),
          Expanded(child: Column(children: main)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full width: the column would otherwise centre the band and let it
        // shrink to its text.
        SizedBox(
          width: double.infinity,
          height: datePickerBandHeight,
          child: band,
        ),
        ...main,
      ],
    );
  }

  /// Today, then Close -- or Cancel and OK unless a tap confirms -- or a
  /// custom footer.
  Widget _buildActions(NepaliCalendarStyle style) {
    final withConfirm = !widget.autoConfirm;
    final custom = widget.pickerBuilder?.footerBuilder?.call(
      PickerFooterData(
        selected: _selected,
        onToday: _bounds.contains(NepaliDateTime.now()) ? _goToToday : null,
        onConfirm: withConfirm ? _confirm : null,
        onCancel: _cancel,
        style: style,
        language: style.effectiveConfig.language,
      ),
    );
    return custom ??
        _Actions(
          style: style,
          confirmText: widget.confirmText,
          cancelText: widget.cancelText,
          onToday: _bounds.contains(NepaliDateTime.now()) ? _goToToday : null,
          onCancel: _cancel,
          onConfirm: withConfirm ? _confirm : null,
        );
  }

  /// Identifies what the grid area shows, so a change of year in the month
  /// view cross-fades just as a change of view does. The day view stays put
  /// across months, as before, and the year list scrolls rather than fades.
  Object get _viewKey {
    switch (_mode) {
      case NepaliDatePickerMode.day:
      case NepaliDatePickerMode.year:
        return _mode;
      case NepaliDatePickerMode.month:
        return (_mode, _displayed.year);
    }
  }

  Widget _buildView(NepaliCalendarStyle style, DatePickerLayout layout) {
    final language = style.effectiveConfig.language;

    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _DayGrid(
          style: style,
          bounds: _bounds,
          displayed: _displayed,
          selected: _selected,
          onSelect: _selectDay,
          builder: widget.pickerBuilder,
        );
      case NepaliDatePickerMode.month:
        return _ChoicePage(
          style: style,
          builder: widget.pickerBuilder,
          choices: [
            for (var month = 1; month <= 12; month++)
              _Choice(
                value: month,
                isYear: false,
                label: MonthUtils.formattedMonth(month, language),
                isSelected: month == _displayed.month,
                isDisabled: !_bounds.containsAnyOf(_displayed.year, month),
                onTap: () => _selectMonth(month),
              ),
          ],
        );
      case NepaliDatePickerMode.year:
        return _YearList(
          style: style,
          firstYear: _bounds.min.year,
          lastYear: _bounds.max.year,
          selectedYear: _displayed.year,
          controller: _yearScroll,
          onSelect: _selectYear,
          builder: widget.pickerBuilder,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// The selected date on a band of the selection colour: the year, the date
/// in BS and the same date in AD. Above the grid, or beside it on a short
/// screen. Display only: Today lives in the action row.
///
/// The AD date is the one most users cross-check a BS date against, so it
/// sits right under it. It is always written in English: it is the
/// Gregorian date, and the format matches what users see on their other
/// devices.
class _TitleBand extends StatelessWidget {
  final PickerTitleData data;

  const _TitleBand({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cells = data.style.cellsStyle;
    final foreground = cells.onHighlightColor;
    final muted = foreground.withValues(alpha: 0.75);
    final year = Text(
      data.yearLabel,
      style: textTheme.titleSmall?.copyWith(
        color: muted,
        fontWeight: FontWeight.w600,
      ),
    );
    final date = Text(
      data.dateLabel,
      style: textTheme.headlineSmall?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
    );
    final ad = Text(
      data.adLabel,
      style: textTheme.bodySmall?.copyWith(color: muted),
    );

    if (data.isBesideGrid) {
      return ColoredBox(
        color: cells.selectedColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          // The date wraps to the band's width; a large text scale shrinks
          // the block rather than overflowing it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(
              width: datePickerSideBandWidth - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  year,
                  const SizedBox(height: 4),
                  date,
                  const SizedBox(height: 4),
                  ad,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: cells.selectedColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // Scaled down rather than overflowing at a large text scale.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [year, date, ad],
          ),
        ),
      ),
    );
  }
}

/// `‹ Month ›  ‹ Year ›`.
///
/// The month arrows step months in the day view; the year arrows step years,
/// or a screenful of the list in the year view. Tapping the month or the
/// year opens its page in the grid area, and tapping it again returns to the
/// days.
class _Header extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDatePickerMode mode;
  final String monthLabel;
  final String yearLabel;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onPreviousYear;
  final VoidCallback? onNextYear;

  const _Header({
    required this.style,
    required this.mode,
    required this.monthLabel,
    required this.yearLabel,
    required this.onMonthTap,
    required this.onYearTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousYear,
    required this.onNextYear,
  });

  @override
  Widget build(BuildContext context) {
    final nepali = style.effectiveConfig.language == Language.nepali;
    final paging = mode == NepaliDatePickerMode.year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _Stepper(
              style: style,
              label: monthLabel,
              semanticLabel: nepali ? 'महिना छान्नुहोस्' : 'Select month',
              isOpen: mode == NepaliDatePickerMode.month,
              onTap: onMonthTap,
              previousTooltip: nepali ? 'अघिल्लो महिना' : 'Previous month',
              nextTooltip: nepali ? 'अर्को महिना' : 'Next month',
              onPrevious: onPreviousMonth,
              onNext: onNextMonth,
            ),
          ),
          const SizedBox(width: _choiceGap),
          Expanded(
            child: _Stepper(
              style: style,
              label: yearLabel,
              semanticLabel: nepali ? 'वर्ष छान्नुहोस्' : 'Select year',
              isOpen: paging,
              onTap: onYearTap,
              previousTooltip: paging
                  ? (nepali ? 'अघिल्लो पृष्ठ' : 'Previous page')
                  : (nepali ? 'अघिल्लो वर्ष' : 'Previous year'),
              nextTooltip: paging
                  ? (nepali ? 'अर्को पृष्ठ' : 'Next page')
                  : (nepali ? 'अर्को वर्ष' : 'Next year'),
              onPrevious: onPreviousYear,
              onNext: onNextYear,
            ),
          ),
        ],
      ),
    );
  }
}

/// `‹ label ›`: a tappable label between two arrows.
///
/// The label carries a ▾, so it reads as something that opens; the open label
/// takes the selection colour and flips its ▾, so it is clear which page the
/// grid is showing. A null arrow callback shows the arrow disabled rather
/// than hiding it, so the row does not reflow at the ends of the range.
class _Stepper extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String label;
  final String semanticLabel;
  final bool isOpen;
  final VoidCallback onTap;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Stepper({
    required this.style,
    required this.label,
    required this.semanticLabel,
    required this.isOpen,
    required this.onTap,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isOpen ? style.cellsStyle.selectedColor : null;

    Widget arrow(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: _arrowSize,
            height: _arrowSize,
          ),
        );

    return Row(
      children: [
        arrow(Icons.chevron_left_rounded, previousTooltip, onPrevious),
        Expanded(
          child: Semantics(
            button: true,
            label: semanticLabel,
            value: label,
            expanded: isOpen,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(pickerRadius),
              child: SizedBox(
                height: _fieldHeight,
                child: Center(
                  // Scaled down rather than cut off: a long month name in a
                  // narrow dialog.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          style: style.headersStyle.monthHeaderStyle.copyWith(
                            fontSize: 15,
                            fontWeight:
                                isOpen ? FontWeight.w700 : FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: _transition,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 20,
                            color: accent ?? colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        arrow(Icons.chevron_right_rounded, nextTooltip, onNext),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Day grid
// ---------------------------------------------------------------------------

/// Six rows of dates, with the adjacent months' days filling the edges.
class _DayGrid extends StatelessWidget {
  final NepaliCalendarStyle style;
  final PickerBounds bounds;
  final NepaliDateTime displayed;
  final NepaliDateTime selected;
  final ValueChanged<NepaliDateTime> onSelect;
  final DatePickerBuilder? builder;

  const _DayGrid({
    required this.style,
    required this.bounds,
    required this.displayed,
    required this.selected,
    required this.onSelect,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final today = NepaliDateTime.now();

    return PickerMonthGrid(
      dates: pickerMonthDates(displayed, style.effectiveConfig.weekStartType),
      cellBuilder: (date) => _cell(date, today),
    );
  }

  Widget _cell(NepaliDateTime date, NepaliDateTime today) {
    final inMonth =
        date.month == displayed.month && date.year == displayed.year;

    return _DayCell(
      style: style,
      date: date,
      isCurrentMonth: inMonth,
      isSelected: inMonth && date.isSameDayAs(selected),
      isToday: date.isSameDayAs(today),
      isDisabled: !bounds.contains(date),
      onTap: () => onSelect(date),
      builder: builder,
    );
  }
}

/// A single date.
class _DayCell extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final VoidCallback onTap;
  final DatePickerBuilder? builder;

  const _DayCell({
    required this.style,
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;

    // An out-of-range day and a neighbouring month's day are both inert: the
    // screen reader must not offer either as a button it can press.
    final inert = isDisabled || !isCurrentMonth;
    final tap = pickerDayTap(config, onTap, enabled: !inert);
    final custom = builder?.dayBuilder?.call(
      PickerDayData(
        date: date,
        isToday: isToday,
        isSelected: isSelected,
        isDisabled: isDisabled,
        isOtherMonth: !isCurrentMonth,
        isWeekend: WeekUtils.isWeekend(date.weekday, config.weekendType),
        rangePosition: PickerRangePosition.none,
        onTap: tap,
        style: style,
        language: config.language,
      ),
    );

    return Semantics(
      button: !inert,
      enabled: !inert,
      selected: isSelected,
      label: _semanticLabel(config.language),
      excludeSemantics: true,
      child: custom ??
          InkResponse(
            onTap: tap,
            containedInkWell: true,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(pickerRadius),
            ),
            // The tap target is the whole cell; the square is only decoration.
            child: PickerDaySquare(
              style: style,
              date: date,
              filled: isSelected,
              isToday: isToday,
              isDisabled: isDisabled,
              isDimmed: !isCurrentMonth,
            ),
          ),
    );
  }

  /// What a screen reader announces.
  ///
  /// Spelled out: "15" alone tells a screen reader user nothing about which
  /// month they are in. Shared with [NepaliCalendar] so the two announce a
  /// date the same way.
  String _semanticLabel(Language language) => CalendarSemantics.dayLabel(
        date,
        language: language,
        isToday: isToday,
        isDisabled: isDisabled,
        isOtherMonth: !isCurrentMonth,
      );
}

// ---------------------------------------------------------------------------
// Month and year pages
// ---------------------------------------------------------------------------

/// One month or year on a page.
@immutable
class _Choice {
  final int value;
  final bool isYear;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _Choice({
    required this.value,
    required this.isYear,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });
}

/// The twelve months as a 4x3 page: four rows of three.
///
/// Laid out as rows and columns rather than a grid view, so the page fills
/// the space the day grid leaves and never scrolls.
class _ChoicePage extends StatelessWidget {
  final NepaliCalendarStyle style;
  final List<_Choice> choices;
  final DatePickerBuilder? builder;

  const _ChoicePage({
    required this.style,
    required this.choices,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < _choiceRows; row++) ...[
          if (row > 0) const SizedBox(height: _choiceGap),
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < _choiceColumns; col++) ...[
                  if (col > 0) const SizedBox(width: _choiceGap),
                  Expanded(child: _slot(row * _choiceColumns + col)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _slot(int index) {
    if (index >= choices.length) return const SizedBox.shrink();
    final choice = choices[index];
    // A fixed-height tile centred in its slot: stretched to the slot, the
    // selected tile became a slab of colour.
    return Center(
      child: SizedBox(
        height: _choiceHeight,
        width: double.infinity,
        child: _ChoiceTile(style: style, choice: choice, builder: builder),
      ),
    );
  }
}

/// Every year in range, three to a row, in one scrolling list.
///
/// One list rather than pages: a birth year decades back is a fling away
/// instead of several page turns, and nothing in range is ever out of reach.
/// Rows are a fixed [_yearRowExtent] tall, so the picker can scroll any year
/// into view without measuring.
class _YearList extends StatelessWidget {
  final NepaliCalendarStyle style;
  final int firstYear;
  final int lastYear;
  final int selectedYear;
  final ScrollController controller;
  final ValueChanged<int> onSelect;
  final DatePickerBuilder? builder;

  const _YearList({
    required this.style,
    required this.firstYear,
    required this.lastYear,
    required this.selectedYear,
    required this.controller,
    required this.onSelect,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final language = style.effectiveConfig.language;

    return GridView.builder(
      controller: controller,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _choiceColumns,
        crossAxisSpacing: _choiceGap,
        mainAxisSpacing: _choiceGap,
        mainAxisExtent: _choiceHeight,
      ),
      itemCount: lastYear - firstYear + 1,
      itemBuilder: (context, index) {
        final year = firstYear + index;
        return _ChoiceTile(
          style: style,
          builder: builder,
          choice: _Choice(
            value: year,
            isYear: true,
            label: NepaliNumberConverter.formattedNumber(
              '$year',
              language: language,
            ),
            isSelected: year == selectedYear,
            // Every listed year is in range by construction.
            isDisabled: false,
            onTap: () => onSelect(year),
          ),
        );
      },
    );
  }
}

/// A month or year choice.
class _ChoiceTile extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Choice choice;
  final DatePickerBuilder? builder;

  const _ChoiceTile({
    required this.style,
    required this.choice,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final custom = builder?.choiceBuilder?.call(
      PickerChoiceData(
        value: choice.value,
        isYear: choice.isYear,
        label: choice.label,
        isSelected: choice.isSelected,
        isDisabled: choice.isDisabled,
        onTap: choice.isDisabled ? null : choice.onTap,
        style: style,
        language: style.effectiveConfig.language,
      ),
    );
    if (custom != null) {
      // The picker's own label, so a custom tile is announced the same way.
      return Semantics(
        button: !choice.isDisabled,
        enabled: !choice.isDisabled,
        selected: choice.isSelected,
        label: choice.label,
        excludeSemantics: true,
        child: custom,
      );
    }

    final cells = style.cellsStyle;

    final Color foreground;
    if (choice.isSelected) {
      foreground = cells.onHighlightColor;
    } else if (choice.isDisabled) {
      foreground = cells.dateTextColor.withValues(alpha: 0.3);
    } else {
      foreground = cells.dateTextColor;
    }

    return Semantics(
      button: !choice.isDisabled,
      enabled: !choice.isDisabled,
      selected: choice.isSelected,
      child: InkWell(
        onTap: choice.isDisabled ? null : choice.onTap,
        borderRadius: BorderRadius.circular(pickerRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: choice.isSelected ? cells.selectedColor : null,
            borderRadius: BorderRadius.circular(pickerRadius),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  choice.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        choice.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer and actions
// ---------------------------------------------------------------------------

/// Today on the left; Close -- or Cancel beside OK -- on the right.
///
/// OK only without auto-confirm, which is when [onConfirm] is set; Today only
/// when today is in range, which is when [onToday] is set.
class _Actions extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onToday;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  const _Actions({
    required this.style,
    required this.confirmText,
    required this.cancelText,
    required this.onToday,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final nepali = style.effectiveConfig.language == Language.nepali;

    // Tight padding rather than a wider dialog: the Nepali labels are much
    // longer than the English ones.
    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, datePickerActionsHeight - 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    final onToday = this.onToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (onToday != null)
            TextButton(
              onPressed: onToday,
              style: buttonStyle,
              child: Text(nepali ? 'आज' : 'Today', softWrap: false),
            ),
          // All the free space goes to Close / Cancel, right-aligned, so a
          // long Nepali label only ever ellipsizes when the row is truly full.
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onCancel,
                style: buttonStyle,
                child: Text(
                  cancelText ?? _cancelLabel(nepali),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ),
          ),
          if (onConfirm != null)
            TextButton(
              onPressed: onConfirm,
              style: buttonStyle,
              child: Text(
                confirmText ?? (nepali ? 'ठीक छ' : 'OK'),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
        ],
      ),
    );
  }

  /// Close when it is the only action, Cancel when it sits beside OK.
  String _cancelLabel(bool nepali) {
    if (onConfirm == null) return nepali ? 'बन्द गर्नुहोस्' : 'Close';
    return nepali ? 'रद्द गर्नुहोस्' : 'Cancel';
  }
}
