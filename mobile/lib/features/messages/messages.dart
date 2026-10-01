import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';
import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import '../parent/parent_providers.dart';

/// Threads, optionally for one child. Polled lightly so new messages appear without a manual refresh.
final threadsProvider = FutureProvider.autoDispose.family<List<Thread>, String?>((ref, studentId) async {
  final timer = Timer(const Duration(seconds: 20), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  final r = await ref.watch(messagingApiProvider).listThreads(studentId: studentId);
  return r?.items ?? (throw StateError('The server returned no threads'));
});

final messagesProvider = FutureProvider.autoDispose.family<List<Message>, String>((ref, threadId) async {
  final timer = Timer(const Duration(seconds: 15), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  final r = await ref.watch(messagingApiProvider).listMessages(threadId, limit: 200);
  return r?.items ?? (throw StateError('The server returned no messages'));
});

/// The teachers of a child's class: the people a parent can start a conversation with.
final childTeachersProvider = FutureProvider.autoDispose.family<List<({String id, String name, String subjects})>, String>((ref, sectionId) async {
  final d = await ref.watch(classesApiProvider).getClassSection(sectionId);
  final seen = <String, ({String id, String name, List<String> subjects})>{};
  for (final t in d?.teachers ?? const <ClassSectionDetailAllOfTeachers>[]) {
    final cur = seen[t.person.id] ?? (id: t.person.id, name: t.person.fullName, subjects: <String>[]);
    cur.subjects.add(t.subject == 'Homeroom' ? 'Homeroom' : t.subject);
    seen[t.person.id] = cur;
  }
  return [for (final e in seen.values) (id: e.id, name: e.name, subjects: e.subjects.join(', '))];
});

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key, required this.base});

  /// '/parent' or '/teacher'
  final String base;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider)!;
    final isParent = me.role == Role.guardian;
    final child = isParent ? ref.watch(currentChildProvider) : null;
    final key = child?.id;
    final threads = ref.watch(threadsProvider(key));

    return HrScreen(
      big: true,
      title: 'Messages',
      onRefresh: () async => ref.refresh(threadsProvider(key).future),
      children: [
        if (isParent) const ChildChips(),
        if (isParent && child == null) const NoChildren(),
        if (isParent && child?.classSection != null) _ParentCompose(child: child!),
        if (!isParent) const _TeacherCompose(),
        if (!isParent || child != null)
          AsyncBody<List<Thread>>(
            value: threads,
            onRetry: () => ref.invalidate(threadsProvider(key)),
            isEmpty: (l) => l.isEmpty,
            emptyText: 'No conversations yet.',
            data: (list) => HrList(children: [
              for (final t in list)
                HrRow(
                  title: '${t.student.fullName} · ${t.student.classSection?.name ?? ''}',
                  sub: '${isParent ? t.teacher.fullName : t.guardian.fullName}: ${t.lastMessage?.body ?? 'No messages yet'}',
                  trailing: t.unread > 0 ? Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(10)), child: Text('${t.unread}', style: HrText.mono(11, Colors.white))) : null,
                  onTap: () => context.push('$base/messages/${t.id}'),
                ),
            ]),
          ),
      ],
    );
  }
}

class _ParentCompose extends ConsumerWidget {
  const _ParentCompose({required this.child});
  final StudentRef child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachers = ref.watch(childTeachersProvider(child.classSection!.id));
    return teachers.maybeWhen(
      data: (list) => list.isEmpty
          ? const SizedBox.shrink()
          : HrCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Eyebrow('Message a teacher · about ${child.fullName.split(' ').first}'),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in list)
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          final thread = await ref.read(messagingApiProvider).openThread(OpenThreadRequest(studentId: child.id, otherPartyId: t.id));
                          ref.invalidate(threadsProvider(child.id));
                          if (thread != null && context.mounted) context.push('/parent/messages/${thread.id}');
                        } catch (e) {
                          if (context.mounted) showFailure(context, e);
                        }
                      },
                      child: Text('${t.name} (${t.subjects})'),
                    ),
                ]),
              ]),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// A teacher picks a class, a pupil, then a guardian of that pupil.
class _TeacherCompose extends ConsumerStatefulWidget {
  const _TeacherCompose();

  @override
  ConsumerState<_TeacherCompose> createState() => _TeacherComposeState();
}

