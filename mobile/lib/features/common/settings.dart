import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../app/theme_mode.dart';
import '../../core/failure.dart';
import '../../core/providers.dart';
import '../../widgets/basics.dart';
import '../../widgets/screen.dart';
import '../auth/auth_actions.dart';

final notificationPrefsProvider = FutureProvider.autoDispose<NotificationPrefs>((ref) async {
  final p = await ref.watch(meApiProvider).getNotificationPrefs();
  return p ?? NotificationPrefs(push: true, email: true, sms: true);
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.base});

  /// '/parent' or '/teacher', for links to sibling screens.
  final String base;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;
  String? _problem;

  @override
  void initState() {
    super.initState();
    final c = ref.read(meProvider)?.contact;
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    setState(() {
      _saving = true;
      _problem = null;
    });
    try {
      final saved = await ref.read(meApiProvider).updateMyContact(UpdateMyContactRequest(
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          ));
      if (!mounted) return;
      if (saved != null) {
        _phone.text = saved.phone ?? '';
        _email.text = saved.email ?? '';
      }
      toast(context, 'Details saved');
    } catch (e) {
      if (mounted) setState(() => _problem = classify(e).message);
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _setPrefs(NotificationPrefs p) async {
    try {
      await ref.read(meApiProvider).setNotificationPrefs(p);
      ref.invalidate(notificationPrefsProvider);
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider);
    final prefs = ref.watch(notificationPrefsProvider);
    final mode = ref.watch(themeModeProvider);
    return HrScreen(
      title: 'Profile and settings',
      back: true,
      children: [
        HrCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Contact details'),
            const SizedBox(height: 8),
            Text(me?.fullName ?? '', style: Theme.of(context).textTheme.titleMedium),
            if (_problem != null) ...[const SizedBox(height: 8), InfoBanner(_problem!, tone: BannerTone.alert)],
            const SizedBox(height: 12),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile')),
            const SizedBox(height: 12),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            WideButton(label: 'Save', secondary: true, busy: _saving, onPressed: _saveContact),
          ]),
        ),
        HrList(children: [
          ...prefs.maybeWhen(
            data: (p) => [
              _Toggle('Push', 'The Homeroom app', p.push, (v) => _setPrefs(NotificationPrefs(push: v, email: p.email, sms: p.sms))),
              _Toggle('Email', 'Receipts', p.email, (v) => _setPrefs(NotificationPrefs(push: p.push, email: v, sms: p.sms))),
              _Toggle('SMS', 'When you have no app or no data', p.sms, (v) => _setPrefs(NotificationPrefs(push: p.push, email: p.email, sms: v))),
            ],
            orElse: () => [const Padding(padding: EdgeInsets.all(16), child: Text('Loading…'))],
          ),
          HrRow(title: 'About SMS alerts', sub: 'For when you do not have data', onTap: () => context.push('${widget.base}/sms')),
        ]),
        SegmentedButton<ThemeMode>(
          segments: const [ButtonSegment(value: ThemeMode.light, label: Text('Light')), ButtonSegment(value: ThemeMode.dark, label: Text('Dark')), ButtonSegment(value: ThemeMode.system, label: Text('System'))],
          selected: {mode},
          onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error, side: BorderSide(color: Theme.of(context).colorScheme.error)),
          onPressed: () => ref.read(authActionsProvider).signOut(),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(this.title, this.sub, this.value, this.onChanged);
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(sub, style: Theme.of(context).textTheme.bodySmall),
        value: value,
        onChanged: onChanged,
      );
}

/// Explains the SMS fallback (the design's "Get alerts by SMS if you don't have data").
class SmsAlertsScreen extends ConsumerWidget {
  const SmsAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final phone = ref.watch(meProvider)?.contact?.phone;
    return HrScreen(
      title: 'SMS alerts',
      back: true,
      children: [
        HrCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Get alerts by SMS if you don't have data", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Homeroom can text you when something needs attention, so you do not need the app open or an internet connection.', style: Theme.of(context).textTheme.bodyLarge),
          ]),
        ),
        HrList(children: [
          for (final t in const ['Your child is marked absent or late', 'A fee is due in 3 days', 'A payment is received'])
            ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(t)),
        ]),
        Text('Standard SMS rates from your network apply. Messages go to ${phone ?? 'the number on your profile'}.', style: Theme.of(context).textTheme.bodySmall),
        prefs.maybeWhen(
          data: (p) => WideButton(
            label: p.sms ? 'SMS alerts are on' : 'Turn on SMS alerts',
            secondary: p.sms,
            onPressed: p.sms
                ? null
                : () async {
                    try {
                      await ref.read(meApiProvider).setNotificationPrefs(NotificationPrefs(push: p.push, email: p.email, sms: true));
                      ref.invalidate(notificationPrefsProvider);
                      if (context.mounted) toast(context, 'SMS alerts turned on');
                    } catch (e) {
                      if (context.mounted) showFailure(context, e);
                    }
                  },
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

