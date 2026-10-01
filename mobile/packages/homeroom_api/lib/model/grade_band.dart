//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GradeBand {
  /// Returns a new [GradeBand] instance.
  GradeBand({
    required this.id,
    required this.label,
    required this.minScore,
    required this.maxScore,
  });

  String id;

  String label;

  num minScore;

  num maxScore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GradeBand &&
    other.id == id &&
    other.label == label &&
    other.minScore == minScore &&
    other.maxScore == maxScore;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (label.hashCode) +
    (minScore.hashCode) +
    (maxScore.hashCode);

  @override
  String toString() => 'GradeBand[id=$id, label=$label, minScore=$minScore, maxScore=$maxScore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'label'] = this.label;
      json[r'min_score'] = this.minScore;
      json[r'max_score'] = this.maxScore;
    return json;
  }

  /// Returns a new [GradeBand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GradeBand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "GradeBand[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "GradeBand[id]" has a null value in JSON.');
        assert(json.containsKey(r'label'), 'Required key "GradeBand[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "GradeBand[label]" has a null value in JSON.');
        assert(json.containsKey(r'min_score'), 'Required key "GradeBand[min_score]" is missing from JSON.');
        assert(json[r'min_score'] != null, 'Required key "GradeBand[min_score]" has a null value in JSON.');
        assert(json.containsKey(r'max_score'), 'Required key "GradeBand[max_score]" is missing from JSON.');
        assert(json[r'max_score'] != null, 'Required key "GradeBand[max_score]" has a null value in JSON.');
        return true;
      }());

      return GradeBand(
        id: mapValueOfType<String>(json, r'id')!,
        label: mapValueOfType<String>(json, r'label')!,
        minScore: num.parse('${json[r'min_score']}'),
        maxScore: num.parse('${json[r'max_score']}'),
      );
    }
    return null;
  }

  static List<GradeBand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GradeBand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GradeBand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GradeBand> mapFromJson(dynamic json) {
    final map = <String, GradeBand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GradeBand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GradeBand-objects as value to a dart map
  static Map<String, List<GradeBand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GradeBand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GradeBand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'label',
    'min_score',
    'max_score',
  };
}

