//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BookConferenceSlotRequest {
  /// Returns a new [BookConferenceSlotRequest] instance.
  BookConferenceSlotRequest({
    required this.studentId,
  });

  String studentId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookConferenceSlotRequest &&
    other.studentId == studentId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode);

  @override
  String toString() => 'BookConferenceSlotRequest[studentId=$studentId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
    return json;
  }

  /// Returns a new [BookConferenceSlotRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookConferenceSlotRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "BookConferenceSlotRequest[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "BookConferenceSlotRequest[student_id]" has a null value in JSON.');
        return true;
      }());

      return BookConferenceSlotRequest(
        studentId: mapValueOfType<String>(json, r'student_id')!,
      );
    }
    return null;
  }

  static List<BookConferenceSlotRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookConferenceSlotRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookConferenceSlotRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookConferenceSlotRequest> mapFromJson(dynamic json) {
    final map = <String, BookConferenceSlotRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookConferenceSlotRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookConferenceSlotRequest-objects as value to a dart map
  static Map<String, List<BookConferenceSlotRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookConferenceSlotRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookConferenceSlotRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
  };
}

