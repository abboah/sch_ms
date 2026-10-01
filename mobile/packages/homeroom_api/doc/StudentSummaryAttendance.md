# homeroom_api.model.StudentSummaryAttendance

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**total** | **int** |  | 
**present** | **int** |  | 
**late_** | **int** |  | 
**absent** | **int** |  | 
**excused** | **int** |  | 
**ratePct** | **num** | (present + late) / total; excused counts as absent for the rate | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


