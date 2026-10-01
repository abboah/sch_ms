//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BatchResult {
  /// Returns a new [BatchResult] instance.
  BatchResult({
    required this.applied,
    required this.rejected,
    this.results = const [],
  });

  int applied;

  int rejected;

  List<BatchResultResultsInner> results;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BatchResult &&
    other.applied == applied &&
    other.rejected == rejected &&
    _deepEquality.equals(other.results, results);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (applied.hashCode) +
    (rejected.hashCode) +
    (results.hashCode);

  @override
  String toString() => 'BatchResult[applied=$applied, rejected=$rejected, results=$results]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'applied'] = this.applied;
      json[r'rejected'] = this.rejected;
      json[r'results'] = this.results;
    return json;
  }

  /// Returns a new [BatchResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BatchResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'applied'), 'Required key "BatchResult[applied]" is missing from JSON.');
        assert(json[r'applied'] != null, 'Required key "BatchResult[applied]" has a null value in JSON.');
        assert(json.containsKey(r'rejected'), 'Required key "BatchResult[rejected]" is missing from JSON.');
        assert(json[r'rejected'] != null, 'Required key "BatchResult[rejected]" has a null value in JSON.');
        assert(json.containsKey(r'results'), 'Required key "BatchResult[results]" is missing from JSON.');
        assert(json[r'results'] != null, 'Required key "BatchResult[results]" has a null value in JSON.');
        return true;
      }());

      return BatchResult(
        applied: mapValueOfType<int>(json, r'applied')!,
        rejected: mapValueOfType<int>(json, r'rejected')!,
        results: BatchResultResultsInner.listFromJson(json[r'results']),
      );
    }
    return null;
  }

  static List<BatchResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BatchResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BatchResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BatchResult> mapFromJson(dynamic json) {
    final map = <String, BatchResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BatchResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BatchResult-objects as value to a dart map
  static Map<String, List<BatchResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BatchResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BatchResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'applied',
    'rejected',
    'results',
  };
}

