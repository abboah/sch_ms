//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationPage {
  /// Returns a new [NotificationPage] instance.
  NotificationPage({
    this.items = const [],
    required this.nextCursor,
    required this.unreadCount,
  });

  List<Notification> items;

  String? nextCursor;

  int unreadCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationPage &&
    _deepEquality.equals(other.items, items) &&
    other.nextCursor == nextCursor &&
    other.unreadCount == unreadCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextCursor == null ? 0 : nextCursor!.hashCode) +
    (unreadCount.hashCode);

  @override
  String toString() => 'NotificationPage[items=$items, nextCursor=$nextCursor, unreadCount=$unreadCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextCursor != null) {
      json[r'next_cursor'] = this.nextCursor;
    } else {
      json[r'next_cursor'] = null;
    }
      json[r'unread_count'] = this.unreadCount;
    return json;
  }

  /// Returns a new [NotificationPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'items'), 'Required key "NotificationPage[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "NotificationPage[items]" has a null value in JSON.');
        assert(json.containsKey(r'next_cursor'), 'Required key "NotificationPage[next_cursor]" is missing from JSON.');
        assert(json.containsKey(r'unread_count'), 'Required key "NotificationPage[unread_count]" is missing from JSON.');
        assert(json[r'unread_count'] != null, 'Required key "NotificationPage[unread_count]" has a null value in JSON.');
        return true;
      }());

      return NotificationPage(
        items: Notification.listFromJson(json[r'items']),
        nextCursor: mapValueOfType<String>(json, r'next_cursor'),
        unreadCount: mapValueOfType<int>(json, r'unread_count')!,
      );
    }
    return null;
  }

  static List<NotificationPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationPage> mapFromJson(dynamic json) {
    final map = <String, NotificationPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationPage-objects as value to a dart map
  static Map<String, List<NotificationPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'next_cursor',
    'unread_count',
  };
}

