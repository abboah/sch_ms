//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:homeroom_api/api.dart';
import 'package:test/test.dart';


/// tests for FeesApi
void main() {
  // final instance = FeesApi();

  group('tests for FeesApi', () {
    // Development only: finish a sandbox payment as the gateway would
    //
    // Exists only while PAYMENT_GATEWAY=sandbox outside production (the server refuses that combination in production). Signs a webhook for the given reference and delivers it through the real webhook path, so the whole flow is exercised with no payment provider.
    //
    //Future completeSandboxPayment(CompleteSandboxPaymentRequest completeSandboxPaymentRequest) async
    test('test completeSandboxPayment', () async {
      // TODO
    });

    // Define a reusable fee
    //
    // Roles: admin.
    //
    //Future<FeeItem> createFeeItem(CreateFeeItemRequest createFeeItemRequest) async
    test('test createFeeItem', () async {
      // TODO
    });

    // Create an invoice, or generate them for a section from a fee structure
    //
    // Roles: admin.
    //
    //Future<GetStudentInvoices200Response> createInvoices(CreateInvoicesRequest createInvoicesRequest) async
    test('test createInvoices', () async {
      // TODO
    });

    // Payment status (clients poll this after /pay)
    //
    // Roles: admin, guardian (own child).
    //
    //Future<Payment> getPayment(String id) async
    test('test getPayment', () async {
      // TODO
    });

    // Invoices with payment history and derived overdue flag
    //
    // Roles: admin, guardian (own child). Teachers get 404.
    //
    //Future<GetStudentInvoices200Response> getStudentInvoices(String id) async
    test('test getStudentInvoices', () async {
      // TODO
    });

    // A school's reusable named charges
    //
    // Roles: admin. A convenience and reporting tag for invoices: creating one does not touch any existing invoice.
    //
    //Future<ListFeeItems200Response> listFeeItems() async
    test('test listFeeItems', () async {
      // TODO
    });

    // Invoices across the school
    //
    // Roles: admin.
    //
    //Future<InvoicePage> listInvoices({ String status, String termId, int limit, String cursor }) async
    test('test listInvoices', () async {
      // TODO
    });

    // Payments ledger for reconciliation
    //
    // Roles: admin. `stale_pending=true` lists payments still pending after 30 minutes: the ones to chase with the gateway.
    //
    //Future<ListPayments200Response> listPayments({ PaymentStatus status, bool stalePending, int limit, String cursor }) async
    test('test listPayments', () async {
      // TODO
    });

    // Gateway callback
    //
    // Not user-authenticated: verified by the provider's signature header. Calls `apply_payment_webhook`, which is idempotent on the provider reference and never downgrades a settled payment, so the gateway may retry freely. Always answer 200 to a verified event. 
    //
    //Future paymentWebhook(Map<String, Object> requestBody) async
    test('test paymentWebhook', () async {
      // TODO
    });

    // Record a manual payment (cash, bank)
    //
    // Roles: admin. Goes through the same settlement function as the webhook.
    //
    //Future<Payment> recordManualPayment(RecordManualPaymentRequest recordManualPaymentRequest) async
    test('test recordManualPayment', () async {
      // TODO
    });

    // Start a payment
    //
    // Roles: guardian (own child). Creates a `pending` payment and returns how to complete it. **The invoice never changes state here**: only the gateway webhook settles it. Card returns a hosted-checkout `redirect_url`; mobile money returns `prompt` (approve on your phone) and the client polls `GET /payments/{id}`. Amount may be partial, up to the outstanding balance. 
    //
    //Future<PaymentStart> startPayment(String id, StartPaymentRequest startPaymentRequest, { String idempotencyKey }) async
    test('test startPayment', () async {
      // TODO
    });

    // Edit or retire a fee item
    //
    // Roles: admin. Retire with `active: false` rather than deleting: past invoices keep their `fee_item_id` reference.
    //
    //Future<FeeItem> updateFeeItem(String id, UpdateFeeItemRequest updateFeeItemRequest) async
    test('test updateFeeItem', () async {
      // TODO
    });

  });
}
