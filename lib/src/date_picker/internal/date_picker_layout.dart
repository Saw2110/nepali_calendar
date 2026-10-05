/// The date picker's measurements, and how it fits them to the space on
/// offer.
///
/// Internal: not exported from the package. Shared by [NepaliDatePicker] and
/// [showNepaliDatePicker], which must agree on when the title band moves
/// beside the grid: the dialog has to be told its width before the picker is
/// laid out.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../src.dart';
import 'picker_shared.dart';

/// Width the picker takes when there is room, with the title band on top.
///
/// The day grid plus its gutters; nothing else in the picker is wider -- the
/// Nepali Close / OK pair included.
const double datePickerWidth = 330.0;

/// Height of the title band when it sits above the grid.
const double datePickerBandHeight = 96.0;

/// Width of the title band when it sits beside the grid instead: on a screen
/// too short for it on top -- a phone in landscape -- as Material's own
/// picker does. On top it would leave the day rows too short to tap.
const double datePickerSideBandWidth = 168.0;

/// Height of the navigation row.
const double datePickerHeaderHeight = 44.0;

/// Height of the weekday row.
const double datePickerWeekdayHeight = 20.0;

/// Height of the action row: Close, and OK without auto-confirm.
const double datePickerActionsHeight = 44.0;

/// Padding above and below the grid, combined.
const double datePickerVerticalPadding = 8.0;

/// Space below the picker in [showNepaliDatePicker]'s dialog. None above:
/// the title band runs to the dialog's top edge.
const EdgeInsets datePickerDialogPadding = EdgeInsets.only(bottom: 4);

/// The size a day cell aims for.
///
/// Material asks for a 48dp touch target. Seven columns of 48 need 336dp plus
/// gutters, which a small phone's dialog does not have -- Flutter's own
/// Material DatePicker lands near 42dp for the same reason.
const double _preferredCell = 42.0;

/// The height a row of the day grid aims for. Equal to [_preferredCell]
/// gives square rows; lower it for rows shorter than a cell is wide. Only a
/// short viewport makes rows shorter still.
const double _preferredRow = 42.0;

/// The narrowest a day cell may get.
const double _minCell = 36.0;

/// How big the picker wants to be for a given viewport.
@immutable
class DatePickerLayout {
  final double width;
  final double height;
  final double cell;

  /// Whether the title band sits beside the grid rather than above it.
  final bool sideBand;

  const DatePickerLayout._({
    required this.width,
    required this.height,
    required this.cell,
    required this.sideBand,
  });

  /// Width the grid occupies. Narrower than the space beside or below the
  /// band; the grid is centred.
  double get gridWidth =>
      (cell * pickerColumns) + (pickerCellGap * (pickerColumns - 1));

  /// Everything but the day rows.
  ///
  /// `pickerCellGap` is the spacer above the weekday row; uncounted, it came
  /// out of the rows' height instead.
  static double _chrome({required bool sideBand, required bool withActions}) =>
      (sideBand ? 0.0 : datePickerBandHeight) +
      datePickerHeaderHeight +
      pickerCellGap +
      datePickerWeekdayHeight +
      datePickerVerticalPadding +
      (withActions ? datePickerActionsHeight : 0.0);

  static const double _rowGaps = pickerCellGap * (pickerRows - 1);

  /// Whether a space of [maxWidth] by [maxHeight] calls for the band beside
  /// the grid: too short for full-height rows under the band, and wide
  /// enough for the band alongside.
  static bool wantsSideBand(
    double maxWidth,
    double maxHeight, {
    required bool withActions,
  }) {
    final fullHeight = _chrome(sideBand: false, withActions: withActions) +
        (_preferredRow * pickerRows) +
        _rowGaps;
    return maxHeight < fullHeight &&
        maxWidth >= datePickerWidth + datePickerSideBandWidth;
  }

  /// Measures the picker against the space on offer.
  ///
  /// The picker sizes to its content rather than to a fixed box, so the rows
  /// never float apart in dead space.
  factory DatePickerLayout.measure(
    BuildContext context,
    BoxConstraints constraints, {
    required bool withActions,
  }) {
    final screen = MediaQuery.sizeOf(context);
    final maxWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : screen.width;
    final maxHeight =
        constraints.hasBoundedHeight ? constraints.maxHeight : screen.height;

    final sideBand =
        wantsSideBand(maxWidth, maxHeight, withActions: withActions);
    final width = sideBand
        ? datePickerWidth + datePickerSideBandWidth
        : math.min(datePickerWidth, maxWidth);
    final gridArea = width - (sideBand ? datePickerSideBandWidth : 0.0);

    // Cells are square. Their size is capped so a tablet does not get a
    // ballooning grid, and floored so a narrow phone does not get an
    // unusable one.
    final widthBudget = (gridArea -
            (pickerGutter * 2) -
            (pickerCellGap * (pickerColumns - 1))) /
        pickerColumns;
    final cell = widthBudget.clamp(_minCell, _preferredCell);

    // Never taller than a cell is wide; the selection square fits the shorter
    // side.
    final row = math.min(cell, _preferredRow);

    // A short viewport caps the height, and the day grid's rows shrink to
    // share what is left. The grid never scrolls.
    final height = math.min(
      maxHeight,
      _chrome(sideBand: sideBand, withActions: withActions) +
          (row * pickerRows) +
          _rowGaps,
    );

    return DatePickerLayout._(
      width: width,
      height: height,
      cell: cell,
      sideBand: sideBand,
    );
  }
}

/// The width [showNepaliDatePicker] gives its dialog on [screen]: the
/// picker's own, or wider to fit the title band beside the grid.
///
/// Mirrors [DatePickerLayout.measure], from the space the dialog leaves its
/// content.
double datePickerDialogWidth(Size screen, {required bool withActions}) {
  final maxWidth = screen.width - pickerDialogInsets.horizontal;
  final maxHeight = screen.height -
      pickerDialogInsets.vertical -
      datePickerDialogPadding.vertical;
  return DatePickerLayout.wantsSideBand(
    maxWidth,
    maxHeight,
    withActions: withActions,
  )
      ? datePickerWidth + datePickerSideBandWidth
      : datePickerWidth;
}
