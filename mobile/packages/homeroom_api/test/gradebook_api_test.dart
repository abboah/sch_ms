//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:homeroom_api/api.dart';
import 'package:test/test.dart';


/// tests for GradebookApi
void main() {
  // final instance = GradebookApi();

  group('tests for GradebookApi', () {
    // Create a gradebook column
    //
    // Roles: teacher (taught, term open).
    //
    //Future<Assessment> createAssessment(String id, AssessmentInput assessmentInput) async
    test('test createAssessment', () async {
      // TODO
    });

    // Add a band to the school's grading scale
    //
    // Roles: admin.
    //
    //Future<GradeBand> createGradeBand(CreateGradeBandRequest createGradeBandRequest) async
    test('test createGradeBand', () async {
      // TODO
    });

    // Remove a band
    //
    // Roles: admin. Nothing else references grade bands, so this is a hard delete.
    //
    //Future deleteGradeBand(String id) async
    test('test deleteGradeBand', () async {
      // TODO
    });

    // Whole gradebook in one call (students × assessments)
    //
    // Roles: teacher (taught), admin (view). Includes weights, scores and each student's running average.
    //
    //Future<Gradebook> getGradebook(String id, { String subject }) async
    test('test getGradebook', () async {
      // TODO
    });

    // A student's issued report comments
    //
    // Roles: admin (any time), guardian (own child, only once the term closes). Not every subject may have one yet.
    //
    //Future<GetReportComments200Response> getReportComments(String id) async
    test('test getReportComments', () async {
      // TODO
    });

    // A student's grades by subject
    //
    // Roles: admin (view), teacher (own class), guardian (own child).
    //
    //Future<GetStudentGrades200Response> getStudentGrades(String id, { String termId }) async
    test('test getStudentGrades', () async {
      // TODO
    });

    // A school's grading scale
    //
    // Roles: any. Ordered by min_score descending. A school with none configured returns an empty list, and running grades show as bare numbers.
    //
    //Future<ListGradeBands200Response> listGradeBands() async
    test('test listGradeBands', () async {
      // TODO
    });

    // Scores for one assessment
    //
    // Roles: teacher (taught), admin (view).
    //
    //Future<ListGrades200Response> listGrades(String id) async
    test('test listGrades', () async {
      // TODO
    });

    // One subject's drafted report comments, one per pupil
    //
    // Roles: teacher (taught), admin (view).
    //
    //Future<ReportCommentSheet> listReportComments(String id, String subject) async
    test('test listReportComments', () async {
      // TODO
    });

    // Edit an assessment's title, weight, max score or due date
    //
    // Roles: teacher (taught, term open).
    //
    //Future<Assessment> updateAssessment(String id, AssessmentInput assessmentInput) async
    test('test updateAssessment', () async {
      // TODO
    });

    // Edit a band
    //
    // Roles: admin.
    //
    //Future<GradeBand> updateGradeBand(String id, UpdateGradeBandRequest updateGradeBandRequest) async
    test('test updateGradeBand', () async {
      // TODO
    });

    // Batch upsert, one row per student
    //
    // Roles: teacher (taught, term open). Per-entry outcomes like the attendance PUT; a score above `max_score` is rejected for that entry.
    //
    //Future<BatchResult> upsertGrades(String id, UpsertGradesRequest upsertGradesRequest, { String idempotencyKey }) async
    test('test upsertGrades', () async {
      // TODO
    });

    // Batch save drafted comments, one row per pupil
    //
    // Roles: teacher (taught, term open). Not visible to guardians until the term closes.
    //
    //Future<BatchResult> upsertReportComments(String id, UpsertReportCommentsRequest upsertReportCommentsRequest, { String idempotencyKey }) async
    test('test upsertReportComments', () async {
      // TODO
    });

  });
}
