//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentStart {
  /// Returns a new [PaymentStart] instance.
  PaymentStart({
    required this.payment,
    required this.next,
  });

  Payment payment;

  PaymentStartNext next;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentStart &&
    other.payment == payment &&
    other.next == next;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (payment.hashCode) +
    (next.hashCode);

  @override
  String toString() => 'PaymentStart[payment=$payment, next=$next]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'payment'] = this.payment;
      json[r'next'] = this.next;
    return json;
  }

  /// Returns a new [PaymentStart] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentStart? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'payment'), 'Required key "PaymentStart[payment]" is missing from JSON.');
        assert(json[r'payment'] != null, 'Required key "PaymentStart[payment]" has a null value in JSON.');
        assert(json.containsKey(r'next'), 'Required key "PaymentStart[next]" is missing from JSON.');
        assert(json[r'next'] != null, 'Required key "PaymentStart[next]" has a null value in JSON.');
        return true;
      }());

      return PaymentStart(
        payment: Payment.fromJson(json[r'payment'])!,
        next: PaymentStartNext.fromJson(json[r'next'])!,
      );
    }
    return null;
  }

  static List<PaymentStart> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentStart>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentStart.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentStart> mapFromJson(dynamic json) {
    final map = <String, PaymentStart>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentStart.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentStart-objects as value to a dart map
  static Map<String, List<PaymentStart>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentStart>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentStart.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'payment',
    'next',
  };
}

