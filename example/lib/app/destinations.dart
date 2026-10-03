import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import '../examples/advanced/advanced_example.dart';
import '../examples/month_calendar_example.dart';
import '../examples/pickers/pickers_example.dart';
import '../examples/week_strip_example.dart';
import '../examples/year_view_example.dart';

/// One entry in the navigation bar.
@immutable
class ShowcaseDestination {
  const ShowcaseDestination({
    required this.label,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  /// The short label under the icon.
  final String label;

  /// The longer title in the app bar.
  final String title;

  final IconData icon;
  final IconData selectedIcon;
  final Widget Function(Language language) builder;
}

/// Every example, in navigation order. Adding an example is one entry here
/// and one file under `examples/`.
final showcaseDestinations = <ShowcaseDestination>[
  ShowcaseDestination(
    label: 'Month',
    title: 'Month calendar',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    builder: (language) => NepaliCalendarExample(language: language),
  ),
  ShowcaseDestination(
    label: 'Week',
    title: 'Week strip',
    icon: Icons.view_week_outlined,
    selectedIcon: Icons.view_week,
    builder: (language) => HorizontalCalendarExample(language: language),
  ),
  ShowcaseDestination(
    label: 'Year',
    title: 'Year view',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    builder: (language) => YearCalendarExample(language: language),
  ),
  ShowcaseDestination(
    label: 'Pickers',
    title: 'Date pickers',
    icon: Icons.edit_calendar_outlined,
    selectedIcon: Icons.edit_calendar,
    builder: (language) => PickersExample(language: language),
  ),
  ShowcaseDestination(
    label: 'Advanced',
    title: 'Advanced',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
    builder: (language) => AdvancedExample(language: language),
  ),
];
