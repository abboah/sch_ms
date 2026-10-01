//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class GradebookApi {
  GradebookApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a gradebook column
  ///
  /// Roles: teacher (taught, term open).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssessmentInput] assessmentInput (required):
  Future<Response> createAssessmentWithHttpInfo(String id, AssessmentInput assessmentInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/assessments'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = assessmentInput;

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

  /// Create a gradebook column
  ///
  /// Roles: teacher (taught, term open).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssessmentInput] assessmentInput (required):
  Future<Assessment?> createAssessment(String id, AssessmentInput assessmentInput, { Future<void>? abortTrigger, }) async {
    final response = await createAssessmentWithHttpInfo(id, assessmentInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Assessment',) as Assessment;
    
    }
    return null;
  }

  /// Add a band to the school's grading scale
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateGradeBandRequest] createGradeBandRequest (required):
  Future<Response> createGradeBandWithHttpInfo(CreateGradeBandRequest createGradeBandRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/grade_bands';

    // ignore: prefer_final_locals
    Object? postBody = createGradeBandRequest;

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

  /// Add a band to the school's grading scale
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [CreateGradeBandRequest] createGradeBandRequest (required):
  Future<GradeBand?> createGradeBand(CreateGradeBandRequest createGradeBandRequest, { Future<void>? abortTrigger, }) async {
    final response = await createGradeBandWithHttpInfo(createGradeBandRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GradeBand',) as GradeBand;
    
    }
    return null;
  }

  /// Remove a band
  ///
  /// Roles: admin. Nothing else references grade bands, so this is a hard delete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> deleteGradeBandWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/grade_bands/{id}'
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

  /// Remove a band
  ///
  /// Roles: admin. Nothing else references grade bands, so this is a hard delete.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> deleteGradeBand(String id, { Future<void>? abortTrigger, }) async {
    final response = await deleteGradeBandWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Whole gradebook in one call (students × assessments)
  ///
  /// Roles: teacher (taught), admin (view). Includes weights, scores and each student's running average.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] subject:
  Future<Response> getGradebookWithHttpInfo(String id, { String? subject, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/gradebook'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (subject != null) {
      queryParams.addAll(_queryParams('', 'subject', subject));
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

  /// Whole gradebook in one call (students × assessments)
  ///
  /// Roles: teacher (taught), admin (view). Includes weights, scores and each student's running average.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] subject:
  Future<Gradebook?> getGradebook(String id, { String? subject, Future<void>? abortTrigger, }) async {
    final response = await getGradebookWithHttpInfo(id, subject: subject, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Gradebook',) as Gradebook;
    
    }
    return null;
  }

  /// A student's issued report comments
  ///
  /// Roles: admin (any time), guardian (own child, only once the term closes). Not every subject may have one yet.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getReportCommentsWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/report_comments'
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

  /// A student's issued report comments
  ///
  /// Roles: admin (any time), guardian (own child, only once the term closes). Not every subject may have one yet.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<GetReportComments200Response?> getReportComments(String id, { Future<void>? abortTrigger, }) async {
    final response = await getReportCommentsWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetReportComments200Response',) as GetReportComments200Response;
    
    }
    return null;
  }

  /// A student's grades by subject
  ///
  /// Roles: admin (view), teacher (own class), guardian (own child).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] termId:
  Future<Response> getStudentGradesWithHttpInfo(String id, { String? termId, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/grades'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (termId != null) {
      queryParams.addAll(_queryParams('', 'term_id', termId));
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

  /// A student's grades by subject
  ///
  /// Roles: admin (view), teacher (own class), guardian (own child).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] termId:
  Future<GetStudentGrades200Response?> getStudentGrades(String id, { String? termId, Future<void>? abortTrigger, }) async {
    final response = await getStudentGradesWithHttpInfo(id, termId: termId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentGrades200Response',) as GetStudentGrades200Response;
    
    }
    return null;
  }

  /// A school's grading scale
  ///
  /// Roles: any. Ordered by min_score descending. A school with none configured returns an empty list, and running grades show as bare numbers.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listGradeBandsWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/grade_bands';

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

  /// A school's grading scale
  ///
  /// Roles: any. Ordered by min_score descending. A school with none configured returns an empty list, and running grades show as bare numbers.
  Future<ListGradeBands200Response?> listGradeBands({ Future<void>? abortTrigger, }) async {
    final response = await listGradeBandsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListGradeBands200Response',) as ListGradeBands200Response;
    
    }
    return null;
  }

  /// Scores for one assessment
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> listGradesWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/assessments/{id}/grades'
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

  /// Scores for one assessment
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<ListGrades200Response?> listGrades(String id, { Future<void>? abortTrigger, }) async {
    final response = await listGradesWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListGrades200Response',) as ListGrades200Response;
    
    }
    return null;
  }

  /// One subject's drafted report comments, one per pupil
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] subject (required):
  Future<Response> listReportCommentsWithHttpInfo(String id, String subject, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/comments'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'subject', subject));

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

  /// One subject's drafted report comments, one per pupil
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] subject (required):
  Future<ReportCommentSheet?> listReportComments(String id, String subject, { Future<void>? abortTrigger, }) async {
    final response = await listReportCommentsWithHttpInfo(id, subject, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReportCommentSheet',) as ReportCommentSheet;
    
    }
    return null;
  }

  /// Edit an assessment's title, weight, max score or due date
  ///
  /// Roles: teacher (taught, term open).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssessmentInput] assessmentInput (required):
  Future<Response> updateAssessmentWithHttpInfo(String id, AssessmentInput assessmentInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/assessments/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = assessmentInput;

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

  /// Edit an assessment's title, weight, max score or due date
  ///
  /// Roles: teacher (taught, term open).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AssessmentInput] assessmentInput (required):
  Future<Assessment?> updateAssessment(String id, AssessmentInput assessmentInput, { Future<void>? abortTrigger, }) async {
    final response = await updateAssessmentWithHttpInfo(id, assessmentInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Assessment',) as Assessment;
    
    }
    return null;
  }

  /// Edit a band
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateGradeBandRequest] updateGradeBandRequest (required):
  Future<Response> updateGradeBandWithHttpInfo(String id, UpdateGradeBandRequest updateGradeBandRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/grade_bands/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateGradeBandRequest;

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

  /// Edit a band
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateGradeBandRequest] updateGradeBandRequest (required):
  Future<GradeBand?> updateGradeBand(String id, UpdateGradeBandRequest updateGradeBandRequest, { Future<void>? abortTrigger, }) async {
    final response = await updateGradeBandWithHttpInfo(id, updateGradeBandRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GradeBand',) as GradeBand;
    
    }
    return null;
  }

  /// Batch upsert, one row per student
  ///
  /// Roles: teacher (taught, term open). Per-entry outcomes like the attendance PUT; a score above `max_score` is rejected for that entry.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpsertGradesRequest] upsertGradesRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Response> upsertGradesWithHttpInfo(String id, UpsertGradesRequest upsertGradesRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/assessments/{id}/grades'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = upsertGradesRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (idempotencyKey != null) {
      headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);
    }

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

  /// Batch upsert, one row per student
  ///
  /// Roles: teacher (taught, term open). Per-entry outcomes like the attendance PUT; a score above `max_score` is rejected for that entry.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpsertGradesRequest] upsertGradesRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<BatchResult?> upsertGrades(String id, UpsertGradesRequest upsertGradesRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    final response = await upsertGradesWithHttpInfo(id, upsertGradesRequest, idempotencyKey: idempotencyKey, abortTrigger: abortTrigger,);
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

  /// Batch save drafted comments, one row per pupil
  ///
  /// Roles: teacher (taught, term open). Not visible to guardians until the term closes.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpsertReportCommentsRequest] upsertReportCommentsRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Response> upsertReportCommentsWithHttpInfo(String id, UpsertReportCommentsRequest upsertReportCommentsRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/comments'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = upsertReportCommentsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (idempotencyKey != null) {
      headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);
    }

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

  /// Batch save drafted comments, one row per pupil
  ///
  /// Roles: teacher (taught, term open). Not visible to guardians until the term closes.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpsertReportCommentsRequest] upsertReportCommentsRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<BatchResult?> upsertReportComments(String id, UpsertReportCommentsRequest upsertReportCommentsRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    final response = await upsertReportCommentsWithHttpInfo(id, upsertReportCommentsRequest, idempotencyKey: idempotencyKey, abortTrigger: abortTrigger,);
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
