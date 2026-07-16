// Boundary dates are written out in full: on a range edge, `month: 1, day: 1`
// states the intent, where leaning on the constructor's defaults would hide it.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../src.dart';

// ---------------------------------------------------------------------------
// Dimensions
//
// Every measurement the picker uses lives here. The previous implementation
// scattered them through the build methods, and two of them disagreed about
// the same gap.
// ---------------------------------------------------------------------------

/// Columns in a month grid: one per weekday.
const int _columns = 7;

/// Rows in a month grid.
///
/// Always six. A month can span six weeks, and a grid that sizes to five
/// silently never builds the sixth -- which is how the 30th and 31st became
/// unselectable before 0.0.8.
const int _rows = 6;

/// Width the picker takes when there is room.
///
/// Set by the actions row, not the grid: the Nepali labels are the widest
/// thing in the picker ("रद्द गर्नुहोस्" against "Cancel"). The grid is
/// narrower and sits centred within this.
const double _preferredWidth = 368.0;

/// Height of the month/year header.
const double _headerHeight = 48.0;

/// Height of the weekday initials row.
const double _weekdayHeight = 24.0;

/// Height of the actions row.
const double _actionsHeight = 44.0;

/// Padding above and below the grid, combined.
const double _verticalPadding = 12.0;

/// Gap between cells.
const double _cellGap = 2.0;

/// The size a day cell aims for.
///
/// Material asks for a 48dp touch target. Seven columns of 48 need 336dp plus
/// gutters, which a small phone's dialog does not have -- Flutter's own
/// Material DatePicker lands near 42dp for the same reason.
const double _preferredCell = 42.0;

/// The smallest a day cell may get. Below this the grid scrolls instead.
const double _minCell = 36.0;

/// Minimum touch target for the header's icon buttons, which can afford it.
const double _minTouchTarget = 48.0;

/// Horizontal padding inside the picker.
const double _gutter = 12.0;

/// Corner radius for interactive surfaces.
const double _radius = 12.0;

/// How long a view change takes.
const Duration _transition = Duration(milliseconds: 200);

// ---------------------------------------------------------------------------
// Selectable range
// ---------------------------------------------------------------------------

/// The dates a picker will allow, already intersected with the range the
/// bundled calendar data covers.
///
/// Pulled out of the widget so the bounds rules live in one place rather than
/// being re-derived at each call site.
@immutable
class _Bounds {
  final NepaliDateTime min;
  final NepaliDateTime max;

  const _Bounds._(this.min, this.max);

  factory _Bounds.from({NepaliDateTime? min, NepaliDateTime? max}) {
    final years = CalendarUtils.nepaliYears;
    final firstYear = years.keys.first;
    final lastYear = years.keys.last;

    final dataStart = NepaliDateTime(year: firstYear, month: 1, day: 1);
    final dataEnd = NepaliDateTime(
      year: lastYear,
      month: 12,
      day: years[lastYear]![12],
    );

    // A caller's bounds can only ever narrow the range: asking for BS 1900
    // cannot conjure data that is not bundled.
    final low = (min != null && min.compareTo(dataStart) > 0) ? min : dataStart;
    final high = (max != null && max.compareTo(dataEnd) < 0) ? max : dataEnd;

    return _Bounds._(low.dateOnly, high.dateOnly);
  }

  bool contains(NepaliDateTime date) {
    final day = date.dateOnly;
    return day.compareTo(min) >= 0 && day.compareTo(max) <= 0;
  }

  /// [date] pulled inside the range.
  ///
  /// Clamps rather than asserting: a stored date drifts out of range easily,
  /// and opening on the nearest legal date beats crashing the caller.
  NepaliDateTime clamp(NepaliDateTime date) {
    if (date.compareTo(min) < 0) return min;
    if (date.compareTo(max) > 0) return max;
    return date;
  }

