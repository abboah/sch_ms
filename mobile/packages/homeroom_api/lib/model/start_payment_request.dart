//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StartPaymentRequest {
  /// Returns a new [StartPaymentRequest] instance.
  StartPaymentRequest({
    required this.amount,
    required this.method,
    this.phone,
  });

  String amount;

  StartPaymentRequestMethodEnum method;

  /// Required for mobile money
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phone;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StartPaymentRequest &&
    other.amount == amount &&
    other.method == method &&
    other.phone == phone;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (amount.hashCode) +
    (method.hashCode) +
    (phone == null ? 0 : phone!.hashCode);

  @override
  String toString() => 'StartPaymentRequest[amount=$amount, method=$method, phone=$phone]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'amount'] = this.amount;
      json[r'method'] = this.method;
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    return json;
  }

  /// Returns a new [StartPaymentRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StartPaymentRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'amount'), 'Required key "StartPaymentRequest[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "StartPaymentRequest[amount]" has a null value in JSON.');
        assert(json.containsKey(r'method'), 'Required key "StartPaymentRequest[method]" is missing from JSON.');
        assert(json[r'method'] != null, 'Required key "StartPaymentRequest[method]" has a null value in JSON.');
        return true;
      }());

      return StartPaymentRequest(
        amount: mapValueOfType<String>(json, r'amount')!,
        method: StartPaymentRequestMethodEnum.fromJson(json[r'method'])!,
        phone: mapValueOfType<String>(json, r'phone'),
      );
    }
    return null;
  }

  static List<StartPaymentRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StartPaymentRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StartPaymentRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StartPaymentRequest> mapFromJson(dynamic json) {
    final map = <String, StartPaymentRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StartPaymentRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StartPaymentRequest-objects as value to a dart map
  static Map<String, List<StartPaymentRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StartPaymentRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StartPaymentRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'amount',
    'method',
  };
}


enum StartPaymentRequestMethodEnum {
  card._(r'card'),
  mtnMomo._(r'mtn_momo'),
  telecelCash._(r'telecel_cash'),
  ;

  /// Instantiate a new enum with the provided value.
  const StartPaymentRequestMethodEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StartPaymentRequestMethodEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StartPaymentRequestMethodEnum? fromJson(dynamic value) => StartPaymentRequestMethodEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StartPaymentRequestMethodEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StartPaymentRequestMethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StartPaymentRequestMethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StartPaymentRequestMethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StartPaymentRequestMethodEnum] to String,
/// and [decode] dynamic data back to [StartPaymentRequestMethodEnum].
class StartPaymentRequestMethodEnumTypeTransformer {
  factory StartPaymentRequestMethodEnumTypeTransformer() => _instance ??= const StartPaymentRequestMethodEnumTypeTransformer._();

  const StartPaymentRequestMethodEnumTypeTransformer._();

  String encode(StartPaymentRequestMethodEnum data) => data._value;

  /// Returns the instance of [StartPaymentRequestMethodEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StartPaymentRequestMethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StartPaymentRequestMethodEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'card': return StartPaymentRequestMethodEnum.card;
        case r'mtn_momo': return StartPaymentRequestMethodEnum.mtnMomo;
        case r'telecel_cash': return StartPaymentRequestMethodEnum.telecelCash;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StartPaymentRequestMethodEnumTypeTransformer? _instance;
}


