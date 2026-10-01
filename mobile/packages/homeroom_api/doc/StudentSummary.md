# homeroom_api.model.StudentSummary

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**studentId** | **String** |  | 
**attendance** | [**StudentSummaryAttendance**](StudentSummaryAttendance.md) |  | 
**grades** | [**List<StudentSummaryGradesInner>**](StudentSummaryGradesInner.md) |  | [default to const []]
**balance** | **String** | Null for teachers | 
**pendingPayments** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


