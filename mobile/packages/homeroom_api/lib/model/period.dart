//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Period {
  /// Returns a new [Period] instance.
  Period({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
  });

  String id;

  String subject;

  Person teacher;

  /// ISO, 1 = Monday
  ///
  /// Minimum value: 1
  /// Maximum value: 7
  int weekday;

  String startsAt;

  String endsAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Period &&
    other.id == id &&
    other.subject == subject &&
    other.teacher == teacher &&
    other.weekday == weekday &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (subject.hashCode) +
    (teacher.hashCode) +
    (weekday.hashCode) +
    (startsAt.hashCode) +
    (endsAt.hashCode);

  @override
  String toString() => 'Period[id=$id, subject=$subject, teacher=$teacher, weekday=$weekday, startsAt=$startsAt, endsAt=$endsAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'subject'] = this.subject;
      json[r'teacher'] = this.teacher;
      json[r'weekday'] = this.weekday;
      json[r'starts_at'] = this.startsAt;
      json[r'ends_at'] = this.endsAt;
    return json;
  }

  /// Returns a new [Period] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Period? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Period[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Period[id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "Period[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "Period[subject]" has a null value in JSON.');
        assert(json.containsKey(r'teacher'), 'Required key "Period[teacher]" is missing from JSON.');
        assert(json[r'teacher'] != null, 'Required key "Period[teacher]" has a null value in JSON.');
        assert(json.containsKey(r'weekday'), 'Required key "Period[weekday]" is missing from JSON.');
        assert(json[r'weekday'] != null, 'Required key "Period[weekday]" has a null value in JSON.');
        assert(json.containsKey(r'starts_at'), 'Required key "Period[starts_at]" is missing from JSON.');
        assert(json[r'starts_at'] != null, 'Required key "Period[starts_at]" has a null value in JSON.');
        assert(json.containsKey(r'ends_at'), 'Required key "Period[ends_at]" is missing from JSON.');
        assert(json[r'ends_at'] != null, 'Required key "Period[ends_at]" has a null value in JSON.');
        return true;
      }());

      return Period(
        id: mapValueOfType<String>(json, r'id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        teacher: Person.fromJson(json[r'teacher'])!,
        weekday: mapValueOfType<int>(json, r'weekday')!,
        startsAt: mapValueOfType<String>(json, r'starts_at')!,
        endsAt: mapValueOfType<String>(json, r'ends_at')!,
      );
    }
    return null;
  }

  static List<Period> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Period>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Period.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Period> mapFromJson(dynamic json) {
    final map = <String, Period>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Period.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Period-objects as value to a dart map
  static Map<String, List<Period>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Period>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Period.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'subject',
    'teacher',
    'weekday',
    'starts_at',
    'ends_at',
  };
}

