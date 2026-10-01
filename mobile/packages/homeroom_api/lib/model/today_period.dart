//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TodayPeriod {
  /// Returns a new [TodayPeriod] instance.
  TodayPeriod({
    required this.period,
    required this.classSection,
    required this.register,
    required this.marked,
    required this.enrolled,
  });

  Period period;

  ClassSection classSection;

  TodayPeriodRegisterEnum register;

  int marked;

  int enrolled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TodayPeriod &&
    other.period == period &&
    other.classSection == classSection &&
    other.register == register &&
    other.marked == marked &&
    other.enrolled == enrolled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (period.hashCode) +
    (classSection.hashCode) +
    (register.hashCode) +
    (marked.hashCode) +
    (enrolled.hashCode);

  @override
  String toString() => 'TodayPeriod[period=$period, classSection=$classSection, register=$register, marked=$marked, enrolled=$enrolled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'period'] = this.period;
      json[r'class_section'] = this.classSection;
      json[r'register'] = this.register;
      json[r'marked'] = this.marked;
      json[r'enrolled'] = this.enrolled;
    return json;
  }

  /// Returns a new [TodayPeriod] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TodayPeriod? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'period'), 'Required key "TodayPeriod[period]" is missing from JSON.');
        assert(json[r'period'] != null, 'Required key "TodayPeriod[period]" has a null value in JSON.');
        assert(json.containsKey(r'class_section'), 'Required key "TodayPeriod[class_section]" is missing from JSON.');
        assert(json[r'class_section'] != null, 'Required key "TodayPeriod[class_section]" has a null value in JSON.');
        assert(json.containsKey(r'register'), 'Required key "TodayPeriod[register]" is missing from JSON.');
        assert(json[r'register'] != null, 'Required key "TodayPeriod[register]" has a null value in JSON.');
        assert(json.containsKey(r'marked'), 'Required key "TodayPeriod[marked]" is missing from JSON.');
        assert(json[r'marked'] != null, 'Required key "TodayPeriod[marked]" has a null value in JSON.');
        assert(json.containsKey(r'enrolled'), 'Required key "TodayPeriod[enrolled]" is missing from JSON.');
        assert(json[r'enrolled'] != null, 'Required key "TodayPeriod[enrolled]" has a null value in JSON.');
        return true;
      }());

      return TodayPeriod(
        period: Period.fromJson(json[r'period'])!,
        classSection: ClassSection.fromJson(json[r'class_section'])!,
        register: TodayPeriodRegisterEnum.fromJson(json[r'register'])!,
        marked: mapValueOfType<int>(json, r'marked')!,
        enrolled: mapValueOfType<int>(json, r'enrolled')!,
      );
    }
    return null;
  }

  static List<TodayPeriod> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TodayPeriod>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TodayPeriod.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TodayPeriod> mapFromJson(dynamic json) {
    final map = <String, TodayPeriod>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TodayPeriod.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TodayPeriod-objects as value to a dart map
  static Map<String, List<TodayPeriod>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TodayPeriod>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TodayPeriod.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'period',
    'class_section',
    'register',
    'marked',
    'enrolled',
  };
}


enum TodayPeriodRegisterEnum {
  unmarked._(r'unmarked'),
  partial._(r'partial'),
  complete._(r'complete'),
  ;

  /// Instantiate a new enum with the provided value.
  const TodayPeriodRegisterEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [TodayPeriodRegisterEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static TodayPeriodRegisterEnum? fromJson(dynamic value) => TodayPeriodRegisterEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [TodayPeriodRegisterEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<TodayPeriodRegisterEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TodayPeriodRegisterEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TodayPeriodRegisterEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TodayPeriodRegisterEnum] to String,
/// and [decode] dynamic data back to [TodayPeriodRegisterEnum].
class TodayPeriodRegisterEnumTypeTransformer {
  factory TodayPeriodRegisterEnumTypeTransformer() => _instance ??= const TodayPeriodRegisterEnumTypeTransformer._();

  const TodayPeriodRegisterEnumTypeTransformer._();

  String encode(TodayPeriodRegisterEnum data) => data._value;

  /// Returns the instance of [TodayPeriodRegisterEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TodayPeriodRegisterEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is TodayPeriodRegisterEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'unmarked': return TodayPeriodRegisterEnum.unmarked;
        case r'partial': return TodayPeriodRegisterEnum.partial;
        case r'complete': return TodayPeriodRegisterEnum.complete;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static TodayPeriodRegisterEnumTypeTransformer? _instance;
}


