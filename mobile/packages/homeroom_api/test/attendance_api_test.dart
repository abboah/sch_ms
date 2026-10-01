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


/// tests for AttendanceApi
void main() {
  // final instance = AttendanceApi();

  group('tests for AttendanceApi', () {
    // Correct a single record
    //
    // Roles: teacher (taught, term open), admin (any term).
    //
    //Future<AttendanceRecord> correctAttendanceRecord(String id, CorrectAttendanceRecordRequest correctAttendanceRecordRequest) async
    test('test correctAttendanceRecord', () async {
      // TODO
    });

    // The register for one period and date
    //
    // Roles: teacher (taught), admin. Returns every enrolled student, with `status: null` where nothing is marked yet.
    //
    //Future<Register> getRegister(String id, String date, { String periodId }) async
    test('test getRegister', () async {
      // TODO
    });

    // A student's attendance history
    //
    // Roles: admin, teacher (own class), guardian (own child). Drives the month calendar.
    //
    //Future<GetStudentAttendance200Response> getStudentAttendance(String id, { String from, String to }) async
    test('test getStudentAttendance', () async {
      // TODO
    });

    // Mark a whole period at once (also the offline-sync endpoint)
    //
    // Roles: teacher (taught, term open), admin. Upserts on (student, section, period, date), so it is safe to replay. Each entry is validated independently and the response reports every outcome, so one bad row (for example a student no longer enrolled) does not lose the rest of a queued offline register. Conflict rule: **last write wins by `marked_at`**; an older queued write never overwrites a newer one. Triggers `attendance.marked` for each absent or late student (push, else SMS). 
    //
    //Future<BatchResult> submitRegister(String id, RegisterSubmission registerSubmission, { String idempotencyKey }) async
    test('test submitRegister', () async {
      // TODO
    });

  });
}
