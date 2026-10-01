import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'failure.dart';

/// Writes that must not be lost when the connection drops (the attendance register, scores).
///
/// A write is attempted immediately. If the network is down, or the server answers 5xx, it is saved on the device and
/// retried until the server accepts it: every 15 seconds while anything is waiting, and whenever the app returns to the
/// foreground. Every write carries an Idempotency-Key, so a retry after a half-finished attempt can never apply twice.
///
/// A 4xx answer means the server understood and refused (for example the term closed while offline). Retrying cannot
/// help, so the write is dropped and reported rather than blocking the queue forever.
class QueuedWrite {
  QueuedWrite({required this.id, required this.method, required this.path, required this.body, required this.key, required this.label, required this.createdAt});

  final String id;
  final String method;

  /// Concrete API path with ids already substituted, e.g. /class_sections/…/attendance
  final String path;
  final Map<String, dynamic> body;
  final String key;

  /// A sentence for people: "Register for 6A, Maths".
  final String label;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {'id': id, 'method': method, 'path': path, 'body': body, 'key': key, 'label': label, 'createdAt': createdAt.toIso8601String()};

  factory QueuedWrite.fromJson(Map<String, dynamic> j) => QueuedWrite(
        id: j['id'] as String,
        method: j['method'] as String,
        path: j['path'] as String,
        body: Map<String, dynamic>.from(j['body'] as Map),
        key: j['key'] as String,
        label: j['label'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class TransportResponse {
  const TransportResponse(this.status, this.body);
  final int status;
  final String body;
}

/// Sends one write. Throws (anything) when the network is unavailable.
typedef Transport = Future<TransportResponse> Function(QueuedWrite write);

enum SubmitStatus { sent, queued, rejected }

class SubmitResult {
  const SubmitResult.sent(this.body)
      : status = SubmitStatus.sent,
        problem = null;
  const SubmitResult.queued()
      : status = SubmitStatus.queued,
        body = null,
        problem = null;
  const SubmitResult.rejected(this.problem)
      : status = SubmitStatus.rejected,
        body = null;

  final SubmitStatus status;

  /// What the server answered (for batch endpoints: the per-entry outcomes).
  final Object? body;
  final ProblemFailure? problem;
}

class DroppedWrite {
  const DroppedWrite(this.label, this.reason);
  final String label;
  final String reason;
}

class Outbox extends ChangeNotifier {
  Outbox({required SharedPreferences prefs, required Transport transport, Uuid? uuid, DateTime Function()? now})
      : _prefs = prefs,
        _transport = transport,
        _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now {
    _items = _read();
  }

  static const _key = 'homeroom.outbox.v1';
  static const retryEvery = Duration(seconds: 15);

  final SharedPreferences _prefs;
  final Transport _transport;
  final Uuid _uuid;
  final DateTime Function() _now;
  late List<QueuedWrite> _items;
  final List<DroppedWrite> _dropped = [];
  Future<void>? _flushing;
  Timer? _timer;

  List<QueuedWrite> get items => List.unmodifiable(_items);
  int get count => _items.length;

  List<QueuedWrite> _read() {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null) return [];
      return [for (final j in jsonDecode(raw) as List<dynamic>) QueuedWrite.fromJson(j as Map<String, dynamic>)];
    } catch (_) {
      return []; // corrupt storage: better an empty queue than a crash on launch
    }
  }

  Future<void> _persist() => _prefs.setString(_key, jsonEncode([for (final w in _items) w.toJson()]));

  /// Writes the server refused while replaying; the UI shows them once, then they are cleared.
  List<DroppedWrite> takeDropped() {
    final d = List<DroppedWrite>.of(_dropped);
    _dropped.clear();
    if (d.isNotEmpty) notifyListeners();
    return d;
  }

  /// Try now; if the network or server fails, keep it and retry in the background.
  Future<SubmitResult> submit({required String method, required String path, required Map<String, dynamic> body, required String label, String? key}) async {
    final write = QueuedWrite(id: _uuid.v4(), method: method, path: path, body: body, key: key ?? _uuid.v4(), label: label, createdAt: _now());
    try {
      final res = await _transport(write);
      if (res.status >= 200 && res.status < 300) return SubmitResult.sent(_decode(res.body));
      if (_retryable(res.status)) return _enqueue(write);
      return SubmitResult.rejected(_problem(res));
    } catch (_) {
      return _enqueue(write); // the transport threw: offline
    }
  }

  /// Replay in order. Stops at the first write that cannot be delivered yet, so order is preserved.
  Future<void> flush() => _flushing ??= _flushAll().whenComplete(() => _flushing = null);

  Future<void> _flushAll() async {
    while (_items.isNotEmpty) {
      final next = _items.first;
      final TransportResponse res;
      try {
        res = await _transport(next);
      } catch (_) {
        return; // still offline
      }
      if (res.status >= 200 && res.status < 300) {
        await _remove(next.id);
      } else if (res.status == 401 || _retryable(res.status)) {
        return; // signed out, or the server is struggling: keep everything and try again later
      } else {
        final p = _problem(res);
        _dropped.add(DroppedWrite(next.label, p.detail ?? p.title));
        await _remove(next.id);
      }
    }
  }

  /// Keep trying to deliver queued writes for as long as the app is open.
  void startSync() {
    _timer?.cancel();
    _timer = Timer.periodic(retryEvery, (_) => unawaited(_tick()));
    unawaited(_tick());
  }

  Future<void> _tick() async {
    if (_items.isNotEmpty) await flush();
  }

  /// Call when the app returns to the foreground.
  Future<void> onResumed() => _tick();

  void stopSync() {
    _timer?.cancel();
    _timer = null;
  }

  Future<SubmitResult> _enqueue(QueuedWrite w) async {
    _items = [..._items, w];
    await _persist();
    notifyListeners();
    return const SubmitResult.queued();
  }

  Future<void> _remove(String id) async {
    _items = _items.where((x) => x.id != id).toList();
    await _persist();
    notifyListeners();
  }

  static bool _retryable(int status) => status >= 500 || status == 408 || status == 429;

  static Object? _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static ProblemFailure _problem(TransportResponse r) {
    final j = _decode(r.body);
    if (j is Map<String, dynamic> && j['status'] is int) {
      return ProblemFailure(status: j['status'] as int, code: '${j['code'] ?? 'error'}', title: '${j['title'] ?? 'Refused'}', detail: j['detail'] as String?, requestId: j['request_id'] as String?);
    }
    return ProblemFailure(status: r.status, code: 'http_${r.status}', title: 'Refused (${r.status})');
  }
}
