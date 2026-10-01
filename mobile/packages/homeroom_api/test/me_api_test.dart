//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:homeroom_api/api.dart';
import 'package:test/test.dart';


/// tests for MeApi
void main() {
  // final instance = MeApi();

  group('tests for MeApi', () {
    // Who am I, and what can I switch between
    //
    // Roles: any. Guardians get `children` (drives the child switcher); teachers get `sections`. 
    //
    //Future<Me> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // Channels the caller receives alerts on
    //
    //Future<NotificationPrefs> getNotificationPrefs() async
    test('test getNotificationPrefs', () async {
      // TODO
    });

    // My in-app notifications, newest first
    //
    // Roles: any. Attendance alerts, fee receipts, homework, announcements, messages.
    //
    //Future<NotificationPage> listNotifications({ bool unread, int limit, String cursor }) async
    test('test listNotifications', () async {
      // TODO
    });

    // Mark notifications read (given ids, or all when ids is omitted)
    //
    //Future markNotificationsRead(MarkNotificationsReadRequest markNotificationsReadRequest) async
    test('test markNotificationsRead', () async {
      // TODO
    });

    // Register a device for push
    //
    //Future registerPushToken(RegisterPushTokenRequest registerPushTokenRequest) async
    test('test registerPushToken', () async {
      // TODO
    });

    // Replace notification channel preferences
    //
    //Future<NotificationPrefs> setNotificationPrefs(NotificationPrefs notificationPrefs) async
    test('test setNotificationPrefs', () async {
      // TODO
    });

    // Unregister a device (call on sign-out)
    //
    //Future unregisterPushToken(String token) async
    test('test unregisterPushToken', () async {
      // TODO
    });

    // Update my own phone and email
    //
    // Roles: any. Only the caller's own contact row; nobody else can read it except admin.
    //
    //Future<Contact> updateMyContact(UpdateMyContactRequest updateMyContactRequest) async
    test('test updateMyContact', () async {
      // TODO
    });

  });
}
