//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class StudentsApi {
  StudentsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Student profile
  ///
  /// Roles: admin, teacher (own class), guardian (own child). Guardians and enrollment history included for admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getStudentWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}'
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

  /// Student profile
  ///
  /// Roles: admin, teacher (own class), guardian (own child). Guardians and enrollment history included for admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<StudentDetail?> getStudent(String id, { Future<void>? abortTrigger, }) async {
    final response = await getStudentWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StudentDetail',) as StudentDetail;
    
    }
    return null;
  }

  /// The one call a portal home screen needs
  ///
  /// Roles: admin, teacher, guardian. Attendance rate, running grade per subject, balance. `balance` and `pending_payments` are null for teachers. **The read is written to the audit log.** 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getStudentSummaryWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/summary'
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

  /// The one call a portal home screen needs
  ///
  /// Roles: admin, teacher, guardian. Attendance rate, running grade per subject, balance. `balance` and `pending_payments` are null for teachers. **The read is written to the audit log.** 
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<StudentSummary?> getStudentSummary(String id, { Future<void>? abortTrigger, }) async {
    final response = await getStudentSummaryWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StudentSummary',) as StudentSummary;
    
    }
    return null;
  }

  /// List students the caller may see
  ///
  /// Roles: admin (all), teacher (own sections), guardian (own children).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] q:
  ///   Name search
  ///
  /// * [String] classSectionId:
  ///
  /// * [String] gradeLevel:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listStudentsWithHttpInfo({ String? q, String? classSectionId, String? gradeLevel, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }
    if (classSectionId != null) {
      queryParams.addAll(_queryParams('', 'class_section_id', classSectionId));
    }
    if (gradeLevel != null) {
      queryParams.addAll(_queryParams('', 'grade_level', gradeLevel));
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

  /// List students the caller may see
  ///
  /// Roles: admin (all), teacher (own sections), guardian (own children).
  ///
  /// Parameters:
  ///
  /// * [String] q:
  ///   Name search
  ///
  /// * [String] classSectionId:
  ///
  /// * [String] gradeLevel:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<StudentPage?> listStudents({ String? q, String? classSectionId, String? gradeLevel, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listStudentsWithHttpInfo(q: q, classSectionId: classSectionId, gradeLevel: gradeLevel, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StudentPage',) as StudentPage;
    
    }
    return null;
  }
}
