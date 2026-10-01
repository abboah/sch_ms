# homeroom_api.api.GradebookApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createAssessment**](GradebookApi.md#createassessment) | **POST** /class_sections/{id}/assessments | Create a gradebook column
[**createGradeBand**](GradebookApi.md#creategradeband) | **POST** /grade_bands | Add a band to the school's grading scale
[**deleteGradeBand**](GradebookApi.md#deletegradeband) | **DELETE** /grade_bands/{id} | Remove a band
[**getGradebook**](GradebookApi.md#getgradebook) | **GET** /class_sections/{id}/gradebook | Whole gradebook in one call (students × assessments)
[**getReportComments**](GradebookApi.md#getreportcomments) | **GET** /students/{id}/report_comments | A student's issued report comments
[**getStudentGrades**](GradebookApi.md#getstudentgrades) | **GET** /students/{id}/grades | A student's grades by subject
[**listGradeBands**](GradebookApi.md#listgradebands) | **GET** /grade_bands | A school's grading scale
[**listGrades**](GradebookApi.md#listgrades) | **GET** /assessments/{id}/grades | Scores for one assessment
[**listReportComments**](GradebookApi.md#listreportcomments) | **GET** /class_sections/{id}/comments | One subject's drafted report comments, one per pupil
[**updateAssessment**](GradebookApi.md#updateassessment) | **PATCH** /assessments/{id} | Edit an assessment's title, weight, max score or due date
[**updateGradeBand**](GradebookApi.md#updategradeband) | **PATCH** /grade_bands/{id} | Edit a band
[**upsertGrades**](GradebookApi.md#upsertgrades) | **PATCH** /assessments/{id}/grades | Batch upsert, one row per student
[**upsertReportComments**](GradebookApi.md#upsertreportcomments) | **PATCH** /class_sections/{id}/comments | Batch save drafted comments, one row per pupil


# **createAssessment**
> Assessment createAssessment(id, assessmentInput)

Create a gradebook column

Roles: teacher (taught, term open).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final assessmentInput = AssessmentInput(); // AssessmentInput | 

try {
    final result = api_instance.createAssessment(id, assessmentInput);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->createAssessment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **assessmentInput** | [**AssessmentInput**](AssessmentInput.md)|  | 

### Return type

[**Assessment**](Assessment.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createGradeBand**
> GradeBand createGradeBand(createGradeBandRequest)

Add a band to the school's grading scale

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final createGradeBandRequest = CreateGradeBandRequest(); // CreateGradeBandRequest | 

try {
    final result = api_instance.createGradeBand(createGradeBandRequest);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->createGradeBand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createGradeBandRequest** | [**CreateGradeBandRequest**](CreateGradeBandRequest.md)|  | 

### Return type

[**GradeBand**](GradeBand.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGradeBand**
> deleteGradeBand(id)

Remove a band

Roles: admin. Nothing else references grade bands, so this is a hard delete.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.deleteGradeBand(id);
} catch (e) {
    print('Exception when calling GradebookApi->deleteGradeBand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGradebook**
> Gradebook getGradebook(id, subject)

Whole gradebook in one call (students × assessments)

Roles: teacher (taught), admin (view). Includes weights, scores and each student's running average.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final subject = subject_example; // String | 

try {
    final result = api_instance.getGradebook(id, subject);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->getGradebook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **subject** | **String**|  | [optional] 

### Return type

[**Gradebook**](Gradebook.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReportComments**
> GetReportComments200Response getReportComments(id)

A student's issued report comments

Roles: admin (any time), guardian (own child, only once the term closes). Not every subject may have one yet.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getReportComments(id);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->getReportComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**GetReportComments200Response**](GetReportComments200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStudentGrades**
> GetStudentGrades200Response getStudentGrades(id, termId)

A student's grades by subject

Roles: admin (view), teacher (own class), guardian (own child).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final termId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getStudentGrades(id, termId);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->getStudentGrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **termId** | **String**|  | [optional] 

### Return type

[**GetStudentGrades200Response**](GetStudentGrades200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGradeBands**
> ListGradeBands200Response listGradeBands()

A school's grading scale

Roles: any. Ordered by min_score descending. A school with none configured returns an empty list, and running grades show as bare numbers.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();

try {
    final result = api_instance.listGradeBands();
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->listGradeBands: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListGradeBands200Response**](ListGradeBands200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGrades**
> ListGrades200Response listGrades(id)

Scores for one assessment

Roles: teacher (taught), admin (view).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.listGrades(id);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->listGrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ListGrades200Response**](ListGrades200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReportComments**
> ReportCommentSheet listReportComments(id, subject)

One subject's drafted report comments, one per pupil

Roles: teacher (taught), admin (view).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final subject = subject_example; // String | 

try {
    final result = api_instance.listReportComments(id, subject);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->listReportComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **subject** | **String**|  | 

### Return type

[**ReportCommentSheet**](ReportCommentSheet.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateAssessment**
> Assessment updateAssessment(id, assessmentInput)

Edit an assessment's title, weight, max score or due date

Roles: teacher (taught, term open).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final assessmentInput = AssessmentInput(); // AssessmentInput | 

try {
    final result = api_instance.updateAssessment(id, assessmentInput);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->updateAssessment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **assessmentInput** | [**AssessmentInput**](AssessmentInput.md)|  | 

### Return type

[**Assessment**](Assessment.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGradeBand**
> GradeBand updateGradeBand(id, updateGradeBandRequest)

Edit a band

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final updateGradeBandRequest = UpdateGradeBandRequest(); // UpdateGradeBandRequest | 

try {
    final result = api_instance.updateGradeBand(id, updateGradeBandRequest);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->updateGradeBand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateGradeBandRequest** | [**UpdateGradeBandRequest**](UpdateGradeBandRequest.md)|  | 

### Return type

[**GradeBand**](GradeBand.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertGrades**
> BatchResult upsertGrades(id, upsertGradesRequest, idempotencyKey)

Batch upsert, one row per student

Roles: teacher (taught, term open). Per-entry outcomes like the attendance PUT; a score above `max_score` is rejected for that entry.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final upsertGradesRequest = UpsertGradesRequest(); // UpsertGradesRequest | 
final idempotencyKey = idempotencyKey_example; // String | Client-generated; replays within 24 h return the original response.

try {
    final result = api_instance.upsertGrades(id, upsertGradesRequest, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->upsertGrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **upsertGradesRequest** | [**UpsertGradesRequest**](UpsertGradesRequest.md)|  | 
 **idempotencyKey** | **String**| Client-generated; replays within 24 h return the original response. | [optional] 

### Return type

[**BatchResult**](BatchResult.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertReportComments**
> BatchResult upsertReportComments(id, upsertReportCommentsRequest, idempotencyKey)

Batch save drafted comments, one row per pupil

Roles: teacher (taught, term open). Not visible to guardians until the term closes.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = GradebookApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final upsertReportCommentsRequest = UpsertReportCommentsRequest(); // UpsertReportCommentsRequest | 
final idempotencyKey = idempotencyKey_example; // String | Client-generated; replays within 24 h return the original response.

try {
    final result = api_instance.upsertReportComments(id, upsertReportCommentsRequest, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling GradebookApi->upsertReportComments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **upsertReportCommentsRequest** | [**UpsertReportCommentsRequest**](UpsertReportCommentsRequest.md)|  | 
 **idempotencyKey** | **String**| Client-generated; replays within 24 h return the original response. | [optional] 

### Return type

[**BatchResult**](BatchResult.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

