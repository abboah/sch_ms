//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AnnouncementResponse {
  /// Returns a new [AnnouncementResponse] instance.
  AnnouncementResponse({
    required this.announcementId,
    required this.studentId,
    required this.guardianId,
    required this.response,
    required this.respondedAt,
  });

  String announcementId;

  String studentId;

  String guardianId;

  AnnouncementResponseResponseEnum response;

  DateTime respondedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AnnouncementResponse &&
    other.announcementId == announcementId &&
    other.studentId == studentId &&
    other.guardianId == guardianId &&
    other.response == response &&
    other.respondedAt == respondedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (announcementId.hashCode) +
    (studentId.hashCode) +
    (guardianId.hashCode) +
    (response.hashCode) +
    (respondedAt.hashCode);

  @override
  String toString() => 'AnnouncementResponse[announcementId=$announcementId, studentId=$studentId, guardianId=$guardianId, response=$response, respondedAt=$respondedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'announcement_id'] = this.announcementId;
      json[r'student_id'] = this.studentId;
      json[r'guardian_id'] = this.guardianId;
      json[r'response'] = this.response;
      json[r'responded_at'] = this.respondedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AnnouncementResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AnnouncementResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'announcement_id'), 'Required key "AnnouncementResponse[announcement_id]" is missing from JSON.');
        assert(json[r'announcement_id'] != null, 'Required key "AnnouncementResponse[announcement_id]" has a null value in JSON.');
        assert(json.containsKey(r'student_id'), 'Required key "AnnouncementResponse[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "AnnouncementResponse[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'guardian_id'), 'Required key "AnnouncementResponse[guardian_id]" is missing from JSON.');
        assert(json[r'guardian_id'] != null, 'Required key "AnnouncementResponse[guardian_id]" has a null value in JSON.');
        assert(json.containsKey(r'response'), 'Required key "AnnouncementResponse[response]" is missing from JSON.');
        assert(json[r'response'] != null, 'Required key "AnnouncementResponse[response]" has a null value in JSON.');
        assert(json.containsKey(r'responded_at'), 'Required key "AnnouncementResponse[responded_at]" is missing from JSON.');
        assert(json[r'responded_at'] != null, 'Required key "AnnouncementResponse[responded_at]" has a null value in JSON.');
        return true;
      }());

      return AnnouncementResponse(
        announcementId: mapValueOfType<String>(json, r'announcement_id')!,
        studentId: mapValueOfType<String>(json, r'student_id')!,
        guardianId: mapValueOfType<String>(json, r'guardian_id')!,
        response: AnnouncementResponseResponseEnum.fromJson(json[r'response'])!,
        respondedAt: mapDateTime(json, r'responded_at', r'')!,
      );
    }
    return null;
  }

  static List<AnnouncementResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AnnouncementResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AnnouncementResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AnnouncementResponse> mapFromJson(dynamic json) {
    final map = <String, AnnouncementResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AnnouncementResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AnnouncementResponse-objects as value to a dart map
  static Map<String, List<AnnouncementResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AnnouncementResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AnnouncementResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'announcement_id',
    'student_id',
    'guardian_id',
    'response',
    'responded_at',
  };
}


enum AnnouncementResponseResponseEnum {
  yes._(r'yes'),
  no._(r'no'),
  ;

  /// Instantiate a new enum with the provided value.
  const AnnouncementResponseResponseEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AnnouncementResponseResponseEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AnnouncementResponseResponseEnum? fromJson(dynamic value) => AnnouncementResponseResponseEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AnnouncementResponseResponseEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<AnnouncementResponseResponseEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AnnouncementResponseResponseEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AnnouncementResponseResponseEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AnnouncementResponseResponseEnum] to String,
/// and [decode] dynamic data back to [AnnouncementResponseResponseEnum].
class AnnouncementResponseResponseEnumTypeTransformer {
  factory AnnouncementResponseResponseEnumTypeTransformer() => _instance ??= const AnnouncementResponseResponseEnumTypeTransformer._();

  const AnnouncementResponseResponseEnumTypeTransformer._();

  String encode(AnnouncementResponseResponseEnum data) => data._value;

  /// Returns the instance of [AnnouncementResponseResponseEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AnnouncementResponseResponseEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is AnnouncementResponseResponseEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'yes': return AnnouncementResponseResponseEnum.yes;
        case r'no': return AnnouncementResponseResponseEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AnnouncementResponseResponseEnumTypeTransformer? _instance;
}


