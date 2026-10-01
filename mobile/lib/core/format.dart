import 'package:intl/intl.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Formatting shared across screens. Money arrives as decimal strings ("1850.00"), never a float on the wire, and
/// calendar dates arrive as "YYYY-MM-DD" strings and stay that way until shown, so they can never shift a day.

bool _tzReady = false;

/// Load the timezone database (once, at startup).
void initFormatting() {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  _tzReady = true;
}

final _money = NumberFormat('#,##0.00', 'en_GB');

String money(Object? v) => 'GH¢ ${_money.format(num.tryParse('${v ?? 0}') ?? 0)}';

String pct(num? n) => n == null ? 'n/a' : '${n.toStringAsFixed(1)}%';

DateTime _utcDate(String ymd) => DateTime.parse('${ymd.substring(0, 10)}T00:00:00Z');

String fmtDay(String ymd) => DateFormat('d MMM').format(_utcDate(ymd));
String fmtDayWeekday(String ymd) => DateFormat('EEE d MMM').format(_utcDate(ymd));
String fmtLong(String ymd) => DateFormat('EEEE d MMMM').format(_utcDate(ymd));
String fmtMonthYear(String ymd) => DateFormat('MMMM yyyy').format(_utcDate(ymd));
String fmtWeekday(String ymd) => DateFormat('EEE').format(_utcDate(ymd));

tz.Location _loc(String zone) {
  initFormatting();
  try {
    return tz.getLocation(zone);
  } catch (_) {
    return tz.UTC;
  }
}

/// "07:52" for a timestamp, in the school's timezone.
String fmtTime(DateTime instant, String zone) => DateFormat('HH:mm').format(tz.TZDateTime.from(instant, _loc(zone)));

/// "Mon 5 Oct 07:52"
String fmtStamp(DateTime instant, String zone) => DateFormat('EEE d MMM HH:mm').format(tz.TZDateTime.from(instant, _loc(zone)));

/// Today as YYYY-MM-DD in a timezone.
String todayIn(String zone, DateTime now) => DateFormat('yyyy-MM-dd').format(tz.TZDateTime.from(now, _loc(zone)));

/// The hour (0-23) in a timezone, for "good morning".
int hourIn(String zone, DateTime now) => tz.TZDateTime.from(now, _loc(zone)).hour;

String greeting(String zone, DateTime now) {
  final h = hourIn(zone, now);
  return h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
}

/// A wall-clock date and time in a named timezone, as the UTC instant it means.
DateTime zonedToUtc(String ymd, String hhmm, String zone) {
  final d = _utcDate(ymd);
  final parts = hhmm.split(':');
  return tz.TZDateTime(_loc(zone), d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1])).toUtc();
}

/// YYYY-MM-DD for a date (no timezone conversion: the calendar date as written).
String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// "2026-10" -> first and last day strings and the weekday of the 1st (1 = Monday).
({String from, String to, int days, int firstWeekday}) monthBounds(String month) {
  final y = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  final last = DateTime.utc(y, m + 1, 0).day;
  return (from: '$month-01', to: '$month-${last.toString().padLeft(2, '0')}', days: last, firstWeekday: DateTime.utc(y, m, 1).weekday);
}

String shiftMonth(String month, int by) {
  final y = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  final d = DateTime.utc(y, m + by, 1);
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

/// Attendance status words <-> the one-letter codes the design uses.
String statusLetter(String status) => switch (status) { 'present' => 'P', 'late' => 'L', 'absent' => 'A', 'excused' => 'E', _ => '?' };
String statusWord(String letter) => switch (letter) { 'P' => 'present', 'L' => 'late', 'A' => 'absent', 'E' => 'excused', _ => letter };
String statusLabel(String letter) => switch (letter) { 'P' => 'Present', 'L' => 'Late', 'A' => 'Absent', 'E' => 'Excused', _ => letter };

/// Weighted over the assessments that have a score; null when nothing is scored. Matches the server, so a teacher
/// typing scores sees the number the parent will see once it is saved.
double? runningGrade(Iterable<({double? score, double max, double weight})> items) {
  var got = 0.0;
  var weights = 0.0;
  for (final i in items) {
    if (i.score == null) continue;
    got += (i.score! / i.max) * i.weight;
    weights += i.weight;
  }
  return weights == 0 ? null : (1000 * got / weights).round() / 10;
}
