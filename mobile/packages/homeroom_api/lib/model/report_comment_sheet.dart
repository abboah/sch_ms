//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReportCommentSheet {
  /// Returns a new [ReportCommentSheet] instance.
  ReportCommentSheet({
    required this.classSectionId,
    required this.subject,
    required this.termClosed,
    this.items = const [],
  });

  String classSectionId;

  String subject;

  bool termClosed;

  List<ReportCommentSheetItemsInner> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReportCommentSheet &&
    other.classSectionId == classSectionId &&
    other.subject == subject &&
    other.termClosed == termClosed &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (classSectionId.hashCode) +
    (subject.hashCode) +
    (termClosed.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'ReportCommentSheet[classSectionId=$classSectionId, subject=$subject, termClosed=$termClosed, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'class_section_id'] = this.classSectionId;
      json[r'subject'] = this.subject;
      json[r'term_closed'] = this.termClosed;
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [ReportCommentSheet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReportCommentSheet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'class_section_id'), 'Required key "ReportCommentSheet[class_section_id]" is missing from JSON.');
        assert(json[r'class_section_id'] != null, 'Required key "ReportCommentSheet[class_section_id]" has a null value in JSON.');
        assert(json.containsKey(r'subject'), 'Required key "ReportCommentSheet[subject]" is missing from JSON.');
        assert(json[r'subject'] != null, 'Required key "ReportCommentSheet[subject]" has a null value in JSON.');
        assert(json.containsKey(r'term_closed'), 'Required key "ReportCommentSheet[term_closed]" is missing from JSON.');
        assert(json[r'term_closed'] != null, 'Required key "ReportCommentSheet[term_closed]" has a null value in JSON.');
        assert(json.containsKey(r'items'), 'Required key "ReportCommentSheet[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "ReportCommentSheet[items]" has a null value in JSON.');
        return true;
      }());

      return ReportCommentSheet(
        classSectionId: mapValueOfType<String>(json, r'class_section_id')!,
        subject: mapValueOfType<String>(json, r'subject')!,
        termClosed: mapValueOfType<bool>(json, r'term_closed')!,
        items: ReportCommentSheetItemsInner.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<ReportCommentSheet> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportCommentSheet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportCommentSheet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReportCommentSheet> mapFromJson(dynamic json) {
    final map = <String, ReportCommentSheet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReportCommentSheet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReportCommentSheet-objects as value to a dart map
  static Map<String, List<ReportCommentSheet>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReportCommentSheet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReportCommentSheet.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'class_section_id',
    'subject',
    'term_closed',
    'items',
  };
}

