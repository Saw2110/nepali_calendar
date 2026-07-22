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

class ExampleTabItem {
  const ExampleTabItem({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

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

  int selectedIndex = 0;

  final tabs = const [
    ExampleTabItem(
      title: 'Calendar',
      icon: Icons.calendar_month,
    ),
    ExampleTabItem(
      title: 'Horizontal',
      icon: Icons.view_week,
    ),
    ExampleTabItem(
      title: 'Date Picker',
      icon: Icons.date_range,
    ),
    ExampleTabItem(
      title: 'Year View',
      icon: Icons.grid_view,
    ),
    ExampleTabItem(
      title: 'Custom',
      icon: Icons.brush,
    ),
  ];

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == Language.nepali
          ? Language.english
          : Language.nepali;
    });
  }

  Widget _buildCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return NepaliCalendarExample(language: currentLanguage);

      case 1:
        return HorizontalCalendarExample(language: currentLanguage);

      case 2:
        return DatePickerExample(language: currentLanguage);

      case 3:
        return YearCalendarExample(language: currentLanguage);

      case 4:
        return CustomBuildersExample(language: currentLanguage);

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nepali Calendar Plus"),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = tabs[index];
                final selected = selectedIndex == index;

                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 400,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(selectedIndex),
                    child: _buildCurrentPage(),
                  ),
                ),
              ),
            ),
          ),
        ],
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
            monthsPerRow: 2,
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
// 5. CUSTOM -- two ready-made designs
// ============================================================================

/// `CalendarBuilder` replaces the header, the weekday row, the day cell and the
/// event row. The package keeps owning the dates, the grid layout and the event
/// lookup, so a custom design is a drawing job rather than a rewrite.
///
/// Two are shown, and they deliberately pull in opposite directions -- that
/// contrast is the useful thing to copy from:
///
/// * **Simple** -- airy and monochrome. No boxes anywhere, one accent colour,
///   and the dates themselves carry the page.
/// * **Traditional** -- the printed Nepali patro. A ruled grid, Saturdays and
///   holidays in red, and the AD date in the corner of every cell.
///
/// Every colour comes from the theme: `Theme.of(context).colorScheme` for
/// surfaces, and `data.style` for calendar-semantic colours, which the calendar
/// has already resolved against the ambient [NepaliCalendarTheme]. Hard-coding
/// one here would look right in one mode and unreadable in the other.
enum _CustomDesign {
  simple('Simple'),
  traditional('Traditional');

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
  _CustomDesign _design = _CustomDesign.simple;

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
              // showBorder stays off for both designs -- the traditional cell
              // rules its own grid, and doubling the package's borders onto it
              // would thicken every line.
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
      case _CustomDesign.simple:
        return CalendarBuilder<Events>(
          headerBuilder: (date, controller) => _SimpleHeader(
            date: date,
            controller: controller,
            language: language,
          ),
          weekdayBuilder: (data) => _SimpleWeekday(data: data),
          cellBuilder: (data) => _SimpleCell(data: data, language: language),
          eventBuilder: (context, index, date, event) =>
              _SimpleEventRow(event: event),
        );

      case _CustomDesign.traditional:
        return CalendarBuilder<Events>(
          headerBuilder: (date, controller) => _TraditionalHeader(
            date: date,
            controller: controller,
            language: language,
          ),
          weekdayBuilder: (data) => _TraditionalWeekday(data: data),
          cellBuilder: (data) =>
              _TraditionalCell(data: data, language: language),
          eventBuilder: (context, index, date, event) =>
              _TraditionalEventRow(event: event, language: language),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Design 1: Simple -- airy, monochrome, one accent
// ---------------------------------------------------------------------------

/// The year in small caps above a large, lightly-weighted month, with the
/// month's event count as a quiet footnote and ghost arrows on the right.
class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NepaliNumberConverter.formattedNumber(
                        '${date.year}',
                        language: language,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      MonthUtils.formattedMonth(date.month, language),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        // Light weight and tight tracking is most of what makes
                        // this design read as "Simple" rather than "default".
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        count == 1 ? '1 event' : '$count events',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _GhostArrow(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Previous month',
                onPressed: () => _stepMonth(controller, -1),
              ),
              const SizedBox(width: 4),
              _GhostArrow(
                icon: Icons.arrow_forward_ios_rounded,
                tooltip: 'Next month',
                onPressed: () => _stepMonth(controller, 1),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 24,
          endIndent: 24,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// An outlined circle rather than a filled button -- the design has no other
/// filled surfaces, and a tonal button here would be the loudest thing on it.
class _GhostArrow extends StatelessWidget {
  const _GhostArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        shape: const CircleBorder(),
      ),
    );
  }
}

/// A single wide-tracked initial. Deliberately the quietest row on the page.
class _SimpleWeekday extends StatelessWidget {
  const _SimpleWeekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = WeekUtils.formattedShortWeekDay(data.weekday, data.language);