  /// Whether any day of [month] in [year] is selectable.
  bool containsAnyOf(int year, int month) {
    if (!CalendarUtils.nepaliYears.containsKey(year)) return false;
    final lastDay = CalendarUtils.nepaliYears[year]![month];
    final start = NepaliDateTime(year: year, month: month, day: 1);
    final end = NepaliDateTime(year: year, month: month, day: lastDay);
    return end.compareTo(min) >= 0 && start.compareTo(max) <= 0;
  }
}

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
  /// The picker sizes to its content. Up to 0.1.0 it was pinned to 420x480
  /// whatever it held, so the rows floated apart in dead space -- which is
  /// what made it look bulky.
  factory _Layout.measure(BuildContext context, BoxConstraints constraints) {
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
    var cell = widthBudget.clamp(_minCell, _preferredCell);

    const chrome =
        _headerHeight + _weekdayHeight + _actionsHeight + _verticalPadding;
    const gaps = _cellGap * (_rows - 1);

    var height = chrome + (cell * _rows) + gaps;
    if (height > maxHeight) {
      // Short viewport. Shrink towards the floor; past it the grid scrolls
      // rather than the dialog overflowing or a row going unbuilt.
      cell = math.max((maxHeight - chrome - gaps) / _rows, _minCell);
      height = math.min(maxHeight, chrome + (cell * _rows) + gaps);
    }

    return _Layout(width: width, height: height, cell: cell);
  }
}

// ---------------------------------------------------------------------------
// The picker
// ---------------------------------------------------------------------------

/// A Nepali (Bikram Sambat) date picker.
///
/// Shows a month grid with year and month selection behind the title. Colours
/// and typography follow an ambient [NepaliCalendarTheme] unless an explicit
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
  final String? confirmText;

  /// Label for the cancel action. Defaults to "Cancel" / "रद्द गर्नुहोस्".
  final String? cancelText;

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
  });

  @override
  State<NepaliDatePicker> createState() => _NepaliDatePickerState();
}

class _NepaliDatePickerState extends State<NepaliDatePicker> {
  late NepaliDateTime _selected;
  late NepaliDateTime _displayed;
  late NepaliDatePickerMode _mode;

  final _yearScroll = ScrollController();

  _Bounds get _bounds => _Bounds.from(min: widget.minDate, max: widget.maxDate);

  @override
  void initState() {
    super.initState();
    final initial = _bounds.clamp(widget.initialDate ?? NepaliDateTime.now());
    _selected = initial;
    _displayed = initial;
    _mode = widget.initialMode;
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
  }

  void _stepMonth(int delta) {
    final target = _monthOffsetBy(delta);
    if (target == null) return;
    setState(() => _displayed = target);
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

  void _toggleYearView() {
    setState(() {
      _mode = _mode == NepaliDatePickerMode.day
          ? NepaliDatePickerMode.year
          : NepaliDatePickerMode.day;
    });
    if (_mode == NepaliDatePickerMode.year) {
      // The grid must exist before it can be scrolled.
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToYear());
    }
  }