class _TeacherComposeState extends ConsumerState<_TeacherCompose> {
  String? _section;
  String? _student;

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(meProvider)?.sections ?? const <ClassSection>[];
    if (sections.isEmpty) return const SizedBox.shrink();
    final section = _section ?? sections.first.id;
    final roster = ref.watch(_rosterProvider(section));
    final student = _student == null ? null : ref.watch(_studentProvider(_student!));
    return HrCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text('New conversation', style: Theme.of(context).textTheme.titleMedium),
        subtitle: const Text('About one pupil'),
        children: [
          DropdownButtonFormField<String>(
            initialValue: section,
            decoration: const InputDecoration(labelText: 'Class'),
            items: [for (final s in sections) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (v) => setState(() {
              _section = v;
              _student = null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _student,
            decoration: const InputDecoration(labelText: 'Pupil'),
            items: [for (final s in roster.valueOrNull ?? const <Student>[]) DropdownMenuItem(value: s.id, child: Text(s.fullName))],
            onChanged: (v) => setState(() => _student = v),
          ),
          if (student != null) ...[
            const SizedBox(height: 12),
            student.when(
              loading: () => const Text('Loading guardians…'),
              error: (e, _) => const Text('Could not load the guardians.'),
              data: (d) => (d?.guardians ?? const <GuardianLink>[]).isEmpty
                  ? const Text('No guardian is linked to this pupil yet. Ask the office.')
                  : Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final g in d!.guardians)
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              final t = await ref.read(messagingApiProvider).openThread(OpenThreadRequest(studentId: d.id, otherPartyId: g.guardian.id));
                              ref.invalidate(threadsProvider(null));
                              if (t != null && context.mounted) context.push('/teacher/messages/${t.id}');
                            } catch (e) {
                              if (context.mounted) showFailure(context, e);
                            }
                          },
                          child: Text('${g.guardian.fullName} (${g.relationship})'),
                        ),
                    ]),
            ),
          ],
        ],
      ),
    );
  }
}

final _rosterProvider = FutureProvider.autoDispose.family<List<Student>, String>((ref, sectionId) async {
  final r = await ref.watch(studentsApiProvider).listStudents(classSectionId: sectionId, limit: 100);
  return r?.items ?? const [];
});

final _studentProvider = FutureProvider.autoDispose.family<StudentDetail?, String>((ref, id) => ref.watch(studentsApiProvider).getStudent(id));

class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({super.key, required this.threadId, required this.base});
  final String threadId;
  final String base;

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  final _text = TextEditingController();
  String? _key; // same key on a retry, so a message cannot be delivered twice
  bool _sending = false;
  bool _markedFor = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    _key ??= const Uuid().v4();
    try {
      await ref.read(messagingApiProvider).sendMessage(widget.threadId, SendMessageRequest(body: body), idempotencyKey: _key);
      _key = null;
      _text.clear();
      ref.invalidate(messagesProvider(widget.threadId));
      ref.invalidate(threadsProvider(null));
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _markRead() async {
    if (_markedFor) return;
    _markedFor = true;
    try {
      await ref.read(messagingApiProvider).markThreadRead(widget.threadId);
      ref.invalidate(threadsProvider(null));
    } catch (_) {
      _markedFor = false; // try again on the next refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider)!;
    final tz = me.school.timezone;
    final messages = ref.watch(messagesProvider(widget.threadId));
    final threads = ref.watch(threadsProvider(null));
    final thread = threads.valueOrNull?.where((t) => t.id == widget.threadId).firstOrNull;
    final t = context.tokens;
    if (messages.hasValue && (thread?.unread ?? 0) > 0) WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());

    return HrScreen(
      title: thread?.student.fullName ?? 'Conversation',
      eyebrow: thread == null ? null : '${thread.student.classSection?.name ?? ''} · about this student',
      back: true,
      onRefresh: () async => ref.refresh(messagesProvider(widget.threadId).future),
      footer: Row(children: [
        Expanded(child: TextField(controller: _text, minLines: 1, maxLines: 4, textInputAction: TextInputAction.send, decoration: const InputDecoration(hintText: 'Message'), onSubmitted: (_) => _send())),
        const SizedBox(width: 8),
        FilledButton(onPressed: _sending ? null : _send, child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send')),
      ]),
      children: [
        AsyncBody<List<Message>>(
          value: messages,
          onRetry: () => ref.invalidate(messagesProvider(widget.threadId)),
          isEmpty: (l) => l.isEmpty,
          emptyText: 'No messages yet. Say hello.',
          data: (list) => Column(children: [
            for (final m in list)
              Align(
                alignment: m.senderId == me.id ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: m.senderId == me.id ? t.accentSoft : t.raised, border: Border.all(color: m.senderId == me.id ? t.accent : t.rule), borderRadius: BorderRadius.circular(3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${m.senderId == thread?.teacher.id ? thread?.teacher.fullName : thread?.guardian.fullName} · ${fmtStamp(m.createdAt, tz)}'.toUpperCase(), style: HrText.mono(10, t.mute, spacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(m.body, style: Theme.of(context).textTheme.bodyLarge),
                  ]),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}
