# homeroom_api.api.ConferencesApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bookConferenceSlot**](ConferencesApi.md#bookconferenceslot) | **PUT** /conference_slots/{id}/booking | Book this slot for a child
[**createConferenceSlots**](ConferencesApi.md#createconferenceslots) | **POST** /conference_slots | Create slots (a window split into equal slots)
[**listConferenceSlots**](ConferencesApi.md#listconferenceslots) | **GET** /conference_slots | Slots I can see
[**releaseConferenceSlot**](ConferencesApi.md#releaseconferenceslot) | **DELETE** /conference_slots/{id}/booking | Release my booking


# **bookConferenceSlot**
> ConferenceSlot bookConferenceSlot(id, bookConferenceSlotRequest)

Book this slot for a child

Roles: guardian. The teacher must teach the child. 409 if already booked.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ConferencesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final bookConferenceSlotRequest = BookConferenceSlotRequest(); // BookConferenceSlotRequest | 

try {
    final result = api_instance.bookConferenceSlot(id, bookConferenceSlotRequest);
    print(result);
} catch (e) {
    print('Exception when calling ConferencesApi->bookConferenceSlot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **bookConferenceSlotRequest** | [**BookConferenceSlotRequest**](BookConferenceSlotRequest.md)|  | 

### Return type

[**ConferenceSlot**](ConferenceSlot.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createConferenceSlots**
> ListConferenceSlots200Response createConferenceSlots(createConferenceSlotsRequest)

Create slots (a window split into equal slots)

Roles: teacher (own), admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ConferencesApi();
final createConferenceSlotsRequest = CreateConferenceSlotsRequest(); // CreateConferenceSlotsRequest | 

try {
    final result = api_instance.createConferenceSlots(createConferenceSlotsRequest);
    print(result);
} catch (e) {
    print('Exception when calling ConferencesApi->createConferenceSlots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createConferenceSlotsRequest** | [**CreateConferenceSlotsRequest**](CreateConferenceSlotsRequest.md)|  | 

### Return type

[**ListConferenceSlots200Response**](ListConferenceSlots200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listConferenceSlots**
> ListConferenceSlots200Response listConferenceSlots(teacherId, from)

Slots I can see

Roles: guardian (open slots of their children's teachers, plus their own bookings), teacher (own), admin (all).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ConferencesApi();
final teacherId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = from_example; // String | 

try {
    final result = api_instance.listConferenceSlots(teacherId, from);
    print(result);
} catch (e) {
    print('Exception when calling ConferencesApi->listConferenceSlots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **teacherId** | **String**|  | [optional] 
 **from** | **String**|  | [optional] 

### Return type

[**ListConferenceSlots200Response**](ListConferenceSlots200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **releaseConferenceSlot**
> releaseConferenceSlot(id)

Release my booking

Roles: guardian (who booked).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ConferencesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.releaseConferenceSlot(id);
} catch (e) {
    print('Exception when calling ConferencesApi->releaseConferenceSlot: $e\n');
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

