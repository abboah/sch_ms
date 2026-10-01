//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EnrollStudentRequest {
  /// Returns a new [EnrollStudentRequest] instance.
  EnrollStudentRequest({
    required this.studentId,
    required this.classSectionId,
  });

  String studentId;

  String classSectionId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EnrollStudentRequest &&
    other.studentId == studentId &&
    other.classSectionId == classSectionId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (classSectionId.hashCode);

  @override
  String toString() => 'EnrollStudentRequest[studentId=$studentId, classSectionId=$classSectionId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'class_section_id'] = this.classSectionId;
    return json;
  }

  /// Returns a new [EnrollStudentRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EnrollStudentRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "EnrollStudentRequest[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "EnrollStudentRequest[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'class_section_id'), 'Required key "EnrollStudentRequest[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "EnrollStudentRequest[class_section_id]" has a null value in JSON.');
        return true;
      }());

      return EnrollStudentRequest(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
      );
    }
    return null;
  }

  static List<EnrollStudentRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EnrollStudentRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EnrollStudentRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EnrollStudentRequest> mapFromJson(dynamic json) {
    final map = <String, EnrollStudentRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EnrollStudentRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EnrollStudentRequest-objects as value to a dart map
  static Map<String, List<EnrollStudentRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EnrollStudentRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EnrollStudentRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'class_section_id',
  };
}

