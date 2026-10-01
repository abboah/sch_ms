# homeroom_api.model.CreateInvoicesRequest

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**studentId** | **String** |  | [optional] 
**classSectionId** | **String** | Bulk: one invoice per enrolled student | [optional] 
**termId** | **String** |  | 
**description** | **String** |  | 
**amountDue** | **String** |  | 
**dueDate** | **String** |  | 
**feeItemId** | **String** | Tags the invoice for reporting; description and amount_due are still explicit and unaffected | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


