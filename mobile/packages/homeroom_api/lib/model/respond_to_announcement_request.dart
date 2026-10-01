//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RespondToAnnouncementRequest {
  /// Returns a new [RespondToAnnouncementRequest] instance.
  RespondToAnnouncementRequest({
    required this.studentId,
    required this.response,
  });

  String studentId;

  RespondToAnnouncementRequestResponseEnum response;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RespondToAnnouncementRequest &&
    other.studentId == studentId &&
    other.response == response;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId.hashCode) +
    (response.hashCode);

  @override
  String toString() => 'RespondToAnnouncementRequest[studentId=$studentId, response=$response]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student_id'] = this.studentId;
      json[r'response'] = this.response;
    return json;
  }

  /// Returns a new [RespondToAnnouncementRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RespondToAnnouncementRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student_id'), 'Required key "RespondToAnnouncementRequest[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "RespondToAnnouncementRequest[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'response'), 'Required key "RespondToAnnouncementRequest[response]" is missing from JSON.');
        assert(json[r'response'] != null, 'Required key "RespondToAnnouncementRequest[response]" has a null value in JSON.');
        return true;
      }());

      return RespondToAnnouncementRequest(
        studentId: mapValueOfType<String>(json, r'student_id')!,
        response: RespondToAnnouncementRequestResponseEnum.fromJson(json[r'response'])!,
      );
    }
    return null;
  }

  static List<RespondToAnnouncementRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RespondToAnnouncementRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RespondToAnnouncementRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RespondToAnnouncementRequest> mapFromJson(dynamic json) {
    final map = <String, RespondToAnnouncementRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RespondToAnnouncementRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RespondToAnnouncementRequest-objects as value to a dart map
  static Map<String, List<RespondToAnnouncementRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RespondToAnnouncementRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RespondToAnnouncementRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student_id',
    'response',
  };
}


enum RespondToAnnouncementRequestResponseEnum {
  yes._(r'yes'),
  no._(r'no'),
  ;

  /// Instantiate a new enum with the provided value.
  const RespondToAnnouncementRequestResponseEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [RespondToAnnouncementRequestResponseEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static RespondToAnnouncementRequestResponseEnum? fromJson(dynamic value) => RespondToAnnouncementRequestResponseEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [RespondToAnnouncementRequestResponseEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<RespondToAnnouncementRequestResponseEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RespondToAnnouncementRequestResponseEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RespondToAnnouncementRequestResponseEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RespondToAnnouncementRequestResponseEnum] to String,
/// and [decode] dynamic data back to [RespondToAnnouncementRequestResponseEnum].
class RespondToAnnouncementRequestResponseEnumTypeTransformer {
  factory RespondToAnnouncementRequestResponseEnumTypeTransformer() => _instance ??= const RespondToAnnouncementRequestResponseEnumTypeTransformer._();

  const RespondToAnnouncementRequestResponseEnumTypeTransformer._();

  String encode(RespondToAnnouncementRequestResponseEnum data) => data._value;

  /// Returns the instance of [RespondToAnnouncementRequestResponseEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RespondToAnnouncementRequestResponseEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is RespondToAnnouncementRequestResponseEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'yes': return RespondToAnnouncementRequestResponseEnum.yes;
        case r'no': return RespondToAnnouncementRequestResponseEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static RespondToAnnouncementRequestResponseEnumTypeTransformer? _instance;
}


