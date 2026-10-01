//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttendanceReport {
  /// Returns a new [AttendanceReport] instance.
  AttendanceReport({
    required this.from,
    required this.to,
    this.rows = const [],
  });

  String from;

  String to;

  List<AttendanceReportRowsInner> rows;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AttendanceReport &&
    other.from == from &&
    other.to == to &&
    _deepEquality.equals(other.rows, rows);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (rows.hashCode);

  @override
  String toString() => 'AttendanceReport[from=$from, to=$to, rows=$rows]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = this.from;
      json[r'to'] = this.to;
      json[r'rows'] = this.rows;
    return json;
  }

  /// Returns a new [AttendanceReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttendanceReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'from'), 'Required key "AttendanceReport[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "AttendanceReport[from]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "AttendanceReport[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "AttendanceReport[to]" has a null value in JSON.');
        assert(json.containsKey(r'rows'), 'Required key "AttendanceReport[rows]" is missing from JSON.');
        assert(json[r'rows'] != null, 'Required key "AttendanceReport[rows]" has a null value in JSON.');
        return true;
      }());

      return AttendanceReport(
        from: mapValueOfType<String>(json, r'from')!,
        to: mapValueOfType<String>(json, r'to')!,
        rows: AttendanceReportRowsInner.listFromJson(json[r'rows']),
      );
    }
    return null;
  }

  static List<AttendanceReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttendanceReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttendanceReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttendanceReport> mapFromJson(dynamic json) {
    final map = <String, AttendanceReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttendanceReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttendanceReport-objects as value to a dart map
  static Map<String, List<AttendanceReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AttendanceReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttendanceReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'rows',
  };
}

