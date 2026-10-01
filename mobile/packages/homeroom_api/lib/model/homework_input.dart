//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class HomeworkInput {
  /// Returns a new [HomeworkInput] instance.
  HomeworkInput({
    required this.title,
    this.body,
    required this.dueDate,
  });

  String title;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? body;

  String dueDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HomeworkInput &&
    other.title == title &&
    other.body == body &&
    other.dueDate == dueDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (body == null ? 0 : body!.hashCode) +
    (dueDate.hashCode);

  @override
  String toString() => 'HomeworkInput[title=$title, body=$body, dueDate=$dueDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
    if (this.body != null) {
      json[r'body'] = this.body;
    } else {
      json[r'body'] = null;
    }
      json[r'due_date'] = this.dueDate;
    return json;
  }

  /// Returns a new [HomeworkInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HomeworkInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'title'), 'Required key "HomeworkInput[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "HomeworkInput[title]" has a null value in JSON.');
        assert(json.containsKey(r'due_date'), 'Required key "HomeworkInput[due_date]" is missing from JSON.');
        assert(json[r'due_date'] != null, 'Required key "HomeworkInput[due_date]" has a null value in JSON.');
        return true;
      }());

      return HomeworkInput(
        title: mapValueOfType<String>(json, r'title')!,
        body: mapValueOfType<String>(json, r'body'),
        dueDate: mapValueOfType<String>(json, r'due_date')!,
      );
    }
    return null;
  }

  static List<HomeworkInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HomeworkInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HomeworkInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HomeworkInput> mapFromJson(dynamic json) {
    final map = <String, HomeworkInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HomeworkInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HomeworkInput-objects as value to a dart map
  static Map<String, List<HomeworkInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HomeworkInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HomeworkInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'due_date',
  };
}

