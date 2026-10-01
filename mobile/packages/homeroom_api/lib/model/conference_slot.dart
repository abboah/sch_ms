//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConferenceSlot {
  /// Returns a new [ConferenceSlot] instance.
  ConferenceSlot({
    required this.id,
    required this.teacher,
    required this.startsAt,
    required this.endsAt,
    required this.booked,
    required this.bookedByMe,
    this.student,
  });

  String id;

  Person teacher;

  DateTime startsAt;

  DateTime endsAt;

  bool booked;

  bool bookedByMe;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StudentRef? student;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConferenceSlot &&
    other.id == id &&
    other.teacher == teacher &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.booked == booked &&
    other.bookedByMe == bookedByMe &&
    other.student == student;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (teacher.hashCode) +
    (startsAt.hashCode) +
    (endsAt.hashCode) +
    (booked.hashCode) +
    (bookedByMe.hashCode) +
    (student == null ? 0 : student!.hashCode);

  @override
  String toString() => 'ConferenceSlot[id=$id, teacher=$teacher, startsAt=$startsAt, endsAt=$endsAt, booked=$booked, bookedByMe=$bookedByMe, student=$student]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'teacher'] = this.teacher;
      json[r'starts_at'] = this.startsAt.toUtc().toIso8601String();
      json[r'ends_at'] = this.endsAt.toUtc().toIso8601String();
      json[r'booked'] = this.booked;
      json[r'booked_by_me'] = this.bookedByMe;
    if (this.student != null) {
      json[r'student'] = this.student;
    } else {
      json[r'student'] = null;
    }
    return json;
  }

  /// Returns a new [ConferenceSlot] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConferenceSlot? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ConferenceSlot[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ConferenceSlot[id]" has a null value in JSON.');
        assert(json.containsKey(r'teacher'), 'Required key "ConferenceSlot[teacher]" is missing from JSON.');
        assert(json[r'teacher'] != null, 'Required key "ConferenceSlot[teacher]" has a null value in JSON.');
        assert(json.containsKey(r'starts_at'), 'Required key "ConferenceSlot[starts_at]" is missing from JSON.');
        assert(json[r'starts_at'] != null, 'Required key "ConferenceSlot[starts_at]" has a null value in JSON.');
        assert(json.containsKey(r'ends_at'), 'Required key "ConferenceSlot[ends_at]" is missing from JSON.');
        assert(json[r'ends_at'] != null, 'Required key "ConferenceSlot[ends_at]" has a null value in JSON.');
        assert(json.containsKey(r'booked'), 'Required key "ConferenceSlot[booked]" is missing from JSON.');
        assert(json[r'booked'] != null, 'Required key "ConferenceSlot[booked]" has a null value in JSON.');
        assert(json.containsKey(r'booked_by_me'), 'Required key "ConferenceSlot[booked_by_me]" is missing from JSON.');
        assert(json[r'booked_by_me'] != null, 'Required key "ConferenceSlot[booked_by_me]" has a null value in JSON.');
        return true;
      }());

      return ConferenceSlot(
        id: mapValueOfType<String>(json, r'id')!,
        teacher: Person.fromJson(json[r'teacher'])!,
        startsAt: mapDateTime(json, r'starts_at', r'')!,
        endsAt: mapDateTime(json, r'ends_at', r'')!,
        booked: mapValueOfType<bool>(json, r'booked')!,
        bookedByMe: mapValueOfType<bool>(json, r'booked_by_me')!,
        student: StudentRef.fromJson(json[r'student']),
      );
    }
    return null;
  }

  static List<ConferenceSlot> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConferenceSlot>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConferenceSlot.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConferenceSlot> mapFromJson(dynamic json) {
    final map = <String, ConferenceSlot>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConferenceSlot.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConferenceSlot-objects as value to a dart map
  static Map<String, List<ConferenceSlot>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConferenceSlot>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConferenceSlot.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'teacher',
    'starts_at',
    'ends_at',
    'booked',
    'booked_by_me',
  };
}

