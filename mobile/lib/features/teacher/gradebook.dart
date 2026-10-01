import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/failure.dart';
import '../../core/format.dart';
import '../../core/outbox.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'teacher_providers.dart';

/// Score entry one pupil at a time with a number pad (the full grid is on the web). Edits are kept locally and saved
/// as one batch per assessment, which is queued on the device when there is no connection.
class GradebookScreen extends ConsumerStatefulWidget {
  const GradebookScreen({super.key});

  @override
  ConsumerState<GradebookScreen> createState() => _GradebookState();
}

class _GradebookState extends ConsumerState<GradebookScreen> {
  String? _section;
  String? _subject;
  int _assessment = 0;
  int _student = 0;
  String _buffer = '';
  final Map<String, double?> _edits = {}; // "assessmentId|studentId" -> score (null clears)
  bool _saving = false;

  String _k(String a, String s) => '$a|$s';

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(meProvider)?.sections ?? const <ClassSection>[];
    if (sections.isEmpty) return const HrScreen(title: 'Gradebook', back: true, children: [InfoBanner('You are not assigned to any class this term.')]);
    final section = sections.firstWhere((s) => s.id == _section, orElse: () => sections.first);
    final subjects = teachingSubjects(section.subject);
    final subject = subjects.contains(_subject) ? _subject : subjects.firstOrNull;
    final key = (section: section.id, subject: subject);
    final book = ref.watch(gradebookProvider(key));
    final t = context.tokens;

