# homeroom_api.model.StudentDetail

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
**guardians** | [**List<GuardianLink>**](GuardianLink.md) | Admin (with contact details) and teachers of the student (names only) | [optional] [default to const []]
**enrollments** | [**List<Enrollment>**](Enrollment.md) | Admin only | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


