//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReportComment {
  /// Returns a new [ReportComment] instance.
  ReportComment({
    required this.classSectionId,
    required this.subject,
    required this.body,
    required this.updatedAt,
    required this.teacher,
  });

  String classSectionId;

  String subject;

  String body;

  DateTime updatedAt;

  Person teacher;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReportComment &&
    other.classSectionId == classSectionId &&
    other.subject == subject &&
    other.body == body &&
    other.updatedAt == updatedAt &&
    other.teacher == teacher;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (subject.hashCode) +
    (body.hashCode) +
    (updatedAt.hashCode) +
    (teacher.hashCode);

  @override
  String toString() => 'ReportComment[classSectionId=$classSectionId, subject=$subject, body=$body, updatedAt=$updatedAt, teacher=$teacher]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
      json[r'subject'] = this.subject;
      json[r'body'] = this.body;
      json[r'updated_at'] = this.updatedAt.toUtc().toIso8601String();
      json[r'teacher'] = this.teacher;
    return json;
  }

  /// Returns a new [ReportComment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReportComment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "ReportComment[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "ReportComment[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "ReportComment[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "ReportComment[subject]" has a null value in JSON.');
        assert(json.containsKey(r'body'), 'Required key "ReportComment[body]" is missing from JSON.');
        assert(json[r'body'] != null, 'Required key "ReportComment[body]" has a null value in JSON.');
        assert(json.containsKey(r'updated_at'), 'Required key "ReportComment[updated_at]" is missing from JSON.');
        assert(json[r'updated_at'] != null, 'Required key "ReportComment[updated_at]" has a null value in JSON.');
        assert(json.containsKey(r'teacher'), 'Required key "ReportComment[teacher]" is missing from JSON.');
        assert(json[r'teacher'] != null, 'Required key "ReportComment[teacher]" has a null value in JSON.');
        return true;
      }());

      return ReportComment(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        body: mapValueOfType<String>(json, r'body')!,
        updatedAt: mapDateTime(json, r'updated_at', r'')!,
        teacher: Person.fromJson(json[r'teacher'])!,
      );
    }
    return null;
  }

  static List<ReportComment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportComment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportComment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReportComment> mapFromJson(dynamic json) {
    final map = <String, ReportComment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReportComment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReportComment-objects as value to a dart map
  static Map<String, List<ReportComment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReportComment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReportComment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section_id',
    'subject',
    'body',
    'updated_at',
    'teacher',
  };
}

