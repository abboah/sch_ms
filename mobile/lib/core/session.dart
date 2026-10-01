import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:homeroom_api/api.dart';

import 'failure.dart';

/// A signed-in session: tokens, who the person is, and how far the device clock is from the server's.
@immutable
class SessionData {
  const SessionData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.clockOffset,
    required this.me,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  /// Server time minus device time when this session was last refreshed.
  final Duration clockOffset;
  final Me me;

  factory SessionData.fromApi(Session s, DateTime deviceNow) => SessionData(
        accessToken: s.accessToken,
        refreshToken: s.refreshToken,
        expiresAt: deviceNow.add(Duration(seconds: s.expiresIn)),
        clockOffset: s.me.now.difference(deviceNow),
        me: s.me,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'clockOffsetMs': clockOffset.inMilliseconds,
        'me': me.toJson(),
      };

  static SessionData? tryParse(String raw) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final me = Me.fromJson(j['me']);
      if (me == null) return null;
      return SessionData(
        accessToken: j['accessToken'] as String,
        refreshToken: j['refreshToken'] as String,
        expiresAt: DateTime.parse(j['expiresAt'] as String),
        clockOffset: Duration(milliseconds: (j['clockOffsetMs'] as num?)?.toInt() ?? 0),
        me: me,
      );
    } catch (_) {
      return null; // corrupt storage: start signed out
    }
  }
}

/// Where the session is kept between launches (the platform's secure storage in the app, memory in tests).
abstract interface class SessionStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class MemorySessionStorage implements SessionStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
  @override
  Future<void> delete() async => value = null;
}

typedef RefreshCall = Future<Session?> Function(String refreshToken);

/// Holds the session and keeps its access token fresh.
///
///  - The token is refreshed shortly BEFORE it expires, so requests rarely meet a 401.
///  - Concurrent callers share one refresh (the server rotates refresh tokens, so two would clash).
///  - A refresh that fails because the network is down, or the server errors, NEVER signs the user out; only the
///    server saying the refresh token is no longer valid does. A teacher on a flaky connection keeps their session.
class SessionStore extends ValueNotifier<SessionData?> {
  SessionStore({required SessionStorage storage, required RefreshCall refresh, DateTime Function()? now})
      : _storage = storage,
        _refreshCall = refresh,
        _now = now ?? DateTime.now,
        super(null);

  static const _earlyRefresh = Duration(seconds: 30);

  final SessionStorage _storage;
  final RefreshCall _refreshCall;
  final DateTime Function() _now;
  Future<bool>? _inflight;

  bool get hasRefresh => value != null;

  /// The current time as the server sees it. Use instead of `DateTime.now()` for anything about "today".
  DateTime get appNow => _now().add(value?.clockOffset ?? Duration.zero);

  Future<void> load() async {
    final raw = await _storage.read();
    value = raw == null ? null : SessionData.tryParse(raw);
  }

  Future<void> start(Session s) async {
    final data = SessionData.fromApi(s, _now());
    value = data;
    await _storage.write(jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    value = null;
    await _storage.delete();
  }

  /// A valid access token, refreshing first if it is about to expire. Null when signed out.
  Future<String?> accessToken() async {
    final s = value;
    if (s == null) return null;
    if (_now().isAfter(s.expiresAt.subtract(_earlyRefresh))) await refresh();
    return value?.accessToken;
  }

  Future<bool> refresh() {
    final current = value;
    if (current == null) return Future.value(false);
    return _inflight ??= _doRefresh(current).whenComplete(() => _inflight = null);
  }

  Future<bool> _doRefresh(SessionData current) async {
    try {
      final fresh = await _refreshCall(current.refreshToken);
      if (fresh != null) {
        await start(fresh);
        return true;
      }
      return value != null;
    } catch (e) {
      final f = classify(e);
      if (f is ProblemFailure && f.status == 401) {
        await clear(); // revoked, reused or expired: the user must sign in again
        return false;
      }
      return value != null; // offline or a server error: keep the session and try again later
    }
  }
}
