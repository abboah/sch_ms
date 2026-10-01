//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SelectionRequiredChoicesInner {
  /// Returns a new [SelectionRequiredChoicesInner] instance.
  SelectionRequiredChoicesInner({
    required this.personId,
    required this.role,
    required this.schoolName,
    this.fullName,
  });

  String personId;

  Role role;

  String schoolName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? fullName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SelectionRequiredChoicesInner &&
    other.personId == personId &&
    other.role == role &&
    other.schoolName == schoolName &&
    other.fullName == fullName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (personId.hashCode) +
    (role.hashCode) +
    (schoolName.hashCode) +
    (fullName == null ? 0 : fullName!.hashCode);

  @override
  String toString() => 'SelectionRequiredChoicesInner[personId=$personId, role=$role, schoolName=$schoolName, fullName=$fullName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'person_id'] = this.personId;
      json[r'role'] = this.role;
      json[r'school_name'] = this.schoolName;
    if (this.fullName != null) {
      json[r'full_name'] = this.fullName;
    } else {
      json[r'full_name'] = null;
    }
    return json;
  }

  /// Returns a new [SelectionRequiredChoicesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SelectionRequiredChoicesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'person_id'), 'Required key "SelectionRequiredChoicesInner[person_id]" is missing from JSON.');
        assert(json[r'person_id'] != null, 'Required key "SelectionRequiredChoicesInner[person_id]" has a null value in JSON.');
        assert(json.containsKey(r'role'), 'Required key "SelectionRequiredChoicesInner[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "SelectionRequiredChoicesInner[role]" has a null value in JSON.');
        assert(json.containsKey(r'school_name'), 'Required key "SelectionRequiredChoicesInner[school_name]" is missing from JSON.');
        assert(json[r'school_name'] != null, 'Required key "SelectionRequiredChoicesInner[school_name]" has a null value in JSON.');
        return true;
      }());

      return SelectionRequiredChoicesInner(
        personId: mapValueOfType<String>(json, r'person_id')!,
        role: Role.fromJson(json[r'role'])!,
        schoolName: mapValueOfType<String>(json, r'school_name')!,
        fullName: mapValueOfType<String>(json, r'full_name'),
      );
    }
    return null;
  }

  static List<SelectionRequiredChoicesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SelectionRequiredChoicesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SelectionRequiredChoicesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SelectionRequiredChoicesInner> mapFromJson(dynamic json) {
    final map = <String, SelectionRequiredChoicesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SelectionRequiredChoicesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SelectionRequiredChoicesInner-objects as value to a dart map
  static Map<String, List<SelectionRequiredChoicesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SelectionRequiredChoicesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SelectionRequiredChoicesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'person_id',
    'role',
    'school_name',
  };
}

