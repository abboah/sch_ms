//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateFeeItemRequest {
  /// Returns a new [CreateFeeItemRequest] instance.
  CreateFeeItemRequest({
    required this.name,
    required this.defaultAmount,
    this.active = true,
  });

  String name;

  String defaultAmount;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateFeeItemRequest &&
    other.name == name &&
    other.defaultAmount == defaultAmount &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (defaultAmount.hashCode) +
    (active.hashCode);

  @override
  String toString() => 'CreateFeeItemRequest[name=$name, defaultAmount=$defaultAmount, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'default_amount'] = this.defaultAmount;
      json[r'active'] = this.active;
    return json;
  }

  /// Returns a new [CreateFeeItemRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateFeeItemRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "CreateFeeItemRequest[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "CreateFeeItemRequest[name]" has a null value in JSON.');
        assert(json.containsKey(r'default_amount'), 'Required key "CreateFeeItemRequest[default_amount]" is missing from JSON.');
        assert(json[r'default_amount'] != null, 'Required key "CreateFeeItemRequest[default_amount]" has a null value in JSON.');
        return true;
      }());

      return CreateFeeItemRequest(
        name: mapValueOfType<String>(json, r'name')!,
        defaultAmount: mapValueOfType<String>(json, r'default_amount')!,
        active: mapValueOfType<bool>(json, r'active') ?? true,
      );
    }
    return null;
  }

  static List<CreateFeeItemRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateFeeItemRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateFeeItemRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateFeeItemRequest> mapFromJson(dynamic json) {
    final map = <String, CreateFeeItemRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateFeeItemRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateFeeItemRequest-objects as value to a dart map
  static Map<String, List<CreateFeeItemRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateFeeItemRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateFeeItemRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'default_amount',
  };
}

