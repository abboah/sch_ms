# homeroom_api.model.Payment

## Load the model package
```dart
import 'package:homeroom_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**invoiceId** | **String** |  | 
**amount** | **String** |  | 
**method** | **String** |  | 
**status** | [**PaymentStatus**](PaymentStatus.md) |  | 
**providerRef** | **String** |  | 
**paidAt** | [**DateTime**](DateTime.md) |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**receiptUrl** | **String** |  | 
**student** | [**StudentRef**](StudentRef.md) |  | [optional] 
**description** | **String** | What the invoice is for | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


