//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.status,
    required this.providerRef,
    required this.paidAt,
    required this.createdAt,
    required this.receiptUrl,
    this.student,
    this.description,
  });

  String id;

  String invoiceId;

  String amount;

  PaymentMethodEnum method;

  PaymentStatus status;

  String providerRef;

  DateTime? paidAt;

  DateTime createdAt;

  String? receiptUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StudentRef? student;

  /// What the invoice is for
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Payment &&
    other.id == id &&
    other.invoiceId == invoiceId &&
    other.amount == amount &&
    other.method == method &&
    other.status == status &&
    other.providerRef == providerRef &&
    other.paidAt == paidAt &&
    other.createdAt == createdAt &&
    other.receiptUrl == receiptUrl &&
    other.student == student &&
    other.description == description;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (invoiceId.hashCode) +
    (amount.hashCode) +
    (method.hashCode) +
    (status.hashCode) +
    (providerRef.hashCode) +
    (paidAt == null ? 0 : paidAt!.hashCode) +
    (createdAt.hashCode) +
    (receiptUrl == null ? 0 : receiptUrl!.hashCode) +
    (student == null ? 0 : student!.hashCode) +
    (description == null ? 0 : description!.hashCode);

  @override
  String toString() => 'Payment[id=$id, invoiceId=$invoiceId, amount=$amount, method=$method, status=$status, providerRef=$providerRef, paidAt=$paidAt, createdAt=$createdAt, receiptUrl=$receiptUrl, student=$student, description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'invoice_id'] = this.invoiceId;
      json[r'amount'] = this.amount;
      json[r'method'] = this.method;
      json[r'status'] = this.status;
      json[r'provider_ref'] = this.providerRef;
    if (this.paidAt != null) {
      json[r'paid_at'] = this.paidAt!.toUtc().toIso8601String();
    } else {
      json[r'paid_at'] = null;
    }
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    if (this.receiptUrl != null) {
      json[r'receipt_url'] = this.receiptUrl;
    } else {
      json[r'receipt_url'] = null;
    }
    if (this.student != null) {
      json[r'student'] = this.student;
    } else {
      json[r'student'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    return json;
  }

  /// Returns a new [Payment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Payment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Payment[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Payment[id]" has a null value in JSON.');
        assert(json.containsKey(r'invoice_id'), 'Required key "Payment[invoice_id]" is missing from JSON.');
        assert(json[r'invoice_id'] != null, 'Required key "Payment[invoice_id]" has a null value in JSON.');
        assert(json.containsKey(r'amount'), 'Required key "Payment[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "Payment[amount]" has a null value in JSON.');
        assert(json.containsKey(r'method'), 'Required key "Payment[method]" is missing from JSON.');
        assert(json[r'method'] != null, 'Required key "Payment[method]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "Payment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "Payment[status]" has a null value in JSON.');
        assert(json.containsKey(r'provider_ref'), 'Required key "Payment[provider_ref]" is missing from JSON.');
        assert(json[r'provider_ref'] != null, 'Required key "Payment[provider_ref]" has a null value in JSON.');
        assert(json.containsKey(r'paid_at'), 'Required key "Payment[paid_at]" is missing from JSON.');
        assert(json.containsKey(r'created_at'), 'Required key "Payment[created_at]" is missing from JSON.');
        assert(json[r'created_at'] != null, 'Required key "Payment[created_at]" has a null value in JSON.');
        assert(json.containsKey(r'receipt_url'), 'Required key "Payment[receipt_url]" is missing from JSON.');
        return true;
      }());

      return Payment(
        id: mapValueOfType<String>(json, r'id')!,
        invoiceId: mapValueOfType<String>(json, r'invoice_id')!,
        amount: mapValueOfType<String>(json, r'amount')!,
        method: PaymentMethodEnum.fromJson(json[r'method'])!,
        status: PaymentStatus.fromJson(json[r'status'])!,
        providerRef: mapValueOfType<String>(json, r'provider_ref')!,
        paidAt: mapDateTime(json, r'paid_at', r''),
        createdAt: mapDateTime(json, r'created_at', r'')!,
        receiptUrl: mapValueOfType<String>(json, r'receipt_url'),
        student: StudentRef.fromJson(json[r'student']),
        description: mapValueOfType<String>(json, r'description'),
      );
    }
    return null;
  }

  static List<Payment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Payment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Payment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Payment> mapFromJson(dynamic json) {
    final map = <String, Payment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Payment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Payment-objects as value to a dart map
  static Map<String, List<Payment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Payment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Payment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'invoice_id',
    'amount',
    'method',
    'status',
    'provider_ref',
    'paid_at',
    'created_at',
    'receipt_url',
  };
}


enum PaymentMethodEnum {
  card._(r'card'),
  mtnMomo._(r'mtn_momo'),
  telecelCash._(r'telecel_cash'),
  manual._(r'manual'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentMethodEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentMethodEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentMethodEnum? fromJson(dynamic value) => PaymentMethodEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentMethodEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentMethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentMethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentMethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentMethodEnum] to String,
/// and [decode] dynamic data back to [PaymentMethodEnum].
class PaymentMethodEnumTypeTransformer {
  factory PaymentMethodEnumTypeTransformer() => _instance ??= const PaymentMethodEnumTypeTransformer._();

  const PaymentMethodEnumTypeTransformer._();

  String encode(PaymentMethodEnum data) => data._value;

  /// Returns the instance of [PaymentMethodEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentMethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentMethodEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'card': return PaymentMethodEnum.card;
        case r'mtn_momo': return PaymentMethodEnum.mtnMomo;
        case r'telecel_cash': return PaymentMethodEnum.telecelCash;
        case r'manual': return PaymentMethodEnum.manual;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentMethodEnumTypeTransformer? _instance;
}


