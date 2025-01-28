import 'package:flutter/material.dart';

class NepaliCalenderStyle {
  final Color? selectedDateColor;
  final Color? selectedTextColor;
  final Color? todayColor;
  final Color? holidayColor;
  final TextStyle? headerTextStyle;
  final Color? defaultTextColor;
  final Color? weekendColor;
  final Color? eventColor;
  final Color? todayTextColor;
  final TextStyle? dayTextStyle;

  const NepaliCalenderStyle({
    this.selectedDateColor = Colors.blueAccent,
    this.selectedTextColor = Colors.yellow,
    this.todayColor = Colors.green,
    this.holidayColor = Colors.redAccent,
    this.headerTextStyle,
    this.defaultTextColor = Colors.black,
    this.weekendColor = Colors.red,
    this.eventColor = Colors.blue,
    this.todayTextColor = Colors.white,
    this.dayTextStyle,
  });
}
