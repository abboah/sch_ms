//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CompleteSandboxPaymentRequest {
  /// Returns a new [CompleteSandboxPaymentRequest] instance.
  CompleteSandboxPaymentRequest({
    required this.reference,
    required this.outcome,
  });

  String reference;

  CompleteSandboxPaymentRequestOutcomeEnum outcome;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CompleteSandboxPaymentRequest &&
    other.reference == reference &&
    other.outcome == outcome;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reference.hashCode) +
    (outcome.hashCode);

  @override
  String toString() => 'CompleteSandboxPaymentRequest[reference=$reference, outcome=$outcome]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'reference'] = this.reference;
      json[r'outcome'] = this.outcome;
    return json;
  }

  /// Returns a new [CompleteSandboxPaymentRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CompleteSandboxPaymentRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'reference'), 'Required key "CompleteSandboxPaymentRequest[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "CompleteSandboxPaymentRequest[reference]" has a null value in JSON.');
        assert(json.containsKey(r'outcome'), 'Required key "CompleteSandboxPaymentRequest[outcome]" is missing from JSON.');
        assert(json[r'outcome'] != null, 'Required key "CompleteSandboxPaymentRequest[outcome]" has a null value in JSON.');
        return true;
      }());

      return CompleteSandboxPaymentRequest(
        reference: mapValueOfType<String>(json, r'reference')!,
        outcome: CompleteSandboxPaymentRequestOutcomeEnum.fromJson(json[r'outcome'])!,
      );
    }
    return null;
  }

  static List<CompleteSandboxPaymentRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CompleteSandboxPaymentRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CompleteSandboxPaymentRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CompleteSandboxPaymentRequest> mapFromJson(dynamic json) {
    final map = <String, CompleteSandboxPaymentRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CompleteSandboxPaymentRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CompleteSandboxPaymentRequest-objects as value to a dart map
  static Map<String, List<CompleteSandboxPaymentRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CompleteSandboxPaymentRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CompleteSandboxPaymentRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'reference',
    'outcome',
  };
}


enum CompleteSandboxPaymentRequestOutcomeEnum {
  succeeded._(r'succeeded'),
  failed._(r'failed'),
  ;

  /// Instantiate a new enum with the provided value.
  const CompleteSandboxPaymentRequestOutcomeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CompleteSandboxPaymentRequestOutcomeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CompleteSandboxPaymentRequestOutcomeEnum? fromJson(dynamic value) => CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CompleteSandboxPaymentRequestOutcomeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CompleteSandboxPaymentRequestOutcomeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CompleteSandboxPaymentRequestOutcomeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CompleteSandboxPaymentRequestOutcomeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CompleteSandboxPaymentRequestOutcomeEnum] to String,
/// and [decode] dynamic data back to [CompleteSandboxPaymentRequestOutcomeEnum].
class CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer {
  factory CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer() => _instance ??= const CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer._();

  const CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer._();

  String encode(CompleteSandboxPaymentRequestOutcomeEnum data) => data._value;

  /// Returns the instance of [CompleteSandboxPaymentRequestOutcomeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CompleteSandboxPaymentRequestOutcomeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CompleteSandboxPaymentRequestOutcomeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'succeeded': return CompleteSandboxPaymentRequestOutcomeEnum.succeeded;
        case r'failed': return CompleteSandboxPaymentRequestOutcomeEnum.failed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CompleteSandboxPaymentRequestOutcomeEnumTypeTransformer? _instance;
}


