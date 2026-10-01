import 'package:http/http.dart';

import 'failure.dart';
import 'session.dart';

/// Wraps an HTTP client to add the access token to every request, retry once after a 401 with a refreshed token,
/// and report transport failures as [TransportFailure] so callers can tell "offline" from "the server said no".
class AuthedClient extends BaseClient {
  AuthedClient({required Client inner, required SessionStore session})
      : _inner = inner,
        _session = session;

  final Client _inner;
  final SessionStore _session;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    // A request body can only be read once, so keep a copy to replay after a refresh.
    final spare = request is Request ? _copy(request) : null;

    final token = await _session.accessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    var response = await _transmit(request);

    if (response.statusCode == 401 && spare != null && _session.hasRefresh && await _session.refresh()) {
      final fresh = _session.value;
      if (fresh != null) spare.headers['Authorization'] = 'Bearer ${fresh.accessToken}';
      response = await _transmit(spare);
    }
    return response;
  }

  Future<StreamedResponse> _transmit(BaseRequest request) async {
    try {
      return await _inner.send(request);
    } on Exception catch (e) {
      throw TransportFailure(e);
    }
  }

  static Request _copy(Request r) => Request(r.method, r.url)
    ..headers.addAll(r.headers)
    ..bodyBytes = r.bodyBytes;

  @override
  void close() => _inner.close();
}