    return HrScreen(
      title: 'Gradebook',
      eyebrow: '${section.name} · ${subject ?? ''}',
      back: true,
      action: TextButton(onPressed: () => context.push('/teacher/gradebook/new?section=${section.id}&subject=${Uri.encodeComponent(subject ?? '')}'), child: const Text('New')),
      onRefresh: () async => ref.refresh(gradebookProvider(key).future),
      children: [
        const OutboxBanner(),
        if (sections.length > 1 || subjects.length > 1)
          Row(children: [
            if (sections.length > 1)
              Expanded(child: DropdownButtonFormField<String>(initialValue: section.id, decoration: const InputDecoration(labelText: 'Class'), items: [for (final s in sections) DropdownMenuItem(value: s.id, child: Text(s.name))], onChanged: (v) => setState(() { _section = v; _assessment = 0; _student = 0; _buffer = ''; }))),
            if (sections.length > 1 && subjects.length > 1) const SizedBox(width: 12),
            if (subjects.length > 1)
              Expanded(child: DropdownButtonFormField<String>(initialValue: subject, decoration: const InputDecoration(labelText: 'Subject'), items: [for (final s in subjects) DropdownMenuItem(value: s, child: Text(s))], onChanged: (v) => setState(() { _subject = v; _assessment = 0; _buffer = ''; }))),
          ]),
        AsyncBody<Gradebook>(
          value: book,
          onRetry: () => ref.invalidate(gradebookProvider(key)),
          isEmpty: (b) => b.assessments.isEmpty || b.rows.isEmpty,
          emptyText: 'No assessments yet. Add one with New.',
          data: (b) {
            final a = b.assessments[_assessment.clamp(0, b.assessments.length - 1)];
            final rows = b.rows;
            final si = _student.clamp(0, rows.length - 1);
            final row = rows[si];
            double? scoreOf(GradebookRowsInner r) => _edits.containsKey(_k(a.id, r.student.id)) ? _edits[_k(a.id, r.student.id)] : r.scores[a.id]?.toDouble();
            final scores = [for (final r in rows) scoreOf(r)].whereType<double>().toList();
            final classAvg = scores.isEmpty ? null : scores.map((s) => 100 * s / a.maxScore).reduce((x, y) => x + y) / scores.length;
            final shown = _buffer.isNotEmpty ? _buffer : (scoreOf(row) == null ? '' : _fmt(scoreOf(row)!));
            final dirty = _edits.length;

            void commit() {
              if (_buffer.isNotEmpty) {
                final v = (double.tryParse(_buffer) ?? 0).clamp(0, a.maxScore).toDouble();
                _edits[_k(a.id, row.student.id)] = v;
              }
              _buffer = '';
              if (si < rows.length - 1) _student = si + 1;
            }

            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var i = 0; i < b.assessments.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(label: Text(b.assessments[i].title), selected: i == _assessment, onSelected: (_) => setState(() { _assessment = i; _student = 0; _buffer = ''; })),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Weight ${a.weight}% · out of ${a.maxScore}', style: HrText.mono(12, t.mute)),
                Text('Class avg ${pct(classAvg)}', style: HrText.mono(12, t.mute)),
              ]),
              const SizedBox(height: 12),
              HrCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Eyebrow('Student ${si + 1} of ${rows.length}'),
                    Row(children: [
                      IconButton(tooltip: 'Previous', onPressed: si == 0 ? null : () => setState(() { _student = si - 1; _buffer = ''; }), icon: const Icon(Icons.chevron_left)),
                      IconButton(tooltip: 'Next', onPressed: si == rows.length - 1 ? null : () => setState(() { _student = si + 1; _buffer = ''; }), icon: const Icon(Icons.chevron_right)),
                    ]),
                  ]),
                  Text(row.student.fullName, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: shown.isEmpty ? '--' : shown, style: HrText.mono(44, shown.isEmpty ? t.rule : t.ink)),
                    TextSpan(text: '  /${_fmt(a.maxScore.toDouble())}', style: HrText.mono(18, t.mute)),
                  ])),
                  const SizedBox(height: 12),
                  _Pad(
                    enabled: !b.termClosed,
                    onKey: (k) => setState(() {
                      if (k == 'del') {
                        if (_buffer.isNotEmpty) _buffer = _buffer.substring(0, _buffer.length - 1);
                      } else if (k == 'save') {
                        commit();
                      } else if (_buffer.length < 4) {
                        _buffer += k;
                      }
                    }),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              HrList(children: [
                for (var i = 0; i < rows.length; i++)
                  HrRow(
                    title: rows[i].student.fullName,
                    trailing: Text(scoreOf(rows[i]) == null ? '--' : _fmt(scoreOf(rows[i])!), style: HrText.mono(14, i == si ? t.accent : t.ink, w: i == si ? FontWeight.w700 : FontWeight.w500)),
                    onTap: () => setState(() { _student = i; _buffer = ''; }),
                  ),
              ]),
              const SizedBox(height: 16),
              WideButton(label: dirty == 0 ? 'No changes to save' : 'Save $dirty score${dirty == 1 ? '' : 's'}', busy: _saving, onPressed: b.termClosed || dirty == 0 ? null : () => _save(b)),
            ]);
          },
        ),
      ],
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _save(Gradebook b) async {
    setState(() => _saving = true);
    final byAssessment = <String, List<Map<String, dynamic>>>{};
    for (final e in _edits.entries) {
      final parts = e.key.split('|');
      byAssessment.putIfAbsent(parts[0], () => []).add({'student_id': parts[1], 'score': e.value});
    }
    var queued = false;
    final refused = <String>[];
    for (final entry in byAssessment.entries) {
      final a = b.assessments.firstWhere((x) => x.id == entry.key);
      final r = await ref.read(outboxProvider).submit(method: 'PATCH', path: '/assessments/${entry.key}/grades', body: {'grades': entry.value}, label: 'Scores for ${a.title}');
      switch (r.status) {
        case SubmitStatus.queued:
          queued = true;
        case SubmitStatus.rejected:
          refused.add('${a.title}: ${r.problem?.detail ?? r.problem?.title ?? 'not accepted'}');
        case SubmitStatus.sent:
          final results = ((r.body is Map ? (r.body as Map)['results'] : null) as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
          for (final x in results.where((x) => x['outcome'] == 'rejected')) {
            final name = b.rows.where((row) => row.student.id == x['student_id']).firstOrNull?.student.fullName ?? 'A student';
            refused.add('$name (${a.title}): ${x['message'] ?? 'not accepted'}');
          }
      }
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!queued && refused.isEmpty) _edits.clear();
    });
    if (refused.isNotEmpty) {
      showFailure(context, ProblemFailure(status: 422, code: 'not_accepted', title: 'Some scores were not accepted', detail: refused.join('; ')));
    } else {
      toast(context, queued ? 'Saved on this device. Will sync when you reconnect.' : 'Scores saved');
    }
    if (!queued) ref.invalidate(gradebookProvider((section: _section ?? b.classSectionId, subject: _subject)));
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onKey, required this.enabled});
  final void Function(String key) onKey;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'];
    return Column(children: [
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: [
          for (final k in keys)
            OutlinedButton(
              onPressed: enabled ? () => onKey(k) : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
              child: k == 'del' ? const Icon(Icons.backspace_outlined) : Text(k, style: HrText.mono(20, t.ink)),
            ),
        ],
      ),
      const SizedBox(height: 8),
      WideButton(label: 'Save and next', onPressed: enabled ? () => onKey('save') : null),
    ]);
  }
}

