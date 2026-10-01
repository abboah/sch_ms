# homeroom_api.api.MessagingApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listMessages**](MessagingApi.md#listmessages) | **GET** /threads/{id}/messages | Messages in a thread, oldest first
[**listThreads**](MessagingApi.md#listthreads) | **GET** /threads | My message threads (admin: all, read-only audit)
[**markThreadRead**](MessagingApi.md#markthreadread) | **POST** /threads/{id}/read | Mark a thread read up to now (clears its unread badge)
[**openThread**](MessagingApi.md#openthread) | **POST** /threads | Open a thread about a child
[**sendMessage**](MessagingApi.md#sendmessage) | **POST** /threads/{id}/messages | Send a message


# **listMessages**
> ListMessages200Response listMessages(id, limit, cursor)

Messages in a thread, oldest first

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MessagingApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listMessages(id, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling MessagingApi->listMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**ListMessages200Response**](ListMessages200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listThreads**
> ListThreads200Response listThreads(studentId)

My message threads (admin: all, read-only audit)

Roles: teacher, guardian (participant), admin (audit).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MessagingApi();
final studentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.listThreads(studentId);
    print(result);
} catch (e) {
    print('Exception when calling MessagingApi->listThreads: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional] 

### Return type

[**ListThreads200Response**](ListThreads200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markThreadRead**
> markThreadRead(id)

Mark a thread read up to now (clears its unread badge)

Roles: teacher, guardian (participant).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MessagingApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.markThreadRead(id);
} catch (e) {
    print('Exception when calling MessagingApi->markThreadRead: $e\n');
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

# **openThread**
> Thread openThread(openThreadRequest)

Open a thread about a child

Roles: teacher, guardian. A thread is always about one student both parties share, never a free DM. Returns the existing thread if one already exists for (student, teacher, guardian). 

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MessagingApi();
final openThreadRequest = OpenThreadRequest(); // OpenThreadRequest | 

try {
    final result = api_instance.openThread(openThreadRequest);
    print(result);
} catch (e) {
    print('Exception when calling MessagingApi->openThread: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **openThreadRequest** | [**OpenThreadRequest**](OpenThreadRequest.md)|  | 

### Return type

[**Thread**](Thread.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMessage**
> Message sendMessage(id, sendMessageRequest, idempotencyKey)

Send a message

Roles: teacher, guardian (participant). Messages are immutable once sent. Admin cannot post.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MessagingApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final sendMessageRequest = SendMessageRequest(); // SendMessageRequest | 
final idempotencyKey = idempotencyKey_example; // String | Client-generated; replays within 24 h return the original response.

try {
    final result = api_instance.sendMessage(id, sendMessageRequest, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling MessagingApi->sendMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **sendMessageRequest** | [**SendMessageRequest**](SendMessageRequest.md)|  | 
 **idempotencyKey** | **String**| Client-generated; replays within 24 h return the original response. | [optional] 

### Return type

[**Message**](Message.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

