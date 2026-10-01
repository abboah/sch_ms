//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BatchResultResultsInner {
  /// Returns a new [BatchResultResultsInner] instance.
  BatchResultResultsInner({
    required this.studentId,
    required this.outcome,
    this.code,
    this.message,
  });

  String studentId;

  BatchResultResultsInnerOutcomeEnum outcome;

  String? code;

  String? message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BatchResultResultsInner &&
    other.studentId == studentId &&
    other.outcome == outcome &&
    other.code == code &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (outcome.hashCode) +
    (code == null ? 0 : code!.hashCode) +
    (message == null ? 0 : message!.hashCode);

  @override
  String toString() => 'BatchResultResultsInner[studentId=$studentId, outcome=$outcome, code=$code, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'outcome'] = this.outcome;
    if (this.code != null) {
      json[r'code'] = this.code;
    } else {
      json[r'code'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    return json;
  }

  /// Returns a new [BatchResultResultsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BatchResultResultsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "BatchResultResultsInner[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "BatchResultResultsInner[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'outcome'), 'Required key "BatchResultResultsInner[outcome]" is missing from JSON.');
        assert(json[r'outcome'] != null, 'Required key "BatchResultResultsInner[outcome]" has a null value in JSON.');
        return true;
      }());

      return BatchResultResultsInner(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        outcome: BatchResultResultsInnerOutcomeEnum.fromJson(json[r'outcome'])!,
        code: mapValueOfType<String>(json, r'code'),
        message: mapValueOfType<String>(json, r'message'),
      );
    }
    return null;
  }

  static List<BatchResultResultsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BatchResultResultsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BatchResultResultsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BatchResultResultsInner> mapFromJson(dynamic json) {
    final map = <String, BatchResultResultsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BatchResultResultsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BatchResultResultsInner-objects as value to a dart map
  static Map<String, List<BatchResultResultsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BatchResultResultsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BatchResultResultsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'outcome',
  };
}


enum BatchResultResultsInnerOutcomeEnum {
  applied._(r'applied'),
  stale._(r'stale'),
  rejected._(r'rejected'),
  ;

  /// Instantiate a new enum with the provided value.
  const BatchResultResultsInnerOutcomeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [BatchResultResultsInnerOutcomeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static BatchResultResultsInnerOutcomeEnum? fromJson(dynamic value) => BatchResultResultsInnerOutcomeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [BatchResultResultsInnerOutcomeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<BatchResultResultsInnerOutcomeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BatchResultResultsInnerOutcomeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BatchResultResultsInnerOutcomeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [BatchResultResultsInnerOutcomeEnum] to String,
/// and [decode] dynamic data back to [BatchResultResultsInnerOutcomeEnum].
class BatchResultResultsInnerOutcomeEnumTypeTransformer {
  factory BatchResultResultsInnerOutcomeEnumTypeTransformer() => _instance ??= const BatchResultResultsInnerOutcomeEnumTypeTransformer._();

  const BatchResultResultsInnerOutcomeEnumTypeTransformer._();

  String encode(BatchResultResultsInnerOutcomeEnum data) => data._value;

  /// Returns the instance of [BatchResultResultsInnerOutcomeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  BatchResultResultsInnerOutcomeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is BatchResultResultsInnerOutcomeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'applied': return BatchResultResultsInnerOutcomeEnum.applied;
        case r'stale': return BatchResultResultsInnerOutcomeEnum.stale;
        case r'rejected': return BatchResultResultsInnerOutcomeEnum.rejected;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static BatchResultResultsInnerOutcomeEnumTypeTransformer? _instance;
}


