import 'package:flutter/material.dart';
import 'package:nepalicalendar/nepalicalendar.dart';

import 'src/models/event_model.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NepaliCalendar(
          // initialDate: NepaliDateTime(year: 2080, month: 9),
          eventList: eventList,
          checkIsHoliday: (event) => event!.eventType == "holiday",
          onDayChanged: (nepaliDateTime) {
            print("on day change NEPALI DATE TIME $nepaliDateTime");
            print("WEEK DAY${nepaliDateTime.weekday}");
          },
          onMonthChanged: (nepaliDateTime) {
            print("on month change NEPALI DATE TIME $nepaliDateTime");
          },
          // calendarStyle: NepaliCalenderStyle(
          //   selectedDateColor: Colors.blueAccent,
          //   selectedTextColor: Colors.yellow,
          //   todayColor: Colors.greenAccent,
          //   holidayColor: Colors.redAccent,
          //   headerTextStyle: const TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.purple,
          //   ),
          // ),
        ),
      ),
    );
  }
}

_getEventForDate(NepaliDateTime date) {
  try {
    return eventList.firstWhere(
      (e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day,
    );
  } catch (e) {
    return null;
  }
}

// // import 'package:flutter/material.dart';

// // import 'nepalicalender.dart';

// // void main() {
// //   runApp(const MainApp());
// // }

// // class MainApp extends StatelessWidget {
// //   const MainApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         body: SafeArea(
// //           child: NepaliCalendar(
// //             eventList: eventList,
// //             checkIsHoliday: (event) => event!.eventType == "holiday",
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class NepaliCalendar<T> extends StatefulWidget {
// //   final NepaliDateTime? initialDate;
// //   final List<MyEvent<T>>? eventList;
// //   final bool Function(T? event)? checkIsHoliday;

// //   const NepaliCalendar({
// //     super.key,
// //     this.initialDate,
// //     this.eventList,
// //     this.checkIsHoliday,
// //   });

// //   @override
// //   State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
// // }

// // class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
// //   late PageController _pageController;
// //   late NepaliDateTime _currentDate;
// //   late NepaliDateTime _selectedDate;
// //   late int _currentPageIndex;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _currentDate = widget.initialDate ?? NepaliDateTime.now();
// //     _selectedDate = _currentDate;
// //     _initializePageController();
// //   }

// //   void _initializePageController() {
// //     _currentPageIndex =
// //         ((_currentDate.year - NepaliCalenderUtils.calenderyearStart) * 12) +
// //             _currentDate.month -
// //             1;
// //     _pageController = PageController(initialPage: _currentPageIndex);
// //   }

// //   void _updateCurrentDate(int year, int month, int day) {
// //     setState(() {
// //       _selectedDate = NepaliDateTime(year: year, month: month, day: day);
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         CalendarHeader(
// //           selectedDate: _selectedDate,
// //           pageController: _pageController,
// //         ),
// //         Expanded(
// //           child: PageView.builder(
// //             controller: _pageController,
// //             itemCount: NepaliCalenderUtils.nepaliYears.length * 12,
// //             onPageChanged: (index) {
// //               int year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
// //               int month = (index % 12) + 1;
// //               _updateCurrentDate(year, month, _currentDate.day);
// //             },
// //             itemBuilder: (context, index) {
// //               final year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
// //               final month = (index % 12) + 1;

// //               return CalendarMonthView<T>(
// //                 year: year,
// //                 month: month,
// //                 selectedDate: _selectedDate,
// //                 eventList: widget.eventList,
// //                 checkIsHoliday: widget.checkIsHoliday,
// //                 onDaySelected: (date) {
// //                   _updateCurrentDate(date.year, date.month, date.day);
// //                 },
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class CalendarHeader extends StatelessWidget {
// //   final NepaliDateTime selectedDate;
// //   final PageController pageController;

// //   const CalendarHeader({
// //     super.key,
// //     required this.selectedDate,
// //     required this.pageController,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         IconButton(
// //           icon: const Icon(Icons.chevron_left),
// //           onPressed: () {
// //             if (pageController.hasClients) {
// //               pageController.previousPage(
// //                 duration: const Duration(milliseconds: 300),
// //                 curve: Curves.easeInOut,
// //               );
// //             }
// //           },
// //         ),
// //         Text(
// //           'Year ${selectedDate.year}, Month ${selectedDate.month}',
// //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         IconButton(
// //           icon: const Icon(Icons.chevron_right),
// //           onPressed: () {
// //             if (pageController.hasClients) {
// //               pageController.nextPage(
// //                 duration: const Duration(milliseconds: 500),
// //                 curve: Curves.easeInOut,
// //               );
// //             }
// //           },
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class CalendarMonthView<T> extends StatelessWidget {
// //   final int year;
// //   final int month;
// //   final NepaliDateTime selectedDate;
// //   final List<MyEvent<T>>? eventList;
// //   final bool Function(T? event)? checkIsHoliday;
// //   final void Function(NepaliDateTime) onDaySelected;

// //   const CalendarMonthView({
// //     super.key,
// //     required this.year,
// //     required this.month,
// //     required this.selectedDate,
// //     required this.eventList,
// //     required this.onDaySelected,
// //     this.checkIsHoliday,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         const WeekdayHeader(),
// //         CalendarGrid<T>(
// //           year: year,
// //           month: month,
// //           selectedDate: selectedDate,
// //           eventList: eventList,
// //           checkIsHoliday: checkIsHoliday,
// //           onDaySelected: onDaySelected,
// //         ),
// //         Flexible(
// //           child: EventList<T>(
// //             eventList: eventList,
// //             selectedDate: selectedDate,
// //             checkIsHoliday: checkIsHoliday,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class WeekdayHeader extends StatelessWidget {
// //   const WeekdayHeader({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     const List<String> weekdays = [
// //       'Sun',
// //       'Mon',
// //       'Tue',
// //       'Wed',
// //       'Thu',
// //       'Fri',
// //       'Sat'
// //     ];
// //     return Row(
// //       children: weekdays
// //           .map((day) => Expanded(
// //                 child: Text(
// //                   day,
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ))
// //           .toList(),
// //     );
// //   }
// // }

// // class CalendarGrid<T> extends StatelessWidget {
// //   final int year;
// //   final int month;
// //   final NepaliDateTime selectedDate;
// //   final List<MyEvent<T>>? eventList;
// //   final bool Function(T? event)? checkIsHoliday;
// //   final void Function(NepaliDateTime) onDaySelected;

// //   const CalendarGrid({
// //     super.key,
// //     required this.year,
// //     required this.month,
// //     required this.selectedDate,
// //     required this.eventList,
// //     required this.onDaySelected,
// //     this.checkIsHoliday,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final firstDayOfMonth = NepaliDateTime(year: year, month: month, day: 1);
// //     final weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
// //     final daysCountInMonth = _getDaysInMonth(year, month);

// //     final gridItems = _buildEmptyPadding(weekdayOfFirstDay);
// //     gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 7,
// //         crossAxisSpacing: 1,
// //         mainAxisSpacing: 1,
// //       ),
// //       itemCount: gridItems.length,
// //       itemBuilder: (context, index) => gridItems[index],
// //     );
// //   }

// //   List<Widget> _buildEmptyPadding(int weekdayOfFirstDay) {
// //     return List.generate(weekdayOfFirstDay, (_) => const EmptyCell());
// //   }

// //   List<Widget> _buildMonthDays(int year, int month, int daysCountInMonth) {
// //     return List.generate(daysCountInMonth, (index) {
// //       final day = index + 1;
// //       final date = NepaliDateTime(year: year, month: month, day: day);
// //       final event = _getEventForDate(date);

// //       return CalendarCell<T>(
// //         day: day,
// //         date: date,
// //         selectedDate: selectedDate,
// //         event: event,
// //         checkIsHoliday: checkIsHoliday,
// //         onDaySelected: onDaySelected,
// //       );
// //     });
// //   }

// //   MyEvent<T>? _getEventForDate(NepaliDateTime date) {
// //     if (eventList == null) return null;
// //     try {
// //       return eventList!.firstWhere(
// //         (e) =>
// //             e.date.year == date.year &&
// //             e.date.month == date.month &&
// //             e.date.day == date.day,
// //       );
// //     } catch (e) {
// //       return null;
// //     }
// //   }

// //   int _getDaysInMonth(int year, int month) {
// //     return NepaliCalenderUtils.nepaliYears[year]![month];
// //   }

// //   int _normalizeWeekday(int weekday) {
// //     return weekday;
// //   }
// // }

// // class CalendarCell<T> extends StatelessWidget {
// //   final int day;
// //   final NepaliDateTime date;
// //   final NepaliDateTime selectedDate;
// //   final MyEvent<T>? event;
// //   final bool Function(T? event)? checkIsHoliday;
// //   final void Function(NepaliDateTime) onDaySelected;

// //   const CalendarCell({
// //     super.key,
// //     required this.day,
// //     required this.date,
// //     required this.selectedDate,
// //     required this.event,
// //     required this.onDaySelected,
// //     this.checkIsHoliday,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final isToday = NepaliCalenderUtils.isToday(date.toDateTime());
// //     final isSelected = _isSelectedDate(date);
// //     final isHoliday =
// //         event?.events != null ? checkIsHoliday?.call(event?.events) : false;

// //     return GestureDetector(
// //       onTap: () => onDaySelected(date),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: _getCellColor(isToday, isSelected),
// //           border: Border.all(
// //             color: _getCellColor(isToday, isSelected).withValues(alpha: 0.05),
// //           ),
// //           borderRadius: BorderRadius.circular(8),
// //         ),
// //         child: Stack(
// //           alignment: Alignment.bottomCenter,
// //           children: [
// //             Center(
// //               child: Text(
// //                 "$day",
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: _getCellTextColor(isToday, isSelected, date.weekday),
// //                 ),
// //               ),
// //             ),
// //             Align(
// //               alignment: Alignment.bottomRight,
// //               child: Padding(
// //                 padding: const EdgeInsets.all(5.0),
// //                 child: Text(
// //                   "${date.toDateTime().day}",
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     color: _getCellTextColor(isToday, isSelected, date.weekday),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             if (event != null)
// //               Positioned(
// //                 bottom: 5.0,
// //                 child: Icon(
// //                   Icons.circle,
// //                   size: 5,
// //                   color:
// //                       _getEventColor(isHoliday ?? false, isToday, date.weekday),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Color _getCellColor(bool isToday, bool isSelected) {
// //     if (isToday && isSelected) return Colors.green;
// //     if (isSelected) return Colors.blue.shade100;
// //     if (isToday) return Colors.green.shade400;
// //     return Colors.transparent;
// //   }

// //   Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
// //     if (isToday && isSelected) return Colors.white;
// //     if (isSelected) return Colors.blue;
// //     if (isToday) return Colors.white;
// //     if (weekday == 6) return Colors.red;
// //     return Colors.black;
// //   }

// //   Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
// //     if (weekday == 6) return Colors.red;
// //     if (isToday) return Colors.white;
// //     if (isHoliday) return Colors.red;
// //     return Colors.blue;
// //   }

// //   bool _isSelectedDate(NepaliDateTime date) {
// //     return date.year == selectedDate.year &&
// //         date.month == selectedDate.month &&
// //         date.day == selectedDate.day;
// //   }
// // }

// // class EmptyCell extends StatelessWidget {
// //   const EmptyCell({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container();
// //   }
// // }

// // class EventList<T> extends StatelessWidget {
// //   final List<MyEvent<T>>? eventList;
// //   final NepaliDateTime selectedDate;
// //   final bool Function(T? event)? checkIsHoliday;

// //   const EventList({
// //     super.key,
// //     required this.eventList,
// //     required this.selectedDate,
// //     this.checkIsHoliday,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     if (eventList == null) return const SizedBox.shrink();

// //     final eventsForMonth = eventList!.where((event) =>
// //         event.date.month == selectedDate.month &&
// //         event.date.year == selectedDate.year);

// //     return ListView.builder(
// //       shrinkWrap: true,
// //       itemCount: eventsForMonth.length,
// //       itemBuilder: (context, index) {
// //         final event = eventsForMonth.elementAt(index);
// //         final isHoliday = checkIsHoliday?.call(event.events) ?? false;

// //         return ListTile(
// //           title: Text(event.events.toString()),
// //           subtitle: Text(event.date.toString()),
// //           trailing: Icon(
// //             Icons.circle,
// //             size: 5,
// //             color: isHoliday ? Colors.red : Colors.blue,
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// ///
// ///
// ///
// library;

// import 'package:flutter/material.dart';

// import 'nepalicalender.dart';

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: SafeArea(
//           child: NepaliCalendar(
//             initialDate: NepaliDateTime(year: 2080, month: 9),
//             // eventList: eventList,
//             // checkIsHoliday: (event) => event!.eventType == "holiday",
//             calendarStyle: NepaliCalenderStyle(
//               selectedDateColor: Colors.blueAccent,
//               selectedTextColor: Colors.yellow,
//               todayColor: Colors.greenAccent,
//               holidayColor: Colors.redAccent,
//               headerTextStyle: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.purple,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NepaliCalendar<T> extends StatefulWidget {
//   final NepaliDateTime? initialDate;
//   final List<MyEvent<T>>? eventList;
//   final bool Function(T? event)? checkIsHoliday;
//   final NepaliCalenderStyle calendarStyle;

//   const NepaliCalendar({
//     super.key,
//     this.initialDate,
//     this.eventList,
//     this.checkIsHoliday,
//     this.calendarStyle = const NepaliCalenderStyle(),
//   });

//   @override
//   State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
// }

// class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
//   late PageController _pageController;
//   late NepaliDateTime _currentDate;
//   late NepaliDateTime _selectedDate;
//   late int _currentPageIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentDate = widget.initialDate ?? NepaliDateTime.now();
//     _selectedDate = _currentDate;
//     _initializePageController();
//   }

//   void _initializePageController() {
//     _currentPageIndex =
//         ((_currentDate.year - NepaliCalenderUtils.calenderyearStart) * 12) +
//             _currentDate.month -
//             1;
//     _pageController = PageController(initialPage: _currentPageIndex);
//   }

//   void _updateCurrentDate(int year, int month, int day) {
//     setState(() {
//       _selectedDate = NepaliDateTime(year: year, month: month, day: day);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CalendarHeader(
//           selectedDate: _selectedDate,
//           pageController: _pageController,
//           calendarStyle: widget.calendarStyle,
//         ),
//         Expanded(
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: NepaliCalenderUtils.nepaliYears.length * 12,
//             onPageChanged: (index) {
//               int year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
//               int month = (index % 12) + 1;
//               _updateCurrentDate(year, month, _currentDate.day);
//             },
//             itemBuilder: (context, index) {
//               final year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
//               final month = (index % 12) + 1;

//               return CalendarMonthView<T>(
//                 year: year,
//                 month: month,
//                 selectedDate: _selectedDate,
//                 eventList: widget.eventList,
//                 checkIsHoliday: widget.checkIsHoliday,
//                 onDaySelected: (date) {
//                   _updateCurrentDate(date.year, date.month, date.day);
//                 },
//                 calendarStyle: widget.calendarStyle,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class CalendarHeader extends StatelessWidget {
//   final NepaliDateTime selectedDate;
//   final PageController pageController;
//   final NepaliCalenderStyle calendarStyle;

//   const CalendarHeader({
//     super.key,
//     required this.selectedDate,
//     required this.pageController,
//     required this.calendarStyle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.chevron_left),
//           onPressed: () {
//             if (pageController.hasClients) {
//               pageController.previousPage(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             }
//           },
//         ),
//         Text(
//           'Year ${selectedDate.year}, Month ${selectedDate.month}',
//           style: calendarStyle.headerTextStyle ??
//               const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right),
//           onPressed: () {
//             if (pageController.hasClients) {
//               pageController.nextPage(
//                 duration: const Duration(milliseconds: 500),
//                 curve: Curves.easeInOut,
//               );
//             }
//           },
//         ),
//       ],
//     );
//   }
// }

// class CalendarMonthView<T> extends StatelessWidget {
//   final int year;
//   final int month;
//   final NepaliDateTime selectedDate;
//   final List<MyEvent<T>>? eventList;
//   final bool Function(T? event)? checkIsHoliday;
//   final void Function(NepaliDateTime) onDaySelected;
//   final NepaliCalenderStyle calendarStyle;
//   // final Widget Function() widgetBuilder;

//   const CalendarMonthView({
//     super.key,
//     required this.year,
//     required this.month,
//     required this.selectedDate,
//     required this.eventList,
//     required this.onDaySelected,
//     this.checkIsHoliday,
//     required this.calendarStyle,
//     // required this.widgetBuilder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const WeekdayHeader(),
//         CalendarGrid<T>(
//           year: year,
//           month: month,
//           selectedDate: selectedDate,
//           eventList: eventList,
//           checkIsHoliday: checkIsHoliday,
//           onDaySelected: onDaySelected,
//           calendarStyle: calendarStyle,
//         ),
//         // widgetBuilder.call(),
//         Flexible(
//           child: EventList<T>(
//             eventList: eventList,
//             selectedDate: selectedDate,
//             checkIsHoliday: checkIsHoliday,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class WeekdayHeader extends StatelessWidget {
//   const WeekdayHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const List<String> weekdays = [
//       'Sun',
//       'Mon',
//       'Tue',
//       'Wed',
//       'Thu',
//       'Fri',
//       'Sat'
//     ];
//     return Row(
//       children: weekdays
//           .map((day) => Expanded(
//                 child: Text(
//                   day,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ))
//           .toList(),
//     );
//   }
// }

// class CalendarGrid<T> extends StatelessWidget {
//   final int year;
//   final int month;
//   final NepaliDateTime selectedDate;
//   final List<MyEvent<T>>? eventList;
//   final bool Function(T? event)? checkIsHoliday;
//   final void Function(NepaliDateTime) onDaySelected;
//   final NepaliCalenderStyle calendarStyle;

//   const CalendarGrid({
//     super.key,
//     required this.year,
//     required this.month,
//     required this.selectedDate,
//     required this.eventList,
//     required this.onDaySelected,
//     this.checkIsHoliday,
//     required this.calendarStyle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final firstDayOfMonth = NepaliDateTime(year: year, month: month, day: 1);
//     final weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
//     final daysCountInMonth = _getDaysInMonth(year, month);

//     final gridItems = _buildEmptyPadding(weekdayOfFirstDay);
//     gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 7,
//         crossAxisSpacing: 1,
//         mainAxisSpacing: 1,
//       ),
//       itemCount: gridItems.length,
//       itemBuilder: (context, index) => gridItems[index],
//     );
//   }

//   List<Widget> _buildEmptyPadding(int weekdayOfFirstDay) {
//     debugPrint("weekdayOfFirstDay ${weekdayOfFirstDay.toString()}");
//     return weekdayOfFirstDay == 7
//         ? []
//         : List.generate(weekdayOfFirstDay, (_) => const EmptyCell());
//   }

//   List<Widget> _buildMonthDays(int year, int month, int daysCountInMonth) {
//     return List.generate(daysCountInMonth, (index) {
//       final day = index + 1;
//       final date = NepaliDateTime(year: year, month: month, day: day);
//       final event = _getEventForDate(date);

//       return CalendarCell<T>(
//         day: day,
//         date: date,
//         selectedDate: selectedDate,
//         event: event,
//         checkIsHoliday: checkIsHoliday,
//         onDaySelected: onDaySelected,
//         calendarStyle: calendarStyle,
//       );
//     });
//   }

//   MyEvent<T>? _getEventForDate(NepaliDateTime date) {
//     if (eventList == null) return null;
//     try {
//       return eventList!.firstWhere(
//         (e) =>
//             e.date.year == date.year &&
//             e.date.month == date.month &&
//             e.date.day == date.day,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   int _getDaysInMonth(int year, int month) {
//     return NepaliCalenderUtils.nepaliYears[year]![month];
//   }

//   int _normalizeWeekday(int weekday) {
//     return weekday;
//   }
// }

// class CalendarCell<T> extends StatelessWidget {
//   final int day;
//   final NepaliDateTime date;
//   final NepaliDateTime selectedDate;
//   final MyEvent<T>? event;
//   final bool Function(T? event)? checkIsHoliday;
//   final void Function(NepaliDateTime) onDaySelected;
//   final NepaliCalenderStyle calendarStyle;

//   const CalendarCell({
//     super.key,
//     required this.day,
//     required this.date,
//     required this.selectedDate,
//     required this.event,
//     required this.onDaySelected,
//     required this.calendarStyle,
//     this.checkIsHoliday,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isToday = NepaliCalenderUtils.isToday(date.toDateTime());
//     final isSelected = _isSelectedDate(date);
//     final isHoliday =
//         event?.events != null ? checkIsHoliday?.call(event?.events) : false;

//     return GestureDetector(
//       onTap: () => onDaySelected(date),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _getCellColor(isToday, isSelected),
//           border: Border.all(
//             color: _getCellColor(isToday, isSelected).withValues(alpha: 0.05),
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             Center(
//               child: Text(
//                 "$day",
//                 style: calendarStyle.dayTextStyle?.copyWith(
//                       color:
//                           _getCellTextColor(isToday, isSelected, date.weekday),
//                     ) ??
//                     TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color:
//                           _getCellTextColor(isToday, isSelected, date.weekday),
//                     ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Text(
//                   "${date.toDateTime().day}",
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: _getCellTextColor(isToday, isSelected, date.weekday),
//                   ),
//                 ),
//               ),
//             ),
//             if (event != null)
//               Positioned(
//                 bottom: 5.0,
//                 child: Icon(
//                   Icons.circle,
//                   size: 5,
//                   color:
//                       _getEventColor(isHoliday ?? false, isToday, date.weekday),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getCellColor(bool isToday, bool isSelected) {
//     if (isToday && isSelected) return calendarStyle.todayColor!;
//     if (isSelected) return calendarStyle.selectedDateColor!;
//     if (isToday) return calendarStyle.todayColor!;
//     return Colors.transparent;
//   }

//   Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
//     if (isToday && isSelected) return calendarStyle.todayTextColor!;
//     if (isSelected) return calendarStyle.selectedTextColor!;
//     if (isToday) return calendarStyle.todayTextColor!;
//     if (weekday == 6) return calendarStyle.weekendColor!;
//     return calendarStyle.defaultTextColor!;
//   }

//   Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
//     if (weekday == 6) return calendarStyle.weekendColor!;
//     if (isToday) return calendarStyle.todayTextColor!;
//     if (isHoliday) return calendarStyle.holidayColor!;
//     return calendarStyle.eventColor!;
//   }

//   bool _isSelectedDate(NepaliDateTime date) {
//     return date.year == selectedDate.year &&
//         date.month == selectedDate.month &&
//         date.day == selectedDate.day;
//   }
// }

// class EmptyCell extends StatelessWidget {
//   const EmptyCell({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.shrink();
//   }
// }

// class EventList<T> extends StatelessWidget {
//   final List<MyEvent<T>>? eventList;
//   final NepaliDateTime selectedDate;
//   final bool Function(T? event)? checkIsHoliday;

//   const EventList({
//     super.key,
//     required this.eventList,
//     required this.selectedDate,
//     this.checkIsHoliday,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (eventList == null) return const SizedBox.shrink();

//     final eventsForMonth = eventList!.where((event) =>
//         event.date.month == selectedDate.month &&
//         event.date.year == selectedDate.year);

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: eventsForMonth.length,
//       itemBuilder: (context, index) {
//         final event = eventsForMonth.elementAt(index);
//         final isHoliday = checkIsHoliday?.call(event.events) ?? false;

//         return ListTile(
//           title: Text(event.events.toString()),
//           subtitle: Text(event.date.toString()),
//           trailing: Icon(
//             Icons.circle,
//             size: 5,
//             color: isHoliday ? Colors.red : Colors.blue,
//           ),
//         );
//       },
//     );
//   }
// }


// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///


// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///


















// // import 'package:flutter/material.dart';
// // import 'package:nepalicalender/nepalicalender.dart';

// // void main() {
// //   runApp(const MainApp());
// // }

// // class MainApp extends StatelessWidget {
// //   const MainApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         body: SafeArea(
// //           child: NepaliCalendar(
// //             widgetBuilder: (context, todayDate, focusMonth) {
// //               if (eventList.isNotEmpty) {
// //                 return ListView.builder(
// //                   itemCount: eventList.length,
// //                   itemBuilder: (_, index) {
// //                     final event = eventList[index].events;
// //                     final date = eventList[index].date;

// //                     // Filter events for the focused month
// //                     if (date.month == focusMonth.month &&
// //                         date.year == focusMonth.year) {
// //                       return ListTile(
// //                         title: Text(event['title']),
// //                         subtitle: Text(
// //                           date.toString(), // Display the date of the event
// //                         ),
// //                         trailing: Icon(
// //                           Icons.circle,
// //                           size: 5,
// //                           color: event['eventType'] == "holiday"
// //                               ? Colors.red
// //                               : Colors.blue,
// //                         ),
// //                       );
// //                     } else {
// //                       return SizedBox.shrink(); // Hide events for other months
// //                     }
// //                   },
// //                 );
// //               }
// //               return SizedBox.shrink();
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class NepaliCalendar extends StatefulWidget {
// //   final Widget Function(BuildContext _, NepaliDateTime todayDate,
// //       NepaliDateTime focusedMonth)? widgetBuilder;

// //   const NepaliCalendar({super.key, this.widgetBuilder});

// //   @override
// //   State<NepaliCalendar> createState() => _NepaliCalendarState();
// // }

// // class _NepaliCalendarState extends State<NepaliCalendar> {
// //   late PageController _pageController;
// //   late NepaliDateTime _currentDate;
// //   late NepaliDateTime _selectedDate;
// //   late int _currentPageIndex;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _currentDate = NepaliDateTime.now();
// //     _selectedDate = _currentDate;
// //     _initializePageController();
// //   }

// //   void _initializePageController() {
// //     _currentPageIndex =
// //         ((_currentDate.year - NepaliCalenderUtils.calenderyearStart) * 12) +
// //             _currentDate.month -
// //             1;
// //     _pageController = PageController(initialPage: _currentPageIndex);
// //   }

// //   void _updateCurrentDate(int year, int month, int day) {
// //     setState(() {
// //       _selectedDate = NepaliDateTime(year: year, month: month, day: day);
// //     });

// //     print("SELECTED DATE $_selectedDate");
// //   }

// //   Widget _buildCalendarHeader() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         IconButton(
// //           icon: Icon(Icons.chevron_left),
// //           onPressed: () {
// //             if (_pageController.hasClients) {
// //               _pageController.previousPage(
// //                 duration: Duration(milliseconds: 300),
// //                 curve: Curves.easeInOut,
// //               );
// //             }
// //           },
// //         ),
// //         Text(
// //           'Year ${_selectedDate.year}, Month ${_selectedDate.month}',
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         IconButton(
// //           icon: Icon(Icons.chevron_right),
// //           onPressed: () {
// //             if (_pageController.hasClients) {
// //               _pageController.nextPage(
// //                 duration: Duration(milliseconds: 500),
// //                 curve: Curves.easeInOut,
// //               );
// //             }
// //           },
// //         ),
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         _buildCalendarHeader(),
// //         Expanded(
// //           child: PageView.builder(
// //             controller: _pageController,
// //             itemCount: NepaliCalenderUtils.nepaliYears.length * 12,
// //             onPageChanged: (index) {
// //               int year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
// //               int month = (index % 12) + 1;
// //               _updateCurrentDate(year, month, _currentDate.day);
// //             },
// //             itemBuilder: (context, index) {
// //               final year = NepaliCalenderUtils.calenderyearStart + (index ~/ 12);
// //               final month = (index % 12) + 1;

// //               return Column(
// //                 children: [
// //                   DaySection(
// //                     nepaliDateTime: NepaliDateTime(year: year, month: month),
// //                     selectedDate: _selectedDate,
// //                     onDaySelected: (date) {
// //                       _updateCurrentDate(date.year, date.month, date.day);
// //                     },
// //                     // eventList: widget.eventList, // Pass eventList to DaySection
// //                   ),

// //                   ///
// //                   Flexible(
// //                     child: widget.widgetBuilder?.call(
// //                           context,
// //                           _currentDate,
// //                           _selectedDate,
// //                         ) ??
// //                         SizedBox.shrink(),
// //                   ),
// //                   // if (widget.eventList != null && widget.eventList!.isNotEmpty)
// //                   //   Expanded(
// //                   //     child: ListView.builder(
// //                   //       shrinkWrap: true,
// //                   //       itemCount: widget.eventList!.length,
// //                   //       itemBuilder: (context, index) {
// //                   //         final event = widget.eventList![index];
// //                   //         return widget.eventBuilder!(
// //                   //             context, index, event, _selectedDate);
// //                   //       },
// //                   //     ),
// //                   //   ),
// //                 ],
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class DaySection extends StatelessWidget {
// //   final NepaliDateTime nepaliDateTime;
// //   final NepaliDateTime selectedDate;
// //   final void Function(NepaliDateTime nepaliDateTime) onDaySelected;
// //   final List<MyEvent>? eventList;

// //   const DaySection({
// //     super.key,
// //     required this.nepaliDateTime,
// //     required this.selectedDate,
// //     required this.onDaySelected,
// //     this.eventList,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         _buildWeekdayHeader(),
// //         _buildCalendarGrid(),
// //       ],
// //     );
// //   }

// //   Widget _buildWeekdayHeader() {
// //     final List<String> weekdays = [
// //       'Sun',
// //       'Mon',
// //       'Tue',
// //       'Wed',
// //       'Thu',
// //       'Fri',
// //       'Sat'
// //     ];
// //     return Row(
// //       children: weekdays
// //           .map((day) => Expanded(
// //                   child: Text(
// //                 day,
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(fontWeight: FontWeight.bold),
// //               )))
// //           .toList(),
// //     );
// //   }

// //   Widget _buildCalendarGrid() {
// //     final year = nepaliDateTime.year;
// //     final month = nepaliDateTime.month;

// //     NepaliDateTime firstDayOfMonth =
// //         NepaliDateTime(year: year, month: month, day: 1);
// //     int weekdayOfFirstDay = _normalizeWeekday(firstDayOfMonth.weekday);
// //     int daysCountInMonth = _getDaysInMonth(year, month);

// //     List<Widget> gridItems = _buildEmptyPadding(weekdayOfFirstDay);
// //     gridItems.addAll(_buildMonthDays(year, month, daysCountInMonth));

// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: NeverScrollableScrollPhysics(),
// //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 7,
// //         childAspectRatio: 1.0,
// //         crossAxisSpacing: 4,
// //         mainAxisSpacing: 4,
// //       ),
// //       itemCount: gridItems.length,
// //       itemBuilder: (context, index) => gridItems[index],
// //     );
// //   }

// //   List<Widget> _buildEmptyPadding(int weekdayOfFirstDay) {
// //     return List.generate(weekdayOfFirstDay, (_) => _buildEmptyCell());
// //   }

// //   List<Widget> _buildMonthDays(int year, int month, int daysCountInMonth) {
// //     return List.generate(daysCountInMonth, (index) {
// //       final day = index + 1;
// //       NepaliDateTime date = NepaliDateTime(year: year, month: month, day: day);

// //       // Check if the date has an event

// //       MyEvent<Map<String, dynamic>>? event;
// //       try {
// //         event = eventList!.firstWhere(
// //           (e) =>
// //               e.date.year == date.year &&
// //               e.date.month == date.month &&
// //               e.date.day == date.day,
// //         ) as MyEvent<Map<String, dynamic>>?;
// //       } catch (e) {
// //         event = null;
// //       }
// //       bool isHoliday = event?.events["eventType"] == "holiday";

// //       return GestureDetector(
// //         onTap: () => onDaySelected(date),
// //         child: _buildCalendarCell(
// //           day,
// //           date,
// //           isHoliday: isHoliday,
// //           event: event,
// //         ),
// //       );
// //     });
// //   }

// //   Widget _buildCalendarCell(int day, NepaliDateTime date,
// //       {MyEvent<Map<String, dynamic>>? event, bool? isHoliday}) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _getCellColor(date),
// //         border: Border.all(color: _getCellColor(date).withValues(alpha: 0.05)),
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Stack(
// //         alignment: Alignment.bottomCenter,
// //         children: [
// //           Center(
// //             child: Text(
// //               "$day",
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.bold,
// //                 color: _getCellTextColor(date),
// //               ),
// //             ),
// //           ),
// //           Align(
// //             alignment: Alignment.bottomRight,
// //             child: Padding(
// //               padding: const EdgeInsets.all(5.0),
// //               child: Text(
// //                 "${date.toDateTime().day}",
// //                 style: TextStyle(
// //                   fontSize: 10,
// //                   color: _getCellTextColor(date),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           if (event != null && isHoliday != null)
// //             Positioned(
// //               bottom: 5.0,
// //               child: Icon(
// //                 Icons.circle,
// //                 size: 5,
// //                 color: _getEventColor(isHoliday, date),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyCell() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //     );
// //   }

// //   int _getDaysInMonth(int year, int month) {
// //     return NepaliCalenderUtils.nepaliYears[year]![month];
// //   }

// //   int _normalizeWeekday(int weekday) {
// //     return weekday;
// //   }

// //   Color _getCellColor(NepaliDateTime date) {
// //     bool isToday = NepaliCalenderUtils.isToday(date.toDateTime());
// //     bool isSelected = _isSelectedDate(date);

// //     if (isToday && isSelected) {
// //       return Colors.green;
// //     }
// //     if (isSelected) {
// //       return Colors.blue.shade100;
// //     }
// //     if (isToday) {
// //       return Colors.green.shade400;
// //     }
// //     return Colors.transparent;
// //   }

// //   Color _getCellTextColor(NepaliDateTime date) {
// //     bool isToday = NepaliCalenderUtils.isToday(date.toDateTime());
// //     bool isSelected = _isSelectedDate(date);

// //     if (isToday && isSelected) {
// //       return Colors.white;
// //     }
// //     if (isSelected) {
// //       return Colors.blue;
// //     }
// //     if (isToday) {
// //       return Colors.white;
// //     }
// //     if (date.weekday == 6) {
// //       return Colors.red;
// //     }
// //     return Colors.black;
// //   }

// //   Color _getEventColor(bool isHoliday, NepaliDateTime date) {
// //     bool isToday = NepaliCalenderUtils.isToday(date.toDateTime());

// //     if (date.weekday == 6) {
// //       return Colors.red;
// //     }
// //     if (isToday) {
// //       return Colors.white;
// //     }
// //     if (date.weekday == 6 && isHoliday) {
// //       return Colors.red;
// //     }
// //     return Colors.blue;
// //   }

// //   bool _isSelectedDate(NepaliDateTime date) {
// //     bool isToday = date.year == selectedDate.year &&
// //         date.month == selectedDate.month &&
// //         date.day == selectedDate.day;
// //     bool isSameDate = date.day == selectedDate.day;
// //     return isToday || isSameDate;
// //   }
// // }
