import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'parent_providers.dart';

final _todayAttendanceProvider = FutureProvider.autoDispose.family<AttendanceRecord?, String>((ref, childId) async {
  final tz = ref.watch(meProvider)?.school.timezone ?? 'UTC';
  final today = todayIn(tz, ref.watch(appNowProvider)());
  final r = await ref.watch(attendanceApiProvider).getStudentAttendance(childId, from: today, to: today);
  final items = r?.items ?? const <AttendanceRecord>[];
  return items.isEmpty ? null : items.first;
});

class ParentHome extends ConsumerWidget {
  const ParentHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider)!;
    final child = ref.watch(currentChildProvider);
    final tz = me.school.timezone;
    final now = ref.watch(appNowProvider)();
    final first = me.fullName.split(' ').first;

    Future<void> refresh() async {
      if (child == null) return;
      ref.invalidate(invoicesProvider(child.id));
      ref.invalidate(gradesProvider(child.id));
      ref.invalidate(_todayAttendanceProvider(child.id));
      ref.invalidate(homeworkProvider(child.id));
      ref.invalidate(announcementsProvider);
    }

    return HrScreen(
      big: true,
      eyebrow: fmtLong(todayIn(tz, now)),
      title: '${greeting(tz, now)}, $first',
      onRefresh: refresh,
      children: [
        const ChildChips(),
        if (child == null) const NoChildren() else _Body(child: child),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.child});
  final StudentRef child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tz = ref.watch(meProvider)!.school.timezone;
    final invoices = ref.watch(invoicesProvider(child.id));
    final grades = ref.watch(gradesProvider(child.id));
    final today = ref.watch(_todayAttendanceProvider(child.id));
    final homework = ref.watch(homeworkProvider(child.id));
    final notice = ref.watch(announcementsProvider);
    final t = context.tokens;
    final now = ref.watch(appNowProvider)();
    final todayYmd = todayIn(tz, now);

    // The two main requests decide loading and failure for the whole screen.
    final loaded = allLoaded([invoices, grades]);
    if (!loaded.hasValue) {
      return AsyncBody<void>(value: loaded, data: (_) => const SizedBox.shrink(), onRetry: () {
        ref.invalidate(invoicesProvider(child.id));
        ref.invalidate(gradesProvider(child.id));
      });
    }

    final items = invoices.requireValue;
    final owed = items.fold<double>(0, (s, i) => s + (double.tryParse(i.outstanding) ?? 0));
    final overdue = items.where((i) => i.overdue).firstOrNull;
    final payable = items.where((i) => (double.tryParse(i.outstanding) ?? 0) > 0).firstOrNull;
    final scored = [
      for (final s in grades.requireValue)
        for (final a in s.assessments)
          if (a.score != null) (subject: s.subject, a: a),
    ]..sort((x, y) => (y.a.dueDate ?? '').compareTo(x.a.dueDate ?? ''));
    final latest = scored.firstOrNull;
    final record = today.valueOrNull;
    final hw = (homework.valueOrNull ?? const <Homework>[]).where((h) => h.dueDate.compareTo(todayYmd) >= 0).toList();
    final firstNotice = notice.valueOrNull?.firstOrNull;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (overdue != null) ...[
        InfoBanner("${child.fullName.split(' ').first}'s balance of ${money(overdue.outstanding)} was due on ${fmtDay(overdue.dueDate)}.", tone: BannerTone.alert),
        const SizedBox(height: 16),
      ],
      HrCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('Attendance today'),
          const SizedBox(height: 8),
          Row(children: [
            if (record != null) StatusChip(statusLetter(record.status.toJson())) else Text('Not marked yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.mute)),
            const SizedBox(width: 12),
            Text(record != null ? 'Marked ${fmtTime(record.markedAt, tz)}' : 'Registers open in the morning', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: StatTile(label: 'Latest grade', value: latest == null ? 'n/a' : '${(100 * (latest.a.score ?? 0) / latest.a.maxScore).round()}%', sub: latest == null ? 'No scores yet' : latest.a.title)),
        const SizedBox(width: 12),
        Expanded(child: StatTile(label: 'Homework due', value: '${hw.length.clamp(0, 9)}', sub: hw.isEmpty ? 'Nothing due' : '${hw.first.subject ?? 'Homeroom'}, ${fmtWeekday(hw.first.dueDate)}')),
      ]),
      const SizedBox(height: 16),
      HrCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('Balance owed'),
          Text(money(owed), style: HrText.mono(28, owed > 0 ? t.alert : t.forest)),
          Text(owed > 0 ? (overdue != null ? 'Overdue since ${fmtDay(overdue.dueDate)}' : 'Open invoices') : 'Paid in full', style: Theme.of(context).textTheme.bodySmall),
          if (payable != null) ...[
            const SizedBox(height: 12),
            WideButton(label: 'Pay ${money(payable.outstanding)}', onPressed: () => context.push('/parent/fees/pay/${payable.id}')),
          ],
        ]),
      ),
      if (firstNotice != null) ...[
        const SizedBox(height: 16),
        HrCard(
          onTap: () => context.push('/parent/announcements'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Eyebrow('Notice${firstNotice.publishedAt != null ? ' · ${fmtStamp(firstNotice.publishedAt!, tz)}' : ''}'),
            Text(firstNotice.title, style: Theme.of(context).textTheme.titleMedium),
            Text(firstNotice.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      ],
    ]);
  }
}
