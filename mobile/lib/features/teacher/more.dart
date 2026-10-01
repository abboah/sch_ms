import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/failure.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import '../common/notifications.dart';
import 'teacher_providers.dart';

class TeacherMore extends ConsumerWidget {
  const TeacherMore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    ref.watch(notificationsProvider);
    return HrScreen(big: true, title: 'More', children: [
      HrList(children: [
        HrRow(title: 'Gradebook', onTap: () => context.push('/teacher/gradebook')),
        HrRow(title: 'Homework', onTap: () => context.push('/teacher/homework')),
        HrRow(title: 'Conference schedule', onTap: () => context.push('/teacher/conferences')),
      ]),
      HrList(children: [
        HrRow(title: 'Notifications', trailing: unread > 0 ? TagChip('$unread new', tone: TagTone.alert) : null, onTap: () => context.push('/teacher/notifications')),
        HrRow(title: 'Profile and settings', onTap: () => context.push('/teacher/settings')),
      ]),
    ]);
  }
}

class TeacherHomeworkScreen extends ConsumerStatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  ConsumerState<TeacherHomeworkScreen> createState() => _TeacherHomeworkState();
}

class _TeacherHomeworkState extends ConsumerState<TeacherHomeworkScreen> {
  final _title = TextEditingController();
  final _due = TextEditingController();
  String? _section;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _due.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(meProvider)?.sections ?? const <ClassSection>[];
    if (sections.isEmpty) return const HrScreen(title: 'Homework', back: true, children: [InfoBanner('You are not assigned to any class this term.')]);
    final section = sections.firstWhere((s) => s.id == _section, orElse: () => sections.first);
    final list = ref.watch(classHomeworkProvider(section.id));

    Future<void> post() async {
      setState(() => _busy = true);
      try {
        await ref.read(homeworkApiProvider).postHomework(section.id, HomeworkInput(title: _title.text.trim(), dueDate: _due.text.trim()));
        _title.clear();
        ref.invalidate(classHomeworkProvider(section.id));
        if (context.mounted) toast(context, 'Posted to guardians');
      } catch (e) {
        if (context.mounted) showFailure(context, e);
      }
      if (mounted) setState(() => _busy = false);
    }

    final dueOk = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_due.text.trim());
    return HrScreen(
      title: 'Homework',
      back: true,
      onRefresh: () async => ref.refresh(classHomeworkProvider(section.id).future),
      children: [
        HrCard(
          child: Column(children: [
            if (sections.length > 1) ...[
              DropdownButtonFormField<String>(initialValue: section.id, decoration: const InputDecoration(labelText: 'Class'), items: [for (final s in sections) DropdownMenuItem(value: s.id, child: Text(s.name))], onChanged: (v) => setState(() => _section = v)),
              const SizedBox(height: 12),
            ],
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Task', hintText: 'Exercises 4.6 to 4.8'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            TextField(controller: _due, keyboardType: TextInputType.datetime, decoration: const InputDecoration(labelText: 'Due (YYYY-MM-DD)'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            WideButton(label: 'Post homework', busy: _busy, onPressed: _title.text.trim().isEmpty || !dueOk ? null : post),
          ]),
        ),
        AsyncBody<List<Homework>>(
          value: list,
          onRetry: () => ref.invalidate(classHomeworkProvider(section.id)),
          isEmpty: (l) => l.isEmpty,
          emptyText: 'No homework posted.',
          data: (items) => HrList(children: [for (final h in items) HrRow(title: h.title, sub: '${h.subject ?? 'Homeroom'} · due ${fmtDayWeekday(h.dueDate)}')]),
        ),
      ],
    );
  }
}

final _mySlotsProvider = FutureProvider.autoDispose<List<ConferenceSlot>>((ref) async {
  final r = await ref.watch(conferencesApiProvider).listConferenceSlots();
  return r?.items ?? (throw const UnknownFailure('The server returned no conference slots'));
});

class TeacherConferencesScreen extends ConsumerWidget {
  const TeacherConferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tz = ref.watch(meProvider)!.school.timezone;
    final slots = ref.watch(_mySlotsProvider);
    return HrScreen(
      title: 'Conferences',
      back: true,
      onRefresh: () async => ref.refresh(_mySlotsProvider.future),
      children: [
        AsyncBody<List<ConferenceSlot>>(
          value: slots,
          onRetry: () => ref.invalidate(_mySlotsProvider),
          isEmpty: (l) => l.isEmpty,
          emptyText: 'You have not opened any conference slots. Ask the office or use the web app to open them.',
          data: (all) {
            final byDay = <String, List<ConferenceSlot>>{};
            for (final s in all) {
              byDay.putIfAbsent(todayIn(tz, s.startsAt), () => []).add(s);
            }
            return Column(children: [
              for (final e in byDay.entries) ...[
                Align(alignment: Alignment.centerLeft, child: Eyebrow('${fmtDayWeekday(e.key)} · ${e.value.where((s) => s.booked).length} of ${e.value.length} booked')),
                const SizedBox(height: 8),
                HrList(children: [
                  for (final s in e.value)
                    HrRow(title: s.student?.fullName ?? (s.booked ? 'Booked' : 'Open'), sub: fmtTime(s.startsAt, tz), trailing: s.booked ? const TagChip('Booked', tone: TagTone.accent) : null),
                ]),
                const SizedBox(height: 16),
              ],
            ]);
          },
        ),
      ],
    );
  }
}
