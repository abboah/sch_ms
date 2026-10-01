# homeroom_api.api.FeesApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**completeSandboxPayment**](FeesApi.md#completesandboxpayment) | **POST** /dev/sandbox/complete | Development only: finish a sandbox payment as the gateway would
[**createFeeItem**](FeesApi.md#createfeeitem) | **POST** /fee_items | Define a reusable fee
[**createInvoices**](FeesApi.md#createinvoices) | **POST** /invoices | Create an invoice, or generate them for a section from a fee structure
[**getPayment**](FeesApi.md#getpayment) | **GET** /payments/{id} | Payment status (clients poll this after /pay)
[**getStudentInvoices**](FeesApi.md#getstudentinvoices) | **GET** /students/{id}/invoices | Invoices with payment history and derived overdue flag
[**listFeeItems**](FeesApi.md#listfeeitems) | **GET** /fee_items | A school's reusable named charges
[**listInvoices**](FeesApi.md#listinvoices) | **GET** /invoices | Invoices across the school
[**listPayments**](FeesApi.md#listpayments) | **GET** /payments | Payments ledger for reconciliation
[**paymentWebhook**](FeesApi.md#paymentwebhook) | **POST** /webhooks/payment | Gateway callback
[**recordManualPayment**](FeesApi.md#recordmanualpayment) | **POST** /payments | Record a manual payment (cash, bank)
[**startPayment**](FeesApi.md#startpayment) | **POST** /invoices/{id}/pay | Start a payment
[**updateFeeItem**](FeesApi.md#updatefeeitem) | **PATCH** /fee_items/{id} | Edit or retire a fee item


# **completeSandboxPayment**
> completeSandboxPayment(completeSandboxPaymentRequest)

Development only: finish a sandbox payment as the gateway would

Exists only while PAYMENT_GATEWAY=sandbox outside production (the server refuses that combination in production). Signs a webhook for the given reference and delivers it through the real webhook path, so the whole flow is exercised with no payment provider.

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = FeesApi();
final completeSandboxPaymentRequest = CompleteSandboxPaymentRequest(); // CompleteSandboxPaymentRequest | 

try {
    api_instance.completeSandboxPayment(completeSandboxPaymentRequest);
} catch (e) {
    print('Exception when calling FeesApi->completeSandboxPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **completeSandboxPaymentRequest** | [**CompleteSandboxPaymentRequest**](CompleteSandboxPaymentRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createFeeItem**
> FeeItem createFeeItem(createFeeItemRequest)

Define a reusable fee

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final createFeeItemRequest = CreateFeeItemRequest(); // CreateFeeItemRequest | 

try {
    final result = api_instance.createFeeItem(createFeeItemRequest);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->createFeeItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createFeeItemRequest** | [**CreateFeeItemRequest**](CreateFeeItemRequest.md)|  | 

### Return type

[**FeeItem**](FeeItem.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInvoices**
> GetStudentInvoices200Response createInvoices(createInvoicesRequest)

Create an invoice, or generate them for a section from a fee structure

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final createInvoicesRequest = CreateInvoicesRequest(); // CreateInvoicesRequest | 

try {
    final result = api_instance.createInvoices(createInvoicesRequest);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->createInvoices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createInvoicesRequest** | [**CreateInvoicesRequest**](CreateInvoicesRequest.md)|  | 

### Return type

[**GetStudentInvoices200Response**](GetStudentInvoices200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPayment**
> Payment getPayment(id)

Payment status (clients poll this after /pay)

Roles: admin, guardian (own child).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getPayment(id);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->getPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Payment**](Payment.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStudentInvoices**
> GetStudentInvoices200Response getStudentInvoices(id)

Invoices with payment history and derived overdue flag

Roles: admin, guardian (own child). Teachers get 404.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getStudentInvoices(id);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->getStudentInvoices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**GetStudentInvoices200Response**](GetStudentInvoices200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFeeItems**
> ListFeeItems200Response listFeeItems()

A school's reusable named charges

Roles: admin. A convenience and reporting tag for invoices: creating one does not touch any existing invoice.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();

try {
    final result = api_instance.listFeeItems();
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->listFeeItems: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListFeeItems200Response**](ListFeeItems200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInvoices**
> InvoicePage listInvoices(status, termId, limit, cursor)

Invoices across the school

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final status = status_example; // String | 
final termId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listInvoices(status, termId, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->listInvoices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | **String**|  | [optional] 
 **termId** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**InvoicePage**](InvoicePage.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPayments**
> ListPayments200Response listPayments(status, stalePending, limit, cursor)

Payments ledger for reconciliation

Roles: admin. `stale_pending=true` lists payments still pending after 30 minutes: the ones to chase with the gateway.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final status = ; // PaymentStatus | 
final stalePending = true; // bool | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listPayments(status, stalePending, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->listPayments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**PaymentStatus**](.md)|  | [optional] 
 **stalePending** | **bool**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**ListPayments200Response**](ListPayments200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentWebhook**
> paymentWebhook(requestBody)

Gateway callback

Not user-authenticated: verified by the provider's signature header. Calls `apply_payment_webhook`, which is idempotent on the provider reference and never downgrades a settled payment, so the gateway may retry freely. Always answer 200 to a verified event. 

### Example
```dart
import 'package:homeroom_api/api.dart';

final api_instance = FeesApi();
final requestBody = Map<String, Object>(); // Map<String, Object> | 

try {
    api_instance.paymentWebhook(requestBody);
} catch (e) {
    print('Exception when calling FeesApi->paymentWebhook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestBody** | [**Map<String, Object>**](Object.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordManualPayment**
> Payment recordManualPayment(recordManualPaymentRequest)

Record a manual payment (cash, bank)

Roles: admin. Goes through the same settlement function as the webhook.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final recordManualPaymentRequest = RecordManualPaymentRequest(); // RecordManualPaymentRequest | 

try {
    final result = api_instance.recordManualPayment(recordManualPaymentRequest);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->recordManualPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recordManualPaymentRequest** | [**RecordManualPaymentRequest**](RecordManualPaymentRequest.md)|  | 

### Return type

[**Payment**](Payment.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startPayment**
> PaymentStart startPayment(id, startPaymentRequest, idempotencyKey)

Start a payment

Roles: guardian (own child). Creates a `pending` payment and returns how to complete it. **The invoice never changes state here**: only the gateway webhook settles it. Card returns a hosted-checkout `redirect_url`; mobile money returns `prompt` (approve on your phone) and the client polls `GET /payments/{id}`. Amount may be partial, up to the outstanding balance. 

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final startPaymentRequest = StartPaymentRequest(); // StartPaymentRequest | 
final idempotencyKey = idempotencyKey_example; // String | Client-generated; replays within 24 h return the original response.

try {
    final result = api_instance.startPayment(id, startPaymentRequest, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->startPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **startPaymentRequest** | [**StartPaymentRequest**](StartPaymentRequest.md)|  | 
 **idempotencyKey** | **String**| Client-generated; replays within 24 h return the original response. | [optional] 

### Return type

[**PaymentStart**](PaymentStart.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateFeeItem**
> FeeItem updateFeeItem(id, updateFeeItemRequest)

Edit or retire a fee item

Roles: admin. Retire with `active: false` rather than deleting: past invoices keep their `fee_item_id` reference.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FeesApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final updateFeeItemRequest = UpdateFeeItemRequest(); // UpdateFeeItemRequest | 

try {
    final result = api_instance.updateFeeItem(id, updateFeeItemRequest);
    print(result);
} catch (e) {
    print('Exception when calling FeesApi->updateFeeItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateFeeItemRequest** | [**UpdateFeeItemRequest**](UpdateFeeItemRequest.md)|  | 

### Return type

[**FeeItem**](FeeItem.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

