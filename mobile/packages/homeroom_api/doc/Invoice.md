# homeroom_api.model.Invoice

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**student** | [**StudentRef**](StudentRef.md) |  | 
**termId** | **String** |  | 
**description** | **String** |  | 
**amountDue** | **String** |  | 
**amountPaid** | **String** |  | 
**outstanding** | **String** |  | 
**status** | **String** |  | 
**dueDate** | **String** |  | 
**overdue** | **bool** | Derived, due_date passed and outstanding > 0 | 
**feeItemId** | **String** | The reusable fee item this was billed from, if any | 
**payments** | [**List<Payment>**](Payment.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


