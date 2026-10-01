//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ImportStudentsRequest {
  /// Returns a new [ImportStudentsRequest] instance.
  ImportStudentsRequest({
    this.students = const [],
  });

  List<ImportStudentsRequestStudentsInner> students;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportStudentsRequest &&
    _deepEquality.equals(other.students, students);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (students.hashCode);

  @override
  String toString() => 'ImportStudentsRequest[students=$students]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'students'] = this.students;
    return json;
  }

  /// Returns a new [ImportStudentsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportStudentsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'students'), 'Required key "ImportStudentsRequest[students]" is missing from JSON.');
        assert(json[r'students'] != null, 'Required key "ImportStudentsRequest[students]" has a null value in JSON.');
        return true;
      }());

      return ImportStudentsRequest(
        students: ImportStudentsRequestStudentsInner.listFromJson(json[r'students']),
      );
    }
    return null;
  }

  static List<ImportStudentsRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportStudentsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportStudentsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportStudentsRequest> mapFromJson(dynamic json) {
    final map = <String, ImportStudentsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportStudentsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportStudentsRequest-objects as value to a dart map
  static Map<String, List<ImportStudentsRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportStudentsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportStudentsRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'students',
  };
}

