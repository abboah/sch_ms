//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.id,
    required this.fullName,
    required this.role,
    required this.school,
    this.contact,
    this.children = const [],
    this.sections = const [],
    required this.now,
  });

  String id;

  String fullName;

  Role role;

  MeSchool school;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Contact? contact;

  /// Guardians only
  List<StudentRef> children;

  /// Teachers only
  List<ClassSection> sections;

  /// The server's current time. Clients use it to correct a wrong device clock and to agree with the server about what 'today' is.
  DateTime now;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Me &&
    other.id == id &&
    other.fullName == fullName &&
    other.role == role &&
    other.school == school &&
    other.contact == contact &&
    _deepEquality.equals(other.children, children) &&
    _deepEquality.equals(other.sections, sections) &&
    other.now == now;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (fullName.hashCode) +
    (role.hashCode) +
    (school.hashCode) +
    (contact == null ? 0 : contact!.hashCode) +
    (children.hashCode) +
    (sections.hashCode) +
    (now.hashCode);

  @override
  String toString() => 'Me[id=$id, fullName=$fullName, role=$role, school=$school, contact=$contact, children=$children, sections=$sections, now=$now]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'full_name'] = this.fullName;
      json[r'role'] = this.role;
      json[r'school'] = this.school;
    if (this.contact != null) {
      json[r'contact'] = this.contact;
    } else {
      json[r'contact'] = null;
    }
      json[r'children'] = this.children;
      json[r'sections'] = this.sections;
      json[r'now'] = this.now.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Me] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Me? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Me[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Me[id]" has a null value in JSON.');
        assert(json.containsKey(r'full_name'), 'Required key "Me[full_name]" is missing from JSON.');
        assert(json[r'full_name'] != null, 'Required key "Me[full_name]" has a null value in JSON.');
        assert(json.containsKey(r'role'), 'Required key "Me[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "Me[role]" has a null value in JSON.');
        assert(json.containsKey(r'school'), 'Required key "Me[school]" is missing from JSON.');
        assert(json[r'school'] != null, 'Required key "Me[school]" has a null value in JSON.');
        assert(json.containsKey(r'now'), 'Required key "Me[now]" is missing from JSON.');
        assert(json[r'now'] != null, 'Required key "Me[now]" has a null value in JSON.');
        return true;
      }());

      return Me(
        id: mapValueOfType<String>(json, r'id')!,
        fullName: mapValueOfType<String>(json, r'full_name')!,
        role: Role.fromJson(json[r'role'])!,
        school: MeSchool.fromJson(json[r'school'])!,
        contact: Contact.fromJson(json[r'contact']),
        children: StudentRef.listFromJson(json[r'children']),
        sections: ClassSection.listFromJson(json[r'sections']),
        now: mapDateTime(json, r'now', r'')!,
      );
    }
    return null;
  }

  static List<Me> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Me>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Me.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Me> mapFromJson(dynamic json) {
    final map = <String, Me>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Me.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Me-objects as value to a dart map
  static Map<String, List<Me>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Me>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Me.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'full_name',
    'role',
    'school',
    'now',
  };
}