  void _scrollToYear() {
    if (!_yearScroll.hasClients) return;
    final index = _selectableYears().indexOf(_displayed.year);
    if (index < 0) return;
    // Three per row; centre the selected year's row rather than pin it to the
    // top, so the years around it stay visible.
    final target = ((index ~/ 3) * 60.0) - 60.0;
    _yearScroll.jumpTo(target.clamp(0.0, _yearScroll.position.maxScrollExtent));
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

  /// The years the year grid offers: a window around the displayed year, slid
  /// to stay inside the selectable range rather than truncated, so a full set
  /// is offered even at the ends.
  List<int> _selectableYears() {
    const before = 15;
    const size = 30;
    final first = _bounds.min.year;
    final last = _bounds.max.year;

    var start = _displayed.year - before;
    if (start + size - 1 > last) start = last - size + 1;
    if (start < first) start = first;

    return [for (var y = start; y <= math.min(start + size - 1, last); y++) y];
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > the built-in defaults.
    final style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _Layout.measure(context, constraints);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _headerHeight,
          child: _Header(
            style: style,
            title: _headerTitle(style),
            isDayView: isDayView,
            onToggle: _toggleYearView,
            onPrevious:
                _monthOffsetBy(-1) == null ? null : () => _stepMonth(-1),
            onNext: _monthOffsetBy(1) == null ? null : () => _stepMonth(1),
          ),
        ),
        // The weekday row means nothing outside the day grid. Total height is
        // fixed regardless, so hiding it gives the space to the grid instead
        // of making the dialog jump.
        if (isDayView)
          SizedBox(
            height: _weekdayHeight,
            child: Center(
              child: SizedBox(
                width: layout.gridWidth,
                child: _WeekdayRow(style: style),
              ),
            ),
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _verticalPadding / 2,
              ),
              child: SizedBox(
                width: layout.gridWidth,
                child: AnimatedSwitcher(
                  duration: _transition,
                  child: KeyedSubtree(
                    key: ValueKey(_mode),
                    child: _buildView(style, layout),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _actionsHeight,
          child: _Actions(
            style: style,
            showToday: _bounds.contains(NepaliDateTime.now()),
            confirmText: widget.confirmText,
            cancelText: widget.cancelText,
            onToday: _goToToday,
            onCancel: _cancel,
            onConfirm: _confirm,
          ),
        ),
      ],
    );
  }

  Widget _buildView(NepaliCalendarStyle style, _Layout layout) {
    switch (_mode) {
      case NepaliDatePickerMode.day:
        return _DayGrid(
          style: style,
          bounds: _bounds,
          displayed: _displayed,
          selected: _selected,
          cell: layout.cell,
          onSelect: _selectDay,
          onSwipe: _stepMonth,
        );
      case NepaliDatePickerMode.month:
        return _MonthGrid(
          style: style,
          bounds: _bounds,
          year: _displayed.year,
          selectedMonth: _displayed.month,
          onSelect: _selectMonth,
        );
      case NepaliDatePickerMode.year:
        return _YearGrid(
          style: style,
          years: _selectableYears(),
          selectedYear: _displayed.year,
          controller: _yearScroll,
          onSelect: _selectYear,
        );
    }
  }

