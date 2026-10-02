import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:homeroom/core/failure.dart';
import 'package:homeroom/core/format.dart';
import 'package:homeroom/core/http_client.dart';
import 'package:homeroom/core/outbox.dart';
import 'package:homeroom/core/session.dart';
import 'package:homeroom_api/api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

void main() {
  setUpAll(initFormatting);

  group('SessionStore', () {
    late DateTime now;
    late MemorySessionStorage storage;
    var refreshes = 0;

    SessionStore make(Future<Session?> Function(String) refresh) => SessionStore(
          storage: storage,
          refresh: (t) {
            refreshes++;
            return refresh(t);
          },
          now: () => now,
        );

    setUp(() {
      now = DateTime.utc(2026, 10, 5, 8);
      storage = MemorySessionStorage();
      refreshes = 0;
    });

    test('refreshes shortly before expiry, not after', () async {
      final store = make((_) async => fakeSession(access: 'a2', refresh: 'r2'));
      await store.start(fakeSession());
      expect(await store.accessToken(), 'a1');
      expect(refreshes, 0);
      now = now.add(const Duration(seconds: 880)); // 20 s left: inside the 30 s margin
      expect(await store.accessToken(), 'a2');
      expect(refreshes, 1);
    });

    test('concurrent callers share one refresh', () async {
      final store = make((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return fakeSession(access: 'a2', refresh: 'r2');
      });
      await store.start(fakeSession());
      await Future.wait([store.refresh(), store.refresh(), store.refresh()]);
      expect(refreshes, 1);
    });

    test('a network failure keeps the session', () async {
      final store = make((_) async => throw const TransportFailure('down'));
      await store.start(fakeSession());
      expect(await store.refresh(), isTrue);
      expect(store.value, isNotNull);
    });

    test('a server error keeps the session', () async {
      final store = make((_) async => throw ApiException(503, '{"status":503,"code":"x","title":"t"}'));
      await store.start(fakeSession());
      expect(await store.refresh(), isTrue);
      expect(store.value, isNotNull);
    });

    test('a 401 signs out and clears storage', () async {
      final store = make((_) async => throw unauthorized());
      await store.start(fakeSession());
      expect(await store.refresh(), isFalse);
      expect(store.value, isNull);
      expect(await storage.read(), isNull);
    });

    test('restores a saved session and follows the server clock', () async {
      final a = make((_) async => null);
      await a.start(fakeSession(serverNow: DateTime.utc(2026, 10, 5, 9)));
      final b = make((_) async => null);
      await b.load();
      expect(b.value?.me.fullName, 'Esi Mensah');
      expect(b.appNow, DateTime.utc(2026, 10, 5, 9));
    });

    test('corrupt storage loads as signed out', () async {
      await storage.write('{not json');
      final store = make((_) async => null);
      await store.load();
      expect(store.value, isNull);
    });
  });

  group('classify', () {
    test('problem documents keep code and field errors', () {
      final f = classify(ApiException(
        422,
        jsonEncode({
          'status': 422,
          'code': 'validation_failed',
          'title': 'Invalid',
          'errors': [
            {'field': 'weight', 'message': 'too big'}
          ],
          'request_id': 'r9',
        }),
      ));
      expect(f, isA<ProblemFailure>());
      final p = f as ProblemFailure;
      expect(p.code, 'validation_failed');
      expect(p.fieldErrors['weight'], 'too big');
      expect(p.requestId, 'r9');
      expect(p.message, contains('too big'));
    });

    test('wrapped transport errors are offline, not a 400', () {
      expect(classify(ApiException.withInner(400, 'Connection failed', const TransportFailure('x'), StackTrace.empty)), isA<NetworkFailure>());
      expect(classify(const TransportFailure('x')), isA<NetworkFailure>());
    });

    test('non-JSON bodies still classify', () {
      final f = classify(ApiException(502, '<html>bad gateway</html>')) as ProblemFailure;
      expect(f.isServerError, isTrue);
      expect(f.message, isNot(contains('html')));
    });
  });

  group('Outbox', () {
    late SharedPreferences prefs;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Future<SubmitResult> put(Outbox o, String label) => o.submit(method: 'PUT', path: '/x', body: {'n': label}, label: label);

    test('sends immediately when online', () async {
      final o = Outbox(prefs: prefs, transport: (_) async => const TransportResponse(200, '{"ok":true}'));
      final r = await put(o, 'a');
      expect(r.status, SubmitStatus.sent);
      expect(o.count, 0);
    });

    test('queues when offline, then replays in order with the same idempotency keys', () async {
      var online = false;
      final seen = <QueuedWrite>[];
      final o = Outbox(prefs: prefs, transport: (w) async {
        if (!online) throw Exception('offline');
        seen.add(w);
        return const TransportResponse(200, '{}');
      });
      expect((await put(o, 'a')).status, SubmitStatus.queued);
      await put(o, 'b');
      final keys = o.items.map((w) => w.key).toList();
      expect(o.count, 2);
      online = true;
      await o.flush();
      expect(o.count, 0);
      expect(seen.map((w) => w.label), ['a', 'b']);
      expect(seen.map((w) => w.key), keys);
    });

    test('5xx keeps the write; a later 4xx drops and reports it', () async {
      var status = 503;
      final o = Outbox(prefs: prefs, transport: (_) async => TransportResponse(status, '{"status":$status,"code":"c","title":"Term closed"}'));
      await put(o, 'a');
      expect(o.count, 1);
      await o.flush();
      expect(o.count, 1);
      status = 409;
      await o.flush();
      expect(o.count, 0);
      expect(o.takeDropped().single.label, 'a');
      expect(o.takeDropped(), isEmpty);
    });

    test('a 4xx on first send is rejected, not queued', () async {
      final o = Outbox(prefs: prefs, transport: (_) async => const TransportResponse(422, '{"status":422,"code":"v","title":"Bad"}'));
      final r = await put(o, 'a');
      expect(r.status, SubmitStatus.rejected);
      expect(o.count, 0);
    });

    test('an unsent write survives an app restart', () async {
      final a = Outbox(prefs: prefs, transport: (_) async => throw Exception('offline'));
      await put(a, 'a');
      final b = Outbox(prefs: prefs, transport: (_) async => const TransportResponse(200, '{}'));
      expect(b.items.single.label, 'a');
      await b.flush();
      expect(b.count, 0);
    });

    test('a queued write is kept while the session is expired (401 on replay)', () async {
      var status = 503;
      final o = Outbox(prefs: prefs, transport: (_) async => TransportResponse(status, '{}'));
      await put(o, 'a');
      status = 401;
      await o.flush();
      expect(o.count, 1);
      expect(o.takeDropped(), isEmpty);
    });
  });

  group('AuthedClient', () {
    test('adds the token and retries once after a 401 with the refreshed token', () async {
      final store = SessionStore(storage: MemorySessionStorage(), refresh: (_) async => fakeSession(access: 'a2', refresh: 'r2'));
      await store.start(fakeSession());
      final tokens = <String?>[];
      final client = AuthedClient(
        session: store,
        inner: MockClient((req) async {
          tokens.add(req.headers['Authorization']);
          return tokens.length == 1 ? http.Response('{}', 401) : http.Response('{"ok":1}', 200);
        }),
      );
      final res = await client.post(Uri.parse('http://x/y'), body: 'hello');
      expect(res.statusCode, 200);
      expect(tokens, ['Bearer a1', 'Bearer a2']);
    });

    test('transport errors become TransportFailure', () async {
      final store = SessionStore(storage: MemorySessionStorage(), refresh: (_) async => null);
      final client = AuthedClient(session: store, inner: MockClient((_) async => throw http.ClientException('no route')));
      await expectLater(client.get(Uri.parse('http://x/y')), throwsA(isA<TransportFailure>()));
    });
  });

  group('TimeoutClient', () {
    test('a request that never responds fails instead of hanging forever', () async {
      final client = TimeoutClient(
        MockClient((_) => Completer<http.Response>().future), // never completes
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(client.get(Uri.parse('http://x/y')), throwsA(isA<TimeoutException>()));
    });

    test('a normal response passes through unchanged', () async {
      final client = TimeoutClient(MockClient((_) async => http.Response('{"ok":1}', 200)));
      final res = await client.get(Uri.parse('http://x/y'));
      expect(res.statusCode, 200);
    });
  });

  group('format', () {
    test('percentages', () {
      expect(pct(null), 'n/a');
      expect(pct(74.5), '74.5%');
    });

    test('"today" is computed in the school timezone', () {
      // 23:30 UTC on the 5th is still the 5th in Accra (UTC+0) and the 6th in Lagos (UTC+1).
      final t = DateTime.utc(2026, 10, 5, 23, 30);
      expect(todayIn('Africa/Accra', t), '2026-10-05');
      expect(todayIn('Africa/Lagos', t), '2026-10-06');
    });

    test('month helpers', () {
      expect(monthBounds('2026-02').days, 28);
      expect(shiftMonth('2026-12', 1), '2027-01');
      expect(shiftMonth('2026-01', -1), '2025-12');
    });

    test('status letters round-trip', () {
      for (final s in ['present', 'late', 'absent', 'excused']) {
        expect(statusWord(statusLetter(s)), s);
      }
    });
  });
}
