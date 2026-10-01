import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../widgets/basics.dart';
import 'auth_actions.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController(text: AppConfig.showDemoShortcuts ? 'akua.asante@greenfield.edu.gh' : '');
  final _password = TextEditingController(text: AppConfig.showDemoShortcuts ? 'password123' : '');
  final _phone = TextEditingController(text: AppConfig.showDemoShortcuts ? '024 000 0001' : '');
  final _code = TextEditingController();
  bool _sms = false;
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final actions = ref.read(authActionsProvider);
    if (_sms && !_codeSent) {
      final problem = await actions.requestOtp(_phone.text);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = problem;
        _codeSent = problem == null;
      });
      return;
    }
    final outcome = _sms ? await actions.signInWithOtp(_phone.text, _code.text) : await actions.signInWithPassword(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case SignedIn():
        break; // the router redirects to the right home
      case ChooseRole():
        context.go('/picker');
      case SignInFailed(:final message):
        setState(() => _error = message);
    }
  }

  void _demo(String email) => setState(() {
        _sms = false;
        _email.text = email;
        _password.text = 'password123';
      });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 24),
          Text('Homeroom', style: theme.textTheme.displaySmall),
          const SizedBox(height: 4),
          Text('Sign in to your school', style: theme.textTheme.bodyMedium?.copyWith(color: t.mute)),
          if (AppConfig.showDemoShortcuts) ...[
            const SizedBox(height: 20),
            Row(children: [
              for (final d in const [('Parent', 'akua.asante@greenfield.edu.gh'), ('Teacher', 'kwame.boateng@greenfield.edu.gh')]) ...[
                Expanded(child: OutlinedButton(onPressed: () => _demo(d.$2), child: Text(d.$1))),
                if (d.$1 == 'Parent') const SizedBox(width: 8),
              ],
            ]),
          ],
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('Email')), ButtonSegment(value: true, label: Text('SMS code'))],
            selected: {_sms},
            onSelectionChanged: (s) => setState(() {
              _sms = s.first;
              _codeSent = false;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[InfoBanner(_error!, tone: BannerTone.alert), const SizedBox(height: 16)],
          if (_sms) ...[
            const Eyebrow('Mobile number'),
            const SizedBox(height: 4),
            TextField(controller: _phone, keyboardType: TextInputType.phone, autofillHints: const [AutofillHints.telephoneNumber], onChanged: (_) => setState(() => _codeSent = false)),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              const Eyebrow('6-digit code sent by SMS'),
              const SizedBox(height: 4),
              TextField(controller: _code, keyboardType: TextInputType.number, maxLength: 6, autofillHints: const [AutofillHints.oneTimeCode], autofocus: true),
            ],
          ] else ...[
            const Eyebrow('Email'),
            const SizedBox(height: 4),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.username]),
            const SizedBox(height: 16),
            const Eyebrow('Password'),
            const SizedBox(height: 4),
            TextField(controller: _password, obscureText: true, autofillHints: const [AutofillHints.password], onSubmitted: (_) => _submit()),
          ],
          const SizedBox(height: 20),
          WideButton(label: _sms ? (_codeSent ? 'Verify and sign in' : 'Send code') : 'Sign in', busy: _busy, onPressed: _submit),
          if (!_sms) TextButton(onPressed: () => context.push('/forgot'), child: const Text('Forgot password')),
        ]),
      ),
    );
  }
}

/// An account that holds several roles: choose which to continue as.
class PickerScreen extends ConsumerWidget {
  const PickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingChoiceProvider);
    final theme = Theme.of(context);
    if (pending == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/signin'));
      return const Scaffold(body: SizedBox.shrink());
    }
    String label(Role r) => switch (r) { Role.admin => 'Admin / Registrar', Role.teacher => 'Teacher', Role.guardian => 'Parent / guardian', _ => 'Student' };
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 24),
          Eyebrow('${pending.choices.first.fullName ?? 'Your account'} holds more than one role'),
          Text('Continue as', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final c in pending.choices) ...[
            HrCard(
              onTap: () async {
                final out = await ref.read(authActionsProvider).choosePerson(pending.token, c.personId);
                if (out is SignInFailed && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(out.message)));
                  context.go('/signin');
                }
              },
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label(c.role), style: theme.textTheme.titleLarge),
                Text(c.schoolName, style: theme.textTheme.bodySmall),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ]),
      ),
    );
  }
}

class ForgotScreen extends ConsumerStatefulWidget {
  const ForgotScreen({super.key});

  @override
  ConsumerState<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends ConsumerState<ForgotScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final problem = await ref.read(authActionsProvider).requestPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = problem;
      _sent = problem == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Reset password', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          if (_sent)
            Text('If that address has an account, we have emailed a link to choose a new password. It works for one hour.', style: theme.textTheme.bodyLarge)
          else ...[
            if (_error != null) ...[InfoBanner(_error!, tone: BannerTone.alert), const SizedBox(height: 12)],
            const Eyebrow('Email'),
            const SizedBox(height: 4),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.username]),
            const SizedBox(height: 16),
            WideButton(label: 'Email me a link', busy: _busy, onPressed: _email.text.trim().isEmpty && !_busy ? null : _send),
          ],
        ]),
      ),
    );
  }
}
