# homeroom_api.api.MeApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMe**](MeApi.md#getme) | **GET** /me | Who am I, and what can I switch between
[**getNotificationPrefs**](MeApi.md#getnotificationprefs) | **GET** /me/notification_prefs | Channels the caller receives alerts on
[**listNotifications**](MeApi.md#listnotifications) | **GET** /notifications | My in-app notifications, newest first
[**markNotificationsRead**](MeApi.md#marknotificationsread) | **POST** /notifications/read | Mark notifications read (given ids, or all when ids is omitted)
[**registerPushToken**](MeApi.md#registerpushtoken) | **POST** /me/push_tokens | Register a device for push
[**setNotificationPrefs**](MeApi.md#setnotificationprefs) | **PUT** /me/notification_prefs | Replace notification channel preferences
[**unregisterPushToken**](MeApi.md#unregisterpushtoken) | **DELETE** /me/push_tokens/{token} | Unregister a device (call on sign-out)
[**updateMyContact**](MeApi.md#updatemycontact) | **PUT** /me/contact | Update my own phone and email


# **getMe**
> Me getMe()

Who am I, and what can I switch between

Roles: any. Guardians get `children` (drives the child switcher); teachers get `sections`. 

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();

try {
    final result = api_instance.getMe();
    print(result);
} catch (e) {
    print('Exception when calling MeApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Me**](Me.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNotificationPrefs**
> NotificationPrefs getNotificationPrefs()

Channels the caller receives alerts on

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();

try {
    final result = api_instance.getNotificationPrefs();
    print(result);
} catch (e) {
    print('Exception when calling MeApi->getNotificationPrefs: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NotificationPrefs**](NotificationPrefs.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNotifications**
> NotificationPage listNotifications(unread, limit, cursor)

My in-app notifications, newest first

Roles: any. Attendance alerts, fee receipts, homework, announcements, messages.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final unread = true; // bool | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listNotifications(unread, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling MeApi->listNotifications: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **unread** | **bool**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**NotificationPage**](NotificationPage.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNotificationsRead**
> markNotificationsRead(markNotificationsReadRequest)

Mark notifications read (given ids, or all when ids is omitted)

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final markNotificationsReadRequest = MarkNotificationsReadRequest(); // MarkNotificationsReadRequest | 

try {
    api_instance.markNotificationsRead(markNotificationsReadRequest);
} catch (e) {
    print('Exception when calling MeApi->markNotificationsRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **markNotificationsReadRequest** | [**MarkNotificationsReadRequest**](MarkNotificationsReadRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerPushToken**
> registerPushToken(registerPushTokenRequest)

Register a device for push

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final registerPushTokenRequest = RegisterPushTokenRequest(); // RegisterPushTokenRequest | 

try {
    api_instance.registerPushToken(registerPushTokenRequest);
} catch (e) {
    print('Exception when calling MeApi->registerPushToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerPushTokenRequest** | [**RegisterPushTokenRequest**](RegisterPushTokenRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setNotificationPrefs**
> NotificationPrefs setNotificationPrefs(notificationPrefs)

Replace notification channel preferences

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final notificationPrefs = NotificationPrefs(); // NotificationPrefs | 

try {
    final result = api_instance.setNotificationPrefs(notificationPrefs);
    print(result);
} catch (e) {
    print('Exception when calling MeApi->setNotificationPrefs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notificationPrefs** | [**NotificationPrefs**](NotificationPrefs.md)|  | 

### Return type

[**NotificationPrefs**](NotificationPrefs.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unregisterPushToken**
> unregisterPushToken(token)

Unregister a device (call on sign-out)

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final token = token_example; // String | 

try {
    api_instance.unregisterPushToken(token);
} catch (e) {
    print('Exception when calling MeApi->unregisterPushToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMyContact**
> Contact updateMyContact(updateMyContactRequest)

Update my own phone and email

Roles: any. Only the caller's own contact row; nobody else can read it except admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MeApi();
final updateMyContactRequest = UpdateMyContactRequest(); // UpdateMyContactRequest | 

try {
    final result = api_instance.updateMyContact(updateMyContactRequest);
    print(result);
} catch (e) {
    print('Exception when calling MeApi->updateMyContact: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateMyContactRequest** | [**UpdateMyContactRequest**](UpdateMyContactRequest.md)|  | 

### Return type

[**Contact**](Contact.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

