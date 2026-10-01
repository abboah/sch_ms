//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterPushTokenRequest {
  /// Returns a new [RegisterPushTokenRequest] instance.
  RegisterPushTokenRequest({
    required this.token,
    required this.platform,
  });

  String token;

  RegisterPushTokenRequestPlatformEnum platform;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterPushTokenRequest &&
    other.token == token &&
    other.platform == platform;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (platform.hashCode);

  @override
  String toString() => 'RegisterPushTokenRequest[token=$token, platform=$platform]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
      json[r'platform'] = this.platform;
    return json;
  }

  /// Returns a new [RegisterPushTokenRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterPushTokenRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'token'), 'Required key "RegisterPushTokenRequest[token]" is missing from JSON.');
        assert(json[r'token'] != null, 'Required key "RegisterPushTokenRequest[token]" has a null value in JSON.');
        assert(json.containsKey(r'platform'), 'Required key "RegisterPushTokenRequest[platform]" is missing from JSON.');
        assert(json[r'platform'] != null, 'Required key "RegisterPushTokenRequest[platform]" has a null value in JSON.');
        return true;
      }());

      return RegisterPushTokenRequest(
        token: mapValueOfType<String>(json, r'token')!,
        platform: RegisterPushTokenRequestPlatformEnum.fromJson(json[r'platform'])!,
      );
    }
    return null;
  }

  static List<RegisterPushTokenRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterPushTokenRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterPushTokenRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterPushTokenRequest> mapFromJson(dynamic json) {
    final map = <String, RegisterPushTokenRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterPushTokenRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterPushTokenRequest-objects as value to a dart map
  static Map<String, List<RegisterPushTokenRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterPushTokenRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterPushTokenRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
    'platform',
  };
}


enum RegisterPushTokenRequestPlatformEnum {
  ios._(r'ios'),
  android._(r'android'),
  web._(r'web'),
  ;

  /// Instantiate a new enum with the provided value.
  const RegisterPushTokenRequestPlatformEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [RegisterPushTokenRequestPlatformEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static RegisterPushTokenRequestPlatformEnum? fromJson(dynamic value) => RegisterPushTokenRequestPlatformEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [RegisterPushTokenRequestPlatformEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<RegisterPushTokenRequestPlatformEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterPushTokenRequestPlatformEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterPushTokenRequestPlatformEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegisterPushTokenRequestPlatformEnum] to String,
/// and [decode] dynamic data back to [RegisterPushTokenRequestPlatformEnum].
class RegisterPushTokenRequestPlatformEnumTypeTransformer {
  factory RegisterPushTokenRequestPlatformEnumTypeTransformer() => _instance ??= const RegisterPushTokenRequestPlatformEnumTypeTransformer._();

  const RegisterPushTokenRequestPlatformEnumTypeTransformer._();

  String encode(RegisterPushTokenRequestPlatformEnum data) => data._value;

  /// Returns the instance of [RegisterPushTokenRequestPlatformEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegisterPushTokenRequestPlatformEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is RegisterPushTokenRequestPlatformEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'ios': return RegisterPushTokenRequestPlatformEnum.ios;
        case r'android': return RegisterPushTokenRequestPlatformEnum.android;
        case r'web': return RegisterPushTokenRequestPlatformEnum.web;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static RegisterPushTokenRequestPlatformEnumTypeTransformer? _instance;
}


