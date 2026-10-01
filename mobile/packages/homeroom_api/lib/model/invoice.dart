//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Invoice {
  /// Returns a new [Invoice] instance.
  Invoice({
    required this.id,
    required this.student,
    required this.termId,
    required this.description,
    required this.amountDue,
    required this.amountPaid,
    required this.outstanding,
    required this.status,
    required this.dueDate,
    required this.overdue,
    required this.feeItemId,
    this.payments = const [],
  });

  String id;

  StudentRef student;

  String termId;

  String description;

  String amountDue;

  String amountPaid;

  String outstanding;

  InvoiceStatusEnum status;

  String dueDate;

  /// Derived, due_date passed and outstanding > 0
  bool overdue;

  /// The reusable fee item this was billed from, if any
  String? feeItemId;

  List<Payment> payments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Invoice &&
    other.id == id &&
    other.student == student &&
    other.termId == termId &&
    other.description == description &&
    other.amountDue == amountDue &&
    other.amountPaid == amountPaid &&
    other.outstanding == outstanding &&
    other.status == status &&
    other.dueDate == dueDate &&
    other.overdue == overdue &&
    other.feeItemId == feeItemId &&
    _deepEquality.equals(other.payments, payments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (student.hashCode) +
    (termId.hashCode) +
    (description.hashCode) +
    (amountDue.hashCode) +
    (amountPaid.hashCode) +
    (outstanding.hashCode) +
    (status.hashCode) +
    (dueDate.hashCode) +
    (overdue.hashCode) +
    (feeItemId == null ? 0 : feeItemId!.hashCode) +
    (payments.hashCode);

  @override
  String toString() => 'Invoice[id=$id, student=$student, termId=$termId, description=$description, amountDue=$amountDue, amountPaid=$amountPaid, outstanding=$outstanding, status=$status, dueDate=$dueDate, overdue=$overdue, feeItemId=$feeItemId, payments=$payments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'student'] = this.student;
      json[r'term_id'] = this.termId;
      json[r'description'] = this.description;
      json[r'amount_due'] = this.amountDue;
      json[r'amount_paid'] = this.amountPaid;
      json[r'outstanding'] = this.outstanding;
      json[r'status'] = this.status;
      json[r'due_date'] = this.dueDate;
      json[r'overdue'] = this.overdue;
    if (this.feeItemId != null) {
      json[r'fee_item_id'] = this.feeItemId;
    } else {
      json[r'fee_item_id'] = null;
    }
      json[r'payments'] = this.payments;
    return json;
  }

  /// Returns a new [Invoice] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Invoice? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Invoice[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Invoice[id]" has a null value in JSON.');
        assert(json.containsKey(r'student'), 'Required key "Invoice[student]" is missing from JSON.');
        assert(json[r'student'] != null, 'Required key "Invoice[student]" has a null value in JSON.');
        assert(json.containsKey(r'term_id'), 'Required key "Invoice[term_id]" is missing from JSON.');
        assert(json[r'term_id'] != null, 'Required key "Invoice[term_id]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "Invoice[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "Invoice[description]" has a null value in JSON.');
        assert(json.containsKey(r'amount_due'), 'Required key "Invoice[amount_due]" is missing from JSON.');
        assert(json[r'amount_due'] != null, 'Required key "Invoice[amount_due]" has a null value in JSON.');
        assert(json.containsKey(r'amount_paid'), 'Required key "Invoice[amount_paid]" is missing from JSON.');
        assert(json[r'amount_paid'] != null, 'Required key "Invoice[amount_paid]" has a null value in JSON.');
        assert(json.containsKey(r'outstanding'), 'Required key "Invoice[outstanding]" is missing from JSON.');
        assert(json[r'outstanding'] != null, 'Required key "Invoice[outstanding]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "Invoice[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "Invoice[status]" has a null value in JSON.');
        assert(json.containsKey(r'due_date'), 'Required key "Invoice[due_date]" is missing from JSON.');
        assert(json[r'due_date'] != null, 'Required key "Invoice[due_date]" has a null value in JSON.');
        assert(json.containsKey(r'overdue'), 'Required key "Invoice[overdue]" is missing from JSON.');
        assert(json[r'overdue'] != null, 'Required key "Invoice[overdue]" has a null value in JSON.');
        assert(json.containsKey(r'fee_item_id'), 'Required key "Invoice[fee_item_id]" is missing from JSON.');
        assert(json.containsKey(r'payments'), 'Required key "Invoice[payments]" is missing from JSON.');
        assert(json[r'payments'] != null, 'Required key "Invoice[payments]" has a null value in JSON.');
        return true;
      }());

      return Invoice(
        id: mapValueOfType<String>(json, r'id')!,
        student: StudentRef.fromJson(json[r'student'])!,
        termId: mapValueOfType<String>(json, r'term_id')!,
        description: mapValueOfType<String>(json, r'description')!,
        amountDue: mapValueOfType<String>(json, r'amount_due')!,
        amountPaid: mapValueOfType<String>(json, r'amount_paid')!,
        outstanding: mapValueOfType<String>(json, r'outstanding')!,
        status: InvoiceStatusEnum.fromJson(json[r'status'])!,
        dueDate: mapValueOfType<String>(json, r'due_date')!,
        overdue: mapValueOfType<bool>(json, r'overdue')!,
        feeItemId: mapValueOfType<String>(json, r'fee_item_id'),
        payments: Payment.listFromJson(json[r'payments']),
      );
    }
    return null;
  }

  static List<Invoice> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Invoice>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Invoice.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Invoice> mapFromJson(dynamic json) {
    final map = <String, Invoice>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Invoice.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Invoice-objects as value to a dart map
  static Map<String, List<Invoice>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Invoice>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Invoice.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'student',
    'term_id',
    'description',
    'amount_due',
    'amount_paid',
    'outstanding',
    'status',
    'due_date',
    'overdue',
    'fee_item_id',
    'payments',
  };
}


enum InvoiceStatusEnum {
  unpaid._(r'unpaid'),
  partial._(r'partial'),
  paid._(r'paid'),
  void_._(r'void'),
  ;

  /// Instantiate a new enum with the provided value.
  const InvoiceStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [InvoiceStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static InvoiceStatusEnum? fromJson(dynamic value) => InvoiceStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [InvoiceStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<InvoiceStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvoiceStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvoiceStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [InvoiceStatusEnum] to String,
/// and [decode] dynamic data back to [InvoiceStatusEnum].
class InvoiceStatusEnumTypeTransformer {
  factory InvoiceStatusEnumTypeTransformer() => _instance ??= const InvoiceStatusEnumTypeTransformer._();

  const InvoiceStatusEnumTypeTransformer._();

  String encode(InvoiceStatusEnum data) => data._value;

  /// Returns the instance of [InvoiceStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  InvoiceStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is InvoiceStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'unpaid': return InvoiceStatusEnum.unpaid;
        case r'partial': return InvoiceStatusEnum.partial;
        case r'paid': return InvoiceStatusEnum.paid;
        case r'void': return InvoiceStatusEnum.void_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static InvoiceStatusEnumTypeTransformer? _instance;
}


