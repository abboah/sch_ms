import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/failure.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import 'basics.dart';

/// A screen in the design's shape: eyebrow and title at the top (with a back arrow on detail screens),
/// a scrolling body with 16dp gutters, and an optional pinned footer for the main action.
class HrScreen extends StatelessWidget {
  const HrScreen({super.key, required this.title, this.eyebrow, this.back = false, this.big = false, this.action, required this.children, this.footer, this.onRefresh});

  final String title;
  final String? eyebrow;

  /// Show a back arrow (pops the route, or goes home if there is nothing to pop).
  final bool back;
  final bool big;
  final Widget? action;
  final List<Widget> children;
  final Widget? footer;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final list = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, i) => children[i],
    );
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (back)
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                  icon: Icon(Icons.chevron_left, size: 30, color: t.accent),
                )
              else
                const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (eyebrow != null) Eyebrow(eyebrow!),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: big ? Theme.of(context).textTheme.headlineMedium : Theme.of(context).textTheme.headlineSmall),
                ]),
              ),
              ?action,
            ]),
          ),
          Expanded(child: onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list)),
          if (footer != null) Container(decoration: BoxDecoration(color: t.raised, border: Border(top: BorderSide(color: t.rule))), padding: const EdgeInsets.all(12), child: footer),
        ]),
      ),
    );
  }
}

/// Several requests as one: an error if any failed with nothing to show, loading until all have a value, else loaded.
AsyncValue<void> allLoaded(List<AsyncValue<Object?>> values) {
  for (final v in values) {
    if (!v.hasValue && v.hasError) return AsyncError<void>(v.error!, v.stackTrace ?? StackTrace.empty);
  }
  return values.every((v) => v.hasValue) ? const AsyncData<void>(null) : const AsyncLoading<void>();
}

/// Loading, error, empty and content for one request, in one place.
///
/// While first loading it shows a skeleton. If the request failed and there is nothing to show, it shows what went
/// wrong with a retry. If a background refresh failed but there is older data, it keeps showing the data with a
/// quiet notice instead of throwing it away: a teacher on a flaky connection still sees their class.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.data, required this.onRetry, this.isEmpty, this.emptyText = 'Nothing here yet.'});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (value.hasValue) {
      final v = value.requireValue;
      if (isEmpty?.call(v) ?? false) return _Empty(emptyText);
      if (value.hasError && !value.isLoading) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const InfoBanner('Showing the last information we have. We could not refresh it just now.'),
          const SizedBox(height: 12),
          data(v),
        ]);
      }
      return data(v);
    }
    if (value.hasError) {
      final f = classify(value.error!);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.alert.withValues(alpha: 0.10), border: Border.all(color: t.alert), borderRadius: BorderRadius.circular(3)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Could not load this screen.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: t.alert)),
          const SizedBox(height: 4),
          Text('${f.message} Nothing you entered is lost.', style: Theme.of(context).textTheme.bodyMedium),
          if (f is ProblemFailure && f.requestId != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Reference ${f.requestId}', style: HrText.mono(11, t.mute))),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
    }
    return const _Skeleton();
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: t.rule), borderRadius: BorderRadius.circular(3)),
      child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.mute)),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: 'Loading',
      child: HrCard(
        child: Column(children: [
          for (final w in const [0.7, 1.0, 1.0, 0.8, 1.0])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FractionallySizedBox(widthFactor: w, child: Container(height: 14, decoration: BoxDecoration(color: t.rule.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(3)))),
            ),
        ]),
      ),
    );
  }
}

/// Reports a failure from an action (saving, sending) as a snack bar, in words a person can use.
void showFailure(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(classify(error).message)));
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// A banner for the offline queue: shown on screens whose writes are saved on the device when offline.
class OutboxBanner extends ConsumerWidget {
  const OutboxBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(outboxProvider).count;
    if (waiting == 0) return const SizedBox.shrink();
    return InfoBanner('$waiting change${waiting == 1 ? '' : 's'} saved on this device, waiting to sync. We will keep trying.', tone: BannerTone.forest);
  }
}
