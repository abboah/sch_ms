//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegisterSubmission {
  /// Returns a new [RegisterSubmission] instance.
  RegisterSubmission({
    required this.date,
    this.periodId,
    this.entries = const [],
  });

  String date;

  String? periodId;

  List<RegisterSubmissionEntriesInner> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterSubmission &&
    other.date == date &&
    other.periodId == periodId &&
    _deepEquality.equals(other.entries, entries);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (date.hashCode) +
    (periodId == null ? 0 : periodId!.hashCode) +
    (entries.hashCode);

  @override
  String toString() => 'RegisterSubmission[date=$date, periodId=$periodId, entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'date'] = this.date;
    if (this.periodId != null) {
      json[r'period_id'] = this.periodId;
    } else {
      json[r'period_id'] = null;
    }
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [RegisterSubmission] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterSubmission? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'date'), 'Required key "RegisterSubmission[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "RegisterSubmission[date]" has a null value in JSON.');
        assert(json.containsKey(r'entries'), 'Required key "RegisterSubmission[entries]" is missing from JSON.');
        assert(json[r'entries'] != null, 'Required key "RegisterSubmission[entries]" has a null value in JSON.');
        return true;
      }());

      return RegisterSubmission(
        date: mapValueOfType<String>(json, r'date')!,
        periodId: mapValueOfType<String>(json, r'period_id'),
        entries: RegisterSubmissionEntriesInner.listFromJson(json[r'entries']),
      );
    }
    return null;
  }

  static List<RegisterSubmission> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterSubmission>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterSubmission.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterSubmission> mapFromJson(dynamic json) {
    final map = <String, RegisterSubmission>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterSubmission.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterSubmission-objects as value to a dart map
  static Map<String, List<RegisterSubmission>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterSubmission>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterSubmission.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'date',
    'entries',
  };
}

