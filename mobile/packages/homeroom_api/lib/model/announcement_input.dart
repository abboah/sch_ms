//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AnnouncementInput {
  /// Returns a new [AnnouncementInput] instance.
  AnnouncementInput({
    required this.title,
    required this.body,
    this.classSectionId,
    this.requiresResponse = false,
    this.published = false,
  });

  String title;

  String body;

  String? classSectionId;

  bool requiresResponse;

  bool published;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AnnouncementInput &&
    other.title == title &&
    other.body == body &&
    other.classSectionId == classSectionId &&
    other.requiresResponse == requiresResponse &&
    other.published == published;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (body.hashCode) +
    (classSectionId == null ? 0 : classSectionId!.hashCode) +
    (requiresResponse.hashCode) +
    (published.hashCode);

  @override
  String toString() => 'AnnouncementInput[title=$title, body=$body, classSectionId=$classSectionId, requiresResponse=$requiresResponse, published=$published]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'body'] = this.body;
    if (this.classSectionId != null) {
      json[r'class_section_id'] = this.classSectionId;
    } else {
      json[r'class_section_id'] = null;
    }
      json[r'requires_response'] = this.requiresResponse;
      json[r'published'] = this.published;
    return json;
  }

  /// Returns a new [AnnouncementInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AnnouncementInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'title'), 'Required key "AnnouncementInput[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "AnnouncementInput[title]" has a null value in JSON.');
        assert(json.containsKey(r'body'), 'Required key "AnnouncementInput[body]" is missing from JSON.');
        assert(json[r'body'] != null, 'Required key "AnnouncementInput[body]" has a null value in JSON.');
        return true;
      }());

      return AnnouncementInput(
        title: mapValueOfType<String>(json, r'title')!,
        body: mapValueOfType<String>(json, r'body')!,
        classSectionId: mapValueOfType<String>(json, r'class_section_id'),
        requiresResponse: mapValueOfType<bool>(json, r'requires_response') ?? false,
        published: mapValueOfType<bool>(json, r'published') ?? false,
      );
    }
    return null;
  }

  static List<AnnouncementInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AnnouncementInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AnnouncementInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AnnouncementInput> mapFromJson(dynamic json) {
    final map = <String, AnnouncementInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AnnouncementInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AnnouncementInput-objects as value to a dart map
  static Map<String, List<AnnouncementInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AnnouncementInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AnnouncementInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'body',
  };
}

