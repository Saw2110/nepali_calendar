// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide it.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_semantics.dart';
import 'internal/picker_shared.dart';

// ---------------------------------------------------------------------------
// Dimensions
//
// Every measurement the picker uses lives here. The previous implementation
// scattered them through the build methods, and two of them disagreed about
// the same gap.
// ---------------------------------------------------------------------------

const int _columns = pickerColumns;

const int _rows = pickerRows;

/// Columns of the month page and the year list.
const int _choiceColumns = 3;

/// Rows of the month page. Four rows of three fit all twelve months at once.
const int _choiceRows = 4;

/// Width the picker takes when there is room.
///
/// The day grid plus its gutters. Since the Today action moved into the
/// footer, nothing else in the picker is wider -- the Nepali Cancel / OK pair
/// included.
const double _preferredWidth = 330.0;

/// Height of the navigation header.
const double _headerHeight = 44.0;

/// Height of a month or year dropdown field inside the header.
const double _fieldHeight = 36.0;

/// Height of the weekday initials row.
const double _weekdayHeight = 20.0;

/// Height of the footer: the divider, the AD date and Today.
const double _footerHeight = 41.0;

/// Height of the Cancel / OK row, shown only without auto-confirm.
const double _actionsHeight = 44.0;

/// Padding above and below the grid, combined.
const double _verticalPadding = 8.0;

/// Gap between cells.
const double _cellGap = pickerCellGap;

/// Gap between month or year tiles.
const double _choiceGap = 8.0;

/// Height of a month or year tile. The month page centres it within its slot.
const double _choiceHeight = 40.0;

/// Distance between the tops of two rows in the year list.
const double _yearRowExtent = _choiceHeight + _choiceGap;

/// The size a day cell aims for.
///
/// Material asks for a 48dp touch target. Seven columns of 48 need 336dp plus
/// gutters, which a small phone's dialog does not have -- Flutter's own
/// Material DatePicker lands near 42dp for the same reason.
const double _preferredCell = 42.0;

/// The height a row of the day grid aims for: shorter than a cell is wide.
/// Only a short viewport (a phone in landscape) makes rows shorter still.
const double _preferredRow = 42.0;

/// The narrowest a day cell may get.
const double _minCell = 36.0;

/// Minimum touch target for the header's icon buttons: the header's height.
const double _minTouchTarget = _headerHeight;

/// Horizontal padding inside the picker.
const double _gutter = 12.0;

/// Corner radius for interactive surfaces: cells, fields and tiles.
const double _radius = pickerRadius;

/// How long a view change takes.
const Duration _transition = Duration(milliseconds: 200);

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

/// How big the picker wants to be for a given viewport.
@immutable
class _Layout {
  final double width;
  final double height;
  final double cell;

  const _Layout({
    required this.width,
    required this.height,
    required this.cell,
  });

  /// Width the grid occupies. Narrower than [width]; the grid is centred.
  double get gridWidth => (cell * _columns) + (_cellGap * (_columns - 1));

  /// Measures the picker against the space on offer.
  ///
  /// The picker sizes to its content. Up to 0.0.7 it was pinned to 420x480
  /// whatever it held, so the rows floated apart in dead space -- which is
  /// what made it look bulky.
  factory _Layout.measure(
    BuildContext context,
    BoxConstraints constraints, {
    required bool withFooter,
    required bool withActions,
  }) {
    final screen = MediaQuery.sizeOf(context);
    final maxWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : screen.width;
    final maxHeight =
        constraints.hasBoundedHeight ? constraints.maxHeight : screen.height;

    final width = math.min(_preferredWidth, maxWidth);

    // Cells are square. Their size is capped so a tablet does not get a
    // ballooning grid, and floored so a phone in landscape does not get an
    // unusable one.
    final widthBudget =
        (width - (_gutter * 2) - (_cellGap * (_columns - 1))) / _columns;
    final cell = widthBudget.clamp(_minCell, _preferredCell);

    // Rows are shorter than cells are wide: square rows made the picker tall
    // for what it holds. The day grid gives whatever rows it gets to the
    // cells, and the selection square fits the shorter side.
    final row = math.min(cell, _preferredRow);

    final chrome = _headerHeight +
        _weekdayHeight +
        _verticalPadding +
        (withFooter ? _footerHeight : 0.0) +
        (withActions ? _actionsHeight : 0.0);
    const gaps = _cellGap * (_rows - 1);

    // A short viewport (a phone in landscape) caps the height, and the day
    // grid's rows shrink to share what is left. The grid never scrolls.
    final height = math.min(maxHeight, chrome + (row * _rows) + gaps);

    return _Layout(width: width, height: height, cell: cell);
  }
}

