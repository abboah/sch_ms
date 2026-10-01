//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AssessmentInput {
  /// Returns a new [AssessmentInput] instance.
  AssessmentInput({
    this.subject,
    this.title,
    this.weight,
    this.maxScore,
    this.dueDate,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subject;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? title;

  /// Minimum value: 0.01
  /// Maximum value: 100
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? weight;

  /// Minimum value: 0.01
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? maxScore;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dueDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AssessmentInput &&
    other.subject == subject &&
    other.title == title &&
    other.weight == weight &&
    other.maxScore == maxScore &&
    other.dueDate == dueDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subject == null ? 0 : subject!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (weight == null ? 0 : weight!.hashCode) +
    (maxScore == null ? 0 : maxScore!.hashCode) +
    (dueDate == null ? 0 : dueDate!.hashCode);

  @override
  String toString() => 'AssessmentInput[subject=$subject, title=$title, weight=$weight, maxScore=$maxScore, dueDate=$dueDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.subject != null) {
      json[r'subject'] = this.subject;
    } else {
      json[r'subject'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    if (this.weight != null) {
      json[r'weight'] = this.weight;
    } else {
      json[r'weight'] = null;
    }
    if (this.maxScore != null) {
      json[r'max_score'] = this.maxScore;
    } else {
      json[r'max_score'] = null;
    }
    if (this.dueDate != null) {
      json[r'due_date'] = this.dueDate;
    } else {
      json[r'due_date'] = null;
    }
    return json;
  }

  /// Returns a new [AssessmentInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AssessmentInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return AssessmentInput(
        subject: mapValueOfType<String>(json, r'subject'),
        title: mapValueOfType<String>(json, r'title'),
        weight: json[r'weight'] == null
            ? null
            : num.parse('${json[r'weight']}'),
        maxScore: json[r'max_score'] == null
            ? null
            : num.parse('${json[r'max_score']}'),
        dueDate: mapValueOfType<String>(json, r'due_date'),
      );
    }
    return null;
  }

  static List<AssessmentInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AssessmentInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AssessmentInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AssessmentInput> mapFromJson(dynamic json) {
    final map = <String, AssessmentInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AssessmentInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AssessmentInput-objects as value to a dart map
  static Map<String, List<AssessmentInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AssessmentInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AssessmentInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

