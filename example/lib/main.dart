import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart' as picker;
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Calendar Plus Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return SafeArea(
          top: false,
          child: child!,
        );
      },
      themeMode: _themeMode,
      home: ExamplesTabScreen(
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

/// Main screen with tabs for different examples
class ExamplesTabScreen extends StatefulWidget {
  const ExamplesTabScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<ExamplesTabScreen> createState() => _ExamplesTabScreenState();
}

class _ExamplesTabScreenState extends State<ExamplesTabScreen> {
  Language currentLanguage = Language.nepali;

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == Language.nepali
          ? Language.english
          : Language.nepali;
    });
  }

  @override
  Widget build(BuildContext context) {
    // One NepaliCalendarTheme above every example. `fromContext` reads the
    // ambient Material ColorScheme, so flipping the app between light and dark
    // restyles every calendar below with no other changes.
    return NepaliCalendarTheme(
      data: NepaliCalendarThemeData.fromContext(context),
      child: DefaultTabController(
        // Must match the number of tabs below, or DefaultTabController throws.
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Nepali Calendar Plus'),
            actions: [
              IconButton(
                icon: Icon(
                  widget.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: widget.onToggleTheme,
                tooltip: 'Toggle Light/Dark',
              ),
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: _toggleLanguage,
                tooltip: 'Toggle Language',
              ),
            ],
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
                Tab(icon: Icon(Icons.view_week), text: 'Horizontal'),
                Tab(icon: Icon(Icons.date_range), text: 'Date Picker'),
                Tab(icon: Icon(Icons.grid_view), text: 'Year View'),
                Tab(icon: Icon(Icons.brush), text: 'Custom'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              NepaliCalendarExample(language: currentLanguage),
              HorizontalCalendarExample(language: currentLanguage),
              DatePickerExample(language: currentLanguage),
              YearCalendarExample(language: currentLanguage),
              CustomBuildersExample(language: currentLanguage),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. YEAR VIEW
// ============================================================================

/// A whole year on one screen: [NepaliYearCalendar].
class YearCalendarExample extends StatefulWidget {
  const YearCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<YearCalendarExample> createState() => _YearCalendarExampleState();
}

class _YearCalendarExampleState extends State<YearCalendarExample> {
  NepaliDateTime? _selected;

  /// The year to open on.
  ///
  /// Deliberately the year the sample events fall in rather than the current
  /// one, so the event and holiday indicators are actually visible. Today's
  /// highlight is demonstrated on the Calendar tab.
  int get _demoYear =>
      eventList.map((event) => event.date.year).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NepaliYearCalendar<Events>(
            year: _demoYear,
            initialDate: _selected,
            eventList: eventList,
            calendarStyle: NepaliCalendarStyle(
              // Config only: no appearance is set here, so the ambient
              // NepaliCalendarTheme still supplies the colours.
              config: CalendarConfig(language: widget.language),
            ),
            // Two per row on a phone, more when there is room.
            monthsPerRow: MediaQuery.sizeOf(context).width > 900 ? 4 : 2,
            onDaySelected: (date) => setState(() => _selected = date),
          ),
        ),
        if (_selected != null) _buildSelectionBar(context, _selected!),
      ],
    );
  }

  Widget _buildSelectionBar(BuildContext context, NepaliDateTime date) {
    final events = CalendarEventIndex.fromList(eventList).eventsOn(date);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${MonthUtils.formattedMonth(date.month, widget.language)} '
            '${date.day}, ${date.year}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          if (events.isEmpty)
            Text('No events', style: theme.textTheme.bodySmall)
          else
            // A date can hold several events; show them all.
            ...events.map(
              (event) => Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: event.isHoliday
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${event.additionalInfo?.title ?? ''}'
                      '${event.isHoliday ? ' (holiday)' : ''}',
                      style: theme.textTheme.bodyMedium,
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

// ============================================================================
// 1. NEPALI CALENDAR
// ============================================================================

/// The month view: [NepaliCalendar] driven by a [NepaliCalendarController],
/// with events listed underneath.
class NepaliCalendarExample extends StatefulWidget {
  const NepaliCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<NepaliCalendarExample> createState() => _NepaliCalendarExampleState();
}

class _NepaliCalendarExampleState extends State<NepaliCalendarExample> {
  late final NepaliCalendarController _controller;

  /// Sorted once, not on every build: sorting in `build` would redo the work
  /// on each frame and hand NepaliCalendar a new list identity every time,
  /// forcing it to re-index the events.
  late final List<CalendarEvent<Events>> _events =
      List<CalendarEvent<Events>>.from(eventList)
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  void initState() {
    super.initState();
    _controller = NepaliCalendarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControls(context),
        Expanded(
          child: NepaliCalendar<Events>(
            controller: _controller,
            eventList: _events,
            calendarBuilder: CalendarBuilder<Events>(
              eventBuilder: (context, index, date, event) =>
                  EventWidget(event: event),
            ),
            onDayChanged: (date) => debugPrint('Day changed: $date'),
            onMonthChanged: (date) =>
                debugPrint('Month changed: ${date.month}/${date.year}'),
            calendarStyle: NepaliCalendarStyle(
              // Config only -- no colours here, so the ambient
              // NepaliCalendarTheme supplies them and dark mode works.
              config: CalendarConfig(
                showEnglishDate: true,
                showBorder: true,
                language: widget.language,
                weekendType: WeekendType.saturdayAndSunday,
                weekStartType: WeekStartType.monday,
                weekTitleType: TitleFormat.half,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: const Icon(Icons.today, size: 18),
            label: const Text('Today'),
            onPressed: _controller.jumpToToday,
          ),
          ActionChip(
            avatar: const Icon(Icons.chevron_left, size: 18),
            label: const Text('Previous'),
            onPressed: _controller.previousMonth,
          ),
          ActionChip(
            avatar: const Icon(Icons.chevron_right, size: 18),
            label: const Text('Next'),
            onPressed: _controller.nextMonth,
          ),
          ActionChip(
            avatar: const Icon(Icons.event, size: 18),
            label: const Text('Baisakh 2080'),
            onPressed: () => _controller
                .jumpToDate(NepaliDateTime(year: 2080, month: 1, day: 1)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. HORIZONTAL CALENDAR
// ============================================================================

/// A one-week strip: [HorizontalNepaliCalendar], useful above a day's agenda.
class HorizontalCalendarExample extends StatefulWidget {
  const HorizontalCalendarExample({super.key, required this.language});

  final Language language;

  @override
  State<HorizontalCalendarExample> createState() =>
      _HorizontalCalendarExampleState();
}

class _HorizontalCalendarExampleState extends State<HorizontalCalendarExample> {
  late NepaliDateTime _selected = NepaliDateTime.now();
  bool _showMonth = true;
  WeekendType _weekendType = WeekendType.saturday;

  late final CalendarEventIndex<Events> _index =
      CalendarEventIndex.fromList(eventList);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          child: HorizontalNepaliCalendar(
            initialDate: _selected,
            showMonth: _showMonth,
            calendarStyle: NepaliCalendarStyle(
              config: CalendarConfig(
                language: widget.language,
                weekendType: _weekendType,
              ),
            ),
            onDateSelected: (date) => setState(() => _selected = date),
          ),
        ),
        _buildOptions(context),
        const Divider(height: 1),
        Expanded(child: _buildAgenda(context, theme)),
      ],
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilterChip(
            label: const Text('Month title'),
            selected: _showMonth,
            onSelected: (value) => setState(() => _showMonth = value),
          ),
          FilterChip(
            label: const Text('Sat weekend'),
            selected: _weekendType == WeekendType.saturday,
            onSelected: (_) =>
                setState(() => _weekendType = WeekendType.saturday),
          ),
          FilterChip(
            label: const Text('Sat + Sun weekend'),
            selected: _weekendType == WeekendType.saturdayAndSunday,
            onSelected: (_) =>
                setState(() => _weekendType = WeekendType.saturdayAndSunday),
          ),
        ],
      ),
    );
  }

  /// The day's agenda, driven by an O(1) lookup into the event index.
  Widget _buildAgenda(BuildContext context, ThemeData theme) {
    final events = _index.eventsOn(_selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${MonthUtils.formattedMonth(_selected.month, widget.language)} '
            '${_selected.day}, ${_selected.year}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        if (events.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 40,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nothing scheduled',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length,
              itemBuilder: (context, index) =>
                  EventWidget(event: events[index]),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// 3. DATE PICKER
// ============================================================================

/// Demonstrates the modal date picker dialog
class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key, required this.language});

  final Language language;

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  NepaliDateTime? selectedDate;

  Future<void> _showDatePickerDialog() async {
    final selected = await picker.showNepaliDatePicker(
      context: context,
      initialDate: selectedDate,
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(
          language: widget.language,
          weekTitleType: TitleFormat.half,
        ),
        cellsStyle: const CellStyle(
          selectedColor: Color(0xFF6366F1),
          todayColor: Colors.green,
          weekDayColor: Colors.red,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  String _formatDate(NepaliDateTime date) {
    final monthName = MonthUtils.formattedMonth(date.month, widget.language);
    final day = widget.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.day.toString())
        : date.day.toString();
    final year = widget.language == Language.nepali
        ? NepaliNumberConverter.englishToNepali(date.year.toString())
        : date.year.toString();
    return '$monthName $day, $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.language == Language.nepali
              ? 'नेपाली मिति चयनकर्ता'
              : 'Nepali Date Picker',
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.language == Language.nepali
                    ? 'मिति छान्नुहोस्'
                    : 'Select a Date',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : widget.language == Language.nepali
                        ? 'कुनै मिति चयन गरिएको छैन'
                        : 'No date selected',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showDatePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Flexible label: the Nepali text is much wider than the
                // English, and a rigid Row here overflows on a narrow phone.
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.language == Language.nepali
                            ? 'मिति छान्नुहोस्'
                            : 'Choose Date',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                  child: Text(
                    widget.language == Language.nepali
                        ? 'चयन हटाउनुहोस्'
                        : 'Clear Selection',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. CUSTOM
// ============================================================================

/// Shows what `CalendarBuilder` can do: every visible part of the calendar --
/// header, weekday row, day cell and event row -- replaced with a custom
/// design, while the package still handles the dates, layout and event lookup.
///
/// The colours come from `data.style`, which [NepaliCalendar] has already
/// resolved against the ambient [NepaliCalendarTheme]. That is what lets a
/// fully custom design follow light and dark mode for free — hard-coding
/// `Colors.white` here would look right in one mode and unreadable in the
/// other.
class CustomBuildersExample extends StatelessWidget {
  const CustomBuildersExample({super.key, required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    return NepaliCalendar<Events>(
      eventList: eventList,
      calendarBuilder: CalendarBuilder<Events>(
        headerBuilder: (date, controller) =>
            _Header(date: date, controller: controller, language: language),
        weekdayBuilder: (data) => _Weekday(data: data),
        cellBuilder: (data) => _DayCell(data: data, language: language),
        eventBuilder: (context, index, date, event) =>
            _EventRow(event: event, language: language),
      ),
      calendarStyle: NepaliCalendarStyle(
        // Config only: no colours, so the theme still drives the palette.
        config: CalendarConfig(
          language: language,
          weekendType: WeekendType.saturday,
        ),
      ),
    );
  }
}

/// A large month/year title with plain navigation controls.
class _Header extends StatelessWidget {
  const _Header({
    required this.date,
    required this.controller,
    required this.language,
  });

  final NepaliDateTime date;
  final PageController controller;
  final Language language;

  void _step(int delta) {
    controller.animateToPage(
      (controller.page?.round() ?? 0) + delta,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = NepaliNumberConverter.formattedNumber(
      '${date.year}',
      language: language,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MonthUtils.formattedMonth(date.month, language),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  year,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _step(-1),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            tooltip: 'Previous month',
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => _step(1),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

/// Weekday initials, spaced out and quiet.
class _Weekday extends StatelessWidget {
  const _Weekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        WeekUtils.formattedShortWeekDay(data.weekday, data.language),
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: data.isWeekend
              ? data.style.cellsStyle.weekDayColor
              : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

/// A day: today is a filled dot, the selection is a ring, and events show as
/// up to three dots underneath.
class _DayCell extends StatelessWidget {
  const _DayCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    // Already resolved against the ambient theme by NepaliCalendar.
    final cells = data.style.cellsStyle;

    final Color foreground;
    if (data.isDimmed) {
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.5);
    } else if (data.isToday) {
      foreground = cells.onHighlightColor;
    } else if (data.isHoliday || data.isWeekend) {
      foreground = cells.weekDayColor;
    } else {
      foreground = cells.dateTextColor;
    }

    return GestureDetector(
      onTap: data.onTap,
      // Most of a cell is empty space; without this only the digits would
      // register a tap.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: data.isToday ? cells.todayColor : Colors.transparent,
            shape: BoxShape.circle,
            border: data.isSelected && !data.isToday
                ? Border.all(color: cells.selectedColor, width: 1.5)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    NepaliNumberConverter.formattedNumber(
                      '${data.day}',
                      language: language,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          data.isToday ? FontWeight.w700 : FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ),
              ),
              if (data.hasEvents && !data.isDimmed)
                Positioned(
                  bottom: 4,
                  child: _EventDots(
                    // A date can hold several events; show up to three dots.
                    events: data.events,
                    onToday: data.isToday,
                    cells: cells,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three dots, one per event, holidays tinted.
class _EventDots extends StatelessWidget {
  const _EventDots({
    required this.events,
    required this.onToday,
    required this.cells,
  });

  final List<CalendarEvent<Events>> events;
  final bool onToday;
  final CellStyle cells;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final event in events.take(3))
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onToday
                  ? cells.onHighlightColor
                  : event.isHoliday
                      ? cells.weekDayColor
                      : cells.dotColor,
            ),
          ),
      ],
    );
  }
}

/// An event row: a coloured rail, the title, and a holiday chip.
class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.language});

  final CalendarEvent<Events> event;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            info?.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (event.isHoliday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Holiday',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (info != null && info.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================================
// SHARED WIDGETS & DATA
// ============================================================================

/// Custom widget to display individual events in the list
/// Shows event date, holiday status, title and description
class EventWidget extends StatelessWidget {
  final CalendarEvent<Events> event;

  const EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Row(
          children: [
            // Colored accent bar on the left
            Container(
              width: 4,
              height: 100,
              color: event.isHoliday ? Colors.red : Colors.blue,
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with date and badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(event.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (event.isHoliday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'Holiday',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Event title
                    Text(
                      event.additionalInfo!.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Event description
                    Text(
                      event.additionalInfo!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(NepaliDateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Custom model class for event details
/// Used as additional information in CalendarEvent
class Events {
  const Events({
    required this.title,
    required this.description,
    required this.additionalInfo,
    required this.eventType,
  });

  final String title;
  final String description;
  final String additionalInfo;
  final String eventType;
}

/// Sample event data showing how to create calendar events
/// Each event includes date, holiday status, and additional information
final List<CalendarEvent<Events>> eventList = [
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 8, day: 17),
    isHoliday: false,
    additionalInfo: Events(
      title: "अन्तर्राष्ट्रिय अपाङ्ग दिवस",
      description:
          "International Day of Persons with Disabilities (only for specially-abled employees).",
      additionalInfo: "Special capacity employees only",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 8, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "उँधौली पर्व / य:मरि पुन्हि / ज्यापु दिवस",
      description:
          "Udhauli festival, Yomari Punhi, Jyapu Day, Purnima fast, Dhanya Purnima.",
      additionalInfo: "Cultural & religious events",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "क्रिसमस डे",
      description: "Christmas Day celebration.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "तमु ल्होसार / लेखनाथ जयन्ती",
      description:
          "Tamu Lhosar, Poet Shiromani Lekhnath Jayanti, Putrada Ekadashi fast.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 19),
    isHoliday: false,
    additionalInfo: Events(
      title: "श्री स्वस्थानी व्रत कथा प्रारम्भ",
      description:
          "Start of Shree Swasthani Brata Katha, Magh Snan, Purnima fast.",
      additionalInfo: "Religious observance",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 9, day: 27),
    isHoliday: false,
    additionalInfo: Events(
      title: "पृथ्वी जयन्ती / राष्ट्रिय एकता दिवस",
      description: "Prithvi Jayanti, National Unity Day, Gorakhkali Puja.",
      additionalInfo: "National & religious observance",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "माघे संक्रान्ति",
      description: "Maghe Sankranti, Ghyu-Chaku Khane Din, Uttarayan begins.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 5),
    isHoliday: true,
    additionalInfo: Events(
      title: "सोनाम ल्होसार",
      description: "Sonam Lhosar and Shri Ballabh Jayanti.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "वसन्तपञ्चमी / सरस्वती पूजा",
      description:
          "Basant Panchami and Saraswati Puja (holiday for educational institutions only).",
      additionalInfo: "Educational institutions holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2082, month: 10, day: 16),
    isHoliday: false,
    additionalInfo: Events(
      title: "शहीद दिवस",
      description: "Martyrs' Day and Pradosh fast.",
      additionalInfo: "National observance",
      eventType: "notHoliday",
    ),
  ),
];
