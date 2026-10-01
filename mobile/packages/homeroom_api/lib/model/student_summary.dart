//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudentSummary {
  /// Returns a new [StudentSummary] instance.
  StudentSummary({
    required this.studentId,
    required this.attendance,
    this.grades = const [],
    required this.balance,
    required this.pendingPayments,
  });

  String studentId;

  StudentSummaryAttendance attendance;

  List<StudentSummaryGradesInner> grades;

  /// Null for teachers
  String? balance;

  String? pendingPayments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudentSummary &&
    other.studentId == studentId &&
    other.attendance == attendance &&
    _deepEquality.equals(other.grades, grades) &&
    other.balance == balance &&
    other.pendingPayments == pendingPayments;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (attendance.hashCode) +
    (grades.hashCode) +
    (balance == null ? 0 : balance!.hashCode) +
    (pendingPayments == null ? 0 : pendingPayments!.hashCode);

  @override
  String toString() => 'StudentSummary[studentId=$studentId, attendance=$attendance, grades=$grades, balance=$balance, pendingPayments=$pendingPayments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'attendance'] = this.attendance;
      json[r'grades'] = this.grades;
    if (this.balance != null) {
      json[r'balance'] = this.balance;
    } else {
      json[r'balance'] = null;
    }
    if (this.pendingPayments != null) {
      json[r'pending_payments'] = this.pendingPayments;
    } else {
      json[r'pending_payments'] = null;
    }
    return json;
  }

  /// Returns a new [StudentSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudentSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "StudentSummary[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "StudentSummary[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'attendance'), 'Required key "StudentSummary[attendance]" is missing from JSON.');
        assert(json[r'attendance'] != null, 'Required key "StudentSummary[attendance]" has a null value in JSON.');
        assert(json.containsKey(r'grades'), 'Required key "StudentSummary[grades]" is missing from JSON.');
        assert(json[r'grades'] != null, 'Required key "StudentSummary[grades]" has a null value in JSON.');
        assert(json.containsKey(r'balance'), 'Required key "StudentSummary[balance]" is missing from JSON.');
        assert(json.containsKey(r'pending_payments'), 'Required key "StudentSummary[pending_payments]" is missing from JSON.');
        return true;
      }());

      return StudentSummary(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        attendance: StudentSummaryAttendance.fromJson(json[r'attendance'])!,
        grades: StudentSummaryGradesInner.listFromJson(json[r'grades']),
        balance: mapValueOfType<String>(json, r'balance'),
        pendingPayments: mapValueOfType<String>(json, r'pending_payments'),
      );
    }
    return null;
  }

  static List<StudentSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudentSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudentSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudentSummary> mapFromJson(dynamic json) {
    final map = <String, StudentSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudentSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudentSummary-objects as value to a dart map
  static Map<String, List<StudentSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudentSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudentSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'attendance',
    'grades',
    'balance',
    'pending_payments',
  };
}

