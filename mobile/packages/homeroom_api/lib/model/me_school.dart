//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MeSchool {
  /// Returns a new [MeSchool] instance.
  MeSchool({
    required this.id,
    required this.name,
    required this.timezone,
    this.term,
  });

  String id;

  String name;

  String timezone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Term? term;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MeSchool &&
    other.id == id &&
    other.name == name &&
    other.timezone == timezone &&
    other.term == term;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (timezone.hashCode) +
    (term == null ? 0 : term!.hashCode);

  @override
  String toString() => 'MeSchool[id=$id, name=$name, timezone=$timezone, term=$term]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'timezone'] = this.timezone;
    if (this.term != null) {
      json[r'term'] = this.term;
    } else {
      json[r'term'] = null;
    }
    return json;
  }

  /// Returns a new [MeSchool] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MeSchool? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "MeSchool[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "MeSchool[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "MeSchool[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "MeSchool[name]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "MeSchool[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "MeSchool[timezone]" has a null value in JSON.');
        return true;
      }());

      return MeSchool(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        term: Term.fromJson(json[r'term']),
      );
    }
    return null;
  }

  static List<MeSchool> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MeSchool>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MeSchool.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MeSchool> mapFromJson(dynamic json) {
    final map = <String, MeSchool>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MeSchool.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MeSchool-objects as value to a dart map
  static Map<String, List<MeSchool>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MeSchool>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MeSchool.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'timezone',
  };
}

