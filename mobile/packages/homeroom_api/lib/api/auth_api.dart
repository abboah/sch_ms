//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Exchange a refresh token for a new access and refresh token
  ///
  /// Refresh tokens rotate: each is single-use. Presenting one that was already used revokes the whole session family (token theft response).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshSessionRequest] refreshSessionRequest (required):
  Future<Response> refreshSessionWithHttpInfo(RefreshSessionRequest refreshSessionRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshSessionRequest;

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

  /// Exchange a refresh token for a new access and refresh token
  ///
  /// Refresh tokens rotate: each is single-use. Presenting one that was already used revokes the whole session family (token theft response).
  ///
  /// Parameters:
  ///
  /// * [RefreshSessionRequest] refreshSessionRequest (required):
  Future<Session?> refreshSession(RefreshSessionRequest refreshSessionRequest, { Future<void>? abortTrigger, }) async {
    final response = await refreshSessionWithHttpInfo(refreshSessionRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Session',) as Session;
    
    }
    return null;
  }

  /// Request a one-time code by SMS (guardians without email)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RequestOtpRequest] requestOtpRequest (required):
  Future<Response> requestOtpWithHttpInfo(RequestOtpRequest requestOtpRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/otp';

    // ignore: prefer_final_locals
    Object? postBody = requestOtpRequest;

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

  /// Request a one-time code by SMS (guardians without email)
  ///
  /// Parameters:
  ///
  /// * [RequestOtpRequest] requestOtpRequest (required):
  Future<void> requestOtp(RequestOtpRequest requestOtpRequest, { Future<void>? abortTrigger, }) async {
    final response = await requestOtpWithHttpInfo(requestOtpRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Email a password-reset link
  ///
  /// Always 204, whether or not the address has an account, so it cannot be used to discover accounts.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RequestPasswordResetRequest] requestPasswordResetRequest (required):
  Future<Response> requestPasswordResetWithHttpInfo(RequestPasswordResetRequest requestPasswordResetRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/password/forgot';

    // ignore: prefer_final_locals
    Object? postBody = requestPasswordResetRequest;

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

  /// Email a password-reset link
  ///
  /// Always 204, whether or not the address has an account, so it cannot be used to discover accounts.
  ///
  /// Parameters:
  ///
  /// * [RequestPasswordResetRequest] requestPasswordResetRequest (required):
  Future<void> requestPasswordReset(RequestPasswordResetRequest requestPasswordResetRequest, { Future<void>? abortTrigger, }) async {
    final response = await requestPasswordResetWithHttpInfo(requestPasswordResetRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Choose a new password from a reset or invitation link
  ///
  /// The token is single-use. Success signs the account out of every device.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ResetPasswordRequest] resetPasswordRequest (required):
  Future<Response> resetPasswordWithHttpInfo(ResetPasswordRequest resetPasswordRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/password/reset';

    // ignore: prefer_final_locals
    Object? postBody = resetPasswordRequest;

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

  /// Choose a new password from a reset or invitation link
  ///
  /// The token is single-use. Success signs the account out of every device.
  ///
  /// Parameters:
  ///
  /// * [ResetPasswordRequest] resetPasswordRequest (required):
  Future<void> resetPassword(ResetPasswordRequest resetPasswordRequest, { Future<void>? abortTrigger, }) async {
    final response = await resetPasswordWithHttpInfo(resetPasswordRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Finish sign-in by choosing which role to continue as
  ///
  /// Used when sign-in returned selection_required because the account holds several people (for example an admin who is also a parent).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SelectSessionPersonRequest] selectSessionPersonRequest (required):
  Future<Response> selectSessionPersonWithHttpInfo(SelectSessionPersonRequest selectSessionPersonRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/sessions/select';

    // ignore: prefer_final_locals
    Object? postBody = selectSessionPersonRequest;

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

  /// Finish sign-in by choosing which role to continue as
  ///
  /// Used when sign-in returned selection_required because the account holds several people (for example an admin who is also a parent).
  ///
  /// Parameters:
  ///
  /// * [SelectSessionPersonRequest] selectSessionPersonRequest (required):
  Future<Session?> selectSessionPerson(SelectSessionPersonRequest selectSessionPersonRequest, { Future<void>? abortTrigger, }) async {
    final response = await selectSessionPersonWithHttpInfo(selectSessionPersonRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Session',) as Session;
    
    }
    return null;
  }

  /// Sign in with email and password
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SignInWithPasswordRequest] signInWithPasswordRequest (required):
  Future<Response> signInWithPasswordWithHttpInfo(SignInWithPasswordRequest signInWithPasswordRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/sessions';

    // ignore: prefer_final_locals
    Object? postBody = signInWithPasswordRequest;

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

  /// Sign in with email and password
  ///
  /// Parameters:
  ///
  /// * [SignInWithPasswordRequest] signInWithPasswordRequest (required):
  Future<SignInResult?> signInWithPassword(SignInWithPasswordRequest signInWithPasswordRequest, { Future<void>? abortTrigger, }) async {
    final response = await signInWithPasswordWithHttpInfo(signInWithPasswordRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SignInResult',) as SignInResult;
    
    }
    return null;
  }

  /// Sign out
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> signOutWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/sessions/current';

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

  /// Sign out
  Future<void> signOut({ Future<void>? abortTrigger, }) async {
    final response = await signOutWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Exchange a one-time code for a session
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [VerifyOtpRequest] verifyOtpRequest (required):
  Future<Response> verifyOtpWithHttpInfo(VerifyOtpRequest verifyOtpRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/otp/verify';

    // ignore: prefer_final_locals
    Object? postBody = verifyOtpRequest;

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

  /// Exchange a one-time code for a session
  ///
  /// Parameters:
  ///
  /// * [VerifyOtpRequest] verifyOtpRequest (required):
  Future<SignInResult?> verifyOtp(VerifyOtpRequest verifyOtpRequest, { Future<void>? abortTrigger, }) async {
    final response = await verifyOtpWithHttpInfo(verifyOtpRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SignInResult',) as SignInResult;
    
    }
    return null;
  }
}
