//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Assessment {
  /// Returns a new [Assessment] instance.
  Assessment({
    required this.id,
    required this.subject,
    required this.title,
    required this.weight,
    required this.maxScore,
    required this.dueDate,
  });

  String id;

  String subject;

  String title;

  /// Percent of the final grade
  num weight;

  num maxScore;

  String? dueDate;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Assessment &&
    other.id == id &&
    other.subject == subject &&
    other.title == title &&
    other.weight == weight &&
    other.maxScore == maxScore &&
    other.dueDate == dueDate;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (subject.hashCode) +
    (title.hashCode) +
    (weight.hashCode) +
    (maxScore.hashCode) +
    (dueDate == null ? 0 : dueDate!.hashCode);

  @override
  String toString() => 'Assessment[id=$id, subject=$subject, title=$title, weight=$weight, maxScore=$maxScore, dueDate=$dueDate]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'subject'] = this.subject;
      json[r'title'] = this.title;
      json[r'weight'] = this.weight;
      json[r'max_score'] = this.maxScore;
    if (this.dueDate != null) {
      json[r'due_date'] = this.dueDate;
    } else {
      json[r'due_date'] = null;
    }
    return json;
  }

  /// Returns a new [Assessment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Assessment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Assessment[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Assessment[id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "Assessment[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "Assessment[subject]" has a null value in JSON.');
        assert(json.containsKey(r'title'), 'Required key "Assessment[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "Assessment[title]" has a null value in JSON.');
        assert(json.containsKey(r'weight'), 'Required key "Assessment[weight]" is missing from JSON.');
        assert(json[r'weight'] != null, 'Required key "Assessment[weight]" has a null value in JSON.');
        assert(json.containsKey(r'max_score'), 'Required key "Assessment[max_score]" is missing from JSON.');
        assert(json[r'max_score'] != null, 'Required key "Assessment[max_score]" has a null value in JSON.');
        assert(json.containsKey(r'due_date'), 'Required key "Assessment[due_date]" is missing from JSON.');
        return true;
      }());

      return Assessment(
        id: mapValueOfType<String>(json, r'id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        title: mapValueOfType<String>(json, r'title')!,
        weight: num.parse('${json[r'weight']}'),
        maxScore: num.parse('${json[r'max_score']}'),
        dueDate: mapValueOfType<String>(json, r'due_date'),
      );
    }
    return null;
  }

  static List<Assessment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Assessment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Assessment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Assessment> mapFromJson(dynamic json) {
    final map = <String, Assessment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Assessment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Assessment-objects as value to a dart map
  static Map<String, List<Assessment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Assessment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Assessment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'subject',
    'title',
    'weight',
    'max_score',
    'due_date',
  };
}

