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


/// tests for AuthApi
void main() {
  // final instance = AuthApi();

  group('tests for AuthApi', () {
    // Exchange a refresh token for a new access and refresh token
    //
    // Refresh tokens rotate: each is single-use. Presenting one that was already used revokes the whole session family (token theft response).
    //
    //Future<Session> refreshSession(RefreshSessionRequest refreshSessionRequest) async
    test('test refreshSession', () async {
      // TODO
    });

    // Request a one-time code by SMS (guardians without email)
    //
    //Future requestOtp(RequestOtpRequest requestOtpRequest) async
    test('test requestOtp', () async {
      // TODO
    });

    // Email a password-reset link
    //
    // Always 204, whether or not the address has an account, so it cannot be used to discover accounts.
    //
    //Future requestPasswordReset(RequestPasswordResetRequest requestPasswordResetRequest) async
    test('test requestPasswordReset', () async {
      // TODO
    });

    // Choose a new password from a reset or invitation link
    //
    // The token is single-use. Success signs the account out of every device.
    //
    //Future resetPassword(ResetPasswordRequest resetPasswordRequest) async
    test('test resetPassword', () async {
      // TODO
    });

    // Finish sign-in by choosing which role to continue as
    //
    // Used when sign-in returned selection_required because the account holds several people (for example an admin who is also a parent).
    //
    //Future<Session> selectSessionPerson(SelectSessionPersonRequest selectSessionPersonRequest) async
    test('test selectSessionPerson', () async {
      // TODO
    });

    // Sign in with email and password
    //
    //Future<SignInResult> signInWithPassword(SignInWithPasswordRequest signInWithPasswordRequest) async
    test('test signInWithPassword', () async {
      // TODO
    });

    // Sign out
    //
    //Future signOut() async
    test('test signOut', () async {
      // TODO
    });

    // Exchange a one-time code for a session
    //
    //Future<SignInResult> verifyOtp(VerifyOtpRequest verifyOtpRequest) async
    test('test verifyOtp', () async {
      // TODO
    });

  });
}
