
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/outbox.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'teacher_providers.dart';

class TeacherToday extends ConsumerWidget {
  const TeacherToday({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider)!;
    final tz = me.school.timezone;
    final now = ref.watch(appNowProvider)();
    final today = ref.watch(todayProvider(null));
    final first = me.fullName.split(' ').first;

    return HrScreen(
      big: true,
      eyebrow: fmtLong(todayIn(tz, now)),
      title: '${greeting(tz, now)}, $first',
      onRefresh: () async => ref.refresh(todayProvider(null).future),
      children: [
        const OutboxBanner(),
        AsyncBody<GetTeacherToday200Response>(
          value: today,
          onRetry: () => ref.invalidate(todayProvider(null)),
          isEmpty: (d) => d.periods.isEmpty,
          emptyText: 'No periods today.',
          data: (d) {
            final unmarked = d.periods.where((p) => p.register == TodayPeriodRegisterEnum.unmarked).toList();
            final next = d.periods.where((p) => p.register != TodayPeriodRegisterEnum.complete).firstOrNull;
            final t = context.tokens;
            String path(TodayPeriod p) => '/teacher/attendance/${p.classSection.id}/${p.period.id}/${d.date}';
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (next != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: t.alert.withValues(alpha: 0.10), border: Border.all(color: t.alert), borderRadius: BorderRadius.circular(3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(unmarked.isEmpty ? 'Finish your registers' : '${unmarked.length} register${unmarked.length == 1 ? '' : 's'} unmarked', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: t.alert)),
                    Text('Next: ${next.period.subject}, ${next.classSection.name}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    WideButton(label: 'Take attendance now', onPressed: () => context.push(path(next))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              HrList(children: [
                for (final p in d.periods)
                  HrRow(
                    title: '${p.period.subject} ${p.classSection.name}',
                    sub: '${p.period.startsAt} to ${p.period.endsAt} · ${p.marked} of ${p.enrolled} marked',
                    trailing: switch (p.register) {
                      TodayPeriodRegisterEnum.complete => const TagChip('Marked', tone: TagTone.forest),
                      TodayPeriodRegisterEnum.partial => const TagChip('Partly', tone: TagTone.brass),
                      _ => const TagChip('Unmarked', tone: TagTone.alert),
                    },
                    onTap: () => context.push(path(p)),
                  ),
              ]),
            ]);
          },
        ),
      ],
    );
  }
}

/// The register: one tap per pupil, saved on the device first if there is no connection.
class TakeAttendanceScreen extends ConsumerStatefulWidget {
  const TakeAttendanceScreen({super.key, required this.section, required this.period, required this.date});
  final String section;
  final String period;
  final String date;

