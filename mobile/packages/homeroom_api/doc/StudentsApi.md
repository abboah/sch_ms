# homeroom_api.api.StudentsApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getStudent**](StudentsApi.md#getstudent) | **GET** /students/{id} | Student profile
[**getStudentSummary**](StudentsApi.md#getstudentsummary) | **GET** /students/{id}/summary | The one call a portal home screen needs
[**listStudents**](StudentsApi.md#liststudents) | **GET** /students | List students the caller may see


# **getStudent**
> StudentDetail getStudent(id)

Student profile

Roles: admin, teacher (own class), guardian (own child). Guardians and enrollment history included for admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StudentsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getStudent(id);
    print(result);
} catch (e) {
    print('Exception when calling StudentsApi->getStudent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**StudentDetail**](StudentDetail.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStudentSummary**
> StudentSummary getStudentSummary(id)

The one call a portal home screen needs

Roles: admin, teacher, guardian. Attendance rate, running grade per subject, balance. `balance` and `pending_payments` are null for teachers. **The read is written to the audit log.** 

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StudentsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getStudentSummary(id);
    print(result);
} catch (e) {
    print('Exception when calling StudentsApi->getStudentSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**StudentSummary**](StudentSummary.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStudents**
> StudentPage listStudents(q, classSectionId, gradeLevel, limit, cursor)

List students the caller may see

Roles: admin (all), teacher (own sections), guardian (own children).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StudentsApi();
final q = q_example; // String | Name search
final classSectionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final gradeLevel = gradeLevel_example; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listStudents(q, classSectionId, gradeLevel, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling StudentsApi->listStudents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**| Name search | [optional] 
 **classSectionId** | **String**|  | [optional] 
 **gradeLevel** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**StudentPage**](StudentPage.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

