import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../../core/failure.dart';
import '../../core/providers.dart';

/// The outcome of a sign-in attempt, as the screens need it.
sealed class SignInOutcome {
  const SignInOutcome();
}

class SignedIn extends SignInOutcome {
  const SignedIn();
}

/// The account holds several roles: pick which to continue as.
class ChooseRole extends SignInOutcome {
  const ChooseRole(this.token, this.choices);
  final String token;
  final List<SelectionRequiredChoicesInner> choices;
}

class SignInFailed extends SignInOutcome {
  const SignInFailed(this.message);
  final String message;
}

/// Role choices waiting for the person to pick one (kept here so the picker screen can read them).
class PendingChoice {
  const PendingChoice(this.token, this.choices);
  final String token;
  final List<SelectionRequiredChoicesInner> choices;
}

final pendingChoiceProvider = StateProvider<PendingChoice?>((ref) => null);

class AuthActions {
  AuthActions(this._ref);
  final Ref _ref;

  Future<SignInOutcome> _outcome(Future<SignInResult?> call) async {
    try {
      final r = await call;
      if (r == null) return const SignInFailed('Sign-in failed. Please try again.');
      if (r.status == SignInResultStatusEnum.selectionRequired && r.selection != null) {
        final choice = PendingChoice(r.selection!.selectionToken, r.selection!.choices);
        _ref.read(pendingChoiceProvider.notifier).state = choice;
        return ChooseRole(choice.token, choice.choices);
      }
      if (r.session != null) {
        await _ref.read(sessionStoreProvider).start(r.session!);
        return const SignedIn();
      }
      return const SignInFailed('Sign-in failed. Please try again.');
    } catch (e) {
      return SignInFailed(classify(e).message);
    }
  }

  Future<SignInOutcome> signInWithPassword(String email, String password) =>
      _outcome(_ref.read(authApiProvider).signInWithPassword(SignInWithPasswordRequest(email: email.trim(), password: password)));

  /// Sends an SMS code. The server answers the same whether or not the number has an account.
  Future<String?> requestOtp(String phone) async {
    try {
      await _ref.read(authApiProvider).requestOtp(RequestOtpRequest(phone: phone.trim()));
      return null;
    } catch (e) {
      return classify(e).message;
    }
  }

  Future<SignInOutcome> signInWithOtp(String phone, String code) =>
      _outcome(_ref.read(authApiProvider).verifyOtp(VerifyOtpRequest(phone: phone.trim(), code: code.trim())));

  Future<SignInOutcome> choosePerson(String token, String personId) async {
    try {
      final s = await _ref.read(authApiProvider).selectSessionPerson(SelectSessionPersonRequest(selectionToken: token, personId: personId));
      if (s == null) return const SignInFailed('Sign-in failed. Please try again.');
      await _ref.read(sessionStoreProvider).start(s);
      _ref.read(pendingChoiceProvider.notifier).state = null;
      return const SignedIn();
    } catch (e) {
      return SignInFailed(classify(e).message);
    }
  }

  Future<String?> requestPasswordReset(String email) async {
    try {
      await _ref.read(authApiProvider).requestPasswordReset(RequestPasswordResetRequest(email: email.trim()));
      return null;
    } catch (e) {
      return classify(e).message;
    }
  }

  /// Sign out here and on the server. Local sign-out always succeeds, even offline.
  Future<void> signOut() async {
    try {
      await _ref.read(authApiProvider).signOut();
    } catch (_) {
      // offline: the refresh token will simply expire
    }
    await _ref.read(sessionStoreProvider).clear();
  }
}

final authActionsProvider = Provider((ref) => AuthActions(ref));
