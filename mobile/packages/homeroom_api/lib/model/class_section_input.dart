//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ClassSectionInput {
  /// Returns a new [ClassSectionInput] instance.
  ClassSectionInput({
    this.name,
    this.gradeLevel,
    this.termId,
    this.homeroomTeacherId,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gradeLevel;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? termId;

  String? homeroomTeacherId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClassSectionInput &&
    other.name == name &&
    other.gradeLevel == gradeLevel &&
    other.termId == termId &&
    other.homeroomTeacherId == homeroomTeacherId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (gradeLevel == null ? 0 : gradeLevel!.hashCode) +
    (termId == null ? 0 : termId!.hashCode) +
    (homeroomTeacherId == null ? 0 : homeroomTeacherId!.hashCode);

  @override
  String toString() => 'ClassSectionInput[name=$name, gradeLevel=$gradeLevel, termId=$termId, homeroomTeacherId=$homeroomTeacherId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.gradeLevel != null) {
      json[r'grade_level'] = this.gradeLevel;
    } else {
      json[r'grade_level'] = null;
    }
    if (this.termId != null) {
      json[r'term_id'] = this.termId;
    } else {
      json[r'term_id'] = null;
    }
    if (this.homeroomTeacherId != null) {
      json[r'homeroom_teacher_id'] = this.homeroomTeacherId;
    } else {
      json[r'homeroom_teacher_id'] = null;
    }
    return json;
  }

  /// Returns a new [ClassSectionInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClassSectionInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ClassSectionInput(
        name: mapValueOfType<String>(json, r'name'),
        gradeLevel: mapValueOfType<String>(json, r'grade_level'),
        termId: mapValueOfType<String>(json, r'term_id'),
        homeroomTeacherId: mapValueOfType<String>(json, r'homeroom_teacher_id'),
      );
    }
    return null;
  }

  static List<ClassSectionInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClassSectionInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClassSectionInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClassSectionInput> mapFromJson(dynamic json) {
    final map = <String, ClassSectionInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClassSectionInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClassSectionInput-objects as value to a dart map
  static Map<String, List<ClassSectionInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClassSectionInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClassSectionInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

