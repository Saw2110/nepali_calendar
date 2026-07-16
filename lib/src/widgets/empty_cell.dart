import 'package:flutter/material.dart';

/// Unused. This renders a `SizedBox.shrink()` and is not referenced anywhere
/// in the package.
///
/// **Deprecated:** this was never intended as public API; it became so
/// because the package exported every internal file. It will be removed in
/// 1.0.0. If you depend on it, please open an issue describing your use
/// case.
@Deprecated(
  'Internal implementation detail, not intended as public API. Will be removed in 1.0.0.',
)
class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
