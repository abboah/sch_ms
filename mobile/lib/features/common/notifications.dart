import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';

final notificationsProvider = FutureProvider.autoDispose<NotificationPage>((ref) async {
  final page = await ref.watch(meApiProvider).listNotifications(limit: 50);
  if (page == null) throw StateError('The server returned no notifications page');
  return page;
});

/// The unread count for the badge on "More"; refreshed whenever the app fetches notifications.
final unreadCountProvider = Provider.autoDispose<int>((ref) => ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0);

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const _kinds = {
    'attendance.marked': ('Attendance', TagTone.alert),
    'payment.succeeded': ('Payment', TagTone.forest),
    'fees.due_soon': ('Fees', TagTone.brass),
    'homework.posted': ('Homework', TagTone.accent),
    'announcement.published': ('Notice', TagTone.accent),
    'message.sent': ('Message', TagTone.mute),
  };

  Future<void> _mark(BuildContext context, WidgetRef ref, {List<String>? ids}) async {
    try {
      await ref.read(meApiProvider).markNotificationsRead(MarkNotificationsReadRequest(ids: ids ?? const []));
      ref.invalidate(notificationsProvider);
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(notificationsProvider);
    final tz = ref.watch(meProvider)?.school.timezone ?? 'UTC';
    return HrScreen(
      title: 'Notifications',
      back: true,
      onRefresh: () async => ref.refresh(notificationsProvider.future),
      action: (value.valueOrNull?.unreadCount ?? 0) > 0 ? TextButton(onPressed: () => _mark(context, ref), child: const Text('Mark all read')) : null,
      children: [
        AsyncBody<NotificationPage>(
          value: value,
          onRetry: () => ref.invalidate(notificationsProvider),
          isEmpty: (p) => p.items.isEmpty,
          emptyText: 'You are all caught up.',
          data: (page) => HrList(children: [
            for (final n in page.items)
              InkWell(
                onTap: n.readAt == null ? () => _mark(context, ref, ids: [n.id]) : null,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 10),
                      child: CircleAvatar(radius: 4, backgroundColor: n.readAt == null ? Theme.of(context).colorScheme.error : Colors.transparent),
                    ),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TagChip((_kinds[n.kind]?.$1) ?? n.kind, tone: (_kinds[n.kind]?.$2) ?? TagTone.mute),
                        const SizedBox(height: 4),
                        Text(n.title, style: Theme.of(context).textTheme.titleMedium),
                        Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                        Text(fmtStamp(n.createdAt, tz), style: Theme.of(context).textTheme.labelSmall),
                      ]),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}
