//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PersonInput {
  /// Returns a new [PersonInput] instance.
  PersonInput({
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.invite = false,
  });

  String fullName;

  Role role;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phone;

  bool invite;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PersonInput &&
    other.fullName == fullName &&
    other.role == role &&
    other.email == email &&
    other.phone == phone &&
    other.invite == invite;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (fullName.hashCode) +
    (role.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (invite.hashCode);

  @override
  String toString() => 'PersonInput[fullName=$fullName, role=$role, email=$email, phone=$phone, invite=$invite]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'full_name'] = this.fullName;
      json[r'role'] = this.role;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
      json[r'invite'] = this.invite;
    return json;
  }

  /// Returns a new [PersonInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PersonInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'full_name'), 'Required key "PersonInput[full_name]" is missing from JSON.');
        assert(json[r'full_name'] != null, 'Required key "PersonInput[full_name]" has a null value in JSON.');
        assert(json.containsKey(r'role'), 'Required key "PersonInput[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "PersonInput[role]" has a null value in JSON.');
        return true;
      }());

      return PersonInput(
        fullName: mapValueOfType<String>(json, r'full_name')!,
        role: Role.fromJson(json[r'role'])!,
        email: mapValueOfType<String>(json, r'email'),
        phone: mapValueOfType<String>(json, r'phone'),
        invite: mapValueOfType<bool>(json, r'invite') ?? false,
      );
    }
    return null;
  }

  static List<PersonInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PersonInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PersonInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PersonInput> mapFromJson(dynamic json) {
    final map = <String, PersonInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PersonInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PersonInput-objects as value to a dart map
  static Map<String, List<PersonInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PersonInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PersonInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'full_name',
    'role',
  };
}