  @override
  ConsumerState<TakeAttendanceScreen> createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends ConsumerState<TakeAttendanceScreen> {
  final Map<String, String> _marks = {}; // studentId -> letter: edits not yet confirmed saved
  ({BannerTone tone, String text})? _note;
  bool _saving = false;

  RegisterKey get _key => (section: widget.section, period: widget.period, date: widget.date);

  String? _current(RegisterEntriesInner e) => _marks[e.student.id] ?? (e.status == null ? null : statusLetter(e.status!.toJson()));

  Future<void> _save(List<RegisterEntriesInner> entries) async {
    final tz = ref.read(meProvider)!.school.timezone;
    final now = ref.read(appNowProvider)();
    setState(() {
      _saving = true;
      _note = null;
    });
    final body = {
      'date': widget.date,
      'period_id': widget.period,
      'entries': [for (final m in _marks.entries) {'student_id': m.key, 'status': statusWord(m.value), 'marked_at': DateTime.now().toUtc().toIso8601String()}],
    };
    final label = 'Register for ${ref.read(todayProvider(null)).valueOrNull?.periods.where((p) => p.period.id == widget.period).firstOrNull?.classSection.name ?? 'your class'}';
    final r = await ref.read(outboxProvider).submit(method: 'PUT', path: '/class_sections/${widget.section}/attendance', body: body, label: label);
    if (!mounted) return;
    setState(() => _saving = false);
    final at = fmtTime(now, tz);
    switch (r.status) {
      case SubmitStatus.queued:
        setState(() => _note = (tone: BannerTone.brass, text: 'Saved on this device at $at. It will sync when you reconnect.'));
      case SubmitStatus.rejected:
        setState(() => _note = (tone: BannerTone.alert, text: r.problem?.detail ?? r.problem?.title ?? 'The register could not be saved.'));
      case SubmitStatus.sent:
        final results = ((r.body is Map ? (r.body as Map)['results'] : null) as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
        final refused = results.where((x) => x['outcome'] == 'rejected').toList();
        String nameOf(String id) => entries.where((e) => e.student.id == id).firstOrNull?.student.fullName ?? 'A student';
        setState(() {
          _note = refused.isEmpty
              ? (tone: BannerTone.forest, text: 'Register saved at $at.')
              : (tone: BannerTone.alert, text: 'Saved at $at, except: ${refused.map((x) => '${nameOf(x['student_id'] as String)} (${x['message'] ?? 'not accepted'})').join('; ')}.');
          _marks.clear();
        });
        ref.invalidate(registerProvider(_key));
        ref.invalidate(todayProvider(null));
        toast(context, 'Register saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final register = ref.watch(registerProvider(_key));
    final info = ref.watch(todayProvider(widget.date)).valueOrNull?.periods.where((p) => p.period.id == widget.period).firstOrNull;
    final t = context.tokens;
    final entries = register.valueOrNull?.entries ?? const <RegisterEntriesInner>[];
    final marked = entries.where((e) => _current(e) != null).length;
    final locked = register.valueOrNull?.termClosed ?? false;
    final dirty = _marks.length;

    return HrScreen(
      title: info == null ? 'Attendance' : '${info.period.subject} ${info.classSection.name}',
      eyebrow: info == null ? null : '${info.period.startsAt} to ${info.period.endsAt}',
      back: true,
      onRefresh: () async => ref.refresh(registerProvider(_key).future),
      footer: entries.isEmpty
          ? null
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Text('$marked/${entries.length}', style: HrText.mono(14, t.ink)),
                const SizedBox(width: 12),
                Expanded(child: LinearProgressIndicator(value: entries.isEmpty ? 0 : marked / entries.length, minHeight: 8, borderRadius: BorderRadius.circular(4))),
              ]),
              const SizedBox(height: 10),
              WideButton(
                label: dirty == 0 ? (marked == entries.length ? 'Everyone is marked' : 'Mark students to save') : 'Save register ($dirty change${dirty == 1 ? '' : 's'})',
                busy: _saving,
                onPressed: locked || dirty == 0 ? null : () => _save(entries),
              ),
            ]),
      children: [
        const OutboxBanner(),
        if (locked) const InfoBanner('This term is closed. This register is read-only.'),
        if (_note != null) InfoBanner(_note!.text, tone: _note!.tone),
        AsyncBody<Register>(
          value: register,
          onRetry: () => ref.invalidate(registerProvider(_key)),
          isEmpty: (r) => r.entries.isEmpty,
          emptyText: 'No students are enrolled in this section.',
          data: (r) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            OutlinedButton(
              onPressed: locked ? null : () => setState(() {
                    for (final e in r.entries) {
                      if (_current(e) == null) _marks[e.student.id] = 'P';
                    }
                    _note = null;
                  }),
              child: const Text('Mark the rest present'),
            ),
            const SizedBox(height: 12),
            HrList(children: [
              for (var i = 0; i < r.entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    SizedBox(width: 22, child: Text('${i + 1}', style: HrText.mono(11, t.mute))),
                    Expanded(child: Text(r.entries[i].student.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium)),
                    for (final k in const ['P', 'L', 'A', 'E'])
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: _Mark(
                          letter: k,
                          on: _current(r.entries[i]) == k,
                          enabled: !locked,
                          onTap: () => setState(() {
                            _marks[r.entries[i].student.id] = k;
                            _note = null;
                          }),
                        ),
                      ),
                  ]),
                ),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.letter, required this.on, required this.enabled, required this.onTap});
  final String letter;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = StatusChip.colorFor(t, letter);
    return Semantics(
      button: true,
      selected: on,
      label: statusLabel(letter),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: on ? c : null, border: Border.all(color: on ? c : t.rule), borderRadius: BorderRadius.circular(3)),
          child: Text(letter, style: HrText.mono(14, on ? t.onAccent : t.mute, w: FontWeight.w600)),
        ),
      ),
    );
  }
}


