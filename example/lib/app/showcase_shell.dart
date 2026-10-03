import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

import 'destinations.dart';

/// The frame around every example: an app bar with the theme and language
/// toggles, and navigation -- a bottom bar on phones, a side rail from
/// [_railBreakpoint] up.
class ShowcaseShell extends StatefulWidget {
  const ShowcaseShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

/// From this width the navigation moves from the bottom to the side.
const double _railBreakpoint = 720;

/// The widest an example gets. The calendars are built for phone widths, and
/// stretched across a desktop window they only get sparser.
const double _contentMaxWidth = 560;

class _ShowcaseShellState extends State<ShowcaseShell> {
  int _index = 0;
  Language _language = Language.nepali;

  void _toggleLanguage() {
    setState(() {
      _language =
          _language == Language.nepali ? Language.english : Language.nepali;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destination = showcaseDestinations[_index];
    final wide = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    // Every example stays alive in an IndexedStack, so switching away and
    // back keeps its month, selection and scroll position.
    final pages = IndexedStack(
      index: _index,
      children: [
        for (final d in showcaseDestinations)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: d.builder(_language),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: _Title(title: destination.title),
        actions: [
          _LanguageButton(language: _language, onPressed: _toggleLanguage),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Light/Dark',
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in showcaseDestinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages),
              ],
            )
          : pages,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in showcaseDestinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }
}

/// The example's title over the package name.
class _Title extends StatelessWidget {
  const _Title({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Nepali Calendar Plus',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Shows the language the examples are in, and switches it.
///
/// A labelled button rather than a bare globe icon: "EN" / "ने" says what the
/// current language is, which an icon cannot.
class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.language, required this.onPressed});

  final Language language;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Toggle Language',
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.translate_rounded, size: 18),
        label: Text(language == Language.nepali ? 'ने' : 'EN'),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
