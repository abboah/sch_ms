//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Grade {
  /// Returns a new [Grade] instance.
  Grade({
    required this.studentId,
    required this.assessmentId,
    required this.score,
    required this.comment,
  });

  String studentId;

  String assessmentId;

  num? score;

  String? comment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Grade &&
    other.studentId == studentId &&
    other.assessmentId == assessmentId &&
    other.score == score &&
    other.comment == comment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (assessmentId.hashCode) +
    (score == null ? 0 : score!.hashCode) +
    (comment == null ? 0 : comment!.hashCode);

  @override
  String toString() => 'Grade[studentId=$studentId, assessmentId=$assessmentId, score=$score, comment=$comment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'assessment_id'] = this.assessmentId;
    if (this.score != null) {
      json[r'score'] = this.score;
    } else {
      json[r'score'] = null;
    }
    if (this.comment != null) {
      json[r'comment'] = this.comment;
    } else {
      json[r'comment'] = null;
    }
    return json;
  }

  /// Returns a new [Grade] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Grade? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "Grade[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "Grade[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'assessment_id'), 'Required key "Grade[assessment_id]" is missing from JSON.');
        assert(json[r'assessment_id'] != null, 'Required key "Grade[assessment_id]" has a null value in JSON.');
        assert(json.containsKey(r'score'), 'Required key "Grade[score]" is missing from JSON.');
        assert(json.containsKey(r'comment'), 'Required key "Grade[comment]" is missing from JSON.');
        return true;
      }());

      return Grade(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        assessmentId: mapValueOfType<String>(json, r'assessment_id')!,
        score: json[r'score'] == null
            ? null
            : num.parse('${json[r'score']}'),
        comment: mapValueOfType<String>(json, r'comment'),
      );
    }
    return null;
  }

  static List<Grade> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Grade>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Grade.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Grade> mapFromJson(dynamic json) {
    final map = <String, Grade>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Grade.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Grade-objects as value to a dart map
  static Map<String, List<Grade>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Grade>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Grade.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'assessment_id',
    'score',
    'comment',
  };
}

