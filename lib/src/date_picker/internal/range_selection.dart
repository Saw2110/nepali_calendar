/// The range picker's selection rules, kept free of widgets so they can be
/// tested on their own. Internal: not exported from the package.
library;

import 'package:flutter/foundation.dart';

import '../../models/date_picker_builder.dart';
import '../../models/nepali_date_time.dart';
import '../../models/nepali_date_time_range.dart';
import 'picker_shared.dart';

/// A range under construction: nothing, a start, or a start and an end.
///
/// Immutable; [tap] returns the next selection rather than changing this one.
@immutable
class RangeSelection {
  final NepaliDateTime? start;
  final NepaliDateTime? end;

  const RangeSelection({this.start, this.end})
      : assert(start != null || end == null, 'an end needs a start');

  /// Seeds a selection from a complete range, or starts empty.
  factory RangeSelection.from(NepaliDateTimeRange? range) => range == null
      ? const RangeSelection()
      : RangeSelection(start: range.start.dateOnly, end: range.end.dateOnly);

  /// Whether both ends are set, so the selection can be confirmed.
  bool get isComplete => start != null && end != null;

  /// The finished range, or null while either end is missing.
  NepaliDateTimeRange? get range =>
      isComplete ? NepaliDateTimeRange(start: start!, end: end!) : null;

  /// Whether tapping [date] would do anything.
  ///
  /// A date outside [bounds] never is. Once a start is set and the end is
  /// pending, a later date is only selectable within [maxDays] of the start,
  /// counting both ends. An earlier date always is: tapping it moves the
  /// start rather than ending the range.
  bool isSelectable(
    NepaliDateTime date,
    PickerBounds bounds, {
    int? maxDays,
  }) {
    if (!bounds.contains(date)) return false;
    final start = this.start;
    if (maxDays == null || start == null || end != null) return true;
    final days = pickerDaysBetween(start, date);
    return days < 0 || days + 1 <= maxDays;
  }

  /// The selection after tapping [date].
  ///
  /// * nothing selected, or a complete range: [date] starts a new range;
  /// * a start only, and [date] is earlier: [date] becomes the start;
  /// * a start only, and [date] is the same day or later: [date] ends the
  ///   range -- a one-day range is allowed.
  ///
  /// A date [isSelectable] rejects leaves the selection unchanged.
  RangeSelection tap(
    NepaliDateTime date,
    PickerBounds bounds, {
    int? maxDays,
  }) {
    if (!isSelectable(date, bounds, maxDays: maxDays)) return this;
    final day = date.dateOnly;
    final start = this.start;
    if (start == null || end != null) return RangeSelection(start: day);
    if (day.compareTo(start) < 0) return RangeSelection(start: day);
    return RangeSelection(start: start, end: day);
  }

  /// Where [date] sits in the selection.
  PickerRangePosition positionOf(NepaliDateTime date) {
    final start = this.start;
    if (start == null) return PickerRangePosition.none;
    final day = date.dateOnly;
    final end = this.end;

    if (end == null || start.isSameDayAs(end)) {
      return day.isSameDayAs(start)
          ? PickerRangePosition.single
          : PickerRangePosition.none;
    }
    if (day.isSameDayAs(start)) return PickerRangePosition.start;
    if (day.isSameDayAs(end)) return PickerRangePosition.end;
    if (day.compareTo(start) > 0 && day.compareTo(end) < 0) {
      return PickerRangePosition.middle;
    }
    return PickerRangePosition.none;
  }

  @override
  bool operator ==(Object other) =>
      other is RangeSelection && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
