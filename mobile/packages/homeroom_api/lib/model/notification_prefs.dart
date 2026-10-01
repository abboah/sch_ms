//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NotificationPrefs {
  /// Returns a new [NotificationPrefs] instance.
  NotificationPrefs({
    required this.push,
    required this.email,
    required this.sms,
  });

  bool push;

  bool email;

  bool sms;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NotificationPrefs &&
    other.push == push &&
    other.email == email &&
    other.sms == sms;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (push.hashCode) +
    (email.hashCode) +
    (sms.hashCode);

  @override
  String toString() => 'NotificationPrefs[push=$push, email=$email, sms=$sms]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'push'] = this.push;
      json[r'email'] = this.email;
      json[r'sms'] = this.sms;
    return json;
  }

  /// Returns a new [NotificationPrefs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NotificationPrefs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'push'), 'Required key "NotificationPrefs[push]" is missing from JSON.');
        assert(json[r'push'] != null, 'Required key "NotificationPrefs[push]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "NotificationPrefs[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "NotificationPrefs[email]" has a null value in JSON.');
        assert(json.containsKey(r'sms'), 'Required key "NotificationPrefs[sms]" is missing from JSON.');
        assert(json[r'sms'] != null, 'Required key "NotificationPrefs[sms]" has a null value in JSON.');
        return true;
      }());

      return NotificationPrefs(
        push: mapValueOfType<bool>(json, r'push')!,
        email: mapValueOfType<bool>(json, r'email')!,
        sms: mapValueOfType<bool>(json, r'sms')!,
      );
    }
    return null;
  }

  static List<NotificationPrefs> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NotificationPrefs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NotificationPrefs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NotificationPrefs> mapFromJson(dynamic json) {
    final map = <String, NotificationPrefs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NotificationPrefs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NotificationPrefs-objects as value to a dart map
  static Map<String, List<NotificationPrefs>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NotificationPrefs>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NotificationPrefs.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'push',
    'email',
    'sms',
  };
}

