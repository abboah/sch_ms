//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentStartNext {
  /// Returns a new [PaymentStartNext] instance.
  PaymentStartNext({
    required this.type,
    this.redirectUrl,
    this.message,
  });

  PaymentStartNextTypeEnum type;

  /// Card: hosted checkout
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? redirectUrl;

  /// Mobile money: e.g. \"Approve the request on 024 000 0001\"
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentStartNext &&
    other.type == type &&
    other.redirectUrl == redirectUrl &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (type.hashCode) +
    (redirectUrl == null ? 0 : redirectUrl!.hashCode) +
    (message == null ? 0 : message!.hashCode);

  @override
  String toString() => 'PaymentStartNext[type=$type, redirectUrl=$redirectUrl, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'type'] = this.type;
    if (this.redirectUrl != null) {
      json[r'redirect_url'] = this.redirectUrl;
    } else {
      json[r'redirect_url'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    return json;
  }

  /// Returns a new [PaymentStartNext] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentStartNext? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'type'), 'Required key "PaymentStartNext[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "PaymentStartNext[type]" has a null value in JSON.');
        return true;
      }());

      return PaymentStartNext(
        type: PaymentStartNextTypeEnum.fromJson(json[r'type'])!,
        redirectUrl: mapValueOfType<String>(json, r'redirect_url'),
        message: mapValueOfType<String>(json, r'message'),
      );
    }
    return null;
  }

  static List<PaymentStartNext> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentStartNext>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentStartNext.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentStartNext> mapFromJson(dynamic json) {
    final map = <String, PaymentStartNext>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentStartNext.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentStartNext-objects as value to a dart map
  static Map<String, List<PaymentStartNext>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentStartNext>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentStartNext.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'type',
  };
}


enum PaymentStartNextTypeEnum {
  redirect._(r'redirect'),
  prompt._(r'prompt'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentStartNextTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentStartNextTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentStartNextTypeEnum? fromJson(dynamic value) => PaymentStartNextTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentStartNextTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentStartNextTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentStartNextTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentStartNextTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentStartNextTypeEnum] to String,
/// and [decode] dynamic data back to [PaymentStartNextTypeEnum].
class PaymentStartNextTypeEnumTypeTransformer {
  factory PaymentStartNextTypeEnumTypeTransformer() => _instance ??= const PaymentStartNextTypeEnumTypeTransformer._();

  const PaymentStartNextTypeEnumTypeTransformer._();

  String encode(PaymentStartNextTypeEnum data) => data._value;

  /// Returns the instance of [PaymentStartNextTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentStartNextTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentStartNextTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'redirect': return PaymentStartNextTypeEnum.redirect;
        case r'prompt': return PaymentStartNextTypeEnum.prompt;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentStartNextTypeEnumTypeTransformer? _instance;
}


