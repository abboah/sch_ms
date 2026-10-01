//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudentDetail {
  /// Returns a new [StudentDetail] instance.
  StudentDetail({
    required this.id,
    required this.fullName,
    this.classSection,
    this.gradeLevel,
    required this.attendanceRatePct,
    this.guardianNames = const [],
    this.guardians = const [],
    this.enrollments = const [],
  });

  String id;

  String fullName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StudentRefClassSection? classSection;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gradeLevel;

  num? attendanceRatePct;

  /// Admin lists only: primary contact first
  List<String> guardianNames;

  /// Admin (with contact details) and teachers of the student (names only)
  List<GuardianLink> guardians;

  /// Admin only
  List<Enrollment> enrollments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudentDetail &&
    other.id == id &&
    other.fullName == fullName &&
    other.classSection == classSection &&
    other.gradeLevel == gradeLevel &&
    other.attendanceRatePct == attendanceRatePct &&
    _deepEquality.equals(other.guardianNames, guardianNames) &&
    _deepEquality.equals(other.guardians, guardians) &&
    _deepEquality.equals(other.enrollments, enrollments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (fullName.hashCode) +
    (classSection == null ? 0 : classSection!.hashCode) +
    (gradeLevel == null ? 0 : gradeLevel!.hashCode) +
    (attendanceRatePct == null ? 0 : attendanceRatePct!.hashCode) +
    (guardianNames.hashCode) +
    (guardians.hashCode) +
    (enrollments.hashCode);

  @override
  String toString() => 'StudentDetail[id=$id, fullName=$fullName, classSection=$classSection, gradeLevel=$gradeLevel, attendanceRatePct=$attendanceRatePct, guardianNames=$guardianNames, guardians=$guardians, enrollments=$enrollments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'full_name'] = this.fullName;
    if (this.classSection != null) {
      json[r'class_section'] = this.classSection;
    } else {
      json[r'class_section'] = null;
    }
    if (this.gradeLevel != null) {
      json[r'grade_level'] = this.gradeLevel;
    } else {
      json[r'grade_level'] = null;
    }
    if (this.attendanceRatePct != null) {
      json[r'attendance_rate_pct'] = this.attendanceRatePct;
    } else {
      json[r'attendance_rate_pct'] = null;
    }
      json[r'guardian_names'] = this.guardianNames;
      json[r'guardians'] = this.guardians;
      json[r'enrollments'] = this.enrollments;
    return json;
  }

  /// Returns a new [StudentDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudentDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "StudentDetail[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "StudentDetail[id]" has a null value in JSON.');
        assert(json.containsKey(r'full_name'), 'Required key "StudentDetail[full_name]" is missing from JSON.');
        assert(json[r'full_name'] != null, 'Required key "StudentDetail[full_name]" has a null value in JSON.');
        assert(json.containsKey(r'attendance_rate_pct'), 'Required key "StudentDetail[attendance_rate_pct]" is missing from JSON.');
        return true;
      }());

      return StudentDetail(
        id: mapValueOfType<String>(json, r'id')!,
        fullName: mapValueOfType<String>(json, r'full_name')!,
        classSection: StudentRefClassSection.fromJson(json[r'class_section']),
        gradeLevel: mapValueOfType<String>(json, r'grade_level'),
        attendanceRatePct: json[r'attendance_rate_pct'] == null
            ? null
            : num.parse('${json[r'attendance_rate_pct']}'),
        guardianNames: json[r'guardian_names'] is Iterable
            ? (json[r'guardian_names'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        guardians: GuardianLink.listFromJson(json[r'guardians']),
        enrollments: Enrollment.listFromJson(json[r'enrollments']),
      );
    }
    return null;
  }

  static List<StudentDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudentDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudentDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudentDetail> mapFromJson(dynamic json) {
    final map = <String, StudentDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudentDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudentDetail-objects as value to a dart map
  static Map<String, List<StudentDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudentDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudentDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'full_name',
    'attendance_rate_pct',
  };
}

