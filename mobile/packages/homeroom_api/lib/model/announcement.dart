//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Announcement {
  /// Returns a new [Announcement] instance.
  Announcement({
    required this.id,
    this.author,
    required this.classSectionId,
    required this.title,
    required this.body,
    required this.requiresResponse,
    required this.publishedAt,
    this.myResponses = const [],
  });

  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Person? author;

  /// Null = school-wide
  String? classSectionId;

  String title;

  String body;

  bool requiresResponse;

  /// Null = draft
  DateTime? publishedAt;

  /// Guardians, for slips that require a reply
  List<AnnouncementResponse> myResponses;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Announcement &&
    other.id == id &&
    other.author == author &&
    other.classSectionId == classSectionId &&
    other.title == title &&
    other.body == body &&
    other.requiresResponse == requiresResponse &&
    other.publishedAt == publishedAt &&
    _deepEquality.equals(other.myResponses, myResponses);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (author == null ? 0 : author!.hashCode) +
    (classSectionId == null ? 0 : classSectionId!.hashCode) +
    (title.hashCode) +
    (body.hashCode) +
    (requiresResponse.hashCode) +
    (publishedAt == null ? 0 : publishedAt!.hashCode) +
    (myResponses.hashCode);

  @override
  String toString() => 'Announcement[id=$id, author=$author, classSectionId=$classSectionId, title=$title, body=$body, requiresResponse=$requiresResponse, publishedAt=$publishedAt, myResponses=$myResponses]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.author != null) {
      json[r'author'] = this.author;
    } else {
      json[r'author'] = null;
    }
    if (this.classSectionId != null) {
      json[r'class_section_id'] = this.classSectionId;
    } else {
      json[r'class_section_id'] = null;
    }
      json[r'title'] = this.title;
      json[r'body'] = this.body;
      json[r'requires_response'] = this.requiresResponse;
    if (this.publishedAt != null) {
      json[r'published_at'] = this.publishedAt!.toUtc().toIso8601String();
    } else {
      json[r'published_at'] = null;
    }
      json[r'my_responses'] = this.myResponses;
    return json;
  }

  /// Returns a new [Announcement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Announcement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Announcement[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Announcement[id]" has a null value in JSON.');
        assert(json.containsKey(r'class_section_id'), 'Required key "Announcement[class_section_id]" is missing from JSON.');
        assert(json.containsKey(r'title'), 'Required key "Announcement[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "Announcement[title]" has a null value in JSON.');
        assert(json.containsKey(r'body'), 'Required key "Announcement[body]" is missing from JSON.');
        assert(json[r'body'] != null, 'Required key "Announcement[body]" has a null value in JSON.');
        assert(json.containsKey(r'requires_response'), 'Required key "Announcement[requires_response]" is missing from JSON.');
        assert(json[r'requires_response'] != null, 'Required key "Announcement[requires_response]" has a null value in JSON.');
        assert(json.containsKey(r'published_at'), 'Required key "Announcement[published_at]" is missing from JSON.');
        return true;
      }());

      return Announcement(
        id: mapValueOfType<String>(json, r'id')!,
        author: Person.fromJson(json[r'author']),
        classSectionId: mapValueOfType<String>(json, r'class_section_id'),
        title: mapValueOfType<String>(json, r'title')!,
        body: mapValueOfType<String>(json, r'body')!,
        requiresResponse: mapValueOfType<bool>(json, r'requires_response')!,
        publishedAt: mapDateTime(json, r'published_at', r''),
        myResponses: AnnouncementResponse.listFromJson(json[r'my_responses']),
      );
    }
    return null;
  }

  static List<Announcement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Announcement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Announcement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Announcement> mapFromJson(dynamic json) {
    final map = <String, Announcement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Announcement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Announcement-objects as value to a dart map
  static Map<String, List<Announcement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Announcement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Announcement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'class_section_id',
    'title',
    'body',
    'requires_response',
    'published_at',
  };
}

