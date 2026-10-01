//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SignInResult {
  /// Returns a new [SignInResult] instance.
  SignInResult({
    required this.status,
    this.session,
    this.selection,
  });

  SignInResultStatusEnum status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Session? session;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  SelectionRequired? selection;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SignInResult &&
    other.status == status &&
    other.session == session &&
    other.selection == selection;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode) +
    (session == null ? 0 : session!.hashCode) +
    (selection == null ? 0 : selection!.hashCode);

  @override
  String toString() => 'SignInResult[status=$status, session=$session, selection=$selection]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
    if (this.session != null) {
      json[r'session'] = this.session;
    } else {
      json[r'session'] = null;
    }
    if (this.selection != null) {
      json[r'selection'] = this.selection;
    } else {
      json[r'selection'] = null;
    }
    return json;
  }

  /// Returns a new [SignInResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SignInResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'status'), 'Required key "SignInResult[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "SignInResult[status]" has a null value in JSON.');
        return true;
      }());

      return SignInResult(
        status: SignInResultStatusEnum.fromJson(json[r'status'])!,
        session: Session.fromJson(json[r'session']),
        selection: SelectionRequired.fromJson(json[r'selection']),
      );
    }
    return null;
  }

  static List<SignInResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignInResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignInResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SignInResult> mapFromJson(dynamic json) {
    final map = <String, SignInResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SignInResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SignInResult-objects as value to a dart map
  static Map<String, List<SignInResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SignInResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SignInResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
  };
}


enum SignInResultStatusEnum {
  signedIn._(r'signed_in'),
  selectionRequired._(r'selection_required'),
  ;

  /// Instantiate a new enum with the provided value.
  const SignInResultStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SignInResultStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SignInResultStatusEnum? fromJson(dynamic value) => SignInResultStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SignInResultStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SignInResultStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignInResultStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignInResultStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SignInResultStatusEnum] to String,
/// and [decode] dynamic data back to [SignInResultStatusEnum].
class SignInResultStatusEnumTypeTransformer {
  factory SignInResultStatusEnumTypeTransformer() => _instance ??= const SignInResultStatusEnumTypeTransformer._();

  const SignInResultStatusEnumTypeTransformer._();

  String encode(SignInResultStatusEnum data) => data._value;

  /// Returns the instance of [SignInResultStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SignInResultStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SignInResultStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'signed_in': return SignInResultStatusEnum.signedIn;
        case r'selection_required': return SignInResultStatusEnum.selectionRequired;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SignInResultStatusEnumTypeTransformer? _instance;
}


