// Dates are always written out in full here, including month/day values that
// happen to match the constructor defaults. In date-conversion tests the
// literal date is the point, so relying on defaults would hurt readability.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Correctness tests for BS <-> AD conversion.
///
/// These are deliberately NOT characterization tests. Version 0.0.7 shipped a
/// timezone-dependent off-by-one in [DateTimeExtension.toNepaliDateTime], so
/// pinning the old output would make the bug permanent. These lock in the
/// properties a calendar mapping must satisfy instead.
void main() {
  group('known anchor dates', () {
    // Externally verifiable: Nepali New Year 2081 fell on 13 April 2024.
    test('BS 2081-01-01 is AD 2024-04-13', () {
      final bs = NepaliDateTime(year: 2081, month: 1, day: 1);
      expect(bs.toDateTime(), DateTime(2024, 4, 13));
    });

    test('AD 2024-04-13 is BS 2081-01-01', () {
      expect(
        DateTime(2024, 4, 13).toNepaliDateTime().toDateFormat(),
        '2081-01-01',
      );
    });

    test('BS 2080-01-01 is AD 2023-04-14', () {
      expect(
        NepaliDateTime(year: 2080, month: 1, day: 1).toDateTime(),
        DateTime(2023, 4, 14),
      );
    });

    test('AD 2023-04-14 is BS 2080-01-01', () {
      expect(
        DateTime(2023, 4, 14).toNepaliDateTime().toDateFormat(),
        '2080-01-01',
      );
    });

    test('epoch: BS 1970-01-01 is AD 1913-04-13', () {
      expect(
        NepaliDateTime(year: 1970, month: 1, day: 1).toDateTime(),
        DateTime(1913, 4, 13),
      );
      expect(
        DateTime(1913, 4, 13).toNepaliDateTime().toDateFormat(),
        '1970-01-01',
      );
    });
  });

  group('round-trip', () {
    test('BS -> AD -> BS is identity across the supported range', () {
      final failures = <String>[];

      for (int year = 1970; year <= 2099; year++) {
        for (int month = 1; month <= 12; month++) {
          for (final day in const [1, 15, 28]) {
            final original = NepaliDateTime(year: year, month: month, day: day);
            final back = original.toDateTime().toNepaliDateTime();

            if (back.year != year || back.month != month || back.day != day) {
              failures.add(
                'BS $year-$month-$day -> AD ${original.toDateTime()} '
                '-> BS ${back.toDateFormat()}',
              );
            }
          }
        }
      }

      expect(
        failures,
        isEmpty,
        reason: '${failures.length} dates failed to round-trip. '
            'First few: ${failures.take(5).join(" | ")}',
      );
    });

    test('AD -> BS -> AD is identity across the supported range', () {
      final failures = <String>[];

      for (var ad = DateTime(1914, 1, 1);
          ad.isBefore(DateTime(2040, 1, 1));
          ad = ad.add(const Duration(days: 29))) {
        final back = ad.toNepaliDateTime().toDateTime();
        if (back != ad) failures.add('AD $ad -> BS -> AD $back');
      }

      expect(
        failures,
        isEmpty,
        reason: '${failures.length} dates failed to round-trip. '
            'First few: ${failures.take(5).join(" | ")}',
      );
    });
  });

  group('continuity', () {
    /// The 0.0.7 bug tore a hole at the 1986 boundary: AD 1985-12-31 mapped to
    /// BS 2042-09-16 while AD 1986-01-02 mapped to BS 2042-09-19 -- two AD days
    /// spanning three BS days. A calendar mapping must never skip or repeat.
    test('consecutive AD days map to consecutive BS days', () {
      final breaks = <String>[];
      var previous = DateTime(1980, 1, 1).toNepaliDateTime();

      for (var ad = DateTime(1980, 1, 2);
          ad.isBefore(DateTime(2000, 1, 1));
          ad = ad.add(const Duration(days: 1))) {
        final current = ad.toNepaliDateTime();
        final gap = CalendarUtils.nepaliDateDifference(current, previous);

        if (gap != 1) {
          breaks.add(
            'AD $ad: ${previous.toDateFormat()} -> ${current.toDateFormat()} '
            '(gap of $gap days)',
          );
        }
        previous = current;
      }

      expect(
        breaks,
        isEmpty,
        reason: 'Mapping is discontinuous at ${breaks.length} point(s). '
            'First few: ${breaks.take(5).join(" | ")}',
      );
    });

    test('no discontinuity across the 1986 boundary specifically', () {
      // The regression site: 0.0.7 added a day to every post-1986 conversion
      // on +5:45 devices, so this exact step jumped by 2 instead of 1.
      final before = DateTime(1985, 12, 31).toNepaliDateTime();
      final after = DateTime(1986, 1, 1).toNepaliDateTime();

      expect(
        CalendarUtils.nepaliDateDifference(after, before),
        1,
        reason: 'AD 1985-12-31 (${before.toDateFormat()}) and '
            'AD 1986-01-01 (${after.toDateFormat()}) must be one BS day apart',
      );
    });
  });

  group('timezone independence', () {
    /// The 0.0.7 bug only fired when the device timezone was exactly +5:45,
    /// meaning users in Nepal got different dates than users anywhere else.
    /// Conversion must depend only on the calendar date, never on the device.
    test('conversion ignores the time component', () {
      final midnight = DateTime(2024, 4, 13);
      final almostMidnight = DateTime(2024, 4, 13, 23, 59, 59);

      expect(
        midnight.toNepaliDateTime().toDateFormat(),
        almostMidnight.toNepaliDateTime().toDateFormat(),
      );
    });

    test('a UTC DateTime and a local DateTime of the same calendar date agree',
        () {
      expect(
        DateTime.utc(2024, 4, 13).toNepaliDateTime().toDateFormat(),
        DateTime(2024, 4, 13).toNepaliDateTime().toDateFormat(),
      );
    });
  });

  group('weekday', () {
    // AD 2024-04-13 was a Saturday; the package uses 0=Sunday..6=Saturday.
    test('BS 2081-01-01 is a Saturday', () {
      expect(NepaliDateTime(year: 2081, month: 1, day: 1).weekday, 6);
    });

    test('weekday advances by one across consecutive days', () {
      var previous = NepaliDateTime(year: 2081, month: 1, day: 1).weekday;
      for (int day = 2; day <= 28; day++) {
        final current = NepaliDateTime(year: 2081, month: 1, day: day).weekday;
        expect(current, (previous + 1) % 7, reason: 'broke at BS 2081-01-$day');
        previous = current;
      }
    });
  });
}
