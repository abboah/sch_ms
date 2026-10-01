//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SelectionRequired {
  /// Returns a new [SelectionRequired] instance.
  SelectionRequired({
    required this.selectionToken,
    this.choices = const [],
  });

  /// Short-lived; exchange via /auth/sessions/select
  String selectionToken;

  List<SelectionRequiredChoicesInner> choices;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SelectionRequired &&
    other.selectionToken == selectionToken &&
    _deepEquality.equals(other.choices, choices);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (selectionToken.hashCode) +
    (choices.hashCode);

  @override
  String toString() => 'SelectionRequired[selectionToken=$selectionToken, choices=$choices]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'selection_token'] = this.selectionToken;
      json[r'choices'] = this.choices;
    return json;
  }

  /// Returns a new [SelectionRequired] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SelectionRequired? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'selection_token'), 'Required key "SelectionRequired[selection_token]" is missing from JSON.');
        assert(json[r'selection_token'] != null, 'Required key "SelectionRequired[selection_token]" has a null value in JSON.');
        assert(json.containsKey(r'choices'), 'Required key "SelectionRequired[choices]" is missing from JSON.');
        assert(json[r'choices'] != null, 'Required key "SelectionRequired[choices]" has a null value in JSON.');
        return true;
      }());

      return SelectionRequired(
        selectionToken: mapValueOfType<String>(json, r'selection_token')!,
        choices: SelectionRequiredChoicesInner.listFromJson(json[r'choices']),
      );
    }
    return null;
  }

  static List<SelectionRequired> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SelectionRequired>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SelectionRequired.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SelectionRequired> mapFromJson(dynamic json) {
    final map = <String, SelectionRequired>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SelectionRequired.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SelectionRequired-objects as value to a dart map
  static Map<String, List<SelectionRequired>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SelectionRequired>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SelectionRequired.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'selection_token',
    'choices',
  };
}

