//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StudentSummaryAttendance {
  /// Returns a new [StudentSummaryAttendance] instance.
  StudentSummaryAttendance({
    required this.total,
    required this.present,
    required this.late_,
    required this.absent,
    required this.excused,
    required this.ratePct,
  });

  int total;

  int present;

  int late_;

  int absent;

  int excused;

  /// (present + late) / total; excused counts as absent for the rate
  num? ratePct;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StudentSummaryAttendance &&
    other.total == total &&
    other.present == present &&
    other.late_ == late_ &&
    other.absent == absent &&
    other.excused == excused &&
    other.ratePct == ratePct;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode) +
    (present.hashCode) +
    (late_.hashCode) +
    (absent.hashCode) +
    (excused.hashCode) +
    (ratePct == null ? 0 : ratePct!.hashCode);

  @override
  String toString() => 'StudentSummaryAttendance[total=$total, present=$present, late_=$late_, absent=$absent, excused=$excused, ratePct=$ratePct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
      json[r'present'] = this.present;
      json[r'late'] = this.late_;
      json[r'absent'] = this.absent;
      json[r'excused'] = this.excused;
    if (this.ratePct != null) {
      json[r'rate_pct'] = this.ratePct;
    } else {
      json[r'rate_pct'] = null;
    }
    return json;
  }

  /// Returns a new [StudentSummaryAttendance] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StudentSummaryAttendance? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'total'), 'Required key "StudentSummaryAttendance[total]" is missing from JSON.');
        assert(json[r'total'] != null, 'Required key "StudentSummaryAttendance[total]" has a null value in JSON.');
        assert(json.containsKey(r'present'), 'Required key "StudentSummaryAttendance[present]" is missing from JSON.');
        assert(json[r'present'] != null, 'Required key "StudentSummaryAttendance[present]" has a null value in JSON.');
        assert(json.containsKey(r'late'), 'Required key "StudentSummaryAttendance[late]" is missing from JSON.');
        assert(json[r'late'] != null, 'Required key "StudentSummaryAttendance[late]" has a null value in JSON.');
        assert(json.containsKey(r'absent'), 'Required key "StudentSummaryAttendance[absent]" is missing from JSON.');
        assert(json[r'absent'] != null, 'Required key "StudentSummaryAttendance[absent]" has a null value in JSON.');
        assert(json.containsKey(r'excused'), 'Required key "StudentSummaryAttendance[excused]" is missing from JSON.');
        assert(json[r'excused'] != null, 'Required key "StudentSummaryAttendance[excused]" has a null value in JSON.');
        assert(json.containsKey(r'rate_pct'), 'Required key "StudentSummaryAttendance[rate_pct]" is missing from JSON.');
        return true;
      }());

      return StudentSummaryAttendance(
        total: mapValueOfType<int>(json, r'total')!,
        present: mapValueOfType<int>(json, r'present')!,
        late_: mapValueOfType<int>(json, r'late')!,
        absent: mapValueOfType<int>(json, r'absent')!,
        excused: mapValueOfType<int>(json, r'excused')!,
        ratePct: json[r'rate_pct'] == null
            ? null
            : num.parse('${json[r'rate_pct']}'),
      );
    }
    return null;
  }

  static List<StudentSummaryAttendance> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StudentSummaryAttendance>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StudentSummaryAttendance.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StudentSummaryAttendance> mapFromJson(dynamic json) {
    final map = <String, StudentSummaryAttendance>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StudentSummaryAttendance.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StudentSummaryAttendance-objects as value to a dart map
  static Map<String, List<StudentSummaryAttendance>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StudentSummaryAttendance>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StudentSummaryAttendance.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'present',
    'late',
    'absent',
    'excused',
    'rate_pct',
  };
}

