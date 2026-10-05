import 'package:flutter/material.dart';

import '../src.dart';
import '../utils/calendar_semantics.dart';

/// The header is an implementation detail of [NepaliCalendar]. To replace it,
/// use `CalendarBuilder.headerBuilder`.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class CalendarHeader extends StatelessWidget {
  final NepaliDateTime selectedDate;
  final PageController pageController;
  final NepaliCalendarStyle calendarStyle;

  const CalendarHeader({
    super.key,
    required this.selectedDate,
    required this.pageController,
    required this.calendarStyle,
  });

  @override
  Widget build(BuildContext context) {
    final language = calendarStyle.effectiveConfig.language;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            // Doubles as the screen-reader label and the desktop hover
            // tooltip, so neither arrow is an unlabelled button.
            tooltip: CalendarSemantics.previousMonth(language),
            onPressed: () => _step(previous: true),
          ),
          Expanded(
            // A single header node reading "बैशाख २०८१", rather than two
            // unrelated text nodes a screen reader announces separately.
            child: Semantics(
              header: true,
              excludeSemantics: true,
              label: CalendarSemantics.monthHeader(selectedDate, language),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 5.0,
                children: [
                  Flexible(
                    child: Text(
                      MonthUtils.formattedMonth(
                        selectedDate.month,
                        language,
                      ),
                      style: calendarStyle.headersStyle.monthHeaderStyle,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      NepaliNumberConverter.formattedNumber(
                        '${selectedDate.year}',
                        language: language,
                      ),
                      style: calendarStyle.headersStyle.yearHeaderStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: CalendarSemantics.nextMonth(language),
            onPressed: () => _step(previous: false),
          ),
        ],
      ),
    );
  }

  /// Pages one month back or forward, once the PageView is attached.
  void _step({required bool previous}) {
    if (!pageController.hasClients) return;
    const duration = Duration(milliseconds: 400);
    const curve = Curves.easeInOutCubic;
    previous
        ? pageController.previousPage(duration: duration, curve: curve)
        : pageController.nextPage(duration: duration, curve: curve);
  }
}
