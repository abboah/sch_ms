# homeroom_api.api.OnboardingApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSchool**](OnboardingApi.md#createschool) | **POST** /schools | Create a school by redeeming a one-time invite code


# **createSchool**
> School createSchool(createSchoolRequest)

Create a school by redeeming a one-time invite code

No login: an operator mints `invite_code` out of band (`node src/cli.ts create-invite`) and hands it to the school. Creates the school and its first admin, and sends that admin an account-setup email or SMS the same way `POST /people` does. The code is single-use and rejected once expired or already redeemed. 

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = OnboardingApi();
final createSchoolRequest = CreateSchoolRequest(); // CreateSchoolRequest | 

try {
    final result = api_instance.createSchool(createSchoolRequest);
    print(result);
} catch (e) {
    print('Exception when calling OnboardingApi->createSchool: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSchoolRequest** | [**CreateSchoolRequest**](CreateSchoolRequest.md)|  | 

### Return type

[**School**](School.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

