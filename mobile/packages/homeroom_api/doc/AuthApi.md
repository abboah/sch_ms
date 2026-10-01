# homeroom_api.api.AuthApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**refreshSession**](AuthApi.md#refreshsession) | **POST** /auth/refresh | Exchange a refresh token for a new access and refresh token
[**requestOtp**](AuthApi.md#requestotp) | **POST** /auth/otp | Request a one-time code by SMS (guardians without email)
[**requestPasswordReset**](AuthApi.md#requestpasswordreset) | **POST** /auth/password/forgot | Email a password-reset link
[**resetPassword**](AuthApi.md#resetpassword) | **POST** /auth/password/reset | Choose a new password from a reset or invitation link
[**selectSessionPerson**](AuthApi.md#selectsessionperson) | **POST** /auth/sessions/select | Finish sign-in by choosing which role to continue as
[**signInWithPassword**](AuthApi.md#signinwithpassword) | **POST** /auth/sessions | Sign in with email and password
[**signOut**](AuthApi.md#signout) | **DELETE** /auth/sessions/current | Sign out
[**verifyOtp**](AuthApi.md#verifyotp) | **POST** /auth/otp/verify | Exchange a one-time code for a session


# **refreshSession**
> Session refreshSession(refreshSessionRequest)

Exchange a refresh token for a new access and refresh token

Refresh tokens rotate: each is single-use. Presenting one that was already used revokes the whole session family (token theft response).

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final refreshSessionRequest = RefreshSessionRequest(); // RefreshSessionRequest | 

try {
    final result = api_instance.refreshSession(refreshSessionRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshSessionRequest** | [**RefreshSessionRequest**](RefreshSessionRequest.md)|  | 

### Return type

[**Session**](Session.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestOtp**
> requestOtp(requestOtpRequest)

Request a one-time code by SMS (guardians without email)

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final requestOtpRequest = RequestOtpRequest(); // RequestOtpRequest | 

try {
    api_instance.requestOtp(requestOtpRequest);
} catch (e) {
    print('Exception when calling AuthApi->requestOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestOtpRequest** | [**RequestOtpRequest**](RequestOtpRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestPasswordReset**
> requestPasswordReset(requestPasswordResetRequest)

Email a password-reset link

Always 204, whether or not the address has an account, so it cannot be used to discover accounts.

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final requestPasswordResetRequest = RequestPasswordResetRequest(); // RequestPasswordResetRequest | 

try {
    api_instance.requestPasswordReset(requestPasswordResetRequest);
} catch (e) {
    print('Exception when calling AuthApi->requestPasswordReset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestPasswordResetRequest** | [**RequestPasswordResetRequest**](RequestPasswordResetRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPassword**
> resetPassword(resetPasswordRequest)

Choose a new password from a reset or invitation link

The token is single-use. Success signs the account out of every device.

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final resetPasswordRequest = ResetPasswordRequest(); // ResetPasswordRequest | 

try {
    api_instance.resetPassword(resetPasswordRequest);
} catch (e) {
    print('Exception when calling AuthApi->resetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **selectSessionPerson**
> Session selectSessionPerson(selectSessionPersonRequest)

Finish sign-in by choosing which role to continue as

Used when sign-in returned selection_required because the account holds several people (for example an admin who is also a parent).

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final selectSessionPersonRequest = SelectSessionPersonRequest(); // SelectSessionPersonRequest | 

try {
    final result = api_instance.selectSessionPerson(selectSessionPersonRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->selectSessionPerson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **selectSessionPersonRequest** | [**SelectSessionPersonRequest**](SelectSessionPersonRequest.md)|  | 

### Return type

[**Session**](Session.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signInWithPassword**
> SignInResult signInWithPassword(signInWithPasswordRequest)

Sign in with email and password

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final signInWithPasswordRequest = SignInWithPasswordRequest(); // SignInWithPasswordRequest | 

try {
    final result = api_instance.signInWithPassword(signInWithPasswordRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->signInWithPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signInWithPasswordRequest** | [**SignInWithPasswordRequest**](SignInWithPasswordRequest.md)|  | 

### Return type

[**SignInResult**](SignInResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signOut**
> signOut()

Sign out

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();

try {
    api_instance.signOut();
} catch (e) {
    print('Exception when calling AuthApi->signOut: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyOtp**
> SignInResult verifyOtp(verifyOtpRequest)

Exchange a one-time code for a session

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = AuthApi();
final verifyOtpRequest = VerifyOtpRequest(); // VerifyOtpRequest | 

try {
    final result = api_instance.verifyOtp(verifyOtpRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->verifyOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyOtpRequest** | [**VerifyOtpRequest**](VerifyOtpRequest.md)|  | 

### Return type

[**SignInResult**](SignInResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