/// Add an assessment. The server refuses weights that would push a subject past 100%.
class NewAssessmentScreen extends ConsumerStatefulWidget {
  const NewAssessmentScreen({super.key, this.section, this.subject});
  final String? section;
  final String? subject;

  @override
  ConsumerState<NewAssessmentScreen> createState() => _NewAssessmentState();
}

class _NewAssessmentState extends ConsumerState<NewAssessmentScreen> {
  final _title = TextEditingController();
  final _weight = TextEditingController(text: '10');
  final _max = TextEditingController(text: '20');
  final _due = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _weight.dispose();
    _max.dispose();
    _due.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(meProvider)?.sections ?? const <ClassSection>[];
    final section = sections.where((s) => s.id == widget.section).firstOrNull ?? sections.firstOrNull;
    if (section == null) return const HrScreen(title: 'New assessment', back: true, children: [InfoBanner('You are not assigned to any class this term.')]);
    final subject = widget.subject != null && widget.subject!.isNotEmpty ? widget.subject! : (teachingSubjects(section.subject).firstOrNull ?? '');
    final book = ref.watch(gradebookProvider((section: section.id, subject: subject))).valueOrNull;
    final used = (book?.assessments ?? const <Assessment>[]).fold<double>(0, (s, a) => s + a.weight);
    final w = double.tryParse(_weight.text) ?? 0;
    final m = double.tryParse(_max.text) ?? 0;
    final valid = _title.text.trim().isNotEmpty && w > 0 && w <= 100 - used && m > 0;

    Future<void> submit() async {
      setState(() => _busy = true);
      try {
        await ref.read(gradebookApiProvider).createAssessment(section.id, AssessmentInput(subject: subject, title: _title.text.trim(), weight: w, maxScore: m, dueDate: _due.text.trim().isEmpty ? null : _due.text.trim()));
        ref.invalidate(gradebookProvider((section: section.id, subject: subject)));
        if (context.mounted) {
          toast(context, 'Assessment added');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) showFailure(context, e);
      }
      if (mounted) setState(() => _busy = false);
    }

    return HrScreen(
      title: 'New assessment',
      eyebrow: '${section.name} · $subject',
      back: true,
      footer: WideButton(label: 'Add assessment', busy: _busy, onPressed: valid ? submit : null),
      children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), onChanged: (_) => setState(() {})),
        Row(children: [
          Expanded(child: TextField(controller: _weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (%)'), onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _max, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Out of'), onChanged: (_) => setState(() {}))),
        ]),
        TextField(controller: _due, keyboardType: TextInputType.datetime, decoration: const InputDecoration(labelText: 'Due date (YYYY-MM-DD, optional)')),
        Text(
          '$subject weights total ${used.toStringAsFixed(used == used.roundToDouble() ? 0 : 1)}%. ${100 - used > 0 ? 'You can add up to ${(100 - used).toStringAsFixed(0)}% more.' : 'There is no weight left: lower another assessment first.'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: w > 100 - used ? context.tokens.alert : context.tokens.mute),
        ),
      ],
    );
  }
}
