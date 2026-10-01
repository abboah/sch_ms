import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'parent_providers.dart';

/// Across several periods in a day, show the most notable mark: absent, then late, then excused, then present.
const _rank = {'A': 3, 'L': 2, 'E': 1, 'P': 0};
String _worst(Iterable<String> letters) => letters.reduce((a, b) => (_rank[b] ?? 0) > (_rank[a] ?? 0) ? b : a);

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _month;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider)!;
    final child = ref.watch(currentChildProvider);
    final month = _month ?? todayIn(me.school.timezone, ref.watch(appNowProvider)()).substring(0, 7);
    final b = monthBounds(month);
    final t = context.tokens;

    return HrScreen(
      big: true,
      eyebrow: fmtMonthYear(b.from),
      title: 'Attendance',
      onRefresh: child == null ? null : () async => ref.refresh(attendanceMonthProvider((childId: child.id, month: month)).future),
      children: [
        const ChildChips(),
        if (child == null)
          const NoChildren()
        else
          AsyncBody<List<AttendanceRecord>>(
            value: ref.watch(attendanceMonthProvider((childId: child.id, month: month))),
            onRetry: () => ref.invalidate(attendanceMonthProvider((childId: child.id, month: month))),
            data: (records) {
              final byDay = <String, List<AttendanceRecord>>{};
              for (final r in records) {
                byDay.putIfAbsent(r.periodDate, () => []).add(r);
              }
              final cells = _grid(month, b, {for (final e in byDay.entries) e.key: _worst(e.value.map((r) => statusLetter(r.status.toJson())))});
              final recent = byDay.keys.toList()..sort((a, c) => c.compareTo(a));
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                HrCard(
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IconButton(tooltip: 'Earlier month', onPressed: () => setState(() => _month = shiftMonth(month, -1)), icon: const Icon(Icons.chevron_left)),
                      Text(fmtMonthYear(b.from), style: Theme.of(context).textTheme.titleMedium),
                      IconButton(tooltip: 'Later month', onPressed: () => setState(() => _month = shiftMonth(month, 1)), icon: const Icon(Icons.chevron_right)),
                    ]),
                    Row(children: [for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']) Expanded(child: Center(child: Eyebrow(d)))]),
                    const SizedBox(height: 6),
                    for (final week in cells)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          for (final c in week)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: InkWell(
                                  onTap: c.letter == null ? null : () => _showDay(context, c.ymd!, byDay[c.ymd!]!, me.school.timezone),
                                  child: Container(
                                    constraints: const BoxConstraints(minHeight: 56),
                                    decoration: BoxDecoration(color: c.day == 0 ? null : t.paper, border: Border.all(color: c.day == 0 ? Colors.transparent : t.rule), borderRadius: BorderRadius.circular(3)),
                                    child: c.day == 0
                                        ? null
                                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Text('${c.day}', style: HrText.mono(11, t.mute)),
                                            if (c.letter != null) StatusChip(c.letter!, compact: true),
                                          ]),
                                  ),
                                ),
                              ),
                            ),
                        ]),
                      ),
                    const SizedBox(height: 6),
                    Text('Tap a day for details. P present, L late, A absent, E excused. When a day has several registers, the most notable mark shows.', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
                const SizedBox(height: 16),
                if (recent.isEmpty)
                  const InfoBanner('No attendance has been recorded this month.')
                else
                  HrList(children: [
                    for (final d in recent.take(5))
                      HrRow(
                        title: fmtDayWeekday(d),
                        sub: byDay[d]!.map((r) => r.note).whereType<String>().firstOrNull,
                        trailing: StatusChip(_worst(byDay[d]!.map((r) => statusLetter(r.status.toJson())))),
                      ),
                  ]),
              ]);
            },
          ),
      ],
    );
  }

  /// Monday-first weeks of weekdays only (weekends are not school days). `day == 0` is a blank cell.
  List<List<({int day, String? ymd, String? letter})>> _grid(String month, ({String from, String to, int days, int firstWeekday}) b, Map<String, String> letters) {
    final weeks = <List<({int day, String? ymd, String? letter})>>[];
    var week = <({int day, String? ymd, String? letter})>[];
    for (var i = 0; i < (b.firstWeekday - 1).clamp(0, 5); i++) {
      week.add((day: 0, ymd: null, letter: null));
    }
    for (var d = 1; d <= b.days; d++) {
      final dow = DateTime.utc(int.parse(month.substring(0, 4)), int.parse(month.substring(5, 7)), d).weekday;
      if (dow > 5) continue;
      final ymd = '$month-${d.toString().padLeft(2, '0')}';
      week.add((day: d, ymd: ymd, letter: letters[ymd]));
      if (week.length == 5) {
        weeks.add(week);
        week = [];
      }
    }
    if (week.isNotEmpty) {
      while (week.length < 5) {
        week.add((day: 0, ymd: null, letter: null));
      }
      weeks.add(week);
    }
    return weeks;
  }

  void _showDay(BuildContext context, String ymd, List<AttendanceRecord> records, String tz) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fmtLong(ymd), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final r in records) ...[
            Row(children: [StatusChip(statusLetter(r.status.toJson())), const SizedBox(width: 10), Text('Marked ${fmtTime(r.markedAt, tz)}', style: Theme.of(context).textTheme.bodySmall)]),
            if (r.note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.note!, style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    );
  }
}

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(currentChildProvider);
    final t = context.tokens;
    return HrScreen(
      big: true,
      eyebrow: 'This term',
      title: 'Grades',
      onRefresh: child == null ? null : () async => ref.refresh(gradesProvider(child.id).future),
      children: [
        const ChildChips(),
        if (child == null)
          const NoChildren()
        else
          AsyncBody<List<SubjectGrades>>(
            value: ref.watch(gradesProvider(child.id)),
            onRetry: () => ref.invalidate(gradesProvider(child.id)),
            isEmpty: (s) => s.isEmpty,
            emptyText: 'No grades posted yet.',
            data: (subjects) => Column(children: [
              for (final s in subjects) ...[
                HrCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    InkWell(
                      onTap: () => setState(() => _open = _open == s.subject ? '' : s.subject),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.subject, style: Theme.of(context).textTheme.titleLarge), const Eyebrow('Running grade')])),
                          Text(pct(s.runningGrade), style: HrText.mono(24, t.ink)),
                        ]),
                      ),
                    ),
                    if ((_open ?? subjects.first.subject) == s.subject)
                      Column(children: [
                        for (final a in s.assessments)
                          Container(
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: t.rule))),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text.rich(TextSpan(children: [TextSpan(text: a.title), TextSpan(text: '  ${a.weight}%', style: HrText.mono(11, t.mute))])),
                                if (a.comment != null) Text(a.comment!, style: Theme.of(context).textTheme.bodySmall),
                              ])),
                              Text(a.score == null ? 'Not yet scored' : '${a.score}/${a.maxScore}', style: HrText.mono(14, a.score == null ? t.mute : t.ink)),
                            ]),
                          ),
                      ]),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
            ]),
          ),
      ],
    );
  }
}
