//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OpenThreadRequest {
  /// Returns a new [OpenThreadRequest] instance.
  OpenThreadRequest({
    required this.studentId,
    required this.otherPartyId,
  });

  String studentId;

  /// The teacher (if caller is a guardian) or guardian (if caller is a teacher)
  String otherPartyId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpenThreadRequest &&
    other.studentId == studentId &&
    other.otherPartyId == otherPartyId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (otherPartyId.hashCode);

  @override
  String toString() => 'OpenThreadRequest[studentId=$studentId, otherPartyId=$otherPartyId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'other_party_id'] = this.otherPartyId;
    return json;
  }

  /// Returns a new [OpenThreadRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OpenThreadRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "OpenThreadRequest[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "OpenThreadRequest[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'other_party_id'), 'Required key "OpenThreadRequest[other_party_id]" is missing from JSON.');
        assert(json[r'other_party_id'] != null, 'Required key "OpenThreadRequest[other_party_id]" has a null value in JSON.');
        return true;
      }());

      return OpenThreadRequest(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        otherPartyId: mapValueOfType<String>(json, r'other_party_id')!,
      );
    }
    return null;
  }

  static List<OpenThreadRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpenThreadRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpenThreadRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OpenThreadRequest> mapFromJson(dynamic json) {
    final map = <String, OpenThreadRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OpenThreadRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OpenThreadRequest-objects as value to a dart map
  static Map<String, List<OpenThreadRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OpenThreadRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OpenThreadRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'other_party_id',
  };
}