    return Center(
      child: Text(
        // One character in English; Devanagari initials are already short, so
        // they are left whole.
        data.language == Language.english && label.isNotEmpty
            ? label.characters.first.toUpperCase()
            : label,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
          color: data.isWeekend
              ? data.style.cellsStyle.weekDayColor.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

/// No box, no fill, no ring: just the number, with a hairline bar underneath
/// when the day has events. Selection is the one solid shape in the design.
class _SimpleCell extends StatelessWidget {
  const _SimpleCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    // Already resolved against the ambient theme by NepaliCalendar.
    final cells = data.style.cellsStyle;

    final Color foreground;
    if (data.isDimmed) {
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.4);
    } else if (data.isSelected) {
      foreground = cells.onHighlightColor;
    } else if (data.isToday) {
      foreground = cells.selectedColor;
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
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: data.isSelected ? cells.selectedColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    NepaliNumberConverter.formattedNumber(
                      '${data.day}',
                      language: language,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      // Today is bold instead of filled, so the fill can mean
                      // selection and nothing else.
                      fontWeight:
                          data.isToday ? FontWeight.w700 : FontWeight.w400,
                      color: foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // The bar is always laid out, empty or not, so the numbers stay
              // on one baseline across the whole grid.
              SizedBox(
                height: 2,
                width: 12,
                child: data.hasEvents && !data.isDimmed
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: data.isSelected
                              ? cells.onHighlightColor
                              : data.isHoliday
                                  ? cells.weekDayColor
                                  : cells.dotColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A hairline-separated row. No card, no fill -- the list matches the grid.
class _SimpleEventRow extends StatelessWidget {
  const _SimpleEventRow({required this.event});

  final CalendarEvent<Events> event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (event.isHoliday) _Chip(label: 'Holiday', color: accent),
                  ],
                ),
                if (info != null && info.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Design 2: Traditional -- the printed Nepali patro
// ---------------------------------------------------------------------------

/// The hairline every part of this design rules itself with.
BorderSide _rule(BuildContext context) => BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: 0.7,
    );

/// A solid band with the month centred in it, the way a wall calendar prints
/// its masthead.
class _TraditionalHeader extends StatelessWidget {
  const _TraditionalHeader({
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

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _stepMonth(controller, -1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: theme.colorScheme.onPrimaryContainer,
            tooltip: 'Previous month',
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  MonthUtils.formattedMonth(date.month, language),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  // The AD span the Nepali month straddles, the way a patro
                  // prints it under the month name.
                  _gregorianSpan(date),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _stepMonth(controller, 1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: theme.colorScheme.onPrimaryContainer,
            tooltip: 'Next month',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  /// e.g. `Jun / Jul 2026` -- a Nepali month nearly always spans two AD ones.
  String _gregorianSpan(NepaliDateTime date) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final first =
        NepaliDateTime(year: date.year, month: date.month, day: 1).toDateTime();
    final lastDay = CalendarUtils.nepaliYears[date.year]![date.month];
    final last =
        NepaliDateTime(year: date.year, month: date.month, day: lastDay)
            .toDateTime();

    if (first.month == last.month) {
      return '${names[first.month - 1]} ${first.year}';
    }
    return '${names[first.month - 1]} / ${names[last.month - 1]} ${last.year}';
  }
}

/// A ruled header row, Saturday in the weekend colour like a printed patro.
class _TraditionalWeekday extends StatelessWidget {
  const _TraditionalWeekday({required this.data});

  final WeekdayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border(right: _rule(context), bottom: _rule(context)),
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

/// A ruled box with the Nepali date large in the middle and the AD date small
/// in the corner -- the single most recognisable thing about a printed patro.
class _TraditionalCell extends StatelessWidget {
  const _TraditionalCell({required this.data, required this.language});

  final CalendarCellData<Events> data;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = data.style.cellsStyle;

    final Color foreground;
    if (data.isDimmed) {
      foreground = cells.dimmedDateTextColor.withValues(alpha: 0.45);
    } else if (data.isToday) {
      foreground = cells.onHighlightColor;
    } else if (data.isHoliday || data.isWeekend) {
      // Red Saturdays and red holidays are the convention the printed
      // calendars use, and the theme's weekend colour already is that red.
      foreground = cells.weekDayColor;
    } else {
      foreground = cells.dateTextColor;
    }

    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: data.isToday
              ? cells.todayColor
              : data.isSelected
                  ? cells.selectedColor.withValues(alpha: 0.18)
                  : data.isDimmed
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.25)
                      : null,
          // Right and bottom only: neighbouring cells share a single line
          // instead of drawing two against each other.
          border: Border(right: _rule(context), bottom: _rule(context)),
        ),
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  NepaliNumberConverter.formattedNumber(
                    '${data.day}',
                    language: language,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        data.isToday ? FontWeight.w800 : FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 3,
              child: Text(
                '${data.date.toDateTime().day}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  height: 1,
                  color: data.isToday
                      ? cells.onHighlightColor.withValues(alpha: 0.8)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            if (data.hasEvents && !data.isDimmed)
              Positioned(
                left: 3,
                bottom: 3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.isToday
                        ? cells.onHighlightColor
                        : data.isHoliday
                            ? cells.weekDayColor
                            : cells.dotColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A ruled row with the date boxed off on the left, like the notes column
/// printed down the side of a patro.
class _TraditionalEventRow extends StatelessWidget {
  const _TraditionalEventRow({required this.event, required this.language});

  final CalendarEvent<Events> event;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        event.isHoliday ? theme.colorScheme.error : theme.colorScheme.primary;
    final info = event.additionalInfo;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                border: Border(right: _rule(context)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    NepaliNumberConverter.formattedNumber(
                      '${event.date.day}',
                      language: language,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: accent,
                    ),
                  ),
                  Text(
                    WeekUtils.formattedShortWeekDay(
                      event.date.weekday,
                      language,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (event.isHoliday)
                          _Chip(label: 'बिदा', color: accent),
                      ],
                    ),
                    if (info != null && info.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
// Small shared pieces
// ---------------------------------------------------------------------------

/// A tinted pill. Shared so the two designs stay visually consistent where
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

// Nepali Calendar Events for BS Year 2083 (Baishakh 2083 - Chaitra 2083)
// Corresponds to approx. April 14, 2026 - April 13, 2027 (AD)

final List<CalendarEvent<Events>> eventList = [
  // ----------------------------- BAISHAKH -----------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 1, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "मेष सङ्क्रान्ति / नयाँ वर्ष / बिस्का जात्रा",
      description: "Mesh Sankranti, Nepali New Year 2083, Biska Jatra.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 1, day: 18),
    isHoliday: true,
    additionalInfo: Events(
      title: "बुद्ध जयन्ती / उभौली पर्व / अन्तर्राष्ट्रिय श्रमिक दिवस",
      description:
          "Buddha Jayanti, Ubhauli Parwa, Chandeshwari Jatra, Chandi Purnima, Gorakhnath Jayanti, Kurma Jayanti, International Labour Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- JESTHA ------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 2, day: 14),
    isHoliday: false,
    additionalInfo: Events(
      title: "बकर ईद / प्रदोष व्रत",
      description: "Bakar Eid (holiday for Muslim community), Pradosh Vrata.",
      additionalInfo: "Community holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 2, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "गणतन्त्र दिवस / अन्तर्राष्ट्रिय सगरमाथा दिवस",
      description: "Republic Day, International Everest Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // -------------------------------- ASHAR -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 3, day: 6),
    isHoliday: false,
    additionalInfo: Events(
      title: "भोटो जात्रा / सिठी नाखा / अन्तर्राष्ट्रिय शरणार्थी दिवस",
      description: "Bhoto Jatra, Sithi Nakha, Kumar Sasthi, World Refugee Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 3, day: 32),
    isHoliday: false,
    additionalInfo: Events(
      title: "आर्थिक वर्ष २०८२/८३ को समापन",
      description:
          "Closing of fiscal year 2082/83; government offices finalise accounts.",
      additionalInfo: "Fiscal year-end closing",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------ SHRAWAN -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 4, day: 1),
    isHoliday: false,
    additionalInfo: Events(
      title: "नयाँ आर्थिक वर्ष २०८३/८४ सुरु",
      description: "Start of Nepal's new fiscal year, 2083/84.",
      additionalInfo: "New fiscal year begins",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------- BHADRA -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 12),
    isHoliday: true,
    additionalInfo: Events(
      title: "जनै पूर्णिमा / रक्षाबन्धन / क्वाँटी खाने दिन",
      description:
          "Janai Purnima, Raksha Bandhan, Purnima Vrata, Kwati Khane Din, Rishi Tarpani, Sanskrit Diwas.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 13),
    isHoliday: true,
    additionalInfo: Events(
      title: "गाईजात्रा",
      description: "Gaijatra, International Day Against Nuclear Tests.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 19),
    isHoliday: true,
    additionalInfo: Events(
      title: "श्री कृष्ण जन्माष्टमी / गौरा पर्व",
      description:
          "Shree Krishna Janmashtami, Gaura Parva, Gorakhkali Puja, Durwashtami.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 29),
    isHoliday: true,
    additionalInfo: Events(
      title: "हरितालिका तीज",
      description:
          "Haritalika Teej, Ganesh Chaturthi Vrata, Rashtriya Dharmasabha Diwas, Rashtriya Bal Diwas.",
      additionalInfo: "Public holiday (women)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- ASHWIN -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 3),
    isHoliday: true,
    additionalInfo: Events(
      title: "संविधान दिवस",
      description:
          "Sambidhan Diwas (Constitution Day), Radha Janmotsav, Gorakhkali Puja.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "इन्द्रजात्रा",
      description:
          "Indra Jaatra, Ananta Chaturdashi Vrata, World Pharmacists Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "नवमी श्राद्ध / जितिया पर्व",
      description: "Nawami Shraddha, Jitiya Parva, World Animal Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "घटस्थापना",
      description: "Ghatasthapana Vrata, Navaratra Arambha (start of Dashain).",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 31),
    isHoliday: true,
    additionalInfo: Events(
      title: "फूलपाती",
      description:
          "Fulpati, Dashain Holiday begins, International Day for the Eradication of Poverty.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- KARTIK -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "महाअष्टमी व्रत / कालरात्री",
      description:
          "Tula Sankranti, Maha Ashtami Vrata, Kalratri, Gorakhkali Puja.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 2),
    isHoliday: true,
    additionalInfo: Events(
      title: "दशैं बिदा",
      description: "Dashain Holiday.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 3),
    isHoliday: true,
    additionalInfo: Events(
      title: "महानवमी व्रत",
      description: "Maha Nawami Vrata.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 4),
    isHoliday: true,
    additionalInfo: Events(
      title: "विजया दशमी",
      description: "Bijaya Dashami, Devi Bisharjan.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 5),
    isHoliday: true,
    additionalInfo: Events(
      title: "पापाङ्कुशा एकादशी व्रत",
      description: "Papakunsa Ekadashi Vrata.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 6),
    isHoliday: true,
    additionalInfo: Events(
      title: "दशैं बिदा / प्रदोष व्रत",
      description:
          "Dashain Holiday, Pradosh Vrata (Duwadashi, last day of Dashain holidays).",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 22),
    isHoliday: true,
    additionalInfo: Events(
      title: "लक्ष्मी पूजा / कुकुर तिहार",
      description:
          "Laxmi Pooja, Laxmi Prasad Devkota Janma Jayanti, Kukur Tihar, Narak Chaturdashi, Sukha Ratri, World Radiography Day.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 23),
    isHoliday: true,
    additionalInfo: Events(
      title: "तिहार बिदा / गाई पूजा",
      description: "Tihar Holiday, Gai Puja, World Freedom Day.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 24),
    isHoliday: true,
    additionalInfo: Events(
      title: "गोवर्धन पूजा / म्ह पूजा / नेपाल सम्बत १९४७",
      description:
          "Gobardan Puja, Mha Puja, Hali Tihar, Nepal Sambat 1147 Starts, Goru Puja, World Science Day for Peace and Development.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "भाइटीका",
      description: "Bhai Tika, Kija Pooja, Falgunanda Jayanti.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 26),
    isHoliday: false,
    additionalInfo: Events(
      title: "तिहार बिदा",
      description: "Tihar Holiday, World Pneumonia Day.",
      additionalInfo: "Regional/office holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 29),
    isHoliday: true,
    additionalInfo: Events(
      title: "छठ पर्व",
      description: "Chhath Parva.",
      additionalInfo: "Public holiday (Terai region)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- MANGSIR -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 8, day: 8),
    isHoliday: false,
    additionalInfo: Events(
      title: "गुरु नानक जयन्ती / निम्बार्काचार्य जयन्ती",
      description:
          "Kartik Snan Samapti, Chaturmas Vrata Samapti, Guru Nanak Jayanti, Nimbarkacharya Jayanti, Sakimana Punhi.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 8, day: 17),
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
    date: NepaliDateTime(year: 2083, month: 8, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "उभौली पर्व / उत्पत्तिका एकादशी व्रत",
      description: "Udhauli Parva, Utpatika Ekadashi Vrata.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),

  // -------------------------------- PAUSH --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "धन्य पूर्णिमा / यःमरी पुन्हि / ज्यापु दिवस",
      description: "Dhanya Purnima, Udhauli Parva, Yomari Punhi, Jyapu Diwas.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "क्रिसमस डे",
      description: "Christmas Day celebration.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "तमु ल्होसार / लेखनाथ जयन्ती",
      description: "Tamu Lhosar, Poet Shiromani Lekhnath Jayanti.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 27),
    isHoliday: false,
    additionalInfo: Events(
      title: "पृथ्वी जयन्ती / राष्ट्रिय एकता दिवस",
      description: "Prithvi Jayanti, National Unity Day.",
      additionalInfo: "National observance",
      eventType: "notHoliday",
    ),
  ),

  // -------------------------------- MAGH ---------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "माघे सङ्क्रान्ति",
      description: "Makar Sankranti, Ghyu-Chaku Khane Din, Uttarayan begins.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 16),
    isHoliday: true,
    additionalInfo: Events(
      title: "शहीद दिवस",
      description: "Martyrs' Day (Sahid Diwas).",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 24),
    isHoliday: true,
    additionalInfo: Events(
      title: "सोनाम ल्होछार",
      description: "Sonam Lhochhar.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 28),
    isHoliday: false,
    additionalInfo: Events(
      title: "वसन्तपञ्चमी / सरस्वती पूजा",
      description:
          "Basant Panchami and Saraswati Puja (holiday for educational institutions only).",
      additionalInfo: "Educational institutions holiday",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------- FALGUN --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 7),
    isHoliday: true,
    additionalInfo: Events(
      title: "प्रजातन्त्र दिवस",
      description: "Prajatantra Diwas (Democracy Day) / Election Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 22),
    isHoliday: true,
    additionalInfo: Events(
      title: "महाशिवरात्री",
      description: "Maha Shivaratri, Nepali Army Day, Silachahre Puja.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 24),
    isHoliday: false,
    additionalInfo: Events(
      title: "अन्तर्राष्ट्रिय महिला दिवस",
      description: "International Women's Day.",
      additionalInfo: "Special holiday for women employees",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "ग्याल्पो ल्होसार",
      description: "Gyalpo Lhosar.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- CHAITRA --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 7),
    isHoliday: true,
    additionalInfo: Events(
      title: "फागु पूर्णिमा / होली",
      description: "Fagu Poornima / Holi, World Poetry Day.",
      additionalInfo: "Public holiday (Hill region)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 8),
    isHoliday: true,
    additionalInfo: Events(
      title: "फागु पूर्णिमा (तराई)",
      description: "Fagu Poornima (Terai), World Water Day.",
      additionalInfo: "Public holiday (Terai region)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 23),
    isHoliday: false,
    additionalInfo: Events(
      title: "घोडेजात्रा",
      description: "Ghode Jaatra.",
      additionalInfo: "Cultural event (Kathmandu Valley)",
      eventType: "notHoliday",
    ),
  ),
];
