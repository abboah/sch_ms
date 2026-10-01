# homeroom_api.api.OverviewApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAdminOverview**](OverviewApi.md#getadminoverview) | **GET** /admin/overview | Admin home
[**getTeacherToday**](OverviewApi.md#getteachertoday) | **GET** /teacher/today | Teacher home, periods for a day with register status


# **getAdminOverview**
> AdminOverview getAdminOverview()

Admin home

Roles: admin. Today's attendance rate, unmarked registers, fees outstanding, recent announcements.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OverviewApi();

try {
    final result = api_instance.getAdminOverview();
    print(result);
} catch (e) {
    print('Exception when calling OverviewApi->getAdminOverview: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminOverview**](AdminOverview.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeacherToday**
> GetTeacherToday200Response getTeacherToday(date)

Teacher home, periods for a day with register status

Roles: teacher.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OverviewApi();
final date = date_example; // String | Defaults to today in the school's timezone

try {
    final result = api_instance.getTeacherToday(date);
    print(result);
} catch (e) {
    print('Exception when calling OverviewApi->getTeacherToday: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**| Defaults to today in the school's timezone | [optional] 

### Return type

[**GetTeacherToday200Response**](GetTeacherToday200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

