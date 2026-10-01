//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateInvoicesRequest {
  /// Returns a new [CreateInvoicesRequest] instance.
  CreateInvoicesRequest({
    this.studentId,
    this.classSectionId,
    required this.termId,
    required this.description,
    required this.amountDue,
    required this.dueDate,
    this.feeItemId,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? studentId;

  /// Bulk: one invoice per enrolled student
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? classSectionId;

  String termId;

  String description;

  String amountDue;

  String dueDate;

  /// Tags the invoice for reporting; description and amount_due are still explicit and unaffected
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? feeItemId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateInvoicesRequest &&
    other.studentId == studentId &&
    other.classSectionId == classSectionId &&
    other.termId == termId &&
    other.description == description &&
    other.amountDue == amountDue &&
    other.dueDate == dueDate &&
    other.feeItemId == feeItemId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (studentId == null ? 0 : studentId!.hashCode) +
    (classSectionId == null ? 0 : classSectionId!.hashCode) +
    (termId.hashCode) +
    (description.hashCode) +
    (amountDue.hashCode) +
    (dueDate.hashCode) +
    (feeItemId == null ? 0 : feeItemId!.hashCode);

  @override
  String toString() => 'CreateInvoicesRequest[studentId=$studentId, classSectionId=$classSectionId, termId=$termId, description=$description, amountDue=$amountDue, dueDate=$dueDate, feeItemId=$feeItemId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.studentId != null) {
      json[r'student_id'] = this.studentId;
    } else {
      json[r'student_id'] = null;
    }
    if (this.classSectionId != null) {
      json[r'class_section_id'] = this.classSectionId;
    } else {
      json[r'class_section_id'] = null;
    }
      json[r'term_id'] = this.termId;
      json[r'description'] = this.description;
      json[r'amount_due'] = this.amountDue;
      json[r'due_date'] = this.dueDate;
    if (this.feeItemId != null) {
      json[r'fee_item_id'] = this.feeItemId;
    } else {
      json[r'fee_item_id'] = null;
    }
    return json;
  }

  /// Returns a new [CreateInvoicesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateInvoicesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'term_id'), 'Required key "CreateInvoicesRequest[term_id]" is missing from JSON.');
        assert(json[r'term_id'] != null, 'Required key "CreateInvoicesRequest[term_id]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "CreateInvoicesRequest[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "CreateInvoicesRequest[description]" has a null value in JSON.');
        assert(json.containsKey(r'amount_due'), 'Required key "CreateInvoicesRequest[amount_due]" is missing from JSON.');
        assert(json[r'amount_due'] != null, 'Required key "CreateInvoicesRequest[amount_due]" has a null value in JSON.');
        assert(json.containsKey(r'due_date'), 'Required key "CreateInvoicesRequest[due_date]" is missing from JSON.');
        assert(json[r'due_date'] != null, 'Required key "CreateInvoicesRequest[due_date]" has a null value in JSON.');
        return true;
      }());

      return CreateInvoicesRequest(
        studentId: mapValueOfType<String>(json, r'student_id'),
        classSectionId: mapValueOfType<String>(json, r'class_section_id'),
        termId: mapValueOfType<String>(json, r'term_id')!,
        description: mapValueOfType<String>(json, r'description')!,
        amountDue: mapValueOfType<String>(json, r'amount_due')!,
        dueDate: mapValueOfType<String>(json, r'due_date')!,
        feeItemId: mapValueOfType<String>(json, r'fee_item_id'),
      );
    }
    return null;
  }

  static List<CreateInvoicesRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateInvoicesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateInvoicesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateInvoicesRequest> mapFromJson(dynamic json) {
    final map = <String, CreateInvoicesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateInvoicesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateInvoicesRequest-objects as value to a dart map
  static Map<String, List<CreateInvoicesRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateInvoicesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateInvoicesRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'term_id',
    'description',
    'amount_due',
    'due_date',
  };
}

