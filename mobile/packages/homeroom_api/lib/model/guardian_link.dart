//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GuardianLink {
  /// Returns a new [GuardianLink] instance.
  GuardianLink({
    required this.guardian,
    required this.relationship,
    required this.isPrimaryContact,
  });

  Person guardian;

  String relationship;

  bool isPrimaryContact;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuardianLink &&
    other.guardian == guardian &&
    other.relationship == relationship &&
    other.isPrimaryContact == isPrimaryContact;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guardian.hashCode) +
    (relationship.hashCode) +
    (isPrimaryContact.hashCode);

  @override
  String toString() => 'GuardianLink[guardian=$guardian, relationship=$relationship, isPrimaryContact=$isPrimaryContact]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guardian'] = this.guardian;
      json[r'relationship'] = this.relationship;
      json[r'is_primary_contact'] = this.isPrimaryContact;
    return json;
  }

  /// Returns a new [GuardianLink] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuardianLink? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'guardian'), 'Required key "GuardianLink[guardian]" is missing from JSON.');
        assert(json[r'guardian'] != null, 'Required key "GuardianLink[guardian]" has a null value in JSON.');
        assert(json.containsKey(r'relationship'), 'Required key "GuardianLink[relationship]" is missing from JSON.');
        assert(json[r'relationship'] != null, 'Required key "GuardianLink[relationship]" has a null value in JSON.');
        assert(json.containsKey(r'is_primary_contact'), 'Required key "GuardianLink[is_primary_contact]" is missing from JSON.');
        assert(json[r'is_primary_contact'] != null, 'Required key "GuardianLink[is_primary_contact]" has a null value in JSON.');
        return true;
      }());

      return GuardianLink(
        guardian: Person.fromJson(json[r'guardian'])!,
        relationship: mapValueOfType<String>(json, r'relationship')!,
        isPrimaryContact: mapValueOfType<bool>(json, r'is_primary_contact')!,
      );
    }
    return null;
  }

  static List<GuardianLink> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuardianLink>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuardianLink.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuardianLink> mapFromJson(dynamic json) {
    final map = <String, GuardianLink>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuardianLink.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuardianLink-objects as value to a dart map
  static Map<String, List<GuardianLink>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuardianLink>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuardianLink.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guardian',
    'relationship',
    'is_primary_contact',
  };
}

