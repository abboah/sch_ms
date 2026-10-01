//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterSubmissionEntriesInner {
  /// Returns a new [RegisterSubmissionEntriesInner] instance.
  RegisterSubmissionEntriesInner({
    required this.studentId,
    required this.status,
    this.note,
    required this.markedAt,
  });

  String studentId;

  AttendanceStatus status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  /// Device time of the tap; decides last-write-wins
  DateTime markedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterSubmissionEntriesInner &&
    other.studentId == studentId &&
    other.status == status &&
    other.note == note &&
    other.markedAt == markedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (status.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (markedAt.hashCode);

  @override
  String toString() => 'RegisterSubmissionEntriesInner[studentId=$studentId, status=$status, note=$note, markedAt=$markedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'status'] = this.status;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'marked_at'] = this.markedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [RegisterSubmissionEntriesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterSubmissionEntriesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "RegisterSubmissionEntriesInner[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "RegisterSubmissionEntriesInner[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "RegisterSubmissionEntriesInner[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "RegisterSubmissionEntriesInner[status]" has a null value in JSON.');
        assert(json.containsKey(r'marked_at'), 'Required key "RegisterSubmissionEntriesInner[marked_at]" is missing from JSON.');
        assert(json[r'marked_at'] != null, 'Required key "RegisterSubmissionEntriesInner[marked_at]" has a null value in JSON.');
        return true;
      }());

      return RegisterSubmissionEntriesInner(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        status: AttendanceStatus.fromJson(json[r'status'])!,
        note: mapValueOfType<String>(json, r'note'),
        markedAt: mapDateTime(json, r'marked_at', r'')!,
      );
    }
    return null;
  }

  static List<RegisterSubmissionEntriesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterSubmissionEntriesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterSubmissionEntriesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterSubmissionEntriesInner> mapFromJson(dynamic json) {
    final map = <String, RegisterSubmissionEntriesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterSubmissionEntriesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterSubmissionEntriesInner-objects as value to a dart map
  static Map<String, List<RegisterSubmissionEntriesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterSubmissionEntriesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterSubmissionEntriesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'status',
    'marked_at',
  };
}

