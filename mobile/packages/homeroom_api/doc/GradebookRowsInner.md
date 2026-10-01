# homeroom_api.model.GradebookRowsInner

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**student** | [**StudentRef**](StudentRef.md) |  | 
**scores** | **Map<String, num?>** | Keyed by assessment id | [default to const {}]
**runningGrade** | **num** |  | 
**gradeBand** | **String** | Label from the school's grading scale, or null if none configured | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


