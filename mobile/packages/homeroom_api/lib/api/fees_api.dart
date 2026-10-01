//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class FeesApi {
  FeesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Development only: finish a sandbox payment as the gateway would
  ///
  /// Exists only while PAYMENT_GATEWAY=sandbox outside production (the server refuses that combination in production). Signs a webhook for the given reference and delivers it through the real webhook path, so the whole flow is exercised with no payment provider.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CompleteSandboxPaymentRequest] completeSandboxPaymentRequest (required):
  Future<Response> completeSandboxPaymentWithHttpInfo(CompleteSandboxPaymentRequest completeSandboxPaymentRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/dev/sandbox/complete';

    // ignore: prefer_final_locals
    Object? postBody = completeSandboxPaymentRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Development only: finish a sandbox payment as the gateway would
  ///
  /// Exists only while PAYMENT_GATEWAY=sandbox outside production (the server refuses that combination in production). Signs a webhook for the given reference and delivers it through the real webhook path, so the whole flow is exercised with no payment provider.
  ///
  /// Parameters:
  ///
  /// * [CompleteSandboxPaymentRequest] completeSandboxPaymentRequest (required):
  Future<void> completeSandboxPayment(CompleteSandboxPaymentRequest completeSandboxPaymentRequest, { Future<void>? abortTrigger, }) async {
    final response = await completeSandboxPaymentWithHttpInfo(completeSandboxPaymentRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Define a reusable fee
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateFeeItemRequest] createFeeItemRequest (required):
  Future<Response> createFeeItemWithHttpInfo(CreateFeeItemRequest createFeeItemRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/fee_items';

    // ignore: prefer_final_locals
    Object? postBody = createFeeItemRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Define a reusable fee
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [CreateFeeItemRequest] createFeeItemRequest (required):
  Future<FeeItem?> createFeeItem(CreateFeeItemRequest createFeeItemRequest, { Future<void>? abortTrigger, }) async {
    final response = await createFeeItemWithHttpInfo(createFeeItemRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FeeItem',) as FeeItem;
    
    }
    return null;
  }

  /// Create an invoice, or generate them for a section from a fee structure
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateInvoicesRequest] createInvoicesRequest (required):
  Future<Response> createInvoicesWithHttpInfo(CreateInvoicesRequest createInvoicesRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/invoices';

    // ignore: prefer_final_locals
    Object? postBody = createInvoicesRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create an invoice, or generate them for a section from a fee structure
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [CreateInvoicesRequest] createInvoicesRequest (required):
  Future<GetStudentInvoices200Response?> createInvoices(CreateInvoicesRequest createInvoicesRequest, { Future<void>? abortTrigger, }) async {
    final response = await createInvoicesWithHttpInfo(createInvoicesRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentInvoices200Response',) as GetStudentInvoices200Response;
    
    }
    return null;
  }

  /// Payment status (clients poll this after /pay)
  ///
  /// Roles: admin, guardian (own child).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getPaymentWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/payments/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Payment status (clients poll this after /pay)
  ///
  /// Roles: admin, guardian (own child).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Payment?> getPayment(String id, { Future<void>? abortTrigger, }) async {
    final response = await getPaymentWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Payment',) as Payment;
    
    }
    return null;
  }

  /// Invoices with payment history and derived overdue flag
  ///
  /// Roles: admin, guardian (own child). Teachers get 404.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getStudentInvoicesWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/invoices'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Invoices with payment history and derived overdue flag
  ///
  /// Roles: admin, guardian (own child). Teachers get 404.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<GetStudentInvoices200Response?> getStudentInvoices(String id, { Future<void>? abortTrigger, }) async {
    final response = await getStudentInvoicesWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStudentInvoices200Response',) as GetStudentInvoices200Response;
    
    }
    return null;
  }

  /// A school's reusable named charges
  ///
  /// Roles: admin. A convenience and reporting tag for invoices: creating one does not touch any existing invoice.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listFeeItemsWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/fee_items';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// A school's reusable named charges
  ///
  /// Roles: admin. A convenience and reporting tag for invoices: creating one does not touch any existing invoice.
  Future<ListFeeItems200Response?> listFeeItems({ Future<void>? abortTrigger, }) async {
    final response = await listFeeItemsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListFeeItems200Response',) as ListFeeItems200Response;
    
    }
    return null;
  }

  /// Invoices across the school
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] status:
  ///
  /// * [String] termId:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listInvoicesWithHttpInfo({ String? status, String? termId, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/invoices';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (termId != null) {
      queryParams.addAll(_queryParams('', 'term_id', termId));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Invoices across the school
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] status:
  ///
  /// * [String] termId:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<InvoicePage?> listInvoices({ String? status, String? termId, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listInvoicesWithHttpInfo(status: status, termId: termId, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InvoicePage',) as InvoicePage;
    
    }
    return null;
  }

  /// Payments ledger for reconciliation
  ///
  /// Roles: admin. `stale_pending=true` lists payments still pending after 30 minutes: the ones to chase with the gateway.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PaymentStatus] status:
  ///
  /// * [bool] stalePending:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listPaymentsWithHttpInfo({ PaymentStatus? status, bool? stalePending, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/payments';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (stalePending != null) {
      queryParams.addAll(_queryParams('', 'stale_pending', stalePending));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Payments ledger for reconciliation
  ///
  /// Roles: admin. `stale_pending=true` lists payments still pending after 30 minutes: the ones to chase with the gateway.
  ///
  /// Parameters:
  ///
  /// * [PaymentStatus] status:
  ///
  /// * [bool] stalePending:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<ListPayments200Response?> listPayments({ PaymentStatus? status, bool? stalePending, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listPaymentsWithHttpInfo(status: status, stalePending: stalePending, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListPayments200Response',) as ListPayments200Response;
    
    }
    return null;
  }

  /// Gateway callback
  ///
  /// Not user-authenticated: verified by the provider's signature header. Calls `apply_payment_webhook`, which is idempotent on the provider reference and never downgrades a settled payment, so the gateway may retry freely. Always answer 200 to a verified event. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Map<String, Object>] requestBody (required):
  Future<Response> paymentWebhookWithHttpInfo(Map<String, Object> requestBody, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/webhooks/payment';

    // ignore: prefer_final_locals
    Object? postBody = requestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Gateway callback
  ///
  /// Not user-authenticated: verified by the provider's signature header. Calls `apply_payment_webhook`, which is idempotent on the provider reference and never downgrades a settled payment, so the gateway may retry freely. Always answer 200 to a verified event. 
  ///
  /// Parameters:
  ///
  /// * [Map<String, Object>] requestBody (required):
  Future<void> paymentWebhook(Map<String, Object> requestBody, { Future<void>? abortTrigger, }) async {
    final response = await paymentWebhookWithHttpInfo(requestBody, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Record a manual payment (cash, bank)
  ///
  /// Roles: admin. Goes through the same settlement function as the webhook.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RecordManualPaymentRequest] recordManualPaymentRequest (required):
  Future<Response> recordManualPaymentWithHttpInfo(RecordManualPaymentRequest recordManualPaymentRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/payments';

    // ignore: prefer_final_locals
    Object? postBody = recordManualPaymentRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Record a manual payment (cash, bank)
  ///
  /// Roles: admin. Goes through the same settlement function as the webhook.
  ///
  /// Parameters:
  ///
  /// * [RecordManualPaymentRequest] recordManualPaymentRequest (required):
  Future<Payment?> recordManualPayment(RecordManualPaymentRequest recordManualPaymentRequest, { Future<void>? abortTrigger, }) async {
    final response = await recordManualPaymentWithHttpInfo(recordManualPaymentRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Payment',) as Payment;
    
    }
    return null;
  }

  /// Start a payment
  ///
  /// Roles: guardian (own child). Creates a `pending` payment and returns how to complete it. **The invoice never changes state here**: only the gateway webhook settles it. Card returns a hosted-checkout `redirect_url`; mobile money returns `prompt` (approve on your phone) and the client polls `GET /payments/{id}`. Amount may be partial, up to the outstanding balance. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [StartPaymentRequest] startPaymentRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<Response> startPaymentWithHttpInfo(String id, StartPaymentRequest startPaymentRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/invoices/{id}/pay'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = startPaymentRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (idempotencyKey != null) {
      headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);
    }

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Start a payment
  ///
  /// Roles: guardian (own child). Creates a `pending` payment and returns how to complete it. **The invoice never changes state here**: only the gateway webhook settles it. Card returns a hosted-checkout `redirect_url`; mobile money returns `prompt` (approve on your phone) and the client polls `GET /payments/{id}`. Amount may be partial, up to the outstanding balance. 
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [StartPaymentRequest] startPaymentRequest (required):
  ///
  /// * [String] idempotencyKey:
  ///   Client-generated; replays within 24 h return the original response.
  Future<PaymentStart?> startPayment(String id, StartPaymentRequest startPaymentRequest, { String? idempotencyKey, Future<void>? abortTrigger, }) async {
    final response = await startPaymentWithHttpInfo(id, startPaymentRequest, idempotencyKey: idempotencyKey, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PaymentStart',) as PaymentStart;
    
    }
    return null;
  }

  /// Edit or retire a fee item
  ///
  /// Roles: admin. Retire with `active: false` rather than deleting: past invoices keep their `fee_item_id` reference.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateFeeItemRequest] updateFeeItemRequest (required):
  Future<Response> updateFeeItemWithHttpInfo(String id, UpdateFeeItemRequest updateFeeItemRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/fee_items/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateFeeItemRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Edit or retire a fee item
  ///
  /// Roles: admin. Retire with `active: false` rather than deleting: past invoices keep their `fee_item_id` reference.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateFeeItemRequest] updateFeeItemRequest (required):
  Future<FeeItem?> updateFeeItem(String id, UpdateFeeItemRequest updateFeeItemRequest, { Future<void>? abortTrigger, }) async {
    final response = await updateFeeItemWithHttpInfo(id, updateFeeItemRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FeeItem',) as FeeItem;
    
    }
    return null;
  }
}
