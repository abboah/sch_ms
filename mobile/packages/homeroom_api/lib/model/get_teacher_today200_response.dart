//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetTeacherToday200Response {
  /// Returns a new [GetTeacherToday200Response] instance.
  GetTeacherToday200Response({
    required this.date,
    this.periods = const [],
  });

  String date;

  List<TodayPeriod> periods;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetTeacherToday200Response &&
    other.date == date &&
    _deepEquality.equals(other.periods, periods);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (date.hashCode) +
    (periods.hashCode);

  @override
  String toString() => 'GetTeacherToday200Response[date=$date, periods=$periods]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'date'] = this.date;
      json[r'periods'] = this.periods;
    return json;
  }

  /// Returns a new [GetTeacherToday200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetTeacherToday200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'date'), 'Required key "GetTeacherToday200Response[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "GetTeacherToday200Response[date]" has a null value in JSON.');
        assert(json.containsKey(r'periods'), 'Required key "GetTeacherToday200Response[periods]" is missing from JSON.');
        assert(json[r'periods'] != null, 'Required key "GetTeacherToday200Response[periods]" has a null value in JSON.');
        return true;
      }());

      return GetTeacherToday200Response(
        date: mapValueOfType<String>(json, r'date')!,
        periods: TodayPeriod.listFromJson(json[r'periods']),
      );
    }
    return null;
  }

  static List<GetTeacherToday200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetTeacherToday200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetTeacherToday200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetTeacherToday200Response> mapFromJson(dynamic json) {
    final map = <String, GetTeacherToday200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetTeacherToday200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetTeacherToday200Response-objects as value to a dart map
  static Map<String, List<GetTeacherToday200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetTeacherToday200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetTeacherToday200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'date',
    'periods',
  };
}

