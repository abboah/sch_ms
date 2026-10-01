import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'teacher_providers.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(meProvider)?.sections ?? const <ClassSection>[];
    return HrScreen(
      big: true,
      title: 'Classes',
      children: [
        if (sections.isEmpty) const InfoBanner('You are not assigned to any class this term.'),
        for (final s in sections) _ClassCard(section: s),
      ],
    );
  }
}

class _ClassCard extends ConsumerWidget {
  const _ClassCard({required this.section});
  final ClassSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(classDetailProvider(section.id)).valueOrNull;
    final t = context.tokens;
    return HrCard(
      onTap: () => context.push('/teacher/class/${section.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(section.name, style: Theme.of(context).textTheme.headlineSmall),
          Eyebrow(detail == null ? '' : '${detail.roster.length} students'),
        ]),
        Text(section.subject ?? '', style: Theme.of(context).textTheme.bodySmall),
        if (detail != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Attendance ${pct(detail.attendanceRatePct)}', style: HrText.mono(13, t.ink))),
      ]),
    );
  }
}

class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(classDetailProvider(id));
    final section = ref.watch(meProvider)?.sections.where((s) => s.id == id).firstOrNull;
    final subject = teachingSubjects(section?.subject).firstOrNull;
    final grades = ref.watch(gradebookProvider((section: id, subject: subject))).valueOrNull;
    final avg = {for (final r in grades?.rows ?? const <GradebookRowsInner>[]) r.student.id: r.runningGrade};
    return HrScreen(
      title: 'Section ${section?.name ?? detail.valueOrNull?.name ?? ''}',
      eyebrow: 'Class overview',
      back: true,
      onRefresh: () async => ref.refresh(classDetailProvider(id).future),
      children: [
        Row(children: [
          Expanded(child: FilledButton(onPressed: () => context.push('/teacher/gradebook'), child: const Text('Gradebook'))),
        ]),
        AsyncBody<ClassSectionDetail>(
          value: detail,
          onRetry: () => ref.invalidate(classDetailProvider(id)),
          isEmpty: (d) => d.roster.isEmpty,
          emptyText: 'No students are enrolled in this section.',
          data: (d) => HrList(children: [
            for (final s in d.roster)
              HrRow(
                title: s.fullName,
                sub: 'Attendance ${pct(s.attendanceRatePct)}',
                trailing: Text(pct(avg[s.id]), style: HrText.mono(14, context.tokens.ink, w: FontWeight.w600)),
              ),
          ]),
        ),
      ],
    );
  }
}
