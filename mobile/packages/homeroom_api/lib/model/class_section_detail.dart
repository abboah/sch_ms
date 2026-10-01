//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ClassSectionDetail {
  /// Returns a new [ClassSectionDetail] instance.
  ClassSectionDetail({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.termId,
    this.homeroomTeacher,
    this.subject,
    this.teachers = const [],
    this.roster = const [],
    required this.attendanceRatePct,
  });

  String id;

  String name;

  String gradeLevel;

  String termId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Person? homeroomTeacher;

  /// Present on /me and /class_sections for a teacher: the subject they teach here
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subject;

  List<ClassSectionDetailAllOfTeachers> teachers;

  List<Student> roster;

  num? attendanceRatePct;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClassSectionDetail &&
    other.id == id &&
    other.name == name &&
    other.gradeLevel == gradeLevel &&
    other.termId == termId &&
    other.homeroomTeacher == homeroomTeacher &&
    other.subject == subject &&
    _deepEquality.equals(other.teachers, teachers) &&
    _deepEquality.equals(other.roster, roster) &&
    other.attendanceRatePct == attendanceRatePct;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (gradeLevel.hashCode) +
    (termId.hashCode) +
    (homeroomTeacher == null ? 0 : homeroomTeacher!.hashCode) +
    (subject == null ? 0 : subject!.hashCode) +
    (teachers.hashCode) +
    (roster.hashCode) +
    (attendanceRatePct == null ? 0 : attendanceRatePct!.hashCode);

  @override
  String toString() => 'ClassSectionDetail[id=$id, name=$name, gradeLevel=$gradeLevel, termId=$termId, homeroomTeacher=$homeroomTeacher, subject=$subject, teachers=$teachers, roster=$roster, attendanceRatePct=$attendanceRatePct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'grade_level'] = this.gradeLevel;
      json[r'term_id'] = this.termId;
    if (this.homeroomTeacher != null) {
      json[r'homeroom_teacher'] = this.homeroomTeacher;
    } else {
      json[r'homeroom_teacher'] = null;
    }
    if (this.subject != null) {
      json[r'subject'] = this.subject;
    } else {
      json[r'subject'] = null;
    }
      json[r'teachers'] = this.teachers;
      json[r'roster'] = this.roster;
    if (this.attendanceRatePct != null) {
      json[r'attendance_rate_pct'] = this.attendanceRatePct;
    } else {
      json[r'attendance_rate_pct'] = null;
    }
    return json;
  }

  /// Returns a new [ClassSectionDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClassSectionDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ClassSectionDetail[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ClassSectionDetail[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "ClassSectionDetail[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ClassSectionDetail[name]" has a null value in JSON.');
        assert(json.containsKey(r'grade_level'), 'Required key "ClassSectionDetail[grade_level]" is missing from JSON.');
        assert(json[r'grade_level'] != null, 'Required key "ClassSectionDetail[grade_level]" has a null value in JSON.');
        assert(json.containsKey(r'term_id'), 'Required key "ClassSectionDetail[term_id]" is missing from JSON.');
        assert(json[r'term_id'] != null, 'Required key "ClassSectionDetail[term_id]" has a null value in JSON.');
        assert(json.containsKey(r'teachers'), 'Required key "ClassSectionDetail[teachers]" is missing from JSON.');
        assert(json[r'teachers'] != null, 'Required key "ClassSectionDetail[teachers]" has a null value in JSON.');
        assert(json.containsKey(r'roster'), 'Required key "ClassSectionDetail[roster]" is missing from JSON.');
        assert(json[r'roster'] != null, 'Required key "ClassSectionDetail[roster]" has a null value in JSON.');
        assert(json.containsKey(r'attendance_rate_pct'), 'Required key "ClassSectionDetail[attendance_rate_pct]" is missing from JSON.');
        return true;
      }());

      return ClassSectionDetail(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        gradeLevel: mapValueOfType<String>(json, r'grade_level')!,
        termId: mapValueOfType<String>(json, r'term_id')!,
        homeroomTeacher: Person.fromJson(json[r'homeroom_teacher']),
        subject: mapValueOfType<String>(json, r'subject'),
        teachers: ClassSectionDetailAllOfTeachers.listFromJson(json[r'teachers']),
        roster: Student.listFromJson(json[r'roster']),
        attendanceRatePct: json[r'attendance_rate_pct'] == null
            ? null
            : num.parse('${json[r'attendance_rate_pct']}'),
      );
    }
    return null;
  }

  static List<ClassSectionDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClassSectionDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClassSectionDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClassSectionDetail> mapFromJson(dynamic json) {
    final map = <String, ClassSectionDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClassSectionDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClassSectionDetail-objects as value to a dart map
  static Map<String, List<ClassSectionDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClassSectionDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClassSectionDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'grade_level',
    'term_id',
    'teachers',
    'roster',
    'attendance_rate_pct',
  };
}

