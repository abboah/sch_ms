import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';

/// Which child the parent is looking at. Defaults to the first until they choose.
class SelectedChild extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String id) => state = id;
}

final selectedChildIdProvider = NotifierProvider<SelectedChild, String?>(SelectedChild.new);

final currentChildProvider = Provider<StudentRef?>((ref) {
  final kids = ref.watch(meProvider)?.children ?? const <StudentRef>[];
  if (kids.isEmpty) return null;
  final id = ref.watch(selectedChildIdProvider);
  return kids.firstWhere((k) => k.id == id, orElse: () => kids.first);
});

T _need<T>(T? v, String what) => v ?? (throw StateError('The server returned no $what'));

final invoicesProvider = FutureProvider.autoDispose.family<List<Invoice>, String>((ref, childId) async {
  final r = await ref.watch(feesApiProvider).getStudentInvoices(childId);
  return _need(r, 'invoices').items;
});

final gradesProvider = FutureProvider.autoDispose.family<List<SubjectGrades>, String>((ref, childId) async {
  final r = await ref.watch(gradebookApiProvider).getStudentGrades(childId);
  return _need(r, 'grades').subjects;
});

/// Homework from two weeks ago onwards, so recent work stays visible after its due date.
final homeworkProvider = FutureProvider.autoDispose.family<List<Homework>, String>((ref, childId) async {
  final now = ref.watch(appNowProvider)();
  final tz = ref.watch(meProvider)?.school.timezone ?? 'UTC';
  final since = todayIn(tz, now.subtract(const Duration(days: 14)));
  final r = await ref.watch(homeworkApiProvider).getStudentHomework(childId, dueFrom: since);
  return _need(r, 'homework').items;
});

typedef MonthKey = ({String childId, String month});

final attendanceMonthProvider = FutureProvider.autoDispose.family<List<AttendanceRecord>, MonthKey>((ref, key) async {
  final b = monthBounds(key.month);
  final r = await ref.watch(attendanceApiProvider).getStudentAttendance(key.childId, from: b.from, to: b.to);
  return _need(r, 'attendance').items;
});

final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final r = await ref.watch(announcementsApiProvider).listAnnouncements(limit: 30);
  return _need(r, 'announcements').items;
});

String invoiceLabel(Invoice i) => i.overdue ? 'Overdue' : '${i.status.toJson()[0].toUpperCase()}${i.status.toJson().substring(1)}';

/// Tabs to switch between one's children. Hidden when there is only one.
class ChildChips extends ConsumerWidget {
  const ChildChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kids = ref.watch(meProvider)?.children ?? const <StudentRef>[];
    if (kids.length < 2) return const SizedBox.shrink();
    final current = ref.watch(currentChildProvider);
    final t = context.tokens;
    return Row(children: [
      for (final k in kids)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => ref.read(selectedChildIdProvider.notifier).select(k.id),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: current?.id == k.id ? t.accentSoft : t.raised,
                  border: Border.all(color: current?.id == k.id ? t.accent : t.rule),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(children: [
                  HrAvatar(k.fullName, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(k.fullName.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                      Text(k.classSection?.name ?? 'Not placed', style: HrText.mono(11, t.mute)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

class NoChildren extends StatelessWidget {
  const NoChildren({super.key});

  @override
  Widget build(BuildContext context) => const HrCard(
        child: Text('No child is linked to your account yet. Ask the school office to link your child, and they will appear here.'),
      );
}
