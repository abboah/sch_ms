//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Thread {
  /// Returns a new [Thread] instance.
  Thread({
    required this.id,
    required this.student,
    required this.teacher,
    required this.guardian,
    this.lastMessage,
    required this.unread,
  });

  String id;

  StudentRef student;

  Person teacher;

  Person guardian;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Message? lastMessage;

  int unread;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Thread &&
    other.id == id &&
    other.student == student &&
    other.teacher == teacher &&
    other.guardian == guardian &&
    other.lastMessage == lastMessage &&
    other.unread == unread;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (student.hashCode) +
    (teacher.hashCode) +
    (guardian.hashCode) +
    (lastMessage == null ? 0 : lastMessage!.hashCode) +
    (unread.hashCode);

  @override
  String toString() => 'Thread[id=$id, student=$student, teacher=$teacher, guardian=$guardian, lastMessage=$lastMessage, unread=$unread]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'student'] = this.student;
      json[r'teacher'] = this.teacher;
      json[r'guardian'] = this.guardian;
    if (this.lastMessage != null) {
      json[r'last_message'] = this.lastMessage;
    } else {
      json[r'last_message'] = null;
    }
      json[r'unread'] = this.unread;
    return json;
  }

  /// Returns a new [Thread] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Thread? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Thread[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Thread[id]" has a null value in JSON.');
        assert(json.containsKey(r'student'), 'Required key "Thread[student]" is missing from JSON.');
        assert(json[r'student'] != null, 'Required key "Thread[student]" has a null value in JSON.');
        assert(json.containsKey(r'teacher'), 'Required key "Thread[teacher]" is missing from JSON.');
        assert(json[r'teacher'] != null, 'Required key "Thread[teacher]" has a null value in JSON.');
        assert(json.containsKey(r'guardian'), 'Required key "Thread[guardian]" is missing from JSON.');
        assert(json[r'guardian'] != null, 'Required key "Thread[guardian]" has a null value in JSON.');
        assert(json.containsKey(r'unread'), 'Required key "Thread[unread]" is missing from JSON.');
        assert(json[r'unread'] != null, 'Required key "Thread[unread]" has a null value in JSON.');
        return true;
      }());

      return Thread(
        id: mapValueOfType<String>(json, r'id')!,
        student: StudentRef.fromJson(json[r'student'])!,
        teacher: Person.fromJson(json[r'teacher'])!,
        guardian: Person.fromJson(json[r'guardian'])!,
        lastMessage: Message.fromJson(json[r'last_message']),
        unread: mapValueOfType<int>(json, r'unread')!,
      );
    }
    return null;
  }

  static List<Thread> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Thread>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Thread.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Thread> mapFromJson(dynamic json) {
    final map = <String, Thread>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Thread.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Thread-objects as value to a dart map
  static Map<String, List<Thread>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Thread>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Thread.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'student',
    'teacher',
    'guardian',
    'unread',
  };
}

