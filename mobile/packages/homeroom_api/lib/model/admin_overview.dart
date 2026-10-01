//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AdminOverview {
  /// Returns a new [AdminOverview] instance.
  AdminOverview({
    required this.date,
    required this.attendanceRateTodayPct,
    this.registersUnmarked = const [],
    required this.feesOutstanding,
    required this.invoicesOverdue,
    this.recentAnnouncements = const [],
  });

  String date;

  num? attendanceRateTodayPct;

  List<AdminOverviewRegistersUnmarkedInner> registersUnmarked;

  String feesOutstanding;

  int invoicesOverdue;

  List<Announcement> recentAnnouncements;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminOverview &&
    other.date == date &&
    other.attendanceRateTodayPct == attendanceRateTodayPct &&
    _deepEquality.equals(other.registersUnmarked, registersUnmarked) &&
    other.feesOutstanding == feesOutstanding &&
    other.invoicesOverdue == invoicesOverdue &&
    _deepEquality.equals(other.recentAnnouncements, recentAnnouncements);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (date.hashCode) +
    (attendanceRateTodayPct == null ? 0 : attendanceRateTodayPct!.hashCode) +
    (registersUnmarked.hashCode) +
    (feesOutstanding.hashCode) +
    (invoicesOverdue.hashCode) +
    (recentAnnouncements.hashCode);

  @override
  String toString() => 'AdminOverview[date=$date, attendanceRateTodayPct=$attendanceRateTodayPct, registersUnmarked=$registersUnmarked, feesOutstanding=$feesOutstanding, invoicesOverdue=$invoicesOverdue, recentAnnouncements=$recentAnnouncements]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'date'] = this.date;
    if (this.attendanceRateTodayPct != null) {
      json[r'attendance_rate_today_pct'] = this.attendanceRateTodayPct;
    } else {
      json[r'attendance_rate_today_pct'] = null;
    }
      json[r'registers_unmarked'] = this.registersUnmarked;
      json[r'fees_outstanding'] = this.feesOutstanding;
      json[r'invoices_overdue'] = this.invoicesOverdue;
      json[r'recent_announcements'] = this.recentAnnouncements;
    return json;
  }

  /// Returns a new [AdminOverview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminOverview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'date'), 'Required key "AdminOverview[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "AdminOverview[date]" has a null value in JSON.');
        assert(json.containsKey(r'attendance_rate_today_pct'), 'Required key "AdminOverview[attendance_rate_today_pct]" is missing from JSON.');
        assert(json.containsKey(r'registers_unmarked'), 'Required key "AdminOverview[registers_unmarked]" is missing from JSON.');
        assert(json[r'registers_unmarked'] != null, 'Required key "AdminOverview[registers_unmarked]" has a null value in JSON.');
        assert(json.containsKey(r'fees_outstanding'), 'Required key "AdminOverview[fees_outstanding]" is missing from JSON.');
        assert(json[r'fees_outstanding'] != null, 'Required key "AdminOverview[fees_outstanding]" has a null value in JSON.');
        assert(json.containsKey(r'invoices_overdue'), 'Required key "AdminOverview[invoices_overdue]" is missing from JSON.');
        assert(json[r'invoices_overdue'] != null, 'Required key "AdminOverview[invoices_overdue]" has a null value in JSON.');
        assert(json.containsKey(r'recent_announcements'), 'Required key "AdminOverview[recent_announcements]" is missing from JSON.');
        assert(json[r'recent_announcements'] != null, 'Required key "AdminOverview[recent_announcements]" has a null value in JSON.');
        return true;
      }());

      return AdminOverview(
        date: mapValueOfType<String>(json, r'date')!,
        attendanceRateTodayPct: json[r'attendance_rate_today_pct'] == null
            ? null
            : num.parse('${json[r'attendance_rate_today_pct']}'),
        registersUnmarked: AdminOverviewRegistersUnmarkedInner.listFromJson(json[r'registers_unmarked']),
        feesOutstanding: mapValueOfType<String>(json, r'fees_outstanding')!,
        invoicesOverdue: mapValueOfType<int>(json, r'invoices_overdue')!,
        recentAnnouncements: Announcement.listFromJson(json[r'recent_announcements']),
      );
    }
    return null;
  }

  static List<AdminOverview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminOverview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminOverview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminOverview> mapFromJson(dynamic json) {
    final map = <String, AdminOverview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminOverview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminOverview-objects as value to a dart map
  static Map<String, List<AdminOverview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminOverview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminOverview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'date',
    'attendance_rate_today_pct',
    'registers_unmarked',
    'fees_outstanding',
    'invoices_overdue',
    'recent_announcements',
  };
}

