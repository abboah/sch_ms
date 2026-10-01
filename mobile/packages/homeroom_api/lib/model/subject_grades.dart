//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubjectGrades {
  /// Returns a new [SubjectGrades] instance.
  SubjectGrades({
    required this.classSectionId,
    required this.subject,
    required this.runningGrade,
    required this.gradeBand,
    this.assessments = const [],
  });

  String classSectionId;

  String subject;

  num? runningGrade;

  /// Label from the school's grading scale, or null if none configured
  String? gradeBand;

  List<SubjectGradesAssessmentsInner> assessments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubjectGrades &&
    other.classSectionId == classSectionId &&
    other.subject == subject &&
    other.runningGrade == runningGrade &&
    other.gradeBand == gradeBand &&
    _deepEquality.equals(other.assessments, assessments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (subject.hashCode) +
    (runningGrade == null ? 0 : runningGrade!.hashCode) +
    (gradeBand == null ? 0 : gradeBand!.hashCode) +
    (assessments.hashCode);

  @override
  String toString() => 'SubjectGrades[classSectionId=$classSectionId, subject=$subject, runningGrade=$runningGrade, gradeBand=$gradeBand, assessments=$assessments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
      json[r'subject'] = this.subject;
    if (this.runningGrade != null) {
      json[r'running_grade'] = this.runningGrade;
    } else {
      json[r'running_grade'] = null;
    }
    if (this.gradeBand != null) {
      json[r'grade_band'] = this.gradeBand;
    } else {
      json[r'grade_band'] = null;
    }
      json[r'assessments'] = this.assessments;
    return json;
  }

  /// Returns a new [SubjectGrades] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubjectGrades? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "SubjectGrades[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "SubjectGrades[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "SubjectGrades[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "SubjectGrades[subject]" has a null value in JSON.');
        assert(json.containsKey(r'running_grade'), 'Required key "SubjectGrades[running_grade]" is missing from JSON.');
        assert(json.containsKey(r'grade_band'), 'Required key "SubjectGrades[grade_band]" is missing from JSON.');
        assert(json.containsKey(r'assessments'), 'Required key "SubjectGrades[assessments]" is missing from JSON.');
        assert(json[r'assessments'] != null, 'Required key "SubjectGrades[assessments]" has a null value in JSON.');
        return true;
      }());

      return SubjectGrades(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        runningGrade: json[r'running_grade'] == null
            ? null
            : num.parse('${json[r'running_grade']}'),
        gradeBand: mapValueOfType<String>(json, r'grade_band'),
        assessments: SubjectGradesAssessmentsInner.listFromJson(json[r'assessments']),
      );
    }
    return null;
  }

  static List<SubjectGrades> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubjectGrades>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubjectGrades.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubjectGrades> mapFromJson(dynamic json) {
    final map = <String, SubjectGrades>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubjectGrades.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubjectGrades-objects as value to a dart map
  static Map<String, List<SubjectGrades>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubjectGrades>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubjectGrades.listFromJson(entry.value, growable: growable,);
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
    'assessments',
  };
}

