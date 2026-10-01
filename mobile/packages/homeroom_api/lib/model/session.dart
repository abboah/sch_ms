//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Session {
  /// Returns a new [Session] instance.
  Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.me,
  });

  String accessToken;

  String refreshToken;

  /// Access token lifetime in seconds
  int expiresIn;

  Me me;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Session &&
    other.accessToken == accessToken &&
    other.refreshToken == refreshToken &&
    other.expiresIn == expiresIn &&
    other.me == me;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken.hashCode) +
    (refreshToken.hashCode) +
    (expiresIn.hashCode) +
    (me.hashCode);

  @override
  String toString() => 'Session[accessToken=$accessToken, refreshToken=$refreshToken, expiresIn=$expiresIn, me=$me]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'access_token'] = this.accessToken;
      json[r'refresh_token'] = this.refreshToken;
      json[r'expires_in'] = this.expiresIn;
      json[r'me'] = this.me;
    return json;
  }

  /// Returns a new [Session] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Session? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'access_token'), 'Required key "Session[access_token]" is missing from JSON.');
        assert(json[r'access_token'] != null, 'Required key "Session[access_token]" has a null value in JSON.');
        assert(json.containsKey(r'refresh_token'), 'Required key "Session[refresh_token]" is missing from JSON.');
        assert(json[r'refresh_token'] != null, 'Required key "Session[refresh_token]" has a null value in JSON.');
        assert(json.containsKey(r'expires_in'), 'Required key "Session[expires_in]" is missing from JSON.');
        assert(json[r'expires_in'] != null, 'Required key "Session[expires_in]" has a null value in JSON.');
        assert(json.containsKey(r'me'), 'Required key "Session[me]" is missing from JSON.');
        assert(json[r'me'] != null, 'Required key "Session[me]" has a null value in JSON.');
        return true;
      }());

      return Session(
        accessToken: mapValueOfType<String>(json, r'access_token')!,
        refreshToken: mapValueOfType<String>(json, r'refresh_token')!,
        expiresIn: mapValueOfType<int>(json, r'expires_in')!,
        me: Me.fromJson(json[r'me'])!,
      );
    }
    return null;
  }

  static List<Session> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Session>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Session.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Session> mapFromJson(dynamic json) {
    final map = <String, Session>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Session.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Session-objects as value to a dart map
  static Map<String, List<Session>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Session>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Session.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'access_token',
    'refresh_token',
    'expires_in',
    'me',
  };
}

