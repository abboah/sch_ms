//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LinkGuardianRequest {
  /// Returns a new [LinkGuardianRequest] instance.
  LinkGuardianRequest({
    required this.guardianId,
    this.relationship,
    this.isPrimaryContact,
  });

  String guardianId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? relationship;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isPrimaryContact;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LinkGuardianRequest &&
    other.guardianId == guardianId &&
    other.relationship == relationship &&
    other.isPrimaryContact == isPrimaryContact;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guardianId.hashCode) +
    (relationship == null ? 0 : relationship!.hashCode) +
    (isPrimaryContact == null ? 0 : isPrimaryContact!.hashCode);

  @override
  String toString() => 'LinkGuardianRequest[guardianId=$guardianId, relationship=$relationship, isPrimaryContact=$isPrimaryContact]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guardian_id'] = this.guardianId;
    if (this.relationship != null) {
      json[r'relationship'] = this.relationship;
    } else {
      json[r'relationship'] = null;
    }
    if (this.isPrimaryContact != null) {
      json[r'is_primary_contact'] = this.isPrimaryContact;
    } else {
      json[r'is_primary_contact'] = null;
    }
    return json;
  }

  /// Returns a new [LinkGuardianRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LinkGuardianRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'guardian_id'), 'Required key "LinkGuardianRequest[guardian_id]" is missing from JSON.');
        assert(json[r'guardian_id'] != null, 'Required key "LinkGuardianRequest[guardian_id]" has a null value in JSON.');
        return true;
      }());

      return LinkGuardianRequest(
        guardianId: mapValueOfType<String>(json, r'guardian_id')!,
        relationship: mapValueOfType<String>(json, r'relationship'),
        isPrimaryContact: mapValueOfType<bool>(json, r'is_primary_contact'),
      );
    }
    return null;
  }

  static List<LinkGuardianRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LinkGuardianRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LinkGuardianRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LinkGuardianRequest> mapFromJson(dynamic json) {
    final map = <String, LinkGuardianRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LinkGuardianRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LinkGuardianRequest-objects as value to a dart map
  static Map<String, List<LinkGuardianRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LinkGuardianRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LinkGuardianRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guardian_id',
  };
}

