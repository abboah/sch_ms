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


/// tests for MessagingApi
void main() {
  // final instance = MessagingApi();

  group('tests for MessagingApi', () {
    // Messages in a thread, oldest first
    //
    //Future<ListMessages200Response> listMessages(String id, { int limit, String cursor }) async
    test('test listMessages', () async {
      // TODO
    });

    // My message threads (admin: all, read-only audit)
    //
    // Roles: teacher, guardian (participant), admin (audit).
    //
    //Future<ListThreads200Response> listThreads({ String studentId }) async
    test('test listThreads', () async {
      // TODO
    });

    // Mark a thread read up to now (clears its unread badge)
    //
    // Roles: teacher, guardian (participant).
    //
    //Future markThreadRead(String id) async
    test('test markThreadRead', () async {
      // TODO
    });

    // Open a thread about a child
    //
    // Roles: teacher, guardian. A thread is always about one student both parties share, never a free DM. Returns the existing thread if one already exists for (student, teacher, guardian). 
    //
    //Future<Thread> openThread(OpenThreadRequest openThreadRequest) async
    test('test openThread', () async {
      // TODO
    });

    // Send a message
    //
    // Roles: teacher, guardian (participant). Messages are immutable once sent. Admin cannot post.
    //
    //Future<Message> sendMessage(String id, SendMessageRequest sendMessageRequest, { String idempotencyKey }) async
    test('test sendMessage', () async {
      // TODO
    });

  });
}
