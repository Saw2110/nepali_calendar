// The package deliberately uses its own deprecated members: back-compatible
// code paths have to keep calling them until they are removed in 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../nepali_calendar_plus.dart';
import 'utils/calendar_semantics.dart';

/// Base height of the scrolling date strip at a text scale of 1.0.
///
/// Sized for Devanagari, which is noticeably taller than Latin at the same
/// font size -- 56 is enough for "Sun / 12" but clips "आइत / १२".
const double _dateStripBaseHeight = 64.0;
const double _dateStripBaseWidth = 64.0;

class HorizontalNepaliCalendar extends StatefulWidget {
  const HorizontalNepaliCalendar({
    super.key,
    this.initialDate,
    @Deprecated(
      'This parameter has never had any effect. Use '
      'calendarStyle.cellsStyle instead. Will be removed in 1.0.0.',
    )
    this.textColor,
    this.backgroundColor,
    @Deprecated(
      'This parameter has never had any effect. Use '
      'calendarStyle.cellsStyle.selectedColor instead. Will be removed in 1.0.0.',
    )
    this.selectedColor,
    this.showMonth = true,
    required this.onDateSelected,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.headerBuilder,
  });

  final NepaliDateTime? initialDate;

  /// Colour for the date text.
  ///
  /// **This parameter has never been read.** It was accepted by the
  /// constructor in every version up to 0.0.7 but never applied, so passing it
  /// had no effect. It is deprecated rather than wired up, because making a
  /// long-dead parameter suddenly take effect would visibly change the
  /// appearance of apps that pass it.
  ///
  /// Use `calendarStyle.cellsStyle` instead.
  @Deprecated(
    'This parameter has never had any effect. Use calendarStyle.cellsStyle '
    'instead. Will be removed in 1.0.0.',
  )
  final Color? textColor;

  /// Background colour behind the whole strip. This one does take effect.
  final Color? backgroundColor;

