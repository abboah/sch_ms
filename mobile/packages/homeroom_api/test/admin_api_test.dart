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


/// tests for AdminApi
void main() {
  // final instance = AdminApi();

  group('tests for AdminApi', () {
    // Create a class section
    //
    // Roles: admin.
    //
    //Future<ClassSection> createClassSection(ClassSectionInput classSectionInput) async
    test('test createClassSection', () async {
      // TODO
    });

    // Create a person (student, guardian, teacher, admin) and optionally invite them
    //
    // Roles: admin.
    //
    //Future<Person> createPerson(PersonInput personInput) async
    test('test createPerson', () async {
      // TODO
    });

    // Create a term
    //
    // Roles: admin.
    //
    //Future<Term> createTerm(TermInput termInput) async
    test('test createTerm', () async {
      // TODO
    });

    // Assign a student to a class section
    //
    // Roles: admin.
    //
    //Future<Enrollment> enrollStudent(EnrollStudentRequest enrollStudentRequest) async
    test('test enrollStudent', () async {
      // TODO
    });

    // Date-ranged attendance register export
    //
    // Roles: admin. Per-pupil counts over a date range. For a spreadsheet use the .csv variant.
    //
    //Future<AttendanceReport> getAttendanceReport(String id, String from, String to, { String classSectionId }) async
    test('test getAttendanceReport', () async {
      // TODO
    });

    // Attendance register export as a CSV file
    //
    // Roles: admin. The same report as a download: one row per pupil, formula-safe, with a Content-Disposition filename.
    //
    //Future<String> getAttendanceReportCsv(String id, String from, String to, { String classSectionId }) async
    test('test getAttendanceReportCsv', () async {
      // TODO
    });

    // Bulk-create students and enrol them in this section
    //
    // Roles: admin. Each row becomes a new student (there is no matching against existing people); build the array from a CSV client-side, one row per pupil.
    //
    //Future<ImportStudents201Response> importStudents(String id, ImportStudentsRequest importStudentsRequest) async
    test('test importStudents', () async {
      // TODO
    });

    // Link a guardian to a student
    //
    // Roles: admin. The link is many-to-many and is the join every guardian permission hangs off.
    //
    //Future linkGuardian(String id, LinkGuardianRequest linkGuardianRequest) async
    test('test linkGuardian', () async {
      // TODO
    });

    // Who read or changed which student record
    //
    // Roles: admin.
    //
    //Future<ListAuditLog200Response> listAuditLog({ String studentId, String actorId, String from, int limit, String cursor }) async
    test('test listAuditLog', () async {
      // TODO
    });

    // Staff and guardians directory
    //
    // Roles: admin. (Students are under /students.)
    //
    //Future<PersonPage> listPeople({ String role, String q, int limit, String cursor }) async
    test('test listPeople', () async {
      // TODO
    });

    // Replace the section's timetable
    //
    // Roles: admin.
    //
    //Future<GetTimetable200Response> setTimetable(String id, List<PeriodInput> periodInput) async
    test('test setTimetable', () async {
      // TODO
    });

    // Edit a section, e.g. change the homeroom teacher
    //
    // Roles: admin.
    //
    //Future<ClassSection> updateClassSection(String id, ClassSectionInput classSectionInput) async
    test('test updateClassSection', () async {
      // TODO
    });

    // Edit a term, or close it
    //
    // Roles: admin. `closed: true` locks teacher edits for every section in the term.
    //
    //Future<Term> updateTerm(String id, TermInput termInput) async
    test('test updateTerm', () async {
      // TODO
    });

    // Withdraw a student from a section
    //
    // Roles: admin. **Soft delete**: sets status to `withdrawn`; the row and its history stay for transcripts (the database has no DELETE policy).
    //
    //Future withdrawStudent(String id) async
    test('test withdrawStudent', () async {
      // TODO
    });

  });
}
