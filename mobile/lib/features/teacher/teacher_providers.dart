import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../../core/providers.dart';

T _need<T>(T? v, String what) => v ?? (throw StateError('The server returned no $what'));

/// The teacher's periods for a day (`null` = today at the school), with how much of each register is marked.
final todayProvider = FutureProvider.autoDispose.family<GetTeacherToday200Response, String?>((ref, date) async {
  return _need(await ref.watch(overviewApiProvider).getTeacherToday(date: date), 'schedule');
});

typedef RegisterKey = ({String section, String? period, String date});

final registerProvider = FutureProvider.autoDispose.family<Register, RegisterKey>((ref, k) async {
  return _need(await ref.watch(attendanceApiProvider).getRegister(k.section, k.date, periodId: k.period), 'register');
});

final classDetailProvider = FutureProvider.autoDispose.family<ClassSectionDetail, String>((ref, id) async {
  return _need(await ref.watch(classesApiProvider).getClassSection(id), 'class');
});

typedef GradebookKey = ({String section, String? subject});

final gradebookProvider = FutureProvider.autoDispose.family<Gradebook, GradebookKey>((ref, k) async {
  return _need(await ref.watch(gradebookApiProvider).getGradebook(k.section, subject: k.subject), 'gradebook');
});

final classHomeworkProvider = FutureProvider.autoDispose.family<List<Homework>, String>((ref, sectionId) async {
  return _need(await ref.watch(homeworkApiProvider).listHomework(sectionId), 'homework').items;
});

/// What a teacher teaches in a section, without the implicit "Homeroom" duty: ['Maths'].
List<String> teachingSubjects(String? subject) => (subject ?? '').split(', ').where((s) => s.isNotEmpty && s != 'Homeroom').toList();
