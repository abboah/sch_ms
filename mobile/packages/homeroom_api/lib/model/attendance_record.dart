//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttendanceRecord {
  /// Returns a new [AttendanceRecord] instance.
  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classSectionId,
    required this.periodId,
    required this.periodDate,
    required this.status,
    required this.note,
    required this.markedBy,
    required this.markedAt,
  });

  String id;

  String studentId;

  String classSectionId;

  String? periodId;

  String periodDate;

  AttendanceStatus status;

  String? note;

  String markedBy;

  DateTime markedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AttendanceRecord &&
    other.id == id &&
    other.studentId == studentId &&
    other.classSectionId == classSectionId &&
    other.periodId == periodId &&
    other.periodDate == periodDate &&
    other.status == status &&
    other.note == note &&
    other.markedBy == markedBy &&
    other.markedAt == markedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (studentId.hashCode) +
    (classSectionId.hashCode) +
    (periodId == null ? 0 : periodId!.hashCode) +
    (periodDate.hashCode) +
    (status.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (markedBy.hashCode) +
    (markedAt.hashCode);

  @override
  String toString() => 'AttendanceRecord[id=$id, studentId=$studentId, classSectionId=$classSectionId, periodId=$periodId, periodDate=$periodDate, status=$status, note=$note, markedBy=$markedBy, markedAt=$markedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'student_id'] = this.studentId;
      json[r'class_section_id'] = this.classSectionId;
    if (this.periodId != null) {
      json[r'period_id'] = this.periodId;
    } else {
      json[r'period_id'] = null;
    }
      json[r'period_date'] = this.periodDate;
      json[r'status'] = this.status;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'marked_by'] = this.markedBy;
      json[r'marked_at'] = this.markedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AttendanceRecord] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttendanceRecord? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "AttendanceRecord[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "AttendanceRecord[id]" has a null value in JSON.');
        assert(json.containsKey(r'student_id'), 'Required key "AttendanceRecord[student_id]" is missing from JSON.');
        assert(json[r'student_id'] != null, 'Required key "AttendanceRecord[student_id]" has a null value in JSON.');
        assert(json.containsKey(r'class_section_id'), 'Required key "AttendanceRecord[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "AttendanceRecord[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'period_id'), 'Required key "AttendanceRecord[period_id]" is missing from JSON.');
        assert(json.containsKey(r'period_date'), 'Required key "AttendanceRecord[period_date]" is missing from JSON.');
        assert(json[r'period_date'] != null, 'Required key "AttendanceRecord[period_date]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "AttendanceRecord[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "AttendanceRecord[status]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "AttendanceRecord[note]" is missing from JSON.');
        assert(json.containsKey(r'marked_by'), 'Required key "AttendanceRecord[marked_by]" is missing from JSON.');
        assert(json[r'marked_by'] != null, 'Required key "AttendanceRecord[marked_by]" has a null value in JSON.');
        assert(json.containsKey(r'marked_at'), 'Required key "AttendanceRecord[marked_at]" is missing from JSON.');
        assert(json[r'marked_at'] != null, 'Required key "AttendanceRecord[marked_at]" has a null value in JSON.');
        return true;
      }());

      return AttendanceRecord(
        id: mapValueOfType<String>(json, r'id')!,
        studentId: mapValueOfType<String>(json, r'student_id')!,
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        periodId: mapValueOfType<String>(json, r'period_id'),
        periodDate: mapValueOfType<String>(json, r'period_date')!,
        status: AttendanceStatus.fromJson(json[r'status'])!,
        note: mapValueOfType<String>(json, r'note'),
        markedBy: mapValueOfType<String>(json, r'marked_by')!,
        markedAt: mapDateTime(json, r'marked_at', r'')!,
      );
    }
    return null;
  }

  static List<AttendanceRecord> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttendanceRecord>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttendanceRecord.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttendanceRecord> mapFromJson(dynamic json) {
    final map = <String, AttendanceRecord>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttendanceRecord.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttendanceRecord-objects as value to a dart map
  static Map<String, List<AttendanceRecord>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AttendanceRecord>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttendanceRecord.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'student_id',
    'class_section_id',
    'period_id',
    'period_date',
    'status',
    'note',
    'marked_by',
    'marked_at',
  };
}

