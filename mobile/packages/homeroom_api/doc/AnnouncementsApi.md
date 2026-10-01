# homeroom_api.api.AnnouncementsApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createAnnouncement**](AnnouncementsApi.md#createannouncement) | **POST** /announcements | Create an announcement or permission slip
[**getAnnouncementResponses**](AnnouncementsApi.md#getannouncementresponses) | **GET** /announcements/{id}/responses | Permission-slip tally
[**listAnnouncements**](AnnouncementsApi.md#listannouncements) | **GET** /announcements | Announcements visible to me
[**publishAnnouncement**](AnnouncementsApi.md#publishannouncement) | **POST** /announcements/{id}/publish | Publish a draft and fan out notifications
[**respondToAnnouncement**](AnnouncementsApi.md#respondtoannouncement) | **PUT** /announcements/{id}/responses | Reply yes or no for one child


# **createAnnouncement**
> Announcement createAnnouncement(announcementInput)

Create an announcement or permission slip

Roles: admin (school-wide or any class), teacher (own class only). Omit `published` to save a draft.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AnnouncementsApi();
final announcementInput = AnnouncementInput(); // AnnouncementInput | 

try {
    final result = api_instance.createAnnouncement(announcementInput);
    print(result);
} catch (e) {
    print('Exception when calling AnnouncementsApi->createAnnouncement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **announcementInput** | [**AnnouncementInput**](AnnouncementInput.md)|  | 

### Return type

[**Announcement**](Announcement.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAnnouncementResponses**
> GetAnnouncementResponses200Response getAnnouncementResponses(id)

Permission-slip tally

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

final api_instance = AnnouncementsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getAnnouncementResponses(id);
    print(result);
} catch (e) {
    print('Exception when calling AnnouncementsApi->getAnnouncementResponses: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**GetAnnouncementResponses200Response**](GetAnnouncementResponses200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAnnouncements**
> AnnouncementPage listAnnouncements(limit, cursor)

Announcements visible to me

Roles: any. Guardians see published, school-wide or their children's sections; admin also sees drafts.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AnnouncementsApi();
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listAnnouncements(limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling AnnouncementsApi->listAnnouncements: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**AnnouncementPage**](AnnouncementPage.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishAnnouncement**
> Announcement publishAnnouncement(id)

Publish a draft and fan out notifications

Roles: admin, teacher (author).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AnnouncementsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.publishAnnouncement(id);
    print(result);
} catch (e) {
    print('Exception when calling AnnouncementsApi->publishAnnouncement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Announcement**](Announcement.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **respondToAnnouncement**
> AnnouncementResponse respondToAnnouncement(id, respondToAnnouncementRequest)

Reply yes or no for one child

Roles: guardian (own child). Only for announcements with `requires_response`. Replaces any earlier reply.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AnnouncementsApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final respondToAnnouncementRequest = RespondToAnnouncementRequest(); // RespondToAnnouncementRequest | 

try {
    final result = api_instance.respondToAnnouncement(id, respondToAnnouncementRequest);
    print(result);
} catch (e) {
    print('Exception when calling AnnouncementsApi->respondToAnnouncement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **respondToAnnouncementRequest** | [**RespondToAnnouncementRequest**](RespondToAnnouncementRequest.md)|  | 

### Return type

[**AnnouncementResponse**](AnnouncementResponse.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

