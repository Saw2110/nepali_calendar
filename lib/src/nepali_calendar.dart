part of nepali_calendar;

typedef TextBuilder = String Function(NepaliDateTime date, Language language);
typedef HeaderGestureCallback = void Function(NepaliDateTime focusedDay);

String formattedMonth(int month, [Language? language]) {
  return NepaliDateFormat.MMMM(language).format(NepaliDateTime(0, month));
}

const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

class NepaliCalendar extends StatefulWidget {
  const NepaliCalendar({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
    this.language = Language.nepali,
    required this.onDaySelected,
    this.headerStyle = const HeaderStyle(),
    this.calendarStyle = const CalendarStyle(),
    required this.onHeaderTapped,
    required this.onHeaderLongPressed,
    required this.controller,
    this.headerDayType = HeaderDayType.initial,
    required this.headerDayBuilder,
    required this.dateCellBuilder,
    required this.headerBuilder,
  }) : super(key: key);

  final NepaliDateTime initialDate;
  final NepaliDateTime firstDate;
  final NepaliDateTime lastDate;
  final Function(NepaliDateTime) onDaySelected;
  final SelectableDayPredicate? selectableDayPredicate;
  final Language language;
  final CalendarStyle calendarStyle;
  final HeaderStyle headerStyle;
  final HeaderGestureCallback onHeaderTapped;
  final HeaderGestureCallback onHeaderLongPressed;
  final NepaliCalendarController controller;
  final HeaderDayType headerDayType;
  final HeaderDayBuilder headerDayBuilder;
  final DateCellBuilder dateCellBuilder;
  final HeaderBuilder headerBuilder;

  @override
  _NepaliCalendarState createState() => _NepaliCalendarState();
}

class _NepaliCalendarState extends State<NepaliCalendar> {
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    widget.controller._init(
      selectedDayCallback: _handleDayChanged,
      initialDay: widget.initialDate,
    );
  }

  bool _announcedInitialDate = false;

  late MaterialLocalizations localizations;
  late TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        NepaliDateFormat.yMMMMd().format(_selectedDate),
        textDirection,
      );
    }
  }

  @override
  void didUpdateWidget(NepaliCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedDate = widget.initialDate;
    widget.controller.setSelectedDay(widget.initialDate);
  }

  late NepaliDateTime _selectedDate;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      // ignore: missing_enum_constant_in_switch
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
      case TargetPlatform.linux:
        // TODO: Handle this case.
        break;
      case TargetPlatform.macOS:
        // TODO: Handle this case.
        break;
      case TargetPlatform.windows:
        // TODO: Handle this case.
        break;
    }
  }

  void _handleDayChanged(NepaliDateTime value, {bool runCallback = true}) {
    _vibrate();
    setState(() {
      widget.controller.setSelectedDay(value, isProgrammatic: false);
      _selectedDate = value;
    });
    if (runCallback && widget.onDaySelected != null)
      widget.onDaySelected(value);
  }

  Widget _buildPicker() {
    return _MonthView(
      key: _pickerKey,
      headerStyle: widget.headerStyle,
      calendarStyle: widget.calendarStyle,
      language: widget.language,
      selectedDate: _selectedDate,
      onChanged: _handleDayChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectableDayPredicate: widget.selectableDayPredicate,
      onHeaderTapped: widget.onHeaderTapped,
      onHeaderLongPressed: widget.onHeaderLongPressed,
      headerDayType: widget.headerDayType,
      headerDayBuilder: widget.headerDayBuilder,
      dateCellBuilder: widget.dateCellBuilder,
      headerBuilder: widget.headerBuilder,
      dragStartBehavior: DragStartBehavior.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPicker();
  }
}

typedef SelectableDayPredicate = bool Function(NepaliDateTime day);
