import 'package:flutter/material.dart';

/// One feature demo: what it is, what it produced, and the button that runs
/// it.
///
/// Every picker demo uses this, so they read as a set: a tinted icon and a
/// title, a result panel that holds its place whether or not anything has
/// been picked, and one primary action.
class DemoCard extends StatelessWidget {
  const DemoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.placeholder,
    required this.actionLabel,
    required this.onAction,
    this.value,
    this.detail,
    this.onClear,
    this.clearTooltip = 'Clear',
  });

  final IconData icon;
  final String title;
  final String description;

  /// What the result panel says before anything is picked.
  final String placeholder;

  /// The result, once there is one.
  final String? value;

  /// A secondary line under [value]: the AD date, a day count.
  final String? detail;

  final String actionLabel;
  final VoidCallback onAction;

  /// Shown as a clear button once there is a [value].
  final VoidCallback? onClear;
  final String clearTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final value = this.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // The result panel. Always laid out, so the card does not jump
          // when a value arrives.
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value ?? placeholder,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              value == null ? FontWeight.w400 : FontWeight.w600,
                          color:
                              value == null ? colors.outline : colors.primary,
                        ),
                      ),
                      if (value != null && detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null && onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: clearTooltip,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAction,
            icon: Icon(icon, size: 18),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
