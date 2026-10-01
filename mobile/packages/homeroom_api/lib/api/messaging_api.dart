//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MessagingApi {
  MessagingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Messages in a thread, oldest first
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listMessagesWithHttpInfo(String id, { int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/threads/{id}/messages'
      .replaceAll('{id}', id);

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

  /// Messages in a thread, oldest first
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<ListMessages200Response?> listMessages(String id, { int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listMessagesWithHttpInfo(id, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListMessages200Response',) as ListMessages200Response;
    
    }
    return null;
  }

  /// My message threads (admin: all, read-only audit)
  ///
  /// Roles: teacher, guardian (participant), admin (audit).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] studentId:
  Future<Response> listThreadsWithHttpInfo({ String? studentId, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/threads';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (studentId != null) {
      queryParams.addAll(_queryParams('', 'student_id', studentId));
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

  /// My message threads (admin: all, read-only audit)
  ///
  /// Roles: teacher, guardian (participant), admin (audit).
  ///
  /// Parameters:
  ///
  /// * [String] studentId:
  Future<ListThreads200Response?> listThreads({ String? studentId, Future<void>? abortTrigger, }) async {
    final response = await listThreadsWithHttpInfo(studentId: studentId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListThreads200Response',) as ListThreads200Response;
    
    }
    return null;
  }

  /// Mark a thread read up to now (clears its unread badge)
  ///
  /// Roles: teacher, guardian (participant).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> markThreadReadWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/threads/{id}/read'
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

  /// Mark a thread read up to now (clears its unread badge)
  ///
  /// Roles: teacher, guardian (participant).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> markThreadRead(String id, { Future<void>? abortTrigger, }) async {
    final response = await markThreadReadWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Open a thread about a child
  ///
  /// Roles: teacher, guardian. A thread is always about one student both parties share, never a free DM. Returns the existing thread if one already exists for (student, teacher, guardian). 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [OpenThreadRequest] openThreadRequest (required):
  Future<Response> openThreadWithHttpInfo(OpenThreadRequest openThreadRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/threads';

    // ignore: prefer_final_locals
    Object? postBody = openThreadRequest;

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

  /// Open a thread about a child
  ///
  /// Roles: teacher, guardian. A thread is always about one student both parties share, never a free DM. Returns the existing thread if one already exists for (student, teacher, guardian). 
  ///
  /// Parameters:
  ///
  /// * [OpenThreadRequest] openThreadRequest (required):
  Future<Thread?> openThread(OpenThreadRequest openThreadRequest, { Future<void>? abortTrigger, }) async {
    final response = await openThreadWithHttpInfo(openThreadRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Thread',) as Thread;
    
    }
    return null;
  }

  /// Send a message
  ///
  /// Roles: teacher, guardian (participant). Messages are immutable once sent. Admin cannot post.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Response> sendMessageWithHttpInfo(String id, SendMessageRequest sendMessageRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/threads/{id}/messages'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = sendMessageRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (idempotencyKey != null) {
      headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);
    }

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

  /// Send a message
  ///
  /// Roles: teacher, guardian (participant). Messages are immutable once sent. Admin cannot post.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Message?> sendMessage(String id, SendMessageRequest sendMessageRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    final response = await sendMessageWithHttpInfo(id, sendMessageRequest, idempotencyKey: idempotencyKey, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Message',) as Message;
    
    }
    return null;
  }
}
