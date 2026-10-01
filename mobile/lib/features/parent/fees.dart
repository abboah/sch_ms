import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';
import 'package:uuid/uuid.dart';

import '../../core/failure.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import 'parent_providers.dart';

class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider)!;
    final child = ref.watch(currentChildProvider);
    return HrScreen(
      big: true,
      eyebrow: me.school.term?.name,
      title: 'Fees',
      onRefresh: child == null ? null : () async => ref.refresh(invoicesProvider(child.id).future),
      children: [
        const ChildChips(),
        if (child == null)
          const NoChildren()
        else
          AsyncBody<List<Invoice>>(
            value: ref.watch(invoicesProvider(child.id)),
            onRetry: () => ref.invalidate(invoicesProvider(child.id)),
            isEmpty: (i) => i.isEmpty,
            emptyText: 'No invoices have been issued.',
            data: (invoices) {
              final pending = [for (final i in invoices) for (final p in i.payments) if (p.status == PaymentStatus.pending) (p: p, i: i)];
              final receipts = [for (final i in invoices) for (final p in i.payments) if (p.status == PaymentStatus.succeeded) p]..sort((a, b) => (b.paidAt ?? DateTime(0)).compareTo(a.paidAt ?? DateTime(0)));
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Eyebrow('Invoices'),
                const SizedBox(height: 8),
                HrList(children: [
                  for (final i in invoices)
                    HrRow(
                      title: i.description,
                      sub: (double.tryParse(i.outstanding) ?? 0) > 0 ? '${money(i.outstanding)} due ${fmtDay(i.dueDate)}' : 'Paid ${money(i.amountDue)}',
                      trailing: TagChip(invoiceLabel(i), tone: invoiceTone(invoiceLabel(i))),
                      onTap: (double.tryParse(i.outstanding) ?? 0) > 0 ? () => context.push('/parent/fees/pay/${i.id}') : null,
                    ),
                ]),
                for (final x in pending) ...[
                  const SizedBox(height: 12),
                  InfoBanner('A payment of ${money(x.p.amount)} for ${x.i.description} is pending confirmation. It will appear in your receipts once the provider confirms it.'),
                ],
                const SizedBox(height: 16),
                const Eyebrow('Receipts'),
                const SizedBox(height: 8),
                if (receipts.isEmpty)
                  const InfoBanner('No payments yet.')
                else
                  HrList(children: [
                    for (final p in receipts)
                      HrRow(title: p.providerRef.length > 18 ? p.providerRef.substring(0, 18) : p.providerRef, sub: p.paidAt == null ? null : fmtStamp(p.paidAt!, me.school.timezone), trailing: Text(money(p.amount), style: HrText.mono(14, context.tokens.ink))),
                  ]),
              ]);
            },
          ),
      ],
    );
  }
}

enum _Step { form, processing, success, failure, pending }

