# homeroom_api.model.Me

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
**school** | [**MeSchool**](MeSchool.md) |  | 
**contact** | [**Contact**](Contact.md) |  | [optional] 
**children** | [**List<StudentRef>**](StudentRef.md) | Guardians only | [optional] [default to const []]
**sections** | [**List<ClassSection>**](ClassSection.md) | Teachers only | [optional] [default to const []]
**now** | [**DateTime**](DateTime.md) | The server's current time. Clients use it to correct a wrong device clock and to agree with the server about what 'today' is. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