// ---------------------------------------------------------------------------
// The picker
// ---------------------------------------------------------------------------

/// A Nepali (Bikram Sambat) date picker.
///
/// A month grid under a `‹ [Month ▾] [Year ▾] ›` header; the two fields swap
/// the grid for a 4x3 page of months or years. A footer shows the selected
/// date in the Gregorian (AD) calendar beside a Today shortcut. Colours and
/// typography follow an ambient [NepaliCalendarTheme] unless an explicit
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
  static const double preferredWidth = _preferredWidth;

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

  /// Label for the cancel action. Defaults to "Cancel" / "रद्द गर्नुहोस्".
  ///
  /// Only shown when [autoConfirm] is false.
  final String? cancelText;

  /// Whether to render the footer: the AD date, Today and, without
  /// [autoConfirm], Cancel / OK.
  ///
  /// Set false when the host supplies its own actions. The picker then never
  /// confirms on its own -- [autoConfirm] is ignored -- so pair it with
  /// [onDateSelected] to receive the selection.
  final bool showActions;

  /// Whether tapping a date (or Today) confirms it straight away.
  ///
  /// On by default: a tap selects and confirms in one step, through
  /// [onConfirm] or by popping the route. Set false to keep the selection
  /// pending until the user presses OK; a Cancel / OK row then appears below
  /// the footer. Ignored when [showActions] is false.
  final bool autoConfirm;

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
    this.autoConfirm = true,
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
          ifFalse: 'confirm with OK',
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

  PickerBounds get _bounds =>
      PickerBounds.from(min: widget.minDate, max: widget.maxDate);

  /// Whether a tap confirms by itself. A picker without its footer never
  /// does: the host owns confirmation there.
  bool get _autoConfirms => widget.autoConfirm && widget.showActions;

  @override
  void initState() {
    super.initState();
    final initial = _bounds.clamp(widget.initialDate ?? NepaliDateTime.now());
    _selected = initial;
    _displayed = initial;
    _mode = widget.initialMode;
    if (_mode == NepaliDatePickerMode.year) _scrollToYearAfterLayout();
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
      switch (_mode) {
        case NepaliDatePickerMode.day:
          _displayed = _monthOffsetBy(delta)!;
        case NepaliDatePickerMode.month:
          _displayed = _bounds.clamp(
            NepaliDateTime(
              year: _displayed.year + delta,
              month: _displayed.month,
              day: 1,
            ),
          );
        case NepaliDatePickerMode.year:
          break;
      }
    });
  }

  bool _canStep(int delta) {
    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _monthOffsetBy(delta) != null;
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

  /// The month [delta] away, or null if nothing in it is selectable.
  NepaliDateTime? _monthOffsetBy(int delta) {
    var year = _displayed.year;
    var month = _displayed.month + delta;
    if (month < 1) {
      month = 12;
      year -= 1;
    } else if (month > 12) {
      month = 1;
      year += 1;
    }
    if (!_bounds.containsAnyOf(year, month)) return null;
    return NepaliDateTime(year: year, month: month, day: 1);
  }

  void _confirm() {
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      onConfirm(_selected);
      return;
    }
    Navigator.of(context).pop(_selected);
  }

  void _cancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
      return;
    }
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
        final layout = _Layout.measure(
          context,
          constraints,
          withFooter: widget.showActions,
          withActions: widget.showActions && !widget.autoConfirm,
        );
        return SizedBox(
          width: layout.width,
          height: layout.height,
          child: _buildBody(style, layout),
        );
      },
    );
  }

  Widget _buildBody(NepaliCalendarStyle style, _Layout layout) {
    final isDayView = _mode == NepaliDatePickerMode.day;
    final language = style.effectiveConfig.language;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _headerHeight,
          // Rebuilt on scroll so the arrows disable at the ends of the year
          // list; outside the year view the list is detached and silent.
          child: ListenableBuilder(
            listenable: _yearScroll,
            builder: (context, _) => _Header(
              style: style,
              mode: _mode,
              monthLabel: MonthUtils.formattedMonth(_displayed.month, language),
              yearLabel: NepaliNumberConverter.formattedNumber(
                '${_displayed.year}',
                language: language,
              ),
              onMonthTap: _toggleMonthView,
              onYearTap: _toggleYearView,
              onPrevious: _canStep(-1) ? () => _step(-1) : null,
              onNext: _canStep(1) ? () => _step(1) : null,
            ),
          ),
        ),
        // The weekday row means nothing outside the day grid. Total height is
        // fixed regardless, so hiding it gives the space to the grid instead
        // of making the dialog jump.
        if (isDayView) ...[
          SizedBox(height: _cellGap),
          SizedBox(
            height: _weekdayHeight,
            child: Center(
              child: SizedBox(
                width: layout.gridWidth,
                child: PickerWeekdayRow(style: style),
              ),
            ),
          ),
        ],
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _verticalPadding / 2,
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
          SizedBox(
            height: _footerHeight,
            child: _Footer(
              style: style,
              selected: _selected,
              showToday: _bounds.contains(NepaliDateTime.now()),
              onToday: _goToToday,
            ),
          ),
        if (widget.showActions && !widget.autoConfirm)
          SizedBox(
            height: _actionsHeight,
            child: _Actions(
              style: style,
              confirmText: widget.confirmText,
              cancelText: widget.cancelText,
              onCancel: _cancel,
              onConfirm: _confirm,
            ),
          ),
      ],
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

  Widget _buildView(NepaliCalendarStyle style, _Layout layout) {
    final language = style.effectiveConfig.language;

    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _DayGrid(
          style: style,
          bounds: _bounds,
          displayed: _displayed,
          selected: _selected,
          onSelect: _selectDay,
        );
      case NepaliDatePickerMode.month:
        return _ChoicePage(
          style: style,
          choices: [
            for (var month = 1; month <= 12; month++)
              _Choice(
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
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// `‹ [Month ▾] [Year ▾] ›`.
///
/// The arrows step through whatever the grid area shows: months in the day
/// view, pages in the month and year views.
class _Header extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDatePickerMode mode;
  final String monthLabel;
  final String yearLabel;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Header({
    required this.style,
    required this.mode,
    required this.monthLabel,
    required this.yearLabel,
    required this.onMonthTap,
    required this.onYearTap,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final nepali = style.effectiveConfig.language == Language.nepali;
    final String previous;
    final String next;
    switch (mode) {
      case NepaliDatePickerMode.day:
        previous = nepali ? 'अघिल्लो महिना' : 'Previous month';
        next = nepali ? 'अर्को महिना' : 'Next month';
      case NepaliDatePickerMode.month:
        previous = nepali ? 'अघिल्लो वर्ष' : 'Previous year';
        next = nepali ? 'अर्को वर्ष' : 'Next year';
      case NepaliDatePickerMode.year:
        previous = nepali ? 'अघिल्लो पृष्ठ' : 'Previous page';
        next = nepali ? 'अर्को पृष्ठ' : 'Next page';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            tooltip: previous,
            onPressed: onPrevious,
          ),
          Expanded(
            flex: 3,
            child: _DropdownField(
              style: style,
              label: monthLabel,
              semanticLabel: nepali ? 'महिना छान्नुहोस्' : 'Select month',
              isOpen: mode == NepaliDatePickerMode.month,
              onTap: onMonthTap,
            ),
          ),
          const SizedBox(width: _choiceGap),
          Expanded(
            flex: 2,
            child: _DropdownField(
              style: style,
              label: yearLabel,
              semanticLabel: nepali ? 'वर्ष छान्नुहोस्' : 'Select year',
              isOpen: mode == NepaliDatePickerMode.year,
              onTap: onYearTap,
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            tooltip: next,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// An outlined field that looks like a dropdown and opens the month or year
/// page in the grid area. Tapping it again returns to the days.
///
/// The open field takes the selection colour, so it is clear which page the
/// grid is showing.
class _DropdownField extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String label;
  final String semanticLabel;
  final bool isOpen;
  final VoidCallback onTap;

  const _DropdownField({
    required this.style,
    required this.label,
    required this.semanticLabel,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderColor =
        isOpen ? style.cellsStyle.selectedColor : colors.outlineVariant;

    return Semantics(
      button: true,
      label: semanticLabel,
      value: label,
      expanded: isOpen,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          height: _fieldHeight,
          padding: const EdgeInsets.only(left: 10, right: 6),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isOpen ? 1.5 : 1),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              // Expanded so an oversized label degrades rather than
              // overflowing -- a last resort, not the normal case.
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: style.headersStyle.monthHeaderStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0,
                duration: _transition,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A navigation arrow.
///
/// A null [onPressed] renders it disabled rather than hiding it, so the header
/// does not reflow at the ends of the range. Colours come from the theme; they
/// used to be hard-coded greys.
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: _minTouchTarget,
        minHeight: _minTouchTarget,
      ),
      visualDensity: VisualDensity.compact,
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

  const _DayGrid({
    required this.style,
    required this.bounds,
    required this.displayed,
    required this.selected,
    required this.onSelect,
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

  const _DayCell({
    required this.style,
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cells = style.cellsStyle;
    final config = style.effectiveConfig;
    final isWeekend = WeekUtils.isWeekend(date.weekday, config.weekendType);

    final label = NepaliNumberConverter.formattedNumber(
      '${date.day}',
      language: config.language,
    );

    return Semantics(
      button: !isDisabled,
      enabled: !isDisabled,
      selected: isSelected,
      label: _semanticLabel(config.language),
      excludeSemantics: true,
      child: InkResponse(
        // A disabled cell gets no callback, so it neither responds nor ripples.
        onTap: isDisabled || !isCurrentMonth
            ? null
            : () {
                config.hapticFeedback.perform();
                onTap();
              },
        containedInkWell: true,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        // The tap target is the whole cell; the square is only decoration.
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _background(cells),
                borderRadius: BorderRadius.circular(_radius),
                border: isToday && !isSelected
                    ? Border.all(color: cells.todayColor, width: 1.5)
                    : null,
              ),
              child: Center(
                child: FittedBox(
                  // Devanagari digits run wider than Latin at the same size.
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      label,
                      style: cells.dayStyle.copyWith(
                        fontSize: 14,
                        fontWeight: isSelected || isToday
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
      ),
    );
  }

  Color _background(CellStyle cells) {
    if (isSelected) return cells.selectedColor;
    return Colors.transparent;
  }

  Color _foreground(CellStyle cells, bool isWeekend) {
    if (isSelected) return cells.onHighlightColor;
    // Adjacent-month days are dimmed; out-of-range days are dimmed further, so
    // "not this month" and "not allowed" stay tellable apart.
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
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _Choice({
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

  const _ChoicePage({required this.style, required this.choices});

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
        child: _ChoiceTile(style: style, choice: choice),
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

  const _YearList({
    required this.style,
    required this.firstYear,
    required this.lastYear,
    required this.selectedYear,
    required this.controller,
    required this.onSelect,
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
          choice: _Choice(
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

  const _ChoiceTile({required this.style, required this.choice});

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: choice.isSelected ? cells.selectedColor : null,
            borderRadius: BorderRadius.circular(_radius),
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

/// The selected date in the Gregorian calendar, with Today beside it.
///
/// The AD date is the one most users cross-check a BS date against, so it
/// sits where the eye lands after picking. It is always written in English:
/// it is the Gregorian date, and the format matches what users see on their
/// other devices.
class _Footer extends StatelessWidget {
  final NepaliCalendarStyle style;
  final NepaliDateTime selected;
  final bool showToday;
  final VoidCallback onToday;

  const _Footer({
    required this.style,
    required this.selected,
    required this.showToday,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nepali = style.effectiveConfig.language == Language.nepali;

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
                    pickerAdLabel(selected),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (showToday)
                  TextButton(
                    onPressed: onToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, _footerHeight - 9),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      foregroundColor: theme.colorScheme.onSurface,
                      // Built on labelLarge: a bare TextStyle would replace
                      // the theme's font family and size, not just the weight.
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(nepali ? 'आज' : 'Today', softWrap: false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Cancel and confirm, right-aligned. Only shown without auto-confirm.
class _Actions extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _Actions({
    required this.style,
    required this.confirmText,
    required this.cancelText,
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
      minimumSize: const Size(0, _actionsHeight - 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: TextButton(
              onPressed: onCancel,
              style: buttonStyle,
              child: Text(
                cancelText ?? (nepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
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
}
