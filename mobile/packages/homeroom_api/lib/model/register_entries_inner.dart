//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterEntriesInner {
  /// Returns a new [RegisterEntriesInner] instance.
  RegisterEntriesInner({
    required this.student,
    required this.status,
    required this.note,
    required this.recordId,
  });

  StudentRef student;

  RegisterEntriesInnerStatusEnum? status;

  String? note;

  String? recordId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterEntriesInner &&
    other.student == student &&
    other.status == status &&
    other.note == note &&
    other.recordId == recordId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (student.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (recordId == null ? 0 : recordId!.hashCode);

  @override
  String toString() => 'RegisterEntriesInner[student=$student, status=$status, note=$note, recordId=$recordId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'student'] = this.student;
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.recordId != null) {
      json[r'record_id'] = this.recordId;
    } else {
      json[r'record_id'] = null;
    }
    return json;
  }

  /// Returns a new [RegisterEntriesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterEntriesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'student'), 'Required key "RegisterEntriesInner[student]" is missing from JSON.');
        assert(json[r'student'] != null, 'Required key "RegisterEntriesInner[student]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "RegisterEntriesInner[status]" is missing from JSON.');
        assert(json.containsKey(r'note'), 'Required key "RegisterEntriesInner[note]" is missing from JSON.');
        assert(json.containsKey(r'record_id'), 'Required key "RegisterEntriesInner[record_id]" is missing from JSON.');
        return true;
      }());

      return RegisterEntriesInner(
        student: StudentRef.fromJson(json[r'student'])!,
        status: RegisterEntriesInnerStatusEnum.fromJson(json[r'status']),
        note: mapValueOfType<String>(json, r'note'),
        recordId: mapValueOfType<String>(json, r'record_id'),
      );
    }
    return null;
  }

  static List<RegisterEntriesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterEntriesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterEntriesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterEntriesInner> mapFromJson(dynamic json) {
    final map = <String, RegisterEntriesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterEntriesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterEntriesInner-objects as value to a dart map
  static Map<String, List<RegisterEntriesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterEntriesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterEntriesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'student',
    'status',
    'note',
    'record_id',
  };
}


enum RegisterEntriesInnerStatusEnum {
  present._(r'present'),
  late_._(r'late'),
  absent._(r'absent'),
  excused._(r'excused'),
  ;

  /// Instantiate a new enum with the provided value.
  const RegisterEntriesInnerStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [RegisterEntriesInnerStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static RegisterEntriesInnerStatusEnum? fromJson(dynamic value) => RegisterEntriesInnerStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [RegisterEntriesInnerStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<RegisterEntriesInnerStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterEntriesInnerStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterEntriesInnerStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegisterEntriesInnerStatusEnum] to String,
/// and [decode] dynamic data back to [RegisterEntriesInnerStatusEnum].
class RegisterEntriesInnerStatusEnumTypeTransformer {
  factory RegisterEntriesInnerStatusEnumTypeTransformer() => _instance ??= const RegisterEntriesInnerStatusEnumTypeTransformer._();

  const RegisterEntriesInnerStatusEnumTypeTransformer._();

  String encode(RegisterEntriesInnerStatusEnum data) => data._value;

  /// Returns the instance of [RegisterEntriesInnerStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegisterEntriesInnerStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is RegisterEntriesInnerStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'present': return RegisterEntriesInnerStatusEnum.present;
        case r'late': return RegisterEntriesInnerStatusEnum.late_;
        case r'absent': return RegisterEntriesInnerStatusEnum.absent;
        case r'excused': return RegisterEntriesInnerStatusEnum.excused;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static RegisterEntriesInnerStatusEnumTypeTransformer? _instance;
}


