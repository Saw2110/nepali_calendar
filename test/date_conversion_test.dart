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

  /// The first year of the data. Up to 0.1.0, BS -> AD counted from BS
  /// 1969-09-18 using an absolute difference, so earlier dates were mirrored
  /// onto the wrong side of it, and AD -> BS rejected all of BS 1969. The
  /// pickers offer BS 1969, so it has to convert like any other year.
  group('BS 1969, the start of the data', () {
    test('BS 1969-01-01 is AD 1912-04-12, and back', () {
      expect(
        NepaliDateTime(year: 1969, month: 1, day: 1).toDateTime(),
        DateTime(1912, 4, 12),
      );
      expect(
        DateTime(1912, 4, 12).toNepaliDateTime().toDateFormat(),
        '1969-01-01',
      );
    });

    test('BS 1969-09-18 is AD 1913-01-01', () {
      expect(
        NepaliDateTime(year: 1969, month: 9, day: 18).toDateTime(),
        DateTime(1913, 1, 1),
      );
    });

    test('the days either side of 1969-09-18 are distinct', () {
      // Both used to convert to AD 1913-01-02.
      expect(
        NepaliDateTime(year: 1969, month: 9, day: 17).toDateTime(),
        DateTime(1912, 12, 31),
      );
      expect(
        NepaliDateTime(year: 1969, month: 9, day: 19).toDateTime(),
        DateTime(1913, 1, 2),
      );
    });

    test('a date before the data still throws', () {
      expect(
        () => DateTime(1912, 4, 11).toNepaliDateTime(),
        throwsArgumentError,
      );
    });
  });

  /// Every day the package has data for, not a sample: the sampled tests
  /// below started at BS 1970, which is how BS 1969 went unnoticed.
  group('the whole bundled range, day by day', () {
    test('every BS day maps to the next AD day and round-trips', () {
      const years = CalendarUtils.nepaliYears;
      DateTime? previous;
      final failures = <String>[];

      for (final year in years.keys) {
        for (var month = 1; month <= 12; month++) {
          for (var day = 1; day <= years[year]![month]; day++) {
            final bs = NepaliDateTime(year: year, month: month, day: day);
            final ad = bs.toDateTime();

            if (previous != null &&
                DateTime.utc(ad.year, ad.month, ad.day)
                        .difference(
                          DateTime.utc(
                            previous.year,
                            previous.month,
                            previous.day,
                          ),
                        )
                        .inDays !=
                    1) {
              failures.add('BS ${bs.toDateFormat()} -> AD $ad after $previous');
            }
            previous = ad;

            final back = ad.toNepaliDateTime();
            if (back.year != year || back.month != month || back.day != day) {
              failures.add(
                'BS ${bs.toDateFormat()} -> AD $ad -> BS ${back.toDateFormat()}',
              );
            }
          }
        }
      }

      expect(
        failures,
        isEmpty,
        reason: '${failures.length} failures. '
            'First few: ${failures.take(5).join(" | ")}',
      );
    });

    /// A BS year is solar: 365 or 366 days, never anything else. BS 2200 was
    /// once listed at 372 -- a placeholder that the totals check alone cannot
    /// catch, because its months did add up to 372.
    test('every year is 365 or 366 days long', () {
      for (final entry in CalendarUtils.nepaliYears.entries) {
        expect(
          entry.value.first,
          anyOf(365, 366),
          reason: 'BS ${entry.key} is ${entry.value.first} days',
        );
      }
    });

    /// BS New Year tracks the solar year, so its AD date may move by a day
    /// between consecutive years but never jump. The 372-day placeholder for
    /// BS 2200 moved it six days at once.
    test('BS New Year never jumps more than a day year to year', () {
      DateTime? previous;
      for (final year in CalendarUtils.nepaliYears.keys) {
        final ad = NepaliDateTime(year: year, month: 1, day: 1).toDateTime();
        final thisYear = DateTime.utc(2000, ad.month, ad.day);
        if (previous != null) {
          expect(
            thisYear.difference(previous).inDays.abs(),
            lessThanOrEqualTo(1),
            reason: 'BS $year New Year is AD $ad',
          );
        }
        previous = thisYear;
      }
    });

    test('each year total matches its months', () {
      for (final entry in CalendarUtils.nepaliYears.entries) {
        final months = entry.value.skip(1).fold<int>(0, (a, b) => a + b);
        expect(
          months,
          entry.value.first,
          reason: 'BS ${entry.key}: months add up to $months',
        );
      }
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
