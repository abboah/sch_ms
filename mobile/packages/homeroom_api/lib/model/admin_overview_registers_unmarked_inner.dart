//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AdminOverviewRegistersUnmarkedInner {
  /// Returns a new [AdminOverviewRegistersUnmarkedInner] instance.
  AdminOverviewRegistersUnmarkedInner({
    required this.classSection,
    required this.period,
    required this.teacher,
  });

  ClassSection classSection;

  Period period;

  Person teacher;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminOverviewRegistersUnmarkedInner &&
    other.classSection == classSection &&
    other.period == period &&
    other.teacher == teacher;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSection.hashCode) +
    (period.hashCode) +
    (teacher.hashCode);

  @override
  String toString() => 'AdminOverviewRegistersUnmarkedInner[classSection=$classSection, period=$period, teacher=$teacher]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section'] = this.classSection;
      json[r'period'] = this.period;
      json[r'teacher'] = this.teacher;
    return json;
  }

  /// Returns a new [AdminOverviewRegistersUnmarkedInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminOverviewRegistersUnmarkedInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section'), 'Required key "AdminOverviewRegistersUnmarkedInner[class_section]" is missing from JSON.');
        assert(json[r'class_section'] != null, 'Required key "AdminOverviewRegistersUnmarkedInner[class_section]" has a null value in JSON.');
        assert(json.containsKey(r'period'), 'Required key "AdminOverviewRegistersUnmarkedInner[period]" is missing from JSON.');
        assert(json[r'period'] != null, 'Required key "AdminOverviewRegistersUnmarkedInner[period]" has a null value in JSON.');
        assert(json.containsKey(r'teacher'), 'Required key "AdminOverviewRegistersUnmarkedInner[teacher]" is missing from JSON.');
        assert(json[r'teacher'] != null, 'Required key "AdminOverviewRegistersUnmarkedInner[teacher]" has a null value in JSON.');
        return true;
      }());

      return AdminOverviewRegistersUnmarkedInner(
        classSection: ClassSection.fromJson(json[r'class_section'])!,
        period: Period.fromJson(json[r'period'])!,
        teacher: Person.fromJson(json[r'teacher'])!,
      );
    }
    return null;
  }

  static List<AdminOverviewRegistersUnmarkedInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminOverviewRegistersUnmarkedInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminOverviewRegistersUnmarkedInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminOverviewRegistersUnmarkedInner> mapFromJson(dynamic json) {
    final map = <String, AdminOverviewRegistersUnmarkedInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminOverviewRegistersUnmarkedInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminOverviewRegistersUnmarkedInner-objects as value to a dart map
  static Map<String, List<AdminOverviewRegistersUnmarkedInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminOverviewRegistersUnmarkedInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminOverviewRegistersUnmarkedInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section',
    'period',
    'teacher',
  };
}

