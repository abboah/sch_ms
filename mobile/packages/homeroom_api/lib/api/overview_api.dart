//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OverviewApi {
  OverviewApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Admin home
  ///
  /// Roles: admin. Today's attendance rate, unmarked registers, fees outstanding, recent announcements.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAdminOverviewWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/overview';

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

  /// Admin home
  ///
  /// Roles: admin. Today's attendance rate, unmarked registers, fees outstanding, recent announcements.
  Future<AdminOverview?> getAdminOverview({ Future<void>? abortTrigger, }) async {
    final response = await getAdminOverviewWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminOverview',) as AdminOverview;
    
    }
    return null;
  }

  /// Teacher home, periods for a day with register status
  ///
  /// Roles: teacher.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] date:
  ///   Defaults to today in the school's timezone
  Future<Response> getTeacherTodayWithHttpInfo({ String? date, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/teacher/today';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (date != null) {
      queryParams.addAll(_queryParams('', 'date', date));
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

  /// Teacher home, periods for a day with register status
  ///
  /// Roles: teacher.
  ///
  /// Parameters:
  ///
  /// * [String] date:
  ///   Defaults to today in the school's timezone
  Future<GetTeacherToday200Response?> getTeacherToday({ String? date, Future<void>? abortTrigger, }) async {
    final response = await getTeacherTodayWithHttpInfo(date: date, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetTeacherToday200Response',) as GetTeacherToday200Response;
    
    }
    return null;
  }
}
