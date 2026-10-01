# homeroom_api.model.Announcement

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**author** | [**Person**](Person.md) |  | [optional] 
**classSectionId** | **String** | Null = school-wide | 
**title** | **String** |  | 
**body** | **String** |  | 
**requiresResponse** | **bool** |  | 
**publishedAt** | [**DateTime**](DateTime.md) | Null = draft | 
**myResponses** | [**List<AnnouncementResponse>**](AnnouncementResponse.md) | Guardians, for slips that require a reply | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


