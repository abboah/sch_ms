//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ConferencesApi {
  ConferencesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Book this slot for a child
  ///
  /// Roles: guardian. The teacher must teach the child. 409 if already booked.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [BookConferenceSlotRequest] bookConferenceSlotRequest (required):
  Future<Response> bookConferenceSlotWithHttpInfo(String id, BookConferenceSlotRequest bookConferenceSlotRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/conference_slots/{id}/booking'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = bookConferenceSlotRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Book this slot for a child
  ///
  /// Roles: guardian. The teacher must teach the child. 409 if already booked.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [BookConferenceSlotRequest] bookConferenceSlotRequest (required):
  Future<ConferenceSlot?> bookConferenceSlot(String id, BookConferenceSlotRequest bookConferenceSlotRequest, { Future<void>? abortTrigger, }) async {
    final response = await bookConferenceSlotWithHttpInfo(id, bookConferenceSlotRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ConferenceSlot',) as ConferenceSlot;
    
    }
    return null;
  }

  /// Create slots (a window split into equal slots)
  ///
  /// Roles: teacher (own), admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateConferenceSlotsRequest] createConferenceSlotsRequest (required):
  Future<Response> createConferenceSlotsWithHttpInfo(CreateConferenceSlotsRequest createConferenceSlotsRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/conference_slots';

    // ignore: prefer_final_locals
    Object? postBody = createConferenceSlotsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create slots (a window split into equal slots)
  ///
  /// Roles: teacher (own), admin.
  ///
  /// Parameters:
  ///
  /// * [CreateConferenceSlotsRequest] createConferenceSlotsRequest (required):
  Future<ListConferenceSlots200Response?> createConferenceSlots(CreateConferenceSlotsRequest createConferenceSlotsRequest, { Future<void>? abortTrigger, }) async {
    final response = await createConferenceSlotsWithHttpInfo(createConferenceSlotsRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListConferenceSlots200Response',) as ListConferenceSlots200Response;
    
    }
    return null;
  }

  /// Slots I can see
  ///
  /// Roles: guardian (open slots of their children's teachers, plus their own bookings), teacher (own), admin (all).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] teacherId:
  ///
  /// * [String] from:
  Future<Response> listConferenceSlotsWithHttpInfo({ String? teacherId, String? from, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/conference_slots';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (teacherId != null) {
      queryParams.addAll(_queryParams('', 'teacher_id', teacherId));
    }
    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Slots I can see
  ///
  /// Roles: guardian (open slots of their children's teachers, plus their own bookings), teacher (own), admin (all).
  ///
  /// Parameters:
  ///
  /// * [String] teacherId:
  ///
  /// * [String] from:
  Future<ListConferenceSlots200Response?> listConferenceSlots({ String? teacherId, String? from, Future<void>? abortTrigger, }) async {
    final response = await listConferenceSlotsWithHttpInfo(teacherId: teacherId, from: from, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListConferenceSlots200Response',) as ListConferenceSlots200Response;
    
    }
    return null;
  }

  /// Release my booking
  ///
  /// Roles: guardian (who booked).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> releaseConferenceSlotWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/conference_slots/{id}/booking'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Release my booking
  ///
  /// Roles: guardian (who booked).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> releaseConferenceSlot(String id, { Future<void>? abortTrigger, }) async {
    final response = await releaseConferenceSlotWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
