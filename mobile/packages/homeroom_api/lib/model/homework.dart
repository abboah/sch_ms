//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Homework {
  /// Returns a new [Homework] instance.
  Homework({
    required this.id,
    required this.classSectionId,
    required this.subject,
    required this.title,
    required this.body,
    required this.dueDate,
    this.postedBy,
  });

  String id;

  String classSectionId;

  String? subject;

  String title;

  String? body;

  String dueDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Person? postedBy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Homework &&
    other.id == id &&
    other.classSectionId == classSectionId &&
    other.subject == subject &&
    other.title == title &&
    other.body == body &&
    other.dueDate == dueDate &&
    other.postedBy == postedBy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (classSectionId.hashCode) +
    (subject == null ? 0 : subject!.hashCode) +
    (title.hashCode) +
    (body == null ? 0 : body!.hashCode) +
    (dueDate.hashCode) +
    (postedBy == null ? 0 : postedBy!.hashCode);

  @override
  String toString() => 'Homework[id=$id, classSectionId=$classSectionId, subject=$subject, title=$title, body=$body, dueDate=$dueDate, postedBy=$postedBy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'class_section_id'] = this.classSectionId;
    if (this.subject != null) {
      json[r'subject'] = this.subject;
    } else {
      json[r'subject'] = null;
    }
      json[r'title'] = this.title;
    if (this.body != null) {
      json[r'body'] = this.body;
    } else {
      json[r'body'] = null;
    }
      json[r'due_date'] = this.dueDate;
    if (this.postedBy != null) {
      json[r'posted_by'] = this.postedBy;
    } else {
      json[r'posted_by'] = null;
    }
    return json;
  }

  /// Returns a new [Homework] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Homework? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Homework[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Homework[id]" has a null value in JSON.');
        assert(json.containsKey(r'class_section_id'), 'Required key "Homework[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "Homework[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "Homework[subject]" is missing from JSON.');
        assert(json.containsKey(r'title'), 'Required key "Homework[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "Homework[title]" has a null value in JSON.');
        assert(json.containsKey(r'body'), 'Required key "Homework[body]" is missing from JSON.');
        assert(json.containsKey(r'due_date'), 'Required key "Homework[due_date]" is missing from JSON.');
        assert(json[r'due_date'] != null, 'Required key "Homework[due_date]" has a null value in JSON.');
        return true;
      }());

      return Homework(
        id: mapValueOfType<String>(json, r'id')!,
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        subject: mapValueOfType<String>(json, r'subject'),
        title: mapValueOfType<String>(json, r'title')!,
        body: mapValueOfType<String>(json, r'body'),
        dueDate: mapValueOfType<String>(json, r'due_date')!,
        postedBy: Person.fromJson(json[r'posted_by']),
      );
    }
    return null;
  }

  static List<Homework> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Homework>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Homework.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Homework> mapFromJson(dynamic json) {
    final map = <String, Homework>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Homework.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Homework-objects as value to a dart map
  static Map<String, List<Homework>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Homework>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Homework.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'class_section_id',
    'subject',
    'title',
    'body',
    'due_date',
  };
}

