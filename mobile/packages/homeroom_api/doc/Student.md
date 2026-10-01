# homeroom_api.model.Student

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**fullName** | **String** |  | 
**classSection** | [**StudentRefClassSection**](StudentRefClassSection.md) |  | [optional] 
**gradeLevel** | **String** |  | [optional] 
**attendanceRatePct** | **num** |  | 
**guardianNames** | **List<String>** | Admin lists only: primary contact first | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


