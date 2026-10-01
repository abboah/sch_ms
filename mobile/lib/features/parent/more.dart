import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import '../common/notifications.dart';
import '../messages/messages.dart';
import 'parent_providers.dart';

class ParentMore extends ConsumerWidget {
  const ParentMore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    ref.watch(notificationsProvider); // keep the badge fresh
    return HrScreen(
      big: true,
      title: 'More',
      children: [
        HrList(children: [
          HrRow(title: 'Report cards', onTap: () => context.push('/parent/reports')),
          HrRow(title: 'Homework', onTap: () => context.push('/parent/homework')),
          HrRow(title: 'Messages', onTap: () => context.push('/parent/messages')),
          HrRow(title: 'Announcements', onTap: () => context.push('/parent/announcements')),
          HrRow(title: 'Book a conference', onTap: () => context.push('/parent/conference')),
        ]),
        HrList(children: [
          HrRow(title: 'Notifications', trailing: unread > 0 ? TagChip('$unread new', tone: TagTone.alert) : null, onTap: () => context.push('/parent/notifications')),
          HrRow(title: 'Profile and settings', onTap: () => context.push('/parent/settings')),
        ]),
      ],
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => const HrScreen(title: 'Report cards', back: true, children: [
        HrCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Eyebrow('Coming soon'),
            SizedBox(height: 6),
            Text('Downloadable report cards, with your child\'s teacher comments, will appear here when each term is issued. Until then, the Grades tab shows every score and running grade as it is posted.'),
            SizedBox(height: 10),
            TagChip('Not yet available'),
          ]),
        ),
      ]);
}

