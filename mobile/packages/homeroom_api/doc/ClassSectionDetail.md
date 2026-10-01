# homeroom_api.model.ClassSectionDetail

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**gradeLevel** | **String** |  | 
**termId** | **String** |  | 
**homeroomTeacher** | [**Person**](Person.md) |  | [optional] 
**subject** | **String** | Present on /me and /class_sections for a teacher: the subject they teach here | [optional] 
**teachers** | [**List<ClassSectionDetailAllOfTeachers>**](ClassSectionDetailAllOfTeachers.md) |  | [default to const []]
**roster** | [**List<Student>**](Student.md) |  | [default to const []]
**attendanceRatePct** | **num** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


