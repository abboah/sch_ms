//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpsertGradesRequest {
  /// Returns a new [UpsertGradesRequest] instance.
  UpsertGradesRequest({
    this.grades = const [],
  });

  List<UpsertGradesRequestGradesInner> grades;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpsertGradesRequest &&
    _deepEquality.equals(other.grades, grades);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (grades.hashCode);

  @override
  String toString() => 'UpsertGradesRequest[grades=$grades]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'grades'] = this.grades;
    return json;
  }

  /// Returns a new [UpsertGradesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpsertGradesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'grades'), 'Required key "UpsertGradesRequest[grades]" is missing from JSON.');
        assert(json[r'grades'] != null, 'Required key "UpsertGradesRequest[grades]" has a null value in JSON.');
        return true;
      }());

      return UpsertGradesRequest(
        grades: UpsertGradesRequestGradesInner.listFromJson(json[r'grades']),
      );
    }
    return null;
  }

  static List<UpsertGradesRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpsertGradesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpsertGradesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpsertGradesRequest> mapFromJson(dynamic json) {
    final map = <String, UpsertGradesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpsertGradesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpsertGradesRequest-objects as value to a dart map
  static Map<String, List<UpsertGradesRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpsertGradesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpsertGradesRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'grades',
  };
}

