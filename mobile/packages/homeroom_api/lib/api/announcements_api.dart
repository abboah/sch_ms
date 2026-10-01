//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AnnouncementsApi {
  AnnouncementsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create an announcement or permission slip
  ///
  /// Roles: admin (school-wide or any class), teacher (own class only). Omit `published` to save a draft.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [AnnouncementInput] announcementInput (required):
  Future<Response> createAnnouncementWithHttpInfo(AnnouncementInput announcementInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/announcements';

    // ignore: prefer_final_locals
    Object? postBody = announcementInput;

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

  /// Create an announcement or permission slip
  ///
  /// Roles: admin (school-wide or any class), teacher (own class only). Omit `published` to save a draft.
  ///
  /// Parameters:
  ///
  /// * [AnnouncementInput] announcementInput (required):
  Future<Announcement?> createAnnouncement(AnnouncementInput announcementInput, { Future<void>? abortTrigger, }) async {
    final response = await createAnnouncementWithHttpInfo(announcementInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Announcement',) as Announcement;
    
    }
    return null;
  }

  /// Permission-slip tally
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getAnnouncementResponsesWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/announcements/{id}/responses'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Permission-slip tally
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<GetAnnouncementResponses200Response?> getAnnouncementResponses(String id, { Future<void>? abortTrigger, }) async {
    final response = await getAnnouncementResponsesWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetAnnouncementResponses200Response',) as GetAnnouncementResponses200Response;
    
    }
    return null;
  }

  /// Announcements visible to me
  ///
  /// Roles: any. Guardians see published, school-wide or their children's sections; admin also sees drafts.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listAnnouncementsWithHttpInfo({ int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/announcements';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
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

  /// Announcements visible to me
  ///
  /// Roles: any. Guardians see published, school-wide or their children's sections; admin also sees drafts.
  ///
  /// Parameters:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<AnnouncementPage?> listAnnouncements({ int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listAnnouncementsWithHttpInfo(limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AnnouncementPage',) as AnnouncementPage;
    
    }
    return null;
  }

  /// Publish a draft and fan out notifications
  ///
  /// Roles: admin, teacher (author).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> publishAnnouncementWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/announcements/{id}/publish'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Publish a draft and fan out notifications
  ///
  /// Roles: admin, teacher (author).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Announcement?> publishAnnouncement(String id, { Future<void>? abortTrigger, }) async {
    final response = await publishAnnouncementWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Announcement',) as Announcement;
    
    }
    return null;
  }

  /// Reply yes or no for one child
  ///
  /// Roles: guardian (own child). Only for announcements with `requires_response`. Replaces any earlier reply.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [RespondToAnnouncementRequest] respondToAnnouncementRequest (required):
  Future<Response> respondToAnnouncementWithHttpInfo(String id, RespondToAnnouncementRequest respondToAnnouncementRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/announcements/{id}/responses'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = respondToAnnouncementRequest;

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

  /// Reply yes or no for one child
  ///
  /// Roles: guardian (own child). Only for announcements with `requires_response`. Replaces any earlier reply.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [RespondToAnnouncementRequest] respondToAnnouncementRequest (required):
  Future<AnnouncementResponse?> respondToAnnouncement(String id, RespondToAnnouncementRequest respondToAnnouncementRequest, { Future<void>? abortTrigger, }) async {
    final response = await respondToAnnouncementWithHttpInfo(id, respondToAnnouncementRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AnnouncementResponse',) as AnnouncementResponse;
    
    }
    return null;
  }
}
