//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateGradeBandRequest {
  /// Returns a new [CreateGradeBandRequest] instance.
  CreateGradeBandRequest({
    required this.label,
    required this.minScore,
    required this.maxScore,
  });

  String label;

  num minScore;

  num maxScore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateGradeBandRequest &&
    other.label == label &&
    other.minScore == minScore &&
    other.maxScore == maxScore;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (label.hashCode) +
    (minScore.hashCode) +
    (maxScore.hashCode);

  @override
  String toString() => 'CreateGradeBandRequest[label=$label, minScore=$minScore, maxScore=$maxScore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'label'] = this.label;
      json[r'min_score'] = this.minScore;
      json[r'max_score'] = this.maxScore;
    return json;
  }

  /// Returns a new [CreateGradeBandRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateGradeBandRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'label'), 'Required key "CreateGradeBandRequest[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "CreateGradeBandRequest[label]" has a null value in JSON.');
        assert(json.containsKey(r'min_score'), 'Required key "CreateGradeBandRequest[min_score]" is missing from JSON.');
        assert(json[r'min_score'] != null, 'Required key "CreateGradeBandRequest[min_score]" has a null value in JSON.');
        assert(json.containsKey(r'max_score'), 'Required key "CreateGradeBandRequest[max_score]" is missing from JSON.');
        assert(json[r'max_score'] != null, 'Required key "CreateGradeBandRequest[max_score]" has a null value in JSON.');
        return true;
      }());

      return CreateGradeBandRequest(
        label: mapValueOfType<String>(json, r'label')!,
        minScore: num.parse('${json[r'min_score']}'),
        maxScore: num.parse('${json[r'max_score']}'),
      );
    }
    return null;
  }

  static List<CreateGradeBandRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateGradeBandRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateGradeBandRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateGradeBandRequest> mapFromJson(dynamic json) {
    final map = <String, CreateGradeBandRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateGradeBandRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateGradeBandRequest-objects as value to a dart map
  static Map<String, List<CreateGradeBandRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateGradeBandRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateGradeBandRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'label',
    'min_score',
    'max_score',
  };
}

