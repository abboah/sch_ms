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


/// tests for ConferencesApi
void main() {
  // final instance = ConferencesApi();

  group('tests for ConferencesApi', () {
    // Book this slot for a child
    //
    // Roles: guardian. The teacher must teach the child. 409 if already booked.
    //
    //Future<ConferenceSlot> bookConferenceSlot(String id, BookConferenceSlotRequest bookConferenceSlotRequest) async
    test('test bookConferenceSlot', () async {
      // TODO
    });

    // Create slots (a window split into equal slots)
    //
    // Roles: teacher (own), admin.
    //
    //Future<ListConferenceSlots200Response> createConferenceSlots(CreateConferenceSlotsRequest createConferenceSlotsRequest) async
    test('test createConferenceSlots', () async {
      // TODO
    });

    // Slots I can see
    //
    // Roles: guardian (open slots of their children's teachers, plus their own bookings), teacher (own), admin (all).
    //
    //Future<ListConferenceSlots200Response> listConferenceSlots({ String teacherId, String from }) async
    test('test listConferenceSlots', () async {
      // TODO
    });

    // Release my booking
    //
    // Roles: guardian (who booked).
    //
    //Future releaseConferenceSlot(String id) async
    test('test releaseConferenceSlot', () async {
      // TODO
    });

  });
}
