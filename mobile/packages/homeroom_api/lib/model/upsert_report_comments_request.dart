//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpsertReportCommentsRequest {
  /// Returns a new [UpsertReportCommentsRequest] instance.
  UpsertReportCommentsRequest({
    required this.subject,
    this.comments = const [],
  });

  String subject;

  List<UpsertReportCommentsRequestCommentsInner> comments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpsertReportCommentsRequest &&
    other.subject == subject &&
    _deepEquality.equals(other.comments, comments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subject.hashCode) +
    (comments.hashCode);

  @override
  String toString() => 'UpsertReportCommentsRequest[subject=$subject, comments=$comments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'subject'] = this.subject;
      json[r'comments'] = this.comments;
    return json;
  }

  /// Returns a new [UpsertReportCommentsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpsertReportCommentsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'subject'), 'Required key "UpsertReportCommentsRequest[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "UpsertReportCommentsRequest[subject]" has a null value in JSON.');
        assert(json.containsKey(r'comments'), 'Required key "UpsertReportCommentsRequest[comments]" is missing from JSON.');
        assert(json[r'comments'] != null, 'Required key "UpsertReportCommentsRequest[comments]" has a null value in JSON.');
        return true;
      }());

      return UpsertReportCommentsRequest(
        subject: mapValueOfType<String>(json, r'subject')!,
        comments: UpsertReportCommentsRequestCommentsInner.listFromJson(json[r'comments']),
      );
    }
    return null;
  }

  static List<UpsertReportCommentsRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpsertReportCommentsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpsertReportCommentsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpsertReportCommentsRequest> mapFromJson(dynamic json) {
    final map = <String, UpsertReportCommentsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpsertReportCommentsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpsertReportCommentsRequest-objects as value to a dart map
  static Map<String, List<UpsertReportCommentsRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpsertReportCommentsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpsertReportCommentsRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'subject',
    'comments',
  };
}

