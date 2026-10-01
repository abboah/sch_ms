# homeroom_api.model.Person

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**fullName** | **String** |  | 
**role** | [**Role**](Role.md) |  | 
**contact** | [**PersonContact**](PersonContact.md) |  | [optional] 
**assignments** | [**List<PersonAssignmentsInner>**](PersonAssignmentsInner.md) | Teachers, in the admin directory: what they teach, in the current term | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


