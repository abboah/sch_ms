//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ClassSectionDetailAllOfTeachers {
  /// Returns a new [ClassSectionDetailAllOfTeachers] instance.
  ClassSectionDetailAllOfTeachers({
    required this.person,
    required this.subject,
  });

  Person person;

  String subject;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ClassSectionDetailAllOfTeachers &&
    other.person == person &&
    other.subject == subject;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (person.hashCode) +
    (subject.hashCode);

  @override
  String toString() => 'ClassSectionDetailAllOfTeachers[person=$person, subject=$subject]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'person'] = this.person;
      json[r'subject'] = this.subject;
    return json;
  }

  /// Returns a new [ClassSectionDetailAllOfTeachers] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ClassSectionDetailAllOfTeachers? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'person'), 'Required key "ClassSectionDetailAllOfTeachers[person]" is missing from JSON.');
        assert(json[r'person'] != null, 'Required key "ClassSectionDetailAllOfTeachers[person]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "ClassSectionDetailAllOfTeachers[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "ClassSectionDetailAllOfTeachers[subject]" has a null value in JSON.');
        return true;
      }());

      return ClassSectionDetailAllOfTeachers(
        person: Person.fromJson(json[r'person'])!,
        subject: mapValueOfType<String>(json, r'subject')!,
      );
    }
    return null;
  }

  static List<ClassSectionDetailAllOfTeachers> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ClassSectionDetailAllOfTeachers>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ClassSectionDetailAllOfTeachers.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ClassSectionDetailAllOfTeachers> mapFromJson(dynamic json) {
    final map = <String, ClassSectionDetailAllOfTeachers>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ClassSectionDetailAllOfTeachers.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ClassSectionDetailAllOfTeachers-objects as value to a dart map
  static Map<String, List<ClassSectionDetailAllOfTeachers>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ClassSectionDetailAllOfTeachers>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ClassSectionDetailAllOfTeachers.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'person',
    'subject',
  };
}

