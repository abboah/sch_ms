//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Register {
  /// Returns a new [Register] instance.
  Register({
    required this.classSectionId,
    required this.periodId,
    required this.date,
    required this.termClosed,
    this.entries = const [],
  });

  String classSectionId;

  String? periodId;

  String date;

  /// True means read-only for teachers
  bool termClosed;

  List<RegisterEntriesInner> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Register &&
    other.classSectionId == classSectionId &&
    other.periodId == periodId &&
    other.date == date &&
    other.termClosed == termClosed &&
    _deepEquality.equals(other.entries, entries);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (periodId == null ? 0 : periodId!.hashCode) +
    (date.hashCode) +
    (termClosed.hashCode) +
    (entries.hashCode);

  @override
  String toString() => 'Register[classSectionId=$classSectionId, periodId=$periodId, date=$date, termClosed=$termClosed, entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
    if (this.periodId != null) {
      json[r'period_id'] = this.periodId;
    } else {
      json[r'period_id'] = null;
    }
      json[r'date'] = this.date;
      json[r'term_closed'] = this.termClosed;
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [Register] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Register? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "Register[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "Register[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'period_id'), 'Required key "Register[period_id]" is missing from JSON.');
        assert(json.containsKey(r'date'), 'Required key "Register[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "Register[date]" has a null value in JSON.');
        assert(json.containsKey(r'term_closed'), 'Required key "Register[term_closed]" is missing from JSON.');
        assert(json[r'term_closed'] != null, 'Required key "Register[term_closed]" has a null value in JSON.');
        assert(json.containsKey(r'entries'), 'Required key "Register[entries]" is missing from JSON.');
        assert(json[r'entries'] != null, 'Required key "Register[entries]" has a null value in JSON.');
        return true;
      }());

      return Register(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        periodId: mapValueOfType<String>(json, r'period_id'),
        date: mapValueOfType<String>(json, r'date')!,
        termClosed: mapValueOfType<bool>(json, r'term_closed')!,
        entries: RegisterEntriesInner.listFromJson(json[r'entries']),
      );
    }
    return null;
  }

  static List<Register> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Register>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Register.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Register> mapFromJson(dynamic json) {
    final map = <String, Register>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Register.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Register-objects as value to a dart map
  static Map<String, List<Register>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Register>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Register.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section_id',
    'period_id',
    'date',
    'term_closed',
    'entries',
  };
}

