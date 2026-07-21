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
      // The theme goes above the Navigator, so it reaches every route and
      // dialog. `fromContext` reads the ambient Material ColorScheme, so
      // flipping themeMode restyles every calendar with no other change.
      builder: (context, child) {
        return NepaliCalendarTheme(
          data: NepaliCalendarThemeData.fromContext(context),
          child: SafeArea(top: false, child: child!),
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
    // The NepaliCalendarTheme lives in MaterialApp.builder, above the
    // Navigator, so it also covers dialogs and pushed routes.
    return DefaultTabController(
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
      // Config only -- deliberately no cellsStyle. An explicit style beats the
      // ambient NepaliCalendarTheme, so setting colours here would opt the
      // picker out of theming and strand it in light mode. This tab used to do
      // exactly that.
      calendarStyle: NepaliCalendarStyle(
        config: CalendarConfig(language: widget.language),
      ),
      // Birthdays are the reason initialMode exists: landing on the year grid
      // saves paging back through months.
      initialMode: NepaliDatePickerMode.day,
      minDate: NepaliDateTime(year: 2070, month: 1, day: 1),
      maxDate: NepaliDateTime(year: 2090, month: 12, day: 30),
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
    final theme = Theme.of(context);

    // Colours come from the ColorScheme, not hard-coded hexes. This tab used to
    // pin 0xFFF8F9FA / white / 0xFF1F2937, so in a dark app it rendered a white
    // card with near-black text -- the tab that demonstrates the date picker
    // was the one that looked broken in dark mode.
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.language == Language.nepali
                    ? 'मिति छान्नुहोस्'
                    : 'Select a Date',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : widget.language == Language.nepali
                        ? 'कुनै मिति चयन गरिएको छैन'
                        : 'No date selected',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selectedDate != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showDatePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
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
// 5. CUSTOM -- three ready-made designs
// ============================================================================

/// `CalendarBuilder` replaces the header, the weekday row, the day cell and the
/// event row. The package keeps owning the dates, the grid layout and the event
/// lookup, so a custom design is a drawing job rather than a rewrite.
///
/// Three are shown because "custom" means different things per product, and a
/// single sample only ever demonstrates one of them:
///
/// * **Minimal** -- a personal calendar. Airy, circular, quiet event dots.
/// * **Agenda** -- a work calendar. Filled tiles and per-day counts, so a busy
///   stretch is obvious without reading anything.
/// * **Booking** -- availability rather than events. The grid encodes open,
///   limited and closed, with a legend and per-day slots.
///
/// Every colour comes from the theme: `Theme.of(context).colorScheme` for
/// surfaces, and `data.style` for calendar-semantic colours, which the calendar
/// has already resolved against the ambient [NepaliCalendarTheme]. Hard-coding
/// one here would look right in one mode and unreadable in the other.
enum _CustomDesign {
  minimal('Minimal'),
  agenda('Agenda'),
  booking('Booking');

  const _CustomDesign(this.label);

  final String label;
}

/// Built once. Rebuilding it per frame would re-index the whole event list on
/// every rebuild.
final _eventIndex = CalendarEventIndex.fromList(eventList);

/// Steps the calendar a month at a time.
///
/// `headerBuilder` is handed the same [PageController] the calendar pages with,
/// so a custom header drives navigation without any extra plumbing.
void _stepMonth(PageController controller, int delta) {
  controller.animateToPage(
    (controller.page?.round() ?? 0) + delta,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
}

class CustomBuildersExample extends StatefulWidget {
  const CustomBuildersExample({super.key, required this.language});

  final Language language;

  @override
  State<CustomBuildersExample> createState() => _CustomBuildersExampleState();
}

class _CustomBuildersExampleState extends State<CustomBuildersExample> {
  _CustomDesign _design = _CustomDesign.minimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSwitcher(),
        Expanded(
          child: NepaliCalendar<Events>(
            // Keyed by design so a switch rebuilds from scratch rather than
            // trying to reuse the previous design's element tree.
            key: ValueKey(_design),
            eventList: eventList,
            calendarBuilder: _builderFor(_design),
            calendarStyle: NepaliCalendarStyle(
              // Config only: no colours, so the theme still drives the palette.
              config: CalendarConfig(
                language: widget.language,
                weekendType: WeekendType.saturday,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SegmentedButton<_CustomDesign>(
        // Labels only, no icons: three icon+label segments do not fit a small
        // phone, and a segmented button has no graceful overflow.
        segments: [
          for (final design in _CustomDesign.values)
            ButtonSegment(value: design, label: Text(design.label)),
        ],
        selected: {_design},
        showSelectedIcon: false,
        onSelectionChanged: (selection) =>
            setState(() => _design = selection.first),
      ),
    );
  }

  CalendarBuilder<Events> _builderFor(_CustomDesign design) {
    final language = widget.language;

    switch (design) {
      case _CustomDesign.minimal:
        return CalendarBuilder<Events>(
          headerBuilder: (date, controller) => _MinimalHeader(
            date: date,
            controller: controller,
            language: language,
          ),
          weekdayBuilder: (data) => _QuietWeekday(data: data),
          cellBuilder: (data) => _MinimalCell(data: data, language: language),
          eventBuilder: (context, index, date, event) =>
              _MinimalEventRow(event: event),
        );

      case _CustomDesign.agenda:
        return CalendarBuilder<Events>(
          headerBuilder: (date, controller) => _AgendaHeader(
            date: date,
            controller: controller,
            language: language,
          ),
          weekdayBuilder: (data) => _BoldWeekday(data: data),
          cellBuilder: (data) => _AgendaCell(data: data, language: language),
          eventBuilder: (context, index, date, event) =>
              _AgendaEventRow(event: event, language: language),
        );

      case _CustomDesign.booking:
        return CalendarBuilder<Events>(
          headerBuilder: (date, controller) => _BookingHeader(
            date: date,
            controller: controller,
            language: language,
          ),
          weekdayBuilder: (data) => _QuietWeekday(data: data),
          cellBuilder: (data) => _BookingCell(data: data, language: language),
          eventBuilder: (context, index, date, event) =>
              _BookingEventRow(event: event, language: language),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Shared weekday rows
// ---------------------------------------------------------------------------

/// Quiet initials. Used by the designs that want the dates to carry the page.
class _QuietWeekday extends StatelessWidget {
  const _QuietWeekday({required this.data});

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

/// Heavier initials on a tinted strip, to anchor a dense grid.
class _BoldWeekday extends StatelessWidget {
  const _BoldWeekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            WeekUtils.formattedShortWeekDay(data.weekday, data.language),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: data.isWeekend
                  ? data.style.cellsStyle.weekDayColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Design 1: Minimal -- a personal calendar
// ---------------------------------------------------------------------------

/// A large month with the year beneath it, and plain navigation.
class _MinimalHeader extends StatelessWidget {
  const _MinimalHeader({
    required this.date,
    required this.controller,
    required this.language,
  });

  final NepaliDateTime date;
  final PageController controller;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  NepaliNumberConverter.formattedNumber(
                    '${date.year}',
                    language: language,
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _stepMonth(controller, -1),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            tooltip: 'Previous month',
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => _stepMonth(controller, 1),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

/// Today is a filled disc, the selection a ring, and events show as dots.
class _MinimalCell extends StatelessWidget {
  const _MinimalCell({required this.data, required this.language});

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

/// A coloured rail, the title, and a holiday chip.
class _MinimalEventRow extends StatelessWidget {
  const _MinimalEventRow({required this.event});

  final CalendarEvent<Events> event;

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
                          _Chip(label: 'Holiday', color: accent),
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

// ---------------------------------------------------------------------------
// Design 2: Agenda -- a dense work calendar
// ---------------------------------------------------------------------------

/// Month and year on one line, with the month's event count beside them.
class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader({
    required this.date,
    required this.controller,
    required this.language,
  });

  final NepaliDateTime date;
  final PageController controller;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _eventIndex.eventsInMonth(date.year, date.month).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${MonthUtils.formattedMonth(date.month, language)} '
                    '${NepaliNumberConverter.formattedNumber('${date.year}', language: language)}',
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  _Chip(label: '$count', color: theme.colorScheme.primary),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _stepMonth(controller, -1),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () => _stepMonth(controller, 1),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// A filled tile per day, tinted by how loaded it is, with a count badge.
///
/// The point of this design: a busy stretch is visible without reading any
/// text, which is what a work calendar is scanned for.
class _AgendaCell extends StatelessWidget {
  const _AgendaCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = data.style.cellsStyle;
    final count = data.events.length;

    final Color background;
    final Color foreground;
    if (data.isDimmed) {
      background = Colors.transparent;
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.45);
    } else if (data.isToday) {
      background = cells.todayColor;
      foreground = cells.onHighlightColor;
    } else if (count > 0) {
      // Denser days read darker, so load shows as a gradient across the month.
      background = theme.colorScheme.primaryContainer
          .withValues(alpha: (0.35 + (count * 0.25)).clamp(0.0, 1.0));
      foreground = theme.colorScheme.onPrimaryContainer;
    } else {
      background =
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
      foreground = data.isWeekend ? cells.weekDayColor : cells.dateTextColor;
    }

    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: data.isSelected && !data.isToday
                ? Border.all(color: cells.selectedColor, width: 1.5)
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 4,
                left: 6,
                child: Text(
                  NepaliNumberConverter.formattedNumber(
                    '${data.day}',
                    language: language,
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight:
                        data.isToday ? FontWeight.w800 : FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              if (count > 0 && !data.isDimmed)
                Positioned(
                  right: 4,
                  bottom: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: data.isHoliday
                          ? cells.weekDayColor
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A date block on the left, then the title and description.
class _AgendaEventRow extends StatelessWidget {
  const _AgendaEventRow({required this.event, required this.language});

  final CalendarEvent<Events> event;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  NepaliNumberConverter.formattedNumber(
                    '${event.date.day}',
                    language: language,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1.1,
                  ),
                ),
                Text(
                  WeekUtils.formattedShortWeekDay(
                    event.date.weekday,
                    language,
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (info != null && info.additionalInfo.isNotEmpty)
                    Text(
                      info.additionalInfo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Design 3: Booking -- availability rather than events
// ---------------------------------------------------------------------------

/// What a day looks like to someone trying to book it.
///
/// Derived from the real event data rather than invented, so the grid stays
/// consistent with the list below it.
enum _Availability {
  open('Open'),
  limited('Limited'),
  closed('Closed');

  const _Availability(this.label);

  final String label;

  Color colorFrom(ColorScheme scheme) => switch (this) {
        _Availability.open => scheme.primary,
        _Availability.limited => scheme.tertiary,
        _Availability.closed => scheme.error,
      };
}

_Availability _availabilityOf({
  required bool isWeekend,
  required bool isHoliday,
  required bool hasEvents,
}) {
  if (isHoliday || isWeekend) return _Availability.closed;
  if (hasEvents) return _Availability.limited;
  return _Availability.open;
}

/// The key to reading the grid. Without it the colours are decoration.
class _BookingLegend extends StatelessWidget {
  const _BookingLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final status in _Availability.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status.colorFrom(theme.colorScheme),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  status.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Month and year, centred, with a line explaining what the colours mean.
class _BookingHeader extends StatelessWidget {
  const _BookingHeader({
    required this.date,
    required this.controller,
    required this.language,
  });

  final NepaliDateTime date;
  final PageController controller;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _stepMonth(controller, -1),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous month',
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  '${MonthUtils.formattedMonth(date.month, language)} '
                  '${NepaliNumberConverter.formattedNumber('${date.year}', language: language)}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _stepMonth(controller, 1),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next month',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const _BookingLegend(),
        ],
      ),
    );
  }
}

/// The date over a status bar, so a month can be read as a strip of
/// availability rather than a list of events.
class _BookingCell extends StatelessWidget {
  const _BookingCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = data.style.cellsStyle;

    final status = _availabilityOf(
      isWeekend: data.isWeekend,
      isHoliday: data.isHoliday,
      hasEvents: data.hasEvents,
    );
    final statusColor = status.colorFrom(theme.colorScheme);

    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: data.isDimmed
                ? Colors.transparent
                : statusColor.withValues(alpha: data.isToday ? 0.22 : 0.10),
            borderRadius: BorderRadius.circular(8),
            border: data.isSelected
                ? Border.all(color: cells.selectedColor, width: 1.5)
                : data.isToday
                    ? Border.all(color: statusColor, width: 1.2)
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NepaliNumberConverter.formattedNumber(
                        '${data.day}',
                        language: language,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight:
                            data.isToday ? FontWeight.w800 : FontWeight.w500,
                        color: data.isDimmed
                            ? cells.dimmedDateTextColor.withValues(alpha: 0.45)
                            : cells.dateTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              if (!data.isDimmed)
                Container(
                  height: 3,
                  width: 18,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A booking rather than an event: what it is, and whether it blocks the day.
class _BookingEventRow extends StatelessWidget {
  const _BookingEventRow({required this.event, required this.language});

  final CalendarEvent<Events> event;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status =
        event.isHoliday ? _Availability.closed : _Availability.limited;
    final statusColor = status.colorFrom(theme.colorScheme);
    final info = event.additionalInfo;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${MonthUtils.formattedMonth(event.date.month, language)} '
                  '${NepaliNumberConverter.formattedNumber('${event.date.day}', language: language)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Chip(label: status.label, color: statusColor),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared pieces
// ---------------------------------------------------------------------------

/// A tinted pill. Shared so the three designs stay visually consistent where
/// they are not deliberately different.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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
    // Colours from the ColorScheme, not hard-coded. This card used to pin
    // Colors.white with black text, so under a themed calendar in a dark app
    // it stayed stubbornly light -- in the event list of the very tab that
    // demonstrates theming.
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Row(
          children: [
            // Colored accent bar on the left
            Container(width: 4, height: 100, color: accent),

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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
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
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'Holiday',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Event description
                    Text(
                      event.additionalInfo!.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
