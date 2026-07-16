// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

void main() {
  group('equality', () {
    test('two identically constructed dates are equal', () {
      expect(
        NepaliDateTime(year: 2081, month: 1, day: 1),
        NepaliDateTime(year: 2081, month: 1, day: 1),
      );
    });

    test('equal dates share a hash code', () {
      expect(
        NepaliDateTime(year: 2081, month: 5, day: 15).hashCode,
        NepaliDateTime(year: 2081, month: 5, day: 15).hashCode,
      );
    });

    test('dates differing in any component are unequal', () {
      final base = NepaliDateTime(year: 2081, month: 5, day: 15, hour: 10);

      final differsByYear =
          NepaliDateTime(year: 2082, month: 5, day: 15, hour: 10);
      final differsByMonth =
          NepaliDateTime(year: 2081, month: 6, day: 15, hour: 10);
      final differsByDay =
          NepaliDateTime(year: 2081, month: 5, day: 16, hour: 10);
      final differsByHour =
          NepaliDateTime(year: 2081, month: 5, day: 15, hour: 11);

      expect(base, isNot(differsByYear));
      expect(base, isNot(differsByMonth));
      expect(base, isNot(differsByDay));
      expect(base, isNot(differsByHour));
    });

    test('works as a Map key', () {
      final events = <NepaliDateTime, String>{
        NepaliDateTime(year: 2081, month: 1, day: 1): 'New Year',
      };

      expect(events[NepaliDateTime(year: 2081, month: 1, day: 1)], 'New Year');
    });

    test('works in a Set', () {
      final dates = {
        NepaliDateTime(year: 2081, month: 1, day: 1),
        NepaliDateTime(year: 2081, month: 1, day: 1),
        NepaliDateTime(year: 2081, month: 1, day: 2),
      };

      expect(dates, hasLength(2));
    });
  });

  group('isSameDayAs / dateOnly', () {
    test('same day with different times', () {
      final morning = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 9);
      final evening = NepaliDateTime(year: 2081, month: 1, day: 1, hour: 17);

      expect(morning.isSameDayAs(evening), isTrue);
      expect(morning == evening, isFalse, reason: 'times differ');
    });

    test('different days', () {
      expect(
        NepaliDateTime(year: 2081, month: 1, day: 1)
            .isSameDayAs(NepaliDateTime(year: 2081, month: 1, day: 2)),
        isFalse,
      );
    });

    test('dateOnly strips the time and is a stable key', () {
      final withTime =
          NepaliDateTime(year: 2081, month: 1, day: 1, hour: 13, minute: 30);

      expect(withTime.dateOnly, NepaliDateTime(year: 2081, month: 1, day: 1));
      expect(withTime.dateOnly.hour, 0);
      expect(withTime.dateOnly.minute, 0);
    });
  });

  group('today resolves against Nepal time', () {
    test('CalendarUtils.isToday agrees with NepaliDateTime.now', () {
      // These two must never disagree about which day is today, regardless of
      // the device timezone. Up to 0.0.7 isToday used the device's local date
      // while now() used Nepal's, so they diverged outside Nepal.
      final today = NepaliDateTime.now();

      expect(CalendarUtils.isToday(today.toDateTime()), isTrue);
    });

    test('a day either side of today is not today', () {
      final today = NepaliDateTime.now().toDateTime();

      expect(
        CalendarUtils.isToday(today.subtract(const Duration(days: 1))),
        isFalse,
      );
      expect(
        CalendarUtils.isToday(today.add(const Duration(days: 1))),
        isFalse,
      );
    });
  });

  group('compareTo', () {
    test('orders by date', () {
      final dates = [
        NepaliDateTime(year: 2081, month: 5, day: 15),
        NepaliDateTime(year: 2080, month: 1, day: 1),
        NepaliDateTime(year: 2081, month: 1, day: 1),
      ]..sort();

      expect(dates.map((d) => d.toDateFormat()), [
        '2080-01-01',
        '2081-01-01',
        '2081-05-15',
      ]);
    });

    test('compareTo is consistent with ==', () {
      final a = NepaliDateTime(year: 2081, month: 1, day: 1);
      final b = NepaliDateTime(year: 2081, month: 1, day: 1);

      expect(a.compareTo(b), 0);
      expect(a, b);
    });
  });

  group('range validation', () {
    test('a date before the epoch throws a clear error', () {
      expect(
        () => DateTime(1900, 1, 1).toNepaliDateTime(),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('before the start of the supported range'),
          ),
        ),
      );
    });

    test('a date past the calendar data throws a clear error', () {
      expect(
        () => DateTime(2200, 1, 1).toNepaliDateTime(),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('beyond the end of the supported range'),
          ),
        ),
      );
    });
  });
}
