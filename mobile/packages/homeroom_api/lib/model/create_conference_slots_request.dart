//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateConferenceSlotsRequest {
  /// Returns a new [CreateConferenceSlotsRequest] instance.
  CreateConferenceSlotsRequest({
    required this.teacherId,
    required this.startsAt,
    required this.endsAt,
    required this.slotMinutes,
  });

  String teacherId;

  DateTime startsAt;

  DateTime endsAt;

  /// Minimum value: 5
  int slotMinutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateConferenceSlotsRequest &&
    other.teacherId == teacherId &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.slotMinutes == slotMinutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (teacherId.hashCode) +
    (startsAt.hashCode) +
    (endsAt.hashCode) +
    (slotMinutes.hashCode);

  @override
  String toString() => 'CreateConferenceSlotsRequest[teacherId=$teacherId, startsAt=$startsAt, endsAt=$endsAt, slotMinutes=$slotMinutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'teacher_id'] = this.teacherId;
      json[r'starts_at'] = this.startsAt.toUtc().toIso8601String();
      json[r'ends_at'] = this.endsAt.toUtc().toIso8601String();
      json[r'slot_minutes'] = this.slotMinutes;
    return json;
  }

  /// Returns a new [CreateConferenceSlotsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateConferenceSlotsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'teacher_id'), 'Required key "CreateConferenceSlotsRequest[teacher_id]" is missing from JSON.');
        assert(json[r'teacher_id'] != null, 'Required key "CreateConferenceSlotsRequest[teacher_id]" has a null value in JSON.');
        assert(json.containsKey(r'starts_at'), 'Required key "CreateConferenceSlotsRequest[starts_at]" is missing from JSON.');
        assert(json[r'starts_at'] != null, 'Required key "CreateConferenceSlotsRequest[starts_at]" has a null value in JSON.');
        assert(json.containsKey(r'ends_at'), 'Required key "CreateConferenceSlotsRequest[ends_at]" is missing from JSON.');
        assert(json[r'ends_at'] != null, 'Required key "CreateConferenceSlotsRequest[ends_at]" has a null value in JSON.');
        assert(json.containsKey(r'slot_minutes'), 'Required key "CreateConferenceSlotsRequest[slot_minutes]" is missing from JSON.');
        assert(json[r'slot_minutes'] != null, 'Required key "CreateConferenceSlotsRequest[slot_minutes]" has a null value in JSON.');
        return true;
      }());

      return CreateConferenceSlotsRequest(
        teacherId: mapValueOfType<String>(json, r'teacher_id')!,
        startsAt: mapDateTime(json, r'starts_at', r'')!,
        endsAt: mapDateTime(json, r'ends_at', r'')!,
        slotMinutes: mapValueOfType<int>(json, r'slot_minutes')!,
      );
    }
    return null;
  }

  static List<CreateConferenceSlotsRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateConferenceSlotsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateConferenceSlotsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateConferenceSlotsRequest> mapFromJson(dynamic json) {
    final map = <String, CreateConferenceSlotsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateConferenceSlotsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateConferenceSlotsRequest-objects as value to a dart map
  static Map<String, List<CreateConferenceSlotsRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateConferenceSlotsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateConferenceSlotsRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'teacher_id',
    'starts_at',
    'ends_at',
    'slot_minutes',
  };
}

