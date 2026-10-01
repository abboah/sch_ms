//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InvoicePage {
  /// Returns a new [InvoicePage] instance.
  InvoicePage({
    this.items = const [],
    required this.nextCursor,
  });

  List<Invoice> items;

  String? nextCursor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InvoicePage &&
    _deepEquality.equals(other.items, items) &&
    other.nextCursor == nextCursor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextCursor == null ? 0 : nextCursor!.hashCode);

  @override
  String toString() => 'InvoicePage[items=$items, nextCursor=$nextCursor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextCursor != null) {
      json[r'next_cursor'] = this.nextCursor;
    } else {
      json[r'next_cursor'] = null;
    }
    return json;
  }

  /// Returns a new [InvoicePage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InvoicePage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'items'), 'Required key "InvoicePage[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "InvoicePage[items]" has a null value in JSON.');
        assert(json.containsKey(r'next_cursor'), 'Required key "InvoicePage[next_cursor]" is missing from JSON.');
        return true;
      }());

      return InvoicePage(
        items: Invoice.listFromJson(json[r'items']),
        nextCursor: mapValueOfType<String>(json, r'next_cursor'),
      );
    }
    return null;
  }

  static List<InvoicePage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvoicePage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvoicePage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InvoicePage> mapFromJson(dynamic json) {
    final map = <String, InvoicePage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InvoicePage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InvoicePage-objects as value to a dart map
  static Map<String, List<InvoicePage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InvoicePage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InvoicePage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'next_cursor',
  };
}