class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  static const _pollEvery = Duration(seconds: 3);
  static const _giveUpAfter = Duration(seconds: 90);
  static const _methods = [(StartPaymentRequestMethodEnum.card, 'Card'), (StartPaymentRequestMethodEnum.mtnMomo, 'MTN MoMo'), (StartPaymentRequestMethodEnum.telecelCash, 'Telecel Cash')];

  final _amount = TextEditingController();
  final _phone = TextEditingController();
  var _method = StartPaymentRequestMethodEnum.card;
  var _step = _Step.form;
  String? _reason;
  String? _prompt;
  Payment? _payment;
  Timer? _poll;
  DateTime? _startedAt;
  String? _key; // kept across retries so a dropped connection cannot charge twice
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _phone.text = ref.read(meProvider)?.contact?.phone ?? '';
  }

  @override
  void dispose() {
    _poll?.cancel();
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  double get _n => double.tryParse(_amount.text) ?? 0;

  Future<void> _run(Invoice invoice) async {
    setState(() {
      _step = _Step.processing;
      _reason = null;
      _startedAt = ref.read(appNowProvider)();
    });
    _key ??= const Uuid().v4();
    try {
      final start = await ref.read(feesApiProvider).startPayment(
            invoice.id,
            StartPaymentRequest(amount: _n.toStringAsFixed(2), method: _method, phone: _method == StartPaymentRequestMethodEnum.card ? null : _phone.text.trim()),
            idempotencyKey: _key,
          );
      if (start == null) throw StateError('No payment was returned');
      _payment = start.payment;
      if (!mounted) return;
      if (start.next.type == PaymentStartNextTypeEnum.redirect) {
        setState(() => _prompt = 'Finish paying on your bank\'s page, then come back here.');
      } else {
        setState(() => _prompt = start.next.message ?? 'Approve the request on your phone.');
      }
      _poll?.cancel();
      _poll = Timer.periodic(_pollEvery, (_) => unawaited(_check()));
    } catch (e) {
      // Keep the key: if the request did reach the server, a retry replays it instead of charging again.
      if (mounted) {
        setState(() {
          _reason = classify(e).message;
          _step = _Step.failure;
        });
      }
    }
  }

  Future<void> _check() async {
    final p = _payment;
    if (p == null || !mounted) return;
    try {
      final fresh = await ref.read(feesApiProvider).getPayment(p.id);
      if (fresh == null || !mounted) return;
      if (fresh.status == PaymentStatus.succeeded) {
        _poll?.cancel();
        ref.invalidate(invoicesProvider(ref.read(currentChildProvider)!.id));
        setState(() => _step = _Step.success);
      } else if (fresh.status == PaymentStatus.failed) {
        _poll?.cancel();
        setState(() {
          _reason = 'The provider did not confirm the payment. You have not been charged.';
          _step = _Step.failure;
        });
      } else if (ref.read(appNowProvider)().difference(_startedAt!) > _giveUpAfter) {
        _poll?.cancel();
        setState(() => _step = _Step.pending);
      }
    } catch (_) {
      // offline for a moment: the next tick tries again
    }
  }

  Future<void> _simulate(String outcome) async {
    final p = _payment;
    if (p == null) return;
    try {
      await ref.read(feesApiProvider).completeSandboxPayment(CompleteSandboxPaymentRequest(reference: p.providerRef, outcome: outcome == 'succeeded' ? CompleteSandboxPaymentRequestOutcomeEnum.succeeded : CompleteSandboxPaymentRequestOutcomeEnum.failed));
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(currentChildProvider);
    if (child == null) return const HrScreen(title: 'Pay fees', back: true, children: [NoChildren()]);
    final invoices = ref.watch(invoicesProvider(child.id));
    final invoice = invoices.valueOrNull?.where((i) => i.id == widget.invoiceId).firstOrNull;
    final owed = double.tryParse(invoice?.outstanding ?? '0') ?? 0;
    if (invoice != null && !_seeded) {
      _amount.text = invoice.outstanding;
      _seeded = true;
    }
    final valid = RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(_amount.text) && _n > 0 && _n <= owed && (_method == StartPaymentRequestMethodEnum.card || _phone.text.trim().length >= 9);
    final t = context.tokens;

    return HrScreen(
      title: 'Pay fees',
      eyebrow: invoice == null ? null : '${child.fullName}, ${invoice.description}',
      back: true,
      footer: _step == _Step.form ? WideButton(label: 'Pay ${valid ? money(_n) : ''}'.trim(), onPressed: valid && invoice != null ? () => _run(invoice) : null) : null,
      children: [
        if (invoice == null)
          AsyncBody<List<Invoice>>(value: invoices, onRetry: () => ref.invalidate(invoicesProvider(child.id)), data: (_) => const InfoBanner('That invoice was not found.'))
        else
          switch (_step) {
            _Step.form => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Eyebrow('Amount (GH¢)'),
                const SizedBox(height: 4),
                TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: HrText.mono(20, t.ink), onChanged: (_) => setState(() {})),
                const SizedBox(height: 4),
                Text(_n > 0 && _n <= owed ? 'Balance is ${money(owed)}. You can pay part of it.' : 'Enter an amount up to ${money(owed)}.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _n > owed ? t.alert : t.mute)),
                const SizedBox(height: 16),
                const Eyebrow('Method'),
                const SizedBox(height: 8),
                RadioGroup<StartPaymentRequestMethodEnum>(
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                  child: Column(children: [
                    for (final m in _methods)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: _method == m.$1 ? t.accentSoft : t.raised, border: Border.all(color: _method == m.$1 ? t.accent : t.rule), borderRadius: BorderRadius.circular(3)),
                        child: RadioListTile<StartPaymentRequestMethodEnum>(value: m.$1, title: Text(m.$2)),
                      ),
                  ]),
                ),
                if (_method != StartPaymentRequestMethodEnum.card) ...[
                  const SizedBox(height: 8),
                  const Eyebrow('Mobile money number'),
                  const SizedBox(height: 4),
                  TextField(controller: _phone, keyboardType: TextInputType.phone, onChanged: (_) => setState(() {})),
                ],
              ]),
            _Step.processing => HrCard(
                child: Column(children: [
                  const SizedBox(height: 16),
                  const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(height: 16),
                  Text('Processing ${money(_n)}', style: Theme.of(context).textTheme.titleMedium),
                  Text(_prompt ?? (_method == StartPaymentRequestMethodEnum.card ? 'Contacting your bank.' : 'Contacting the provider.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  if (kDebugMode && _payment != null && _prompt != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: () => _simulate('succeeded'), child: const Text('Simulate approval (sandbox)')),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: () => _simulate('failed'), child: const Text('Simulate decline')),
                  ],
                  const SizedBox(height: 8),
                ]),
              ),
            _Step.success => HrCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TagChip('Paid', tone: TagTone.forest),
                  const SizedBox(height: 8),
                  Text('Payment received', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Reference ${_payment?.providerRef.substring(0, 18) ?? ''}\n${money(_n)} via ${_methods.firstWhere((m) => m.$1 == _method).$2}\n${child.fullName}, ${invoice.description}', style: HrText.mono(13, t.ink)),
                  const SizedBox(height: 16),
                  WideButton(label: 'Back to fees', onPressed: () => context.pop()),
                ]),
              ),
            _Step.failure => HrCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TagChip('Failed', tone: TagTone.alert),
                  const SizedBox(height: 8),
                  Text('Payment did not go through', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(_reason ?? '', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  WideButton(label: 'Retry', onPressed: () => _run(invoice)),
                  const SizedBox(height: 8),
                  WideButton(label: 'Change method', secondary: true, onPressed: () => setState(() {
                        _key = null;
                        _step = _Step.form;
                      })),
                ]),
              ),
            _Step.pending => HrCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TagChip('Pending confirmation', tone: TagTone.brass),
                  const SizedBox(height: 8),
                  Text('Waiting for the provider', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('We have not heard back about your ${money(_n)} payment yet. Your balance updates as soon as it is confirmed. You can leave this screen.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  WideButton(label: 'Back to fees', onPressed: () => context.pop()),
                ]),
              ),
          },
      ],
    );
  }
}
