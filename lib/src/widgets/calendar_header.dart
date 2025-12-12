// Import required Flutter material package
import 'package:flutter/material.dart';

// Import custom source file
import '../src.dart';

// Widget to display the calendar header with month/year and navigation buttons
class CalendarHeader extends StatefulWidget {
  // Selected date to display in header
  final NepaliDateTime selectedDate;
  // Controller for handling page transitions
  final PageController pageController;
  // Style configuration for the calendar
  final CalendarTheme calendarStyle;

  // Constructor with required parameters
  const CalendarHeader({
    super.key,
    required this.selectedDate,
    required this.pageController,
    required this.calendarStyle,
  });

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final headerTheme = widget.calendarStyle.headerTheme;
    final animations = widget.calendarStyle.animations;

    // Use animations.enableHeaderAnimation to control header animations
    _fadeController = AnimationController(
      duration: animations.enableHeaderAnimation
          ? headerTheme.transitionDuration
          : Duration.zero,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: headerTheme.transitionCurve,
    );

    _fadeController.value = 1.0;
  }

  @override
  void didUpdateWidget(CalendarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    final animations = widget.calendarStyle.animations;

    // Trigger fade animation on month change if both header animation and fade transition are enabled
    if (animations.enableHeaderAnimation &&
        widget.calendarStyle.headerTheme.enableFadeTransition &&
        (oldWidget.selectedDate.month != widget.selectedDate.month ||
            oldWidget.selectedDate.year != widget.selectedDate.year)) {
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerTheme = widget.calendarStyle.headerTheme;

    return Container(
      height: _getHeaderHeight(headerTheme.layout),
      padding: headerTheme.headerPadding,
      decoration: BoxDecoration(
        color: headerTheme.headerBackgroundColor,
        border: headerTheme.headerBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading widget or default back button
          _buildLeading(headerTheme),

          // Center section containing month and year
          Expanded(
            child: _buildCenterContent(headerTheme),
          ),

          // Trailing widget and actions
          _buildTrailing(headerTheme),
        ],
      ),
    );
  }

  /// Gets the header height based on layout.
  double _getHeaderHeight(HeaderLayout layout) {
    switch (layout) {
      case HeaderLayout.compact:
        return 40.0;
      case HeaderLayout.expanded:
        return 64.0;
      case HeaderLayout.standard:
        return widget.calendarStyle.headerTheme.headerHeight;
    }
  }

  /// Builds the leading widget.
  Widget _buildLeading(HeaderTheme headerTheme) {
    if (headerTheme.leading != null) {
      return headerTheme.leading!;
    }

    if (!headerTheme.showNavigationButtons) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(
        Icons.chevron_left,
        color: headerTheme.navigationIconColor,
        size: headerTheme.navigationIconSize,
      ),
      onPressed: () {
        if (widget.pageController.hasClients) {
          widget.pageController.previousPage(
            duration: widget.calendarStyle.animations.monthTransitionDuration,
            curve: widget.calendarStyle.animations.monthTransitionCurve,
          );
        }
      },
    );
  }

  /// Builds the center content with month/year.
  Widget _buildCenterContent(HeaderTheme headerTheme) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month display
        if (headerTheme.showMonth)
          Flexible(
            child: Text(
              MonthUtils.formattedMonth(
                widget.selectedDate.month,
                widget.calendarStyle.locale,
              ),
              style: headerTheme.monthTextStyle,
            ),
          ),
        // Separator
        if (headerTheme.showMonth && headerTheme.showYear)
          Text(headerTheme.monthYearSeparator),
        // Year display with language-specific formatting
        if (headerTheme.showYear)
          Flexible(
            child: Text(
              widget.calendarStyle.locale == CalendarLocale.english
                  ? "${widget.selectedDate.year}"
                  : NepaliNumberConverter.englishToNepali(
                      widget.selectedDate.year.toString(),
                    ),
              style: headerTheme.yearTextStyle,
            ),
          ),
      ],
    );

    // Add subtitle if provided
    if (headerTheme.subtitleTextStyle != null &&
        widget.calendarStyle.cellTheme.showEnglishDate) {
      final englishDate = widget.selectedDate.toDateTime();
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          content,
          Text(
            '${englishDate.day}/${englishDate.month}/${englishDate.year}',
            style: headerTheme.subtitleTextStyle,
          ),
        ],
      );
    }

    // Apply fade animation if enabled
    if (headerTheme.enableFadeTransition) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: content,
      );
    }

    return content;
  }

  /// Builds the trailing widget and actions.
  Widget _buildTrailing(HeaderTheme headerTheme) {
    final List<Widget> trailingWidgets = [];

    // Add actions if provided
    if (headerTheme.actions != null) {
      trailingWidgets.addAll(headerTheme.actions!);
    }

    // Add trailing widget or default forward button
    if (headerTheme.trailing != null) {
      trailingWidgets.add(headerTheme.trailing!);
    } else if (headerTheme.showNavigationButtons) {
      trailingWidgets.add(
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: headerTheme.navigationIconColor,
            size: headerTheme.navigationIconSize,
          ),
          onPressed: () {
            if (widget.pageController.hasClients) {
              widget.pageController.nextPage(
                duration:
                    widget.calendarStyle.animations.monthTransitionDuration,
                curve: widget.calendarStyle.animations.monthTransitionCurve,
              );
            }
          },
        ),
      );
    }

    if (trailingWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    if (trailingWidgets.length == 1) {
      return trailingWidgets.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingWidgets,
    );
  }
}
