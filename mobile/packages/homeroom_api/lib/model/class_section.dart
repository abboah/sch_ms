//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ClassSection {
  /// Returns a new [ClassSection] instance.
  ClassSection({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.termId,
    this.homeroomTeacher,
    this.subject,
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

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClassSection &&
    other.id == id &&
    other.name == name &&
    other.gradeLevel == gradeLevel &&
    other.termId == termId &&
    other.homeroomTeacher == homeroomTeacher &&
    other.subject == subject;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (gradeLevel.hashCode) +
    (termId.hashCode) +
    (homeroomTeacher == null ? 0 : homeroomTeacher!.hashCode) +
    (subject == null ? 0 : subject!.hashCode);

  @override
  String toString() => 'ClassSection[id=$id, name=$name, gradeLevel=$gradeLevel, termId=$termId, homeroomTeacher=$homeroomTeacher, subject=$subject]';

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
    return json;
  }

  /// Returns a new [ClassSection] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClassSection? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ClassSection[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ClassSection[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "ClassSection[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ClassSection[name]" has a null value in JSON.');
        assert(json.containsKey(r'grade_level'), 'Required key "ClassSection[grade_level]" is missing from JSON.');
        assert(json[r'grade_level'] != null, 'Required key "ClassSection[grade_level]" has a null value in JSON.');
        assert(json.containsKey(r'term_id'), 'Required key "ClassSection[term_id]" is missing from JSON.');
        assert(json[r'term_id'] != null, 'Required key "ClassSection[term_id]" has a null value in JSON.');
        return true;
      }());

      return ClassSection(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        gradeLevel: mapValueOfType<String>(json, r'grade_level')!,
        termId: mapValueOfType<String>(json, r'term_id')!,
        homeroomTeacher: Person.fromJson(json[r'homeroom_teacher']),
        subject: mapValueOfType<String>(json, r'subject'),
      );
    }
    return null;
  }

  static List<ClassSection> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClassSection>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClassSection.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClassSection> mapFromJson(dynamic json) {
    final map = <String, ClassSection>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClassSection.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClassSection-objects as value to a dart map
  static Map<String, List<ClassSection>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClassSection>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClassSection.listFromJson(entry.value, growable: growable,);
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
  };
}

