//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudentRef {
  /// Returns a new [StudentRef] instance.
  StudentRef({
    required this.id,
    required this.fullName,
    this.classSection,
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

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudentRef &&
    other.id == id &&
    other.fullName == fullName &&
    other.classSection == classSection;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (fullName.hashCode) +
    (classSection == null ? 0 : classSection!.hashCode);

  @override
  String toString() => 'StudentRef[id=$id, fullName=$fullName, classSection=$classSection]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'full_name'] = this.fullName;
    if (this.classSection != null) {
      json[r'class_section'] = this.classSection;
    } else {
      json[r'class_section'] = null;
    }
    return json;
  }

  /// Returns a new [StudentRef] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudentRef? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "StudentRef[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "StudentRef[id]" has a null value in JSON.');
        assert(json.containsKey(r'full_name'), 'Required key "StudentRef[full_name]" is missing from JSON.');
        assert(json[r'full_name'] != null, 'Required key "StudentRef[full_name]" has a null value in JSON.');
        return true;
      }());

      return StudentRef(
        id: mapValueOfType<String>(json, r'id')!,
        fullName: mapValueOfType<String>(json, r'full_name')!,
        classSection: StudentRefClassSection.fromJson(json[r'class_section']),
      );
    }
    return null;
  }

  static List<StudentRef> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudentRef>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudentRef.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudentRef> mapFromJson(dynamic json) {
    final map = <String, StudentRef>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudentRef.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudentRef-objects as value to a dart map
  static Map<String, List<StudentRef>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudentRef>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudentRef.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'full_name',
  };
}

