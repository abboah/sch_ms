import 'package:flutter/foundation.dart';

/// Build-time settings. Override with `--dart-define=API_URL=https://api.example.com/v1`.
class AppConfig {
  const AppConfig._();

  static const _override = String.fromEnvironment('API_URL');

  /// Where the API lives. The Android emulator reaches the host machine at 10.0.2.2.
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/v1';
    }
    return 'http://localhost:3000/v1';
  }

  /// Demo shortcuts (role chips that pre-fill the sign-in form) are only offered in debug builds.
  static const showDemoShortcuts = kDebugMode;
}
