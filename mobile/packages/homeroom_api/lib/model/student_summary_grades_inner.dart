//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudentSummaryGradesInner {
  /// Returns a new [StudentSummaryGradesInner] instance.
  StudentSummaryGradesInner({
    required this.classSectionId,
    required this.subject,
    required this.runningGrade,
    required this.gradeBand,
  });

  String classSectionId;

  String subject;

  /// Weighted over assessments that have a score
  num runningGrade;

  /// Label from the school's grading scale, or null if none configured
  String? gradeBand;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudentSummaryGradesInner &&
    other.classSectionId == classSectionId &&
    other.subject == subject &&
    other.runningGrade == runningGrade &&
    other.gradeBand == gradeBand;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (subject.hashCode) +
    (runningGrade.hashCode) +
    (gradeBand == null ? 0 : gradeBand!.hashCode);

  @override
  String toString() => 'StudentSummaryGradesInner[classSectionId=$classSectionId, subject=$subject, runningGrade=$runningGrade, gradeBand=$gradeBand]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
      json[r'subject'] = this.subject;
      json[r'running_grade'] = this.runningGrade;
    if (this.gradeBand != null) {
      json[r'grade_band'] = this.gradeBand;
    } else {
      json[r'grade_band'] = null;
    }
    return json;
  }

  /// Returns a new [StudentSummaryGradesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudentSummaryGradesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "StudentSummaryGradesInner[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "StudentSummaryGradesInner[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "StudentSummaryGradesInner[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "StudentSummaryGradesInner[subject]" has a null value in JSON.');
        assert(json.containsKey(r'running_grade'), 'Required key "StudentSummaryGradesInner[running_grade]" is missing from JSON.');
        assert(json[r'running_grade'] != null, 'Required key "StudentSummaryGradesInner[running_grade]" has a null value in JSON.');
        assert(json.containsKey(r'grade_band'), 'Required key "StudentSummaryGradesInner[grade_band]" is missing from JSON.');
        return true;
      }());

      return StudentSummaryGradesInner(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        runningGrade: num.parse('${json[r'running_grade']}'),
        gradeBand: mapValueOfType<String>(json, r'grade_band'),
      );
    }
    return null;
  }

  static List<StudentSummaryGradesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudentSummaryGradesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudentSummaryGradesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudentSummaryGradesInner> mapFromJson(dynamic json) {
    final map = <String, StudentSummaryGradesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudentSummaryGradesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudentSummaryGradesInner-objects as value to a dart map
  static Map<String, List<StudentSummaryGradesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudentSummaryGradesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudentSummaryGradesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section_id',
    'subject',
    'running_grade',
    'grade_band',
  };
}

