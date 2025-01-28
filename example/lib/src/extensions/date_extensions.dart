// import 'package:nepalicalender/nepalicalender.dart';

// /// Extension to convert standard DateTime to NepaliDateTime
// extension DateTimeExtension on DateTime {
//   /// Converts the [DateTime] to [NepaliDateTime].
//   NepaliDateTime toNepaliDateTime() {
//     const nepalTzOffset = Duration(hours: 5, minutes: 45);
//     final now = toUtc().add(nepalTzOffset);

//     // Reference point: 1970/1/1 with English date 1913/4/13
//     var nepaliYear = 1970;
//     var nepaliMonth = 1;
//     var nepaliDay = 1;

//     // Normalize time to avoid date difference calculation issues
//     final date = DateTime(now.year, now.month, now.day);
//     var difference = date.difference(DateTime(1913, 4, 13)).inDays;

//     // Compensate for time zone offset anomaly after 1986
//     if (date.timeZoneOffset == nepalTzOffset && date.isAfter(DateTime(1986))) {
//       difference += 1;
//     }

//     // Calculate Nepali year
//     var daysInYear = NepaliCalenderUtils.nepaliYears[nepaliYear]!.first;
//     while (difference >= daysInYear) {
//       nepaliYear += 1;
//       difference -= daysInYear;
//       daysInYear = NepaliCalenderUtils.nepaliYears[nepaliYear]!.first;
//     }

//     // Calculate Nepali month
//     var daysInMonth = NepaliCalenderUtils.nepaliYears[nepaliYear]![nepaliMonth];
//     while (difference >= daysInMonth) {
//       difference -= daysInMonth;
//       nepaliMonth += 1;
//       daysInMonth = NepaliCalenderUtils.nepaliYears[nepaliYear]![nepaliMonth];
//     }

//     // Remaining days is the actual day
//     nepaliDay += difference;

//     return NepaliDateTime(
//       year: nepaliYear,
//       month: nepaliMonth,
//       day: nepaliDay,
//       hour: now.hour,
//       minute: now.minute,
//       second: now.second,
//       millisecond: now.millisecond,
//       microsecond: now.microsecond,
//     );
//   }
// }
