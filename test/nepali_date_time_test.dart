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

  /// Validation runs in every build mode: these used to be asserts, which
  /// release builds strip.
  group('validation', () {
    test('a day past the end of its month is rejected', () {
      // Jestha 2083 has 31 days.
      expect(
        () => NepaliDateTime(year: 2083, month: 2, day: 32),
        throwsRangeError,
      );
      expect(NepaliDateTime(year: 2083, month: 2, day: 31).day, 31);
    });

    test('a year outside the data is rejected', () {
      final years = CalendarUtils.nepaliYears.keys;
      expect(() => NepaliDateTime(year: years.first - 1), throwsRangeError);
      expect(() => NepaliDateTime(year: years.last + 1), throwsRangeError);
    });

    test('the first and last days of the data are accepted', () {
      const years = CalendarUtils.nepaliYears;
      final last = years.keys.last;
      expect(NepaliDateTime(year: years.keys.first).year, years.keys.first);
      expect(
        NepaliDateTime(year: last, month: 12, day: years[last]![12]).year,
        last,
      );
    });

    test('out-of-range fields are rejected', () {
      expect(() => NepaliDateTime(year: 2081, month: 13), throwsRangeError);
      expect(() => NepaliDateTime(year: 2081, day: 0), throwsRangeError);
      expect(() => NepaliDateTime(year: 2081, hour: 24), throwsRangeError);
      expect(() => NepaliDateTime(year: 2081, minute: 60), throwsRangeError);
      expect(
        () => NepaliDateTime(year: 2081, millisecond: 1000),
        throwsRangeError,
      );
    });

    test('the error names the field and the month length', () {
      expect(
        () => NepaliDateTime(year: 2083, month: 2, day: 32),
        throwsA(
          isA<RangeError>()
              .having((e) => e.name, 'name', 'day')
              .having((e) => e.message, 'message', contains('31 days')),
        ),
      );
    });
  });

  group('NepaliDateTimeRange', () {
    test('equality ignores the time of day', () {
      final morning = NepaliDateTimeRange(
        start: NepaliDateTime(year: 2081, month: 1, day: 10, hour: 9),
        end: NepaliDateTime(year: 2081, month: 1, day: 12, hour: 9),
      );
      final evening = NepaliDateTimeRange(
        start: NepaliDateTime(year: 2081, month: 1, day: 10, hour: 18),
        end: NepaliDateTime(year: 2081, month: 1, day: 12, hour: 18),
      );
      expect(morning, evening);
      expect(morning.hashCode, evening.hashCode);
    });

    test('an end before the start is rejected in every build mode', () {
      expect(
        () => NepaliDateTimeRange(
          start: NepaliDateTime(year: 2081, month: 1, day: 12),
          end: NepaliDateTime(year: 2081, month: 1, day: 10),
        ),
        throwsArgumentError,
      );
    });
  });
}
