/// Enums for the calendar theme system.
///
/// This library provides enums for configuring calendar cell shapes
/// and header layouts.
library;

/// Shape options for calendar cells.
///
/// This enum defines the available shapes for rendering calendar date cells.
/// The shape affects how selection highlights and decorations are displayed.
enum CellShape {
  /// Circular cell shape.
  ///
  /// Creates a perfectly round selection indicator.
  /// Best suited for compact calendar layouts.
  circle,

  /// Rounded square cell shape.
  ///
  /// Creates a square with rounded corners.
  /// The corner radius can be customized via [CellTheme.borderRadius].
  roundedSquare,

  /// Square cell shape.
  ///
  /// Creates a square selection indicator with sharp corners.
  /// Best suited for grid-style calendar layouts.
  square,
}

/// Layout options for calendar header.
///
/// This enum defines the available layout styles for the calendar header,
/// controlling the arrangement and spacing of header elements.
enum HeaderLayout {
  /// Standard header layout.
  ///
  /// Default layout with balanced spacing between elements.
  standard,

  /// Compact header layout.
  ///
  /// Reduced height and tighter spacing for space-constrained UIs.
  compact,

  /// Expanded header layout.
  ///
  /// Additional vertical space and larger touch targets.
  /// Suitable for accessibility-focused designs.
  expanded,
}
