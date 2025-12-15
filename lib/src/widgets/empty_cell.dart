import 'package:flutter/material.dart';

/// An empty cell placeholder used when [CellTheme.showAdjacentMonthDays] is false.
/// This maintains the grid structure without displaying any content.
class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