  String _headerTitle(NepaliCalendarStyle style) {
    final language = style.effectiveConfig.language;
    final year = NepaliNumberConverter.formattedNumber(
      '${_displayed.year}',
      language: language,
    );

    switch (_mode) {
      case NepaliDatePickerMode.day:
        return '${MonthUtils.formattedMonth(_displayed.month, language)} $year';
      case NepaliDatePickerMode.month:
        return year;
      case NepaliDatePickerMode.year:
        return language == Language.nepali ? 'वर्ष छान्नुहोस्' : 'Select Year';
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// The month/year title, which doubles as the year-view toggle, plus month
/// navigation.
///
/// The title is the control because the title is what users reach for. Year
/// selection used to hide behind an unlabelled edit-calendar icon.
class _Header extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String title;
  final bool isDayView;
  final VoidCallback onToggle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Header({
    required this.style,
    required this.title,
    required this.isDayView,
    required this.onToggle,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final nepali = style.effectiveConfig.language == Language.nepali;

    return Padding(
      padding: const EdgeInsets.only(left: _gutter, right: 4),
      child: Row(
        children: [
          // Expanded, not Flexible-beside-a-Spacer: those both default to
          // flex: 1 and split the free space, which ellipsised the title with
          // room to spare.
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _TitleToggle(
                style: style,
                title: title,
                isDayView: isDayView,
                onTap: onToggle,
              ),
            ),
          ),
          if (isDayView) ...[
            _NavButton(
              icon: Icons.chevron_left_rounded,
              tooltip: nepali ? 'अघिल्लो महिना' : 'Previous month',
              onPressed: onPrevious,
            ),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              tooltip: nepali ? 'अर्को महिना' : 'Next month',
              onPressed: onNext,
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleToggle extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String title;
  final bool isDayView;
  final VoidCallback onTap;

  const _TitleToggle({
    required this.style,
    required this.title,
    required this.isDayView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nepali = style.effectiveConfig.language == Language.nepali;

    return Semantics(
      button: true,
      label: isDayView
          ? (nepali ? 'वर्ष छान्नुहोस्' : 'Select year')
          : (nepali ? 'मिति छान्नुहोस्' : 'Select date'),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flexible so an oversized title degrades rather than
              // overflowing -- a last resort, not the normal case.
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: style.headersStyle.monthHeaderStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              AnimatedRotation(
                turns: isDayView ? 0 : 0.5,
                duration: _transition,
                child: const Icon(Icons.arrow_drop_down_rounded, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A month-navigation button.
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
      icon: Icon(icon, size: 20),
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
// Weekday row
// ---------------------------------------------------------------------------

/// Weekday initials above the grid.
///
/// Always the short form, whatever `weekTitleType` says. The half form
/// ("आइत", "मंगल", "बिहि") forces the columns far wider than the digits need
/// and is what made the picker look bulky; native pickers use initials here.
/// `weekTitleType` still applies to the calendar widgets, which have the room.
class _WeekdayRow extends StatelessWidget {
  final NepaliCalendarStyle style;

  const _WeekdayRow({required this.style});

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;
    final headerStyle = style.headersStyle.weekHeaderStyle;

    return Row(
      children: _weekdayOrder(config.weekStartType).map((weekday) {
        final isWeekend = WeekUtils.isWeekend(weekday, config.weekendType);
        return Expanded(
          child: Center(
            child: Text(
              WeekUtils.formattedShortWeekDay(weekday, config.language),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: headerStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? style.cellsStyle.weekDayColor
                    : headerStyle.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

List<int> _weekdayOrder(WeekStartType start) {
  switch (start) {
    case WeekStartType.sunday:
      return const [0, 1, 2, 3, 4, 5, 6];
    case WeekStartType.monday:
      return const [1, 2, 3, 4, 5, 6, 0];
  }
}

// ---------------------------------------------------------------------------
// Day grid
// ---------------------------------------------------------------------------

/// Six rows of dates, with the adjacent months' days filling the edges.
class _DayGrid extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Bounds bounds;
  final NepaliDateTime displayed;
  final NepaliDateTime selected;
  final double cell;
  final ValueChanged<NepaliDateTime> onSelect;
  final ValueChanged<int> onSwipe;

  const _DayGrid({
    required this.style,
    required this.bounds,
    required this.displayed,
    required this.selected,
    required this.cell,
    required this.onSelect,
    required this.onSwipe,
  });

  /// The date each of the 42 cells shows, running from the trailing days of
  /// the previous month to the leading days of the next.
  List<NepaliDateTime> get _dates {
    final firstOfMonth = NepaliDateTime(
      year: displayed.year,
      month: displayed.month,
      day: 1,
    );
    final leading = _leadingBlanks(firstOfMonth.weekday);

    return [
      for (var i = 0; i < _rows * _columns; i++)
        firstOfMonth.add(Duration(days: i - leading)),
    ];
  }

  int _leadingBlanks(int weekday) {
    switch (style.effectiveConfig.weekStartType) {
      case WeekStartType.sunday:
        return weekday;
      case WeekStartType.monday:
        return weekday == 0 ? 6 : weekday - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _dates;
    final today = NepaliDateTime.now();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -500) onSwipe(1);
        if (velocity > 500) onSwipe(-1);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // All six rows must fit the space on offer. A GridView only builds
          // what its viewport covers, so a row that does not fit is not
          // clipped -- it does not exist. That is how the 30th and 31st went
          // missing before 0.0.8.
          final rowHeight =
              (constraints.maxHeight - (_cellGap * (_rows - 1))) / _rows;
          final needsScroll = rowHeight < _minCell;
          final height = math.max(rowHeight, _minCell);
          final width =
              (constraints.maxWidth - (_cellGap * (_columns - 1))) / _columns;

          return GridView.builder(
            physics: needsScroll
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              crossAxisSpacing: _cellGap,
              mainAxisSpacing: _cellGap,
              childAspectRatio: height > 0 ? width / height : 1.0,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
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
            },
          );
        },
      ),
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
        onTap: isDisabled || !isCurrentMonth ? null : onTap,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        // The tap target is the whole cell; the disc is only decoration.
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _background(cells),
                shape: BoxShape.circle,
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
                            : FontWeight.w400,
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
  /// month they are in.
  String _semanticLabel(Language language) {
    final nepali = language == Language.nepali;
    return [
      MonthUtils.formattedMonth(date.month, language),
      NepaliNumberConverter.formattedNumber('${date.day}', language: language),
      NepaliNumberConverter.formattedNumber('${date.year}', language: language),
      WeekUtils.formattedWeekDay(date.weekday, language),
      if (isToday) nepali ? 'आज' : 'Today',
      if (isDisabled) nepali ? 'उपलब्ध छैन' : 'Unavailable',
    ].join(', ');
  }
}

// ---------------------------------------------------------------------------
// Month and year grids
// ---------------------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  final NepaliCalendarStyle style;
  final _Bounds bounds;
  final int year;
  final int selectedMonth;
  final ValueChanged<int> onSelect;

  const _MonthGrid({
    required this.style,
    required this.bounds,
    required this.year,
    required this.selectedMonth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final language = style.effectiveConfig.language;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        return _ChoiceTile(
          style: style,
          label: MonthUtils.formattedMonth(month, language),
          isSelected: month == selectedMonth,
          isDisabled: !bounds.containsAnyOf(year, month),
          onTap: () => onSelect(month),
        );
      },
    );
  }
}

class _YearGrid extends StatelessWidget {
  final NepaliCalendarStyle style;
  final List<int> years;
  final int selectedYear;
  final ScrollController controller;
  final ValueChanged<int> onSelect;

  const _YearGrid({
    required this.style,
    required this.years,
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
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        return _ChoiceTile(
          style: style,
          // Every offered year is in range by construction; see
          // _selectableYears.
          label: NepaliNumberConverter.formattedNumber(
            '$year',
            language: language,
          ),
          isSelected: year == selectedYear,
          isDisabled: false,
          onTap: () => onSelect(year),
        );
      },
    );
  }
}

/// A month or year choice.
class _ChoiceTile extends StatelessWidget {
  final NepaliCalendarStyle style;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.style,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cells = style.cellsStyle;
    final theme = Theme.of(context);

    final Color foreground;
    if (isSelected) {
      foreground = cells.onHighlightColor;
    } else if (isDisabled) {
      foreground = cells.dateTextColor.withValues(alpha: 0.3);
    } else {
      foreground = cells.dateTextColor;
    }

    return Semantics(
      button: !isDisabled,
      enabled: !isDisabled,
      selected: isSelected,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? cells.selectedColor
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
// Actions
// ---------------------------------------------------------------------------

/// Today on the left, Cancel and confirm on the right.
///
/// Today lives here rather than in the header, where it used to take the most
/// prominent corner despite being the least-used control.
class _Actions extends StatelessWidget {
  final NepaliCalendarStyle style;
  final bool showToday;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onToday;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _Actions({
    required this.style,
    required this.showToday,
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
    // longer than the English ones, and at the default TextButton padding all
    // three together do not fit a compact picker on a phone.
    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, _actionsHeight - 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showToday)
            TextButton(
              onPressed: onToday,
              style: buttonStyle,
              child: Text(nepali ? 'आज' : 'Today', softWrap: false),
            )
          else
            const SizedBox.shrink(),
          // One Flexible taking the rest, rather than a Flexible next to a
          // Spacer: those both default to flex: 1 and split the free space, so
          // the labels ellipsised with room to spare. Here they take their
          // natural width and shrink only when genuinely constrained.
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
    );
  }
}
