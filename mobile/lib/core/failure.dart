import 'dart:convert';

import 'package:homeroom_api/api.dart';

/// Something failed to load or save, in terms the app can act on.
sealed class Failure implements Exception {
  const Failure();

  /// A sentence safe to show a person. Never a stack trace or a bare status code.
  String get message;
}

/// The device is offline, the server is unreachable, or the connection dropped mid-request.
class NetworkFailure extends Failure {
  const NetworkFailure([this.cause]);
  final Object? cause;

  @override
  String get message => 'You appear to be offline, or the server cannot be reached.';
}

/// The server answered with an RFC 9457 problem document.
class ProblemFailure extends Failure {
  const ProblemFailure({
    required this.status,
    required this.code,
    required this.title,
    this.detail,
    this.requestId,
    this.fieldErrors = const {},
  });

  final int status;
  final String code;
  final String title;
  final String? detail;
  final String? requestId;
  final Map<String, String> fieldErrors;

  bool get isServerError => status >= 500;

  @override
  String get message {
    if (isServerError) return 'The server had a problem. Nothing you did is lost; please try again in a moment.';
    if (fieldErrors.isNotEmpty) return fieldErrors.entries.map((e) => '${e.key}: ${e.value}').join('. ');
    return detail ?? title;
  }
}

class UnknownFailure extends Failure {
  const UnknownFailure(this.cause);
  final Object cause;

  @override
  String get message => 'Something went wrong. Please try again.';
}

/// Raised by the HTTP decorator when a request could not reach the server. The generated client wraps
/// every transport error into `ApiException(400, ...)`, so this marker is how "offline" stays distinguishable
/// from a genuine 400 response.
class TransportFailure implements Exception {
  const TransportFailure(this.cause);
  final Object cause;

  @override
  String toString() => 'TransportFailure($cause)';
}

/// Turn anything thrown by the API layer into a [Failure].
Failure classify(Object error) {
  if (error is Failure) return error;
  if (error is TransportFailure) return NetworkFailure(error.cause);
  if (error is ApiException) {
    // A real HTTP 400 carries the response body; a wrapped transport error carries an inner exception.
    if (error.innerException != null) {
      final inner = error.innerException;
      return inner is TransportFailure ? NetworkFailure(inner.cause) : NetworkFailure(inner);
    }
    return _problemFrom(error) ?? UnknownFailure(error);
  }
  return UnknownFailure(error);
}

bool isNetworkFailure(Object error) => classify(error) is NetworkFailure;

ProblemFailure? _problemFrom(ApiException e) {
  final body = e.message;
  if (body == null || body.isEmpty) return ProblemFailure(status: e.code, code: 'http_${e.code}', title: 'Request failed');
  try {
    final json = jsonDecode(body);
    if (json is Map<String, dynamic> && json['status'] is int) {
      final errors = <String, String>{};
      for (final item in (json['errors'] as List<dynamic>? ?? const [])) {
        if (item is Map<String, dynamic>) errors['${item['field']}'] = '${item['message']}';
      }
      return ProblemFailure(
        status: json['status'] as int,
        code: '${json['code'] ?? 'error'}',
        title: '${json['title'] ?? 'Request failed'}',
        detail: json['detail'] as String?,
        requestId: json['request_id'] as String?,
        fieldErrors: errors,
      );
    }
  } on FormatException {
    // not JSON (a proxy error page, say): fall through
  }
  return ProblemFailure(status: e.code, code: 'http_${e.code}', title: 'Request failed');
}
