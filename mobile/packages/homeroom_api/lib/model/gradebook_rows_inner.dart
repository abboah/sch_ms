//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GradebookRowsInner {
  /// Returns a new [GradebookRowsInner] instance.
  GradebookRowsInner({
    required this.student,
    this.scores = const {},
    required this.runningGrade,
    required this.gradeBand,
  });

  StudentRef student;

  /// Keyed by assessment id
  Map<String, num?> scores;

  num? runningGrade;

  /// Label from the school's grading scale, or null if none configured
  String? gradeBand;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GradebookRowsInner &&
    other.student == student &&
    _deepEquality.equals(other.scores, scores) &&
    other.runningGrade == runningGrade &&
    other.gradeBand == gradeBand;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (student.hashCode) +
    (scores.hashCode) +
    (runningGrade == null ? 0 : runningGrade!.hashCode) +
    (gradeBand == null ? 0 : gradeBand!.hashCode);

  @override
  String toString() => 'GradebookRowsInner[student=$student, scores=$scores, runningGrade=$runningGrade, gradeBand=$gradeBand]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student'] = this.student;
      json[r'scores'] = this.scores;
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
    return json;
  }

  /// Returns a new [GradebookRowsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GradebookRowsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student'), 'Required key "GradebookRowsInner[student]" is missing from JSON.');
        assert(json[r'student'] != null, 'Required key "GradebookRowsInner[student]" has a null value in JSON.');
        assert(json.containsKey(r'scores'), 'Required key "GradebookRowsInner[scores]" is missing from JSON.');
        assert(json[r'scores'] != null, 'Required key "GradebookRowsInner[scores]" has a null value in JSON.');
        assert(json.containsKey(r'running_grade'), 'Required key "GradebookRowsInner[running_grade]" is missing from JSON.');
        assert(json.containsKey(r'grade_band'), 'Required key "GradebookRowsInner[grade_band]" is missing from JSON.');
        return true;
      }());

      return GradebookRowsInner(
        student: StudentRef.fromJson(json[r'student'])!,
        scores: mapCastOfType<String, num>(json, r'scores')!,
        runningGrade: json[r'running_grade'] == null
            ? null
            : num.parse('${json[r'running_grade']}'),
        gradeBand: mapValueOfType<String>(json, r'grade_band'),
      );
    }
    return null;
  }

  static List<GradebookRowsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GradebookRowsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GradebookRowsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GradebookRowsInner> mapFromJson(dynamic json) {
    final map = <String, GradebookRowsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GradebookRowsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GradebookRowsInner-objects as value to a dart map
  static Map<String, List<GradebookRowsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GradebookRowsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GradebookRowsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student',
    'scores',
    'running_grade',
    'grade_band',
  };
}

