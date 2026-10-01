//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Gradebook {
  /// Returns a new [Gradebook] instance.
  Gradebook({
    required this.classSectionId,
    required this.termClosed,
    this.assessments = const [],
    this.rows = const [],
  });

  String classSectionId;

  bool termClosed;

  List<Assessment> assessments;

  List<GradebookRowsInner> rows;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Gradebook &&
    other.classSectionId == classSectionId &&
    other.termClosed == termClosed &&
    _deepEquality.equals(other.assessments, assessments) &&
    _deepEquality.equals(other.rows, rows);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (termClosed.hashCode) +
    (assessments.hashCode) +
    (rows.hashCode);

  @override
  String toString() => 'Gradebook[classSectionId=$classSectionId, termClosed=$termClosed, assessments=$assessments, rows=$rows]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
      json[r'term_closed'] = this.termClosed;
      json[r'assessments'] = this.assessments;
      json[r'rows'] = this.rows;
    return json;
  }

  /// Returns a new [Gradebook] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Gradebook? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "Gradebook[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "Gradebook[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'term_closed'), 'Required key "Gradebook[term_closed]" is missing from JSON.');
        assert(json[r'term_closed'] != null, 'Required key "Gradebook[term_closed]" has a null value in JSON.');
        assert(json.containsKey(r'assessments'), 'Required key "Gradebook[assessments]" is missing from JSON.');
        assert(json[r'assessments'] != null, 'Required key "Gradebook[assessments]" has a null value in JSON.');
        assert(json.containsKey(r'rows'), 'Required key "Gradebook[rows]" is missing from JSON.');
        assert(json[r'rows'] != null, 'Required key "Gradebook[rows]" has a null value in JSON.');
        return true;
      }());

      return Gradebook(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        termClosed: mapValueOfType<bool>(json, r'term_closed')!,
        assessments: Assessment.listFromJson(json[r'assessments']),
        rows: GradebookRowsInner.listFromJson(json[r'rows']),
      );
    }
    return null;
  }

  static List<Gradebook> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Gradebook>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Gradebook.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Gradebook> mapFromJson(dynamic json) {
    final map = <String, Gradebook>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Gradebook.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Gradebook-objects as value to a dart map
  static Map<String, List<Gradebook>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Gradebook>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Gradebook.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section_id',
    'term_closed',
    'assessments',
    'rows',
  };
}

