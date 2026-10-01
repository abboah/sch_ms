//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class HomeworkApi {
  HomeworkApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Homework for a child's sections
  ///
  /// Roles: guardian (own child), teacher, admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] dueFrom:
  Future<Response> getStudentHomeworkWithHttpInfo(String id, { String? dueFrom, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/homework'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (dueFrom != null) {
      queryParams.addAll(_queryParams('', 'due_from', dueFrom));
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

  /// Homework for a child's sections
  ///
  /// Roles: guardian (own child), teacher, admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] dueFrom:
  Future<GetStudentHomework200Response?> getStudentHomework(String id, { String? dueFrom, Future<void>? abortTrigger, }) async {
    final response = await getStudentHomeworkWithHttpInfo(id, dueFrom: dueFrom, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentHomework200Response',) as GetStudentHomework200Response;
    
    }
    return null;
  }

  /// Homework for a section
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> listHomeworkWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/homework'
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

  /// Homework for a section
  ///
  /// Roles: teacher (taught), admin (view).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<GetStudentHomework200Response?> listHomework(String id, { Future<void>? abortTrigger, }) async {
    final response = await listHomeworkWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentHomework200Response',) as GetStudentHomework200Response;
    
    }
    return null;
  }

  /// Post homework
  ///
  /// Roles: teacher (taught, term open). Notifies guardians of enrolled students.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [HomeworkInput] homeworkInput (required):
  Future<Response> postHomeworkWithHttpInfo(String id, HomeworkInput homeworkInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/homework'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = homeworkInput;

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

  /// Post homework
  ///
  /// Roles: teacher (taught, term open). Notifies guardians of enrolled students.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [HomeworkInput] homeworkInput (required):
  Future<Homework?> postHomework(String id, HomeworkInput homeworkInput, { Future<void>? abortTrigger, }) async {
    final response = await postHomeworkWithHttpInfo(id, homeworkInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Homework',) as Homework;
    
    }
    return null;
  }
}
