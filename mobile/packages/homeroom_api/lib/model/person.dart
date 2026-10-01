//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Person {
  /// Returns a new [Person] instance.
  Person({
    required this.id,
    required this.fullName,
    required this.role,
    this.contact,
    this.assignments = const [],
  });

  String id;

  String fullName;

  Role role;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PersonContact? contact;

  /// Teachers, in the admin directory: what they teach, in the current term
  List<PersonAssignmentsInner> assignments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Person &&
    other.id == id &&
    other.fullName == fullName &&
    other.role == role &&
    other.contact == contact &&
    _deepEquality.equals(other.assignments, assignments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (fullName.hashCode) +
    (role.hashCode) +
    (contact == null ? 0 : contact!.hashCode) +
    (assignments.hashCode);

  @override
  String toString() => 'Person[id=$id, fullName=$fullName, role=$role, contact=$contact, assignments=$assignments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'full_name'] = this.fullName;
      json[r'role'] = this.role;
    if (this.contact != null) {
      json[r'contact'] = this.contact;
    } else {
      json[r'contact'] = null;
    }
      json[r'assignments'] = this.assignments;
    return json;
  }

  /// Returns a new [Person] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Person? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Person[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Person[id]" has a null value in JSON.');
        assert(json.containsKey(r'full_name'), 'Required key "Person[full_name]" is missing from JSON.');
        assert(json[r'full_name'] != null, 'Required key "Person[full_name]" has a null value in JSON.');
        assert(json.containsKey(r'role'), 'Required key "Person[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "Person[role]" has a null value in JSON.');
        return true;
      }());

      return Person(
        id: mapValueOfType<String>(json, r'id')!,
        fullName: mapValueOfType<String>(json, r'full_name')!,
        role: Role.fromJson(json[r'role'])!,
        contact: PersonContact.fromJson(json[r'contact']),
        assignments: PersonAssignmentsInner.listFromJson(json[r'assignments']),
      );
    }
    return null;
  }

  static List<Person> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Person>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Person.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Person> mapFromJson(dynamic json) {
    final map = <String, Person>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Person.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Person-objects as value to a dart map
  static Map<String, List<Person>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Person>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Person.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'full_name',
    'role',
  };
}

