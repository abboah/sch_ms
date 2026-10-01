//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Enrollment {
  /// Returns a new [Enrollment] instance.
  Enrollment({
    required this.id,
    required this.studentId,
    required this.classSectionId,
    this.classSectionName,
    this.termName,
    required this.status,
  });

  String id;

  String studentId;

  String classSectionId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? classSectionName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? termName;

  EnrollmentStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Enrollment &&
    other.id == id &&
    other.studentId == studentId &&
    other.classSectionId == classSectionId &&
    other.classSectionName == classSectionName &&
    other.termName == termName &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (studentId.hashCode) +
    (classSectionId.hashCode) +
    (classSectionName == null ? 0 : classSectionName!.hashCode) +
    (termName == null ? 0 : termName!.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'Enrollment[id=$id, studentId=$studentId, classSectionId=$classSectionId, classSectionName=$classSectionName, termName=$termName, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'student_id'] = this.studentId;
      json[r'class_section_id'] = this.classSectionId;
    if (this.classSectionName != null) {
      json[r'class_section_name'] = this.classSectionName;
    } else {
      json[r'class_section_name'] = null;
    }
    if (this.termName != null) {
      json[r'term_name'] = this.termName;
    } else {
      json[r'term_name'] = null;
    }
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [Enrollment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Enrollment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Enrollment[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Enrollment[id]" has a null value in JSON.');
        assert(json.containsKey(r'student_id'), 'Required key "Enrollment[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "Enrollment[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'class_section_id'), 'Required key "Enrollment[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "Enrollment[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "Enrollment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "Enrollment[status]" has a null value in JSON.');
        return true;
      }());

      return Enrollment(
        id: mapValueOfType<String>(json, r'id')!,
        studentId: mapValueOfType<String>(json, r'student_id')!,
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        classSectionName: mapValueOfType<String>(json, r'class_section_name'),
        termName: mapValueOfType<String>(json, r'term_name'),
        status: EnrollmentStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<Enrollment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Enrollment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Enrollment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Enrollment> mapFromJson(dynamic json) {
    final map = <String, Enrollment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Enrollment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Enrollment-objects as value to a dart map
  static Map<String, List<Enrollment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Enrollment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Enrollment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'student_id',
    'class_section_id',
    'status',
  };
}


enum EnrollmentStatusEnum {
  active._(r'active'),
  completed._(r'completed'),
  withdrawn._(r'withdrawn'),
  ;

  /// Instantiate a new enum with the provided value.
  const EnrollmentStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [EnrollmentStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static EnrollmentStatusEnum? fromJson(dynamic value) => EnrollmentStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [EnrollmentStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<EnrollmentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EnrollmentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EnrollmentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EnrollmentStatusEnum] to String,
/// and [decode] dynamic data back to [EnrollmentStatusEnum].
class EnrollmentStatusEnumTypeTransformer {
  factory EnrollmentStatusEnumTypeTransformer() => _instance ??= const EnrollmentStatusEnumTypeTransformer._();

  const EnrollmentStatusEnumTypeTransformer._();

  String encode(EnrollmentStatusEnum data) => data._value;

  /// Returns the instance of [EnrollmentStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EnrollmentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is EnrollmentStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'active': return EnrollmentStatusEnum.active;
        case r'completed': return EnrollmentStatusEnum.completed;
        case r'withdrawn': return EnrollmentStatusEnum.withdrawn;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static EnrollmentStatusEnumTypeTransformer? _instance;
}


