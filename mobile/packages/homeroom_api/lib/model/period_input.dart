//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PeriodInput {
  /// Returns a new [PeriodInput] instance.
  PeriodInput({
    required this.subject,
    required this.teacherId,
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
  });

  String subject;

  String teacherId;

  int weekday;

  String startsAt;

  String endsAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PeriodInput &&
    other.subject == subject &&
    other.teacherId == teacherId &&
    other.weekday == weekday &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subject.hashCode) +
    (teacherId.hashCode) +
    (weekday.hashCode) +
    (startsAt.hashCode) +
    (endsAt.hashCode);

  @override
  String toString() => 'PeriodInput[subject=$subject, teacherId=$teacherId, weekday=$weekday, startsAt=$startsAt, endsAt=$endsAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'subject'] = this.subject;
      json[r'teacher_id'] = this.teacherId;
      json[r'weekday'] = this.weekday;
      json[r'starts_at'] = this.startsAt;
      json[r'ends_at'] = this.endsAt;
    return json;
  }

  /// Returns a new [PeriodInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PeriodInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'subject'), 'Required key "PeriodInput[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "PeriodInput[subject]" has a null value in JSON.');
        assert(json.containsKey(r'teacher_id'), 'Required key "PeriodInput[teacher_id]" is missing from JSON.');
        assert(json[r'teacher_id'] != null, 'Required key "PeriodInput[teacher_id]" has a null value in JSON.');
        assert(json.containsKey(r'weekday'), 'Required key "PeriodInput[weekday]" is missing from JSON.');
        assert(json[r'weekday'] != null, 'Required key "PeriodInput[weekday]" has a null value in JSON.');
        assert(json.containsKey(r'starts_at'), 'Required key "PeriodInput[starts_at]" is missing from JSON.');
        assert(json[r'starts_at'] != null, 'Required key "PeriodInput[starts_at]" has a null value in JSON.');
        assert(json.containsKey(r'ends_at'), 'Required key "PeriodInput[ends_at]" is missing from JSON.');
        assert(json[r'ends_at'] != null, 'Required key "PeriodInput[ends_at]" has a null value in JSON.');
        return true;
      }());

      return PeriodInput(
        subject: mapValueOfType<String>(json, r'subject')!,
        teacherId: mapValueOfType<String>(json, r'teacher_id')!,
        weekday: mapValueOfType<int>(json, r'weekday')!,
        startsAt: mapValueOfType<String>(json, r'starts_at')!,
        endsAt: mapValueOfType<String>(json, r'ends_at')!,
      );
    }
    return null;
  }

  static List<PeriodInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PeriodInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PeriodInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PeriodInput> mapFromJson(dynamic json) {
    final map = <String, PeriodInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PeriodInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PeriodInput-objects as value to a dart map
  static Map<String, List<PeriodInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PeriodInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PeriodInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'subject',
    'teacher_id',
    'weekday',
    'starts_at',
    'ends_at',
  };
}

