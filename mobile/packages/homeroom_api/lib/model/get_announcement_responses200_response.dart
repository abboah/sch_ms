//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetAnnouncementResponses200Response {
  /// Returns a new [GetAnnouncementResponses200Response] instance.
  GetAnnouncementResponses200Response({
    this.true_,
    this.false_,
    this.awaiting,
    this.items = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? true_;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? false_;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? awaiting;

  List<AnnouncementResponse> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetAnnouncementResponses200Response &&
    other.true_ == true_ &&
    other.false_ == false_ &&
    other.awaiting == awaiting &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (true_ == null ? 0 : true_!.hashCode) +
    (false_ == null ? 0 : false_!.hashCode) +
    (awaiting == null ? 0 : awaiting!.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'GetAnnouncementResponses200Response[true_=$true_, false_=$false_, awaiting=$awaiting, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.true_ != null) {
      json[r'true'] = this.true_;
    } else {
      json[r'true'] = null;
    }
    if (this.false_ != null) {
      json[r'false'] = this.false_;
    } else {
      json[r'false'] = null;
    }
    if (this.awaiting != null) {
      json[r'awaiting'] = this.awaiting;
    } else {
      json[r'awaiting'] = null;
    }
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [GetAnnouncementResponses200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetAnnouncementResponses200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'items'), 'Required key "GetAnnouncementResponses200Response[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "GetAnnouncementResponses200Response[items]" has a null value in JSON.');
        return true;
      }());

      return GetAnnouncementResponses200Response(
        true_: mapValueOfType<int>(json, r'true'),
        false_: mapValueOfType<int>(json, r'false'),
        awaiting: mapValueOfType<int>(json, r'awaiting'),
        items: AnnouncementResponse.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<GetAnnouncementResponses200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetAnnouncementResponses200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetAnnouncementResponses200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetAnnouncementResponses200Response> mapFromJson(dynamic json) {
    final map = <String, GetAnnouncementResponses200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetAnnouncementResponses200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetAnnouncementResponses200Response-objects as value to a dart map
  static Map<String, List<GetAnnouncementResponses200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetAnnouncementResponses200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetAnnouncementResponses200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
  };
}

