//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MeApi {
  MeApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Who am I, and what can I switch between
  ///
  /// Roles: any. Guardians get `children` (drives the child switcher); teachers get `sections`. 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMeWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me';

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

  /// Who am I, and what can I switch between
  ///
  /// Roles: any. Guardians get `children` (drives the child switcher); teachers get `sections`. 
  Future<Me?> getMe({ Future<void>? abortTrigger, }) async {
    final response = await getMeWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Me',) as Me;
    
    }
    return null;
  }

  /// Channels the caller receives alerts on
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getNotificationPrefsWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me/notification_prefs';

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

  /// Channels the caller receives alerts on
  Future<NotificationPrefs?> getNotificationPrefs({ Future<void>? abortTrigger, }) async {
    final response = await getNotificationPrefsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationPrefs',) as NotificationPrefs;
    
    }
    return null;
  }

  /// My in-app notifications, newest first
  ///
  /// Roles: any. Attendance alerts, fee receipts, homework, announcements, messages.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [bool] unread:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listNotificationsWithHttpInfo({ bool? unread, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/notifications';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (unread != null) {
      queryParams.addAll(_queryParams('', 'unread', unread));
    }
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

  /// My in-app notifications, newest first
  ///
  /// Roles: any. Attendance alerts, fee receipts, homework, announcements, messages.
  ///
  /// Parameters:
  ///
  /// * [bool] unread:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<NotificationPage?> listNotifications({ bool? unread, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listNotificationsWithHttpInfo(unread: unread, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationPage',) as NotificationPage;
    
    }
    return null;
  }

  /// Mark notifications read (given ids, or all when ids is omitted)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MarkNotificationsReadRequest] markNotificationsReadRequest (required):
  Future<Response> markNotificationsReadWithHttpInfo(MarkNotificationsReadRequest markNotificationsReadRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/notifications/read';

    // ignore: prefer_final_locals
    Object? postBody = markNotificationsReadRequest;

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

  /// Mark notifications read (given ids, or all when ids is omitted)
  ///
  /// Parameters:
  ///
  /// * [MarkNotificationsReadRequest] markNotificationsReadRequest (required):
  Future<void> markNotificationsRead(MarkNotificationsReadRequest markNotificationsReadRequest, { Future<void>? abortTrigger, }) async {
    final response = await markNotificationsReadWithHttpInfo(markNotificationsReadRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Register a device for push
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterPushTokenRequest] registerPushTokenRequest (required):
  Future<Response> registerPushTokenWithHttpInfo(RegisterPushTokenRequest registerPushTokenRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me/push_tokens';

    // ignore: prefer_final_locals
    Object? postBody = registerPushTokenRequest;

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

  /// Register a device for push
  ///
  /// Parameters:
  ///
  /// * [RegisterPushTokenRequest] registerPushTokenRequest (required):
  Future<void> registerPushToken(RegisterPushTokenRequest registerPushTokenRequest, { Future<void>? abortTrigger, }) async {
    final response = await registerPushTokenWithHttpInfo(registerPushTokenRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Replace notification channel preferences
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [NotificationPrefs] notificationPrefs (required):
  Future<Response> setNotificationPrefsWithHttpInfo(NotificationPrefs notificationPrefs, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me/notification_prefs';

    // ignore: prefer_final_locals
    Object? postBody = notificationPrefs;

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

  /// Replace notification channel preferences
  ///
  /// Parameters:
  ///
  /// * [NotificationPrefs] notificationPrefs (required):
  Future<NotificationPrefs?> setNotificationPrefs(NotificationPrefs notificationPrefs, { Future<void>? abortTrigger, }) async {
    final response = await setNotificationPrefsWithHttpInfo(notificationPrefs, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'NotificationPrefs',) as NotificationPrefs;
    
    }
    return null;
  }

  /// Unregister a device (call on sign-out)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> unregisterPushTokenWithHttpInfo(String token, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me/push_tokens/{token}'
      .replaceAll('{token}', token);

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

  /// Unregister a device (call on sign-out)
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<void> unregisterPushToken(String token, { Future<void>? abortTrigger, }) async {
    final response = await unregisterPushTokenWithHttpInfo(token, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update my own phone and email
  ///
  /// Roles: any. Only the caller's own contact row; nobody else can read it except admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UpdateMyContactRequest] updateMyContactRequest (required):
  Future<Response> updateMyContactWithHttpInfo(UpdateMyContactRequest updateMyContactRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/me/contact';

    // ignore: prefer_final_locals
    Object? postBody = updateMyContactRequest;

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

  /// Update my own phone and email
  ///
  /// Roles: any. Only the caller's own contact row; nobody else can read it except admin.
  ///
  /// Parameters:
  ///
  /// * [UpdateMyContactRequest] updateMyContactRequest (required):
  Future<Contact?> updateMyContact(UpdateMyContactRequest updateMyContactRequest, { Future<void>? abortTrigger, }) async {
    final response = await updateMyContactWithHttpInfo(updateMyContactRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Contact',) as Contact;
    
    }
    return null;
  }
}
