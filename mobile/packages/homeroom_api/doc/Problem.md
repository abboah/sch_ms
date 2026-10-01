# homeroom_api.model.Problem

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | **int** |  | 
**title** | **String** |  | 
**detail** | **String** |  | [optional] 
**code** | **String** |  | [optional] 
**errors** | [**List<ProblemErrorsInner>**](ProblemErrorsInner.md) |  | [optional] [default to const []]
**requestId** | **String** | Matches the X-Request-Id response header and the server logs | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


