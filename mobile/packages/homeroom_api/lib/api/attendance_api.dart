//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AttendanceApi {
  AttendanceApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Correct a single record
  ///
  /// Roles: teacher (taught, term open), admin (any term).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [CorrectAttendanceRecordRequest] correctAttendanceRecordRequest (required):
  Future<Response> correctAttendanceRecordWithHttpInfo(String id, CorrectAttendanceRecordRequest correctAttendanceRecordRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/attendance_records/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = correctAttendanceRecordRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Correct a single record
  ///
  /// Roles: teacher (taught, term open), admin (any term).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [CorrectAttendanceRecordRequest] correctAttendanceRecordRequest (required):
  Future<AttendanceRecord?> correctAttendanceRecord(String id, CorrectAttendanceRecordRequest correctAttendanceRecordRequest, { Future<void>? abortTrigger, }) async {
    final response = await correctAttendanceRecordWithHttpInfo(id, correctAttendanceRecordRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttendanceRecord',) as AttendanceRecord;
    
    }
    return null;
  }

  /// The register for one period and date
  ///
  /// Roles: teacher (taught), admin. Returns every enrolled student, with `status: null` where nothing is marked yet.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] date (required):
  ///
  /// * [String] periodId:
  Future<Response> getRegisterWithHttpInfo(String id, String date, { String? periodId, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/attendance'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'date', date));
    if (periodId != null) {
      queryParams.addAll(_queryParams('', 'period_id', periodId));
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

  /// The register for one period and date
  ///
  /// Roles: teacher (taught), admin. Returns every enrolled student, with `status: null` where nothing is marked yet.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] date (required):
  ///
  /// * [String] periodId:
  Future<Register?> getRegister(String id, String date, { String? periodId, Future<void>? abortTrigger, }) async {
    final response = await getRegisterWithHttpInfo(id, date, periodId: periodId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Register',) as Register;
    
    }
    return null;
  }

  /// A student's attendance history
  ///
  /// Roles: admin, teacher (own class), guardian (own child). Drives the month calendar.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from:
  ///
  /// * [String] to:
  Future<Response> getStudentAttendanceWithHttpInfo(String id, { String? from, String? to, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/attendance'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (to != null) {
      queryParams.addAll(_queryParams('', 'to', to));
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

  /// A student's attendance history
  ///
  /// Roles: admin, teacher (own class), guardian (own child). Drives the month calendar.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from:
  ///
  /// * [String] to:
  Future<GetStudentAttendance200Response?> getStudentAttendance(String id, { String? from, String? to, Future<void>? abortTrigger, }) async {
    final response = await getStudentAttendanceWithHttpInfo(id, from: from, to: to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentAttendance200Response',) as GetStudentAttendance200Response;
    
    }
    return null;
  }

  /// Mark a whole period at once (also the offline-sync endpoint)
  ///
  /// Roles: teacher (taught, term open), admin. Upserts on (student, section, period, date), so it is safe to replay. Each entry is validated independently and the response reports every outcome, so one bad row (for example a student no longer enrolled) does not lose the rest of a queued offline register. Conflict rule: **last write wins by `marked_at`**; an older queued write never overwrites a newer one. Triggers `attendance.marked` for each absent or late student (push, else SMS). 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [RegisterSubmission] registerSubmission (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Response> submitRegisterWithHttpInfo(String id, RegisterSubmission registerSubmission, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/attendance'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = registerSubmission;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (idempotencyKey != null) {
      headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);
    }

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

  /// Mark a whole period at once (also the offline-sync endpoint)
  ///
  /// Roles: teacher (taught, term open), admin. Upserts on (student, section, period, date), so it is safe to replay. Each entry is validated independently and the response reports every outcome, so one bad row (for example a student no longer enrolled) does not lose the rest of a queued offline register. Conflict rule: **last write wins by `marked_at`**; an older queued write never overwrites a newer one. Triggers `attendance.marked` for each absent or late student (push, else SMS). 
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [RegisterSubmission] registerSubmission (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<BatchResult?> submitRegister(String id, RegisterSubmission registerSubmission, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    final response = await submitRegisterWithHttpInfo(id, registerSubmission, idempotencyKey: idempotencyKey, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BatchResult',) as BatchResult;
    
    }
    return null;
  }
}
