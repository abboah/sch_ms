//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OnboardingApi {
  OnboardingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a school by redeeming a one-time invite code
  ///
  /// No login: an operator mints `invite_code` out of band (`node src/cli.ts create-invite`) and hands it to the school. Creates the school and its first admin, and sends that admin an account-setup email or SMS the same way `POST /people` does. The code is single-use and rejected once expired or already redeemed. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateSchoolRequest] createSchoolRequest (required):
  Future<Response> createSchoolWithHttpInfo(CreateSchoolRequest createSchoolRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/schools';

    // ignore: prefer_final_locals
    Object? postBody = createSchoolRequest;

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

  /// Create a school by redeeming a one-time invite code
  ///
  /// No login: an operator mints `invite_code` out of band (`node src/cli.ts create-invite`) and hands it to the school. Creates the school and its first admin, and sends that admin an account-setup email or SMS the same way `POST /people` does. The code is single-use and rejected once expired or already redeemed. 
  ///
  /// Parameters:
  ///
  /// * [CreateSchoolRequest] createSchoolRequest (required):
  Future<School?> createSchool(CreateSchoolRequest createSchoolRequest, { Future<void>? abortTrigger, }) async {
    final response = await createSchoolWithHttpInfo(createSchoolRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'School',) as School;
    
    }
    return null;
  }
}
