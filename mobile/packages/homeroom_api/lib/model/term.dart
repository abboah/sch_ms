//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Term {
  /// Returns a new [Term] instance.
  Term({
    required this.id,
    required this.name,
    required this.startsOn,
    required this.endsOn,
    required this.closed,
  });

  String id;

  String name;

  String startsOn;

  String endsOn;

  bool closed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Term &&
    other.id == id &&
    other.name == name &&
    other.startsOn == startsOn &&
    other.endsOn == endsOn &&
    other.closed == closed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (startsOn.hashCode) +
    (endsOn.hashCode) +
    (closed.hashCode);

  @override
  String toString() => 'Term[id=$id, name=$name, startsOn=$startsOn, endsOn=$endsOn, closed=$closed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'starts_on'] = this.startsOn;
      json[r'ends_on'] = this.endsOn;
      json[r'closed'] = this.closed;
    return json;
  }

  /// Returns a new [Term] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Term? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Term[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Term[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Term[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Term[name]" has a null value in JSON.');
        assert(json.containsKey(r'starts_on'), 'Required key "Term[starts_on]" is missing from JSON.');
        assert(json[r'starts_on'] != null, 'Required key "Term[starts_on]" has a null value in JSON.');
        assert(json.containsKey(r'ends_on'), 'Required key "Term[ends_on]" is missing from JSON.');
        assert(json[r'ends_on'] != null, 'Required key "Term[ends_on]" has a null value in JSON.');
        assert(json.containsKey(r'closed'), 'Required key "Term[closed]" is missing from JSON.');
        assert(json[r'closed'] != null, 'Required key "Term[closed]" has a null value in JSON.');
        return true;
      }());

      return Term(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        startsOn: mapValueOfType<String>(json, r'starts_on')!,
        endsOn: mapValueOfType<String>(json, r'ends_on')!,
        closed: mapValueOfType<bool>(json, r'closed')!,
      );
    }
    return null;
  }

  static List<Term> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Term>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Term.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Term> mapFromJson(dynamic json) {
    final map = <String, Term>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Term.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Term-objects as value to a dart map
  static Map<String, List<Term>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Term>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Term.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'starts_on',
    'ends_on',
    'closed',
  };
}

