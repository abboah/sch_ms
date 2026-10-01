# homeroom_api.api.HomeworkApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getStudentHomework**](HomeworkApi.md#getstudenthomework) | **GET** /students/{id}/homework | Homework for a child's sections
[**listHomework**](HomeworkApi.md#listhomework) | **GET** /class_sections/{id}/homework | Homework for a section
[**postHomework**](HomeworkApi.md#posthomework) | **POST** /class_sections/{id}/homework | Post homework


# **getStudentHomework**
> GetStudentHomework200Response getStudentHomework(id, dueFrom)

Homework for a child's sections

Roles: guardian (own child), teacher, admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = HomeworkApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final dueFrom = dueFrom_example; // String | 

try {
    final result = api_instance.getStudentHomework(id, dueFrom);
    print(result);
} catch (e) {
    print('Exception when calling HomeworkApi->getStudentHomework: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **dueFrom** | **String**|  | [optional] 

### Return type

[**GetStudentHomework200Response**](GetStudentHomework200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listHomework**
> GetStudentHomework200Response listHomework(id)

Homework for a section

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

final api_instance = HomeworkApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.listHomework(id);
    print(result);
} catch (e) {
    print('Exception when calling HomeworkApi->listHomework: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**GetStudentHomework200Response**](GetStudentHomework200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postHomework**
> Homework postHomework(id, homeworkInput)

Post homework

Roles: teacher (taught, term open). Notifies guardians of enrolled students.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = HomeworkApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final homeworkInput = HomeworkInput(); // HomeworkInput | 

try {
    final result = api_instance.postHomework(id, homeworkInput);
    print(result);
} catch (e) {
    print('Exception when calling HomeworkApi->postHomework: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **homeworkInput** | [**HomeworkInput**](HomeworkInput.md)|  | 

### Return type

[**Homework**](Homework.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

