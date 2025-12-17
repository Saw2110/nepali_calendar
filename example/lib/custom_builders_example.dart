import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

Widget customCellExample(CalendarCellData<Events> data) {
  return GestureDetector(
    onTap: data.onTap,
    child: Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: data.isToday
            ? Colors.blue.withOpacity(0.2)
            : data.isSelected
                ? Colors.blue.withOpacity(0.1)
                : data.isDimmed
                    ? Colors.grey.shade300
                    : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: data.isToday
            ? Border.all(
                color: Colors.blue,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${data.day}',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: data.isToday ? FontWeight.bold : FontWeight.w600,
              color: data.isToday
                  ? Colors.blue
                  : data.isWeekend
                      ? Colors.red
                      : data.isDimmed
                          ? Colors.grey
                          : Colors.black,
            ),
          ),
          if (data.event != null)
            Icon(
              Icons.star,
              color: data.event!.isHoliday ? Colors.red : Colors.blue,
              size: 12.0,
            ),
        ],
      ),
    ),
  );
}

Widget customWeekDayExample(WeekdayData data) {
  return Container(
    margin: const EdgeInsets.all(4.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weekday name in Nepali
          Text(
            WeekUtils.formattedWeekDay(
              data.weekday,
              Language.nepali,
              data.format,
            ),
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: data.isWeekend ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          // Weekday name in English (optional - remove if not needed)
          Text(
            WeekUtils.formattedWeekDay(
              data.weekday,
              Language.english,
              TitleFormat.half,
            ),
            style: TextStyle(
              fontSize: 10.0,
              color:
                  data.isWeekend ? Colors.red.withOpacity(0.7) : Colors.black54,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget? customHeaderExample(date, controller) {
  return Container(
    margin: const EdgeInsets.all(8.0),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.blue,
            size: 28,
          ),
          onPressed: () {
            if (controller.hasClients) {
              controller.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
            }
          },
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                MonthUtils.formattedMonth(date.month, Language.nepali),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                NepaliNumberConverter.englishToNepali(date.year.toString()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: Colors.blue,
            size: 28,
          ),
          onPressed: () {
            if (controller.hasClients) {
              controller.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
            }
          },
        ),
      ],
    ),
  );
}
