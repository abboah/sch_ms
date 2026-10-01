//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateSchoolRequest {
  /// Returns a new [CreateSchoolRequest] instance.
  CreateSchoolRequest({
    required this.inviteCode,
    required this.schoolName,
    this.timezone = 'Africa/Accra',
    required this.admin,
  });

  String inviteCode;

  String schoolName;

  String timezone;

  CreateSchoolRequestAdmin admin;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateSchoolRequest &&
    other.inviteCode == inviteCode &&
    other.schoolName == schoolName &&
    other.timezone == timezone &&
    other.admin == admin;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (inviteCode.hashCode) +
    (schoolName.hashCode) +
    (timezone.hashCode) +
    (admin.hashCode);

  @override
  String toString() => 'CreateSchoolRequest[inviteCode=$inviteCode, schoolName=$schoolName, timezone=$timezone, admin=$admin]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'invite_code'] = this.inviteCode;
      json[r'school_name'] = this.schoolName;
      json[r'timezone'] = this.timezone;
      json[r'admin'] = this.admin;
    return json;
  }

  /// Returns a new [CreateSchoolRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSchoolRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'invite_code'), 'Required key "CreateSchoolRequest[invite_code]" is missing from JSON.');
        assert(json[r'invite_code'] != null, 'Required key "CreateSchoolRequest[invite_code]" has a null value in JSON.');
        assert(json.containsKey(r'school_name'), 'Required key "CreateSchoolRequest[school_name]" is missing from JSON.');
        assert(json[r'school_name'] != null, 'Required key "CreateSchoolRequest[school_name]" has a null value in JSON.');
        assert(json.containsKey(r'admin'), 'Required key "CreateSchoolRequest[admin]" is missing from JSON.');
        assert(json[r'admin'] != null, 'Required key "CreateSchoolRequest[admin]" has a null value in JSON.');
        return true;
      }());

      return CreateSchoolRequest(
        inviteCode: mapValueOfType<String>(json, r'invite_code')!,
        schoolName: mapValueOfType<String>(json, r'school_name')!,
        timezone: mapValueOfType<String>(json, r'timezone') ?? 'Africa/Accra',
        admin: CreateSchoolRequestAdmin.fromJson(json[r'admin'])!,
      );
    }
    return null;
  }

  static List<CreateSchoolRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateSchoolRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSchoolRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSchoolRequest> mapFromJson(dynamic json) {
    final map = <String, CreateSchoolRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSchoolRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSchoolRequest-objects as value to a dart map
  static Map<String, List<CreateSchoolRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateSchoolRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSchoolRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'invite_code',
    'school_name',
    'admin',
  };
}