class ParentHomeworkScreen extends ConsumerWidget {
  const ParentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(currentChildProvider);
    return HrScreen(
      title: 'Homework',
      back: true,
      onRefresh: child == null ? null : () async => ref.refresh(homeworkProvider(child.id).future),
      children: [
        const ChildChips(),
        if (child == null)
          const NoChildren()
        else
          AsyncBody<List<Homework>>(
            value: ref.watch(homeworkProvider(child.id)),
            onRetry: () => ref.invalidate(homeworkProvider(child.id)),
            isEmpty: (l) => l.isEmpty,
            emptyText: 'No homework has been posted for ${child.fullName.split(' ').first} recently.',
            data: (list) => HrList(children: [
              for (final h in list)
                ExpansionTile(
                  title: Text('${h.subject ?? 'Homeroom'}: ${h.title}', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Due ${fmtDayWeekday(h.dueDate)}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (h.body != null) Text(h.body!, style: Theme.of(context).textTheme.bodyLarge),
                    if (h.postedBy != null) Text('Posted by ${h.postedBy!.fullName}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ]),
          ),
      ],
    );
  }
}

class ParentAnnouncementsScreen extends ConsumerWidget {
  const ParentAnnouncementsScreen({super.key});

  Future<void> _reply(BuildContext context, WidgetRef ref, Announcement a, StudentRef kid, bool yes) async {
    try {
      await ref.read(announcementsApiProvider).respondToAnnouncement(a.id, RespondToAnnouncementRequest(studentId: kid.id, response: yes ? RespondToAnnouncementRequestResponseEnum.yes : RespondToAnnouncementRequestResponseEnum.no));
      ref.invalidate(announcementsProvider);
      if (context.mounted) toast(context, 'Response sent');
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider)!;
    final kids = me.children;
    return HrScreen(
      title: 'Announcements',
      back: true,
      onRefresh: () async => ref.refresh(announcementsProvider.future),
      children: [
        AsyncBody<List<Announcement>>(
          value: ref.watch(announcementsProvider),
          onRetry: () => ref.invalidate(announcementsProvider),
          isEmpty: (l) => l.isEmpty,
          emptyText: 'No announcements.',
          data: (list) => Column(children: [
            for (final a in list) ...[
              HrCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (a.publishedAt != null) Eyebrow(fmtStamp(a.publishedAt!, me.school.timezone)),
                  Text(a.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(a.body, style: Theme.of(context).textTheme.bodyLarge),
                  if (a.requiresResponse)
                    for (final k in kids) ...[
                      const SizedBox(height: 12),
                      Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: context.tokens.rule))), padding: const EdgeInsets.only(top: 12), child: _Slip(a: a, kid: k, onReply: (yes) => _reply(context, ref, a, k, yes))),
                    ],
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

class _Slip extends StatelessWidget {
  const _Slip({required this.a, required this.kid, required this.onReply});
  final Announcement a;
  final StudentRef kid;
  final void Function(bool yes) onReply;

  @override
  Widget build(BuildContext context) {
    final mine = a.myResponses.where((r) => r.studentId == kid.id).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Eyebrow('Permission slip for ${kid.fullName}'),
      const SizedBox(height: 8),
      if (mine != null)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TagChip(mine.response == AnnouncementResponseResponseEnum.yes ? 'Permission given' : 'Declined', tone: mine.response == AnnouncementResponseResponseEnum.yes ? TagTone.forest : TagTone.alert),
          TextButton(onPressed: () => onReply(mine.response != AnnouncementResponseResponseEnum.yes), child: const Text('Change')),
        ])
      else
        Row(children: [
          Expanded(child: FilledButton(onPressed: () => onReply(true), child: const Text('Yes'))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(onPressed: () => onReply(false), child: const Text('No'))),
        ]),
    ]);
  }
}

final _slotsProvider = FutureProvider.autoDispose<List<ConferenceSlot>>((ref) async {
  final r = await ref.watch(conferencesApiProvider).listConferenceSlots();
  return r?.items ?? (throw StateError('The server returned no conference slots'));
});

class ConferenceScreen extends ConsumerStatefulWidget {
  const ConferenceScreen({super.key});

  @override
  ConsumerState<ConferenceScreen> createState() => _ConferenceScreenState();
}

class _ConferenceScreenState extends ConsumerState<ConferenceScreen> {
  String? _pick;
  bool _busy = false;

  Future<void> _book(StudentRef child) async {
    if (_pick == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(conferencesApiProvider).bookConferenceSlot(_pick!, BookConferenceSlotRequest(studentId: child.id));
      _pick = null;
      ref.invalidate(_slotsProvider);
      if (mounted) toast(context, 'Conference booked');
    } catch (e) {
      ref.invalidate(_slotsProvider);
      if (mounted) showFailure(context, e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _release(ConferenceSlot s) async {
    try {
      await ref.read(conferencesApiProvider).releaseConferenceSlot(s.id);
      ref.invalidate(_slotsProvider);
      if (mounted) toast(context, 'Booking cancelled');
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(currentChildProvider);
    final tz = ref.watch(meProvider)!.school.timezone;
    final t = context.tokens;
    final teachers = child?.classSection == null ? null : ref.watch(childTeachersProvider(child!.classSection!.id));
    final teacherIds = {for (final x in teachers?.valueOrNull ?? const <({String id, String name, String subjects})>[]) x.id};

    return HrScreen(
      title: 'Book a conference',
      eyebrow: child == null ? null : "${child.fullName.split(' ').first}'s teachers",
      back: true,
      onRefresh: () async => ref.refresh(_slotsProvider.future),
      footer: child == null ? null : WideButton(label: _pick == null ? 'Select a slot' : 'Book this slot', busy: _busy, onPressed: _pick == null ? null : () => _book(child)),
      children: [
        const ChildChips(),
        if (child == null)
          const NoChildren()
        else
          AsyncBody<List<ConferenceSlot>>(
            value: ref.watch(_slotsProvider),
            onRetry: () => ref.invalidate(_slotsProvider),
            data: (all) {
              final slots = all.where((s) => teacherIds.contains(s.teacher.id)).toList();
              if (slots.isEmpty) return const InfoBanner('No conference slots have been opened for your child\'s teachers yet.');
              final mine = slots.where((s) => s.bookedByMe && s.student?.id == child.id);
              final groups = <String, List<ConferenceSlot>>{};
              for (final s in slots) {
                groups.putIfAbsent('${s.teacher.id}|${s.startsAt.toUtc().toIso8601String().substring(0, 10)}', () => []).add(s);
              }
              String hhmm(DateTime d) => fmtTime(d, tz);
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (final b in mine) ...[
                  InfoBanner('You are booked with ${b.teacher.fullName} at ${hhmm(b.startsAt)}, ${fmtDayWeekday(b.startsAt.toUtc().toIso8601String().substring(0, 10))}. Choose another slot to move it.', tone: BannerTone.forest, action: TextButton(onPressed: () => _release(b), child: const Text('Cancel booking'))),
                  const SizedBox(height: 12),
                ],
                for (final g in groups.values) ...[
                  HrCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Eyebrow('${g.first.teacher.fullName} · ${fmtDayWeekday(g.first.startsAt.toUtc().toIso8601String().substring(0, 10))}'),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in g)
                          SizedBox(
                            width: 92,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), backgroundColor: s.bookedByMe ? t.accentSoft : (_pick == s.id ? t.accentSoft : null), side: BorderSide(color: s.bookedByMe || _pick == s.id ? t.accent : t.rule, width: _pick == s.id ? 2 : 1)),
                              onPressed: (s.booked && !s.bookedByMe) || s.bookedByMe ? null : () => setState(() => _pick = s.id),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [Text(hhmm(s.startsAt), style: HrText.mono(14, t.ink)), Text(s.bookedByMe ? 'Yours' : (s.booked ? 'Taken' : 'Open'), style: HrText.sans(11, t.mute))]),
                            ),
                          ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
              ]);
            },
          ),
      ],
    );
  }
}

/// Used by the messages tab's shared screens; re-exported so the router can reach one place per role.
