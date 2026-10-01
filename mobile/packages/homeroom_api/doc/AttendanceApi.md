# homeroom_api.api.AttendanceApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**correctAttendanceRecord**](AttendanceApi.md#correctattendancerecord) | **PATCH** /attendance_records/{id} | Correct a single record
[**getRegister**](AttendanceApi.md#getregister) | **GET** /class_sections/{id}/attendance | The register for one period and date
[**getStudentAttendance**](AttendanceApi.md#getstudentattendance) | **GET** /students/{id}/attendance | A student's attendance history
[**submitRegister**](AttendanceApi.md#submitregister) | **PUT** /class_sections/{id}/attendance | Mark a whole period at once (also the offline-sync endpoint)


# **correctAttendanceRecord**
> AttendanceRecord correctAttendanceRecord(id, correctAttendanceRecordRequest)

Correct a single record

Roles: teacher (taught, term open), admin (any term).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final correctAttendanceRecordRequest = CorrectAttendanceRecordRequest(); // CorrectAttendanceRecordRequest | 

try {
    final result = api_instance.correctAttendanceRecord(id, correctAttendanceRecordRequest);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->correctAttendanceRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **correctAttendanceRecordRequest** | [**CorrectAttendanceRecordRequest**](CorrectAttendanceRecordRequest.md)|  | 

### Return type

[**AttendanceRecord**](AttendanceRecord.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRegister**
> Register getRegister(id, date, periodId)

The register for one period and date

Roles: teacher (taught), admin. Returns every enrolled student, with `status: null` where nothing is marked yet.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final date = date_example; // String | 
final periodId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getRegister(id, date, periodId);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->getRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **date** | **String**|  | 
 **periodId** | **String**|  | [optional] 

### Return type

[**Register**](Register.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStudentAttendance**
> GetStudentAttendance200Response getStudentAttendance(id, from, to)

A student's attendance history

Roles: admin, teacher (own class), guardian (own child). Drives the month calendar.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = from_example; // String | 
final to = to_example; // String | 

try {
    final result = api_instance.getStudentAttendance(id, from, to);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->getStudentAttendance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **from** | **String**|  | [optional] 
 **to** | **String**|  | [optional] 

### Return type

[**GetStudentAttendance200Response**](GetStudentAttendance200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitRegister**
> BatchResult submitRegister(id, registerSubmission, idempotencyKey)

Mark a whole period at once (also the offline-sync endpoint)

Roles: teacher (taught, term open), admin. Upserts on (student, section, period, date), so it is safe to replay. Each entry is validated independently and the response reports every outcome, so one bad row (for example a student no longer enrolled) does not lose the rest of a queued offline register. Conflict rule: **last write wins by `marked_at`**; an older queued write never overwrites a newer one. Triggers `attendance.marked` for each absent or late student (push, else SMS). 

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final registerSubmission = RegisterSubmission(); // RegisterSubmission | 
final idempotencyKey = idempotencyKey_example; // String | Client-generated; replays within 24 h return the original response.

try {
    final result = api_instance.submitRegister(id, registerSubmission, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->submitRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **registerSubmission** | [**RegisterSubmission**](RegisterSubmission.md)|  | 
 **idempotencyKey** | **String**| Client-generated; replays within 24 h return the original response. | [optional] 

### Return type

[**BatchResult**](BatchResult.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

