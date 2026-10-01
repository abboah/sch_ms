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


/// tests for AnnouncementsApi
void main() {
  // final instance = AnnouncementsApi();

  group('tests for AnnouncementsApi', () {
    // Create an announcement or permission slip
    //
    // Roles: admin (school-wide or any class), teacher (own class only). Omit `published` to save a draft.
    //
    //Future<Announcement> createAnnouncement(AnnouncementInput announcementInput) async
    test('test createAnnouncement', () async {
      // TODO
    });

    // Permission-slip tally
    //
    // Roles: admin.
    //
    //Future<GetAnnouncementResponses200Response> getAnnouncementResponses(String id) async
    test('test getAnnouncementResponses', () async {
      // TODO
    });

    // Announcements visible to me
    //
    // Roles: any. Guardians see published, school-wide or their children's sections; admin also sees drafts.
    //
    //Future<AnnouncementPage> listAnnouncements({ int limit, String cursor }) async
    test('test listAnnouncements', () async {
      // TODO
    });

    // Publish a draft and fan out notifications
    //
    // Roles: admin, teacher (author).
    //
    //Future<Announcement> publishAnnouncement(String id) async
    test('test publishAnnouncement', () async {
      // TODO
    });

    // Reply yes or no for one child
    //
    // Roles: guardian (own child). Only for announcements with `requires_response`. Replaces any earlier reply.
    //
    //Future<AnnouncementResponse> respondToAnnouncement(String id, RespondToAnnouncementRequest respondToAnnouncementRequest) async
    test('test respondToAnnouncement', () async {
      // TODO
    });

  });
}
