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


/// tests for StudentsApi
void main() {
  // final instance = StudentsApi();

  group('tests for StudentsApi', () {
    // Student profile
    //
    // Roles: admin, teacher (own class), guardian (own child). Guardians and enrollment history included for admin.
    //
    //Future<StudentDetail> getStudent(String id) async
    test('test getStudent', () async {
      // TODO
    });

    // The one call a portal home screen needs
    //
    // Roles: admin, teacher, guardian. Attendance rate, running grade per subject, balance. `balance` and `pending_payments` are null for teachers. **The read is written to the audit log.** 
    //
    //Future<StudentSummary> getStudentSummary(String id) async
    test('test getStudentSummary', () async {
      // TODO
    });

    // List students the caller may see
    //
    // Roles: admin (all), teacher (own sections), guardian (own children).
    //
    //Future<StudentPage> listStudents({ String q, String classSectionId, String gradeLevel, int limit, String cursor }) async
    test('test listStudents', () async {
      // TODO
    });

  });
}
