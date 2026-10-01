//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum AttendanceStatus {
  present._(r'present'),
  late_._(r'late'),
  absent._(r'absent'),
  excused._(r'excused'),
  ;

  /// Instantiate a new enum with the provided value.
  const AttendanceStatus._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AttendanceStatus] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AttendanceStatus? fromJson(dynamic value) => AttendanceStatusTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AttendanceStatus]
  /// that were successfully decoded from the passed [JSON][json].
  static List<AttendanceStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttendanceStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttendanceStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AttendanceStatus] to String,
/// and [decode] dynamic data back to [AttendanceStatus].
class AttendanceStatusTypeTransformer {
  factory AttendanceStatusTypeTransformer() => _instance ??= const AttendanceStatusTypeTransformer._();

  const AttendanceStatusTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(AttendanceStatus data) => data._value;

  /// Returns the instance of [AttendanceStatus] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AttendanceStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data is AttendanceStatus) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'present': return AttendanceStatus.present;
        case r'late': return AttendanceStatus.late_;
        case r'absent': return AttendanceStatus.absent;
        case r'excused': return AttendanceStatus.excused;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AttendanceStatusTypeTransformer? _instance;
}