  /// Colour for the selected date.
  ///
  /// **This parameter has never been read.** See [textColor] for why it is
  /// deprecated rather than fixed. Use
  /// `calendarStyle.cellsStyle.selectedColor` instead.
  @Deprecated(
    'This parameter has never had any effect. Use '
    'calendarStyle.cellsStyle.selectedColor instead. Will be removed in 1.0.0.',
  )
  final Color? selectedColor;
  final bool showMonth;
  final OnDateSelected onDateSelected;
  final NepaliCalendarStyle calendarStyle;
  final Widget Function(
    NepaliDateTime currentDateTime,
    NepaliDateTime selectedDateTime,
  )? headerBuilder;

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
      ..add(FlagProperty('showMonth', value: showMonth, ifFalse: 'no month'));
  }

  @override
  State<HorizontalNepaliCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalNepaliCalendar> {
  late NepaliDateTime _selectedDate;
  late NepaliDateTime _startDate;

  /// The style to render with, resolved in [build] against any ambient
  /// [NepaliCalendarTheme]. Held as a field because the colour helpers below
  /// have no [BuildContext] of their own.
  NepaliCalendarStyle _style = const NepaliCalendarStyle();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? NepaliDateTime.now();
    _startDate = _selectedDate.subtract(Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    // Explicit style > ambient NepaliCalendarTheme > the built-in defaults.
    _style = NepaliCalendarTheme.resolve(context, widget.calendarStyle);

    // Scale with the user's text size preference so the strip does not clip
    // for anyone relying on larger system text.
    final stripHeight =
        MediaQuery.textScalerOf(context).scale(_dateStripBaseHeight);
    // Sized to its content, not to a share of the viewport: a box too small
    // for the title and the strip paints the strip outside it, where Flutter
    // does not hit-test it, so taps would be silently swallowed.
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showMonth)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: widget.headerBuilder
                      ?.call(NepaliDateTime.now(), _selectedDate) ??
                  _buildMonthTitle(),
            ),
          SizedBox(
            height: stripHeight,
            child: _buildDateList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTitle() {
    final month = MonthUtils.formattedMonth(
      _selectedDate.month,
      _style.effectiveConfig.language,
    );
    final year = NepaliNumberConverter.formattedNumber(
      '${_selectedDate.year}',
      language: _style.effectiveConfig.language,
    );

    ///
    return Text(
      "$year, $month",
      textAlign: TextAlign.start,
      style: _style.headersStyle.monthHeaderStyle,
    );
  }

  Widget _buildDateList() {
    // Read at build time, not once in initState: an app left open past
    // midnight would otherwise keep highlighting yesterday.
    final today = NepaliDateTime.now();

    return ListView.builder(
      itemCount: 7,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final date = _startDate.add(Duration(days: index));

        final bool isToday = date.isSameDayAs(today);
        final bool isSelected = date.isSameDayAs(_selectedDate);

        return CalendarItem(
          date: date,
          isSelected: isSelected,
          textColor: _getCellTextColor(isToday, isSelected, date.weekday),
          backgroundColor: _getCellColor(isToday, isSelected, date.weekday),
          style: _style,
          onDatePressed: () => _handleDateSelection(date),
        );
      },
    );
  }

  void _handleDateSelection(NepaliDateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _startDate = _selectedDate.subtract(Duration(days: 2));
    });

    widget.onDateSelected(selectedDate);
  }

  Color _getCellColor(bool isToday, bool isSelected, int weekday) {
    final cells = _style.cellsStyle;
    // Weekends take the weekend colour wherever a weekday takes its own.
    final isWeekend = _isWeekend(weekday);

    if (isToday) return isWeekend ? cells.weekDayColor : cells.todayColor;
    if (isSelected) {
      return (isWeekend ? cells.weekDayColor : cells.selectedColor)
          .withValues(alpha: 0.2);
    }
    return Colors.transparent;
  }

  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    final isWeekend = _isWeekend(weekday);

    // Today sits on a filled highlight, so use the on-highlight colour.
    if (isToday) return _style.cellsStyle.onHighlightColor;
    if (isWeekend) return _style.cellsStyle.weekDayColor;
    if (isSelected) return _style.cellsStyle.selectedColor;
    return _style.cellsStyle.dateTextColor;
  }

  bool _isWeekend(int weekday) {
    return WeekUtils.isWeekend(
      weekday,
      _style.effectiveConfig.weekendType,
    );
  }
}

/// One date in [HorizontalNepaliCalendar]'s strip.
///
/// **Deprecated:** this was never intended as public API; it became so because
/// the package exported every internal file. It will be removed in 1.0.0. If
/// you depend on it, please open an issue describing your use case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.date,
    required this.textColor,
    required this.backgroundColor,
    required this.onDatePressed,
    required this.style,
    this.isSelected = false,
  });

  final NepaliDateTime date;

  /// Whether this is the selected date, reported to screen readers.
  final bool isSelected;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onDatePressed;
  final NepaliCalendarStyle style;

  @override
  Widget build(BuildContext context) {
    final config = style.effectiveConfig;

    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: CalendarSemantics.dayLabel(
        date,
        language: config.language,
        isToday: CalendarUtils.isToday(date.toDateTime()),
      ),
      child: InkWell(
        onTap: () {
          config.hapticFeedback.perform();
          onDatePressed();
        },
        child: Container(
          width: _dateStripBaseWidth,
          color: backgroundColor,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WeekUtils.formattedWeekDay(
                  date.weekday,
                  config.language,
                  config.weekTitleType,
                ),
                style: style.headersStyle.weekHeaderStyle.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 13.0,
                ),
              ),
              Text(
                NepaliNumberConverter.formattedNumber(
                  '${date.day}',
                  language: config.language,
                ),
                style: style.cellsStyle.dayStyle.copyWith(
                  color: textColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
