import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:homeroom_api/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'http_client.dart';
import 'outbox.dart';
import 'session.dart';

/// Everything the app depends on is a provider, so tests can swap any piece (the HTTP client, storage, the clock).

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Overridden in main() with the real instance, and in tests with an in-memory one.
final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefsProvider must be overridden'));

final sessionStorageProvider = Provider<SessionStorage>((ref) => SecureSessionStorage());

class SecureSessionStorage implements SessionStorage {
  static const _key = 'homeroom.session.v1';
  final _store = const FlutterSecureStorage();

  @override
  Future<String?> read() async {
    try {
      return await _store.read(key: _key);
    } catch (_) {
      return null; // a keystore that cannot be read means starting signed out, not crashing
    }
  }

  @override
  Future<void> write(String value) => _store.write(key: _key, value: value);

  @override
  Future<void> delete() => _store.delete(key: _key);
}

/// The session lives outside the widget tree (the HTTP layer needs it too); [sessionProvider] mirrors it for widgets.
final sessionStoreProvider = Provider<SessionStore>((ref) {
  // Refreshing uses a plain client on purpose: it must not go through the authed client it is refreshing for.
  final plain = ApiClient(basePath: AppConfig.apiBaseUrl)..client = ref.watch(httpClientProvider);
  final store = SessionStore(
    storage: ref.watch(sessionStorageProvider),
    refresh: (token) => AuthApi(plain).refreshSession(RefreshSessionRequest(refreshToken: token)),
  );
  ref.onDispose(store.dispose);
  return store;
});

class SessionNotifier extends Notifier<SessionData?> {
  @override
  SessionData? build() {
    final store = ref.watch(sessionStoreProvider);
    void sync() => state = store.value;
    store.addListener(sync);
    ref.onDispose(() => store.removeListener(sync));
    return store.value;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionData?>(SessionNotifier.new);

/// The signed-in person (null when signed out).
final meProvider = Provider<Me?>((ref) => ref.watch(sessionProvider)?.me);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(basePath: AppConfig.apiBaseUrl);
  client.client = AuthedClient(inner: ref.watch(httpClientProvider), session: ref.watch(sessionStoreProvider));
  return client;
});

final authApiProvider = Provider((ref) => AuthApi(ref.watch(apiClientProvider)));
final meApiProvider = Provider((ref) => MeApi(ref.watch(apiClientProvider)));
final studentsApiProvider = Provider((ref) => StudentsApi(ref.watch(apiClientProvider)));
final classesApiProvider = Provider((ref) => ClassesApi(ref.watch(apiClientProvider)));
final attendanceApiProvider = Provider((ref) => AttendanceApi(ref.watch(apiClientProvider)));
final gradebookApiProvider = Provider((ref) => GradebookApi(ref.watch(apiClientProvider)));
final feesApiProvider = Provider((ref) => FeesApi(ref.watch(apiClientProvider)));
final messagingApiProvider = Provider((ref) => MessagingApi(ref.watch(apiClientProvider)));
final announcementsApiProvider = Provider((ref) => AnnouncementsApi(ref.watch(apiClientProvider)));
final homeworkApiProvider = Provider((ref) => HomeworkApi(ref.watch(apiClientProvider)));
final conferencesApiProvider = Provider((ref) => ConferencesApi(ref.watch(apiClientProvider)));
final overviewApiProvider = Provider((ref) => OverviewApi(ref.watch(apiClientProvider)));

/// The offline write queue (attendance, scores). Replays on a timer and when the app comes back to the foreground.
final outboxProvider = ChangeNotifierProvider<Outbox>((ref) {
  final client = ref.watch(apiClientProvider);
  final outbox = Outbox(
    prefs: ref.watch(prefsProvider),
    transport: (w) async {
      final r = await client.invokeAPI(w.path, w.method, [], w.body, {'Idempotency-Key': w.key}, {}, 'application/json');
      return TransportResponse(r.statusCode, r.body);
    },
  );
  ref.onDispose(outbox.stopSync);
  return outbox;
});

/// "Now" as the server sees it (device clock corrected by the offset learned at sign-in).
final appNowProvider = Provider<DateTime Function()>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return () => store.appNow;
});
