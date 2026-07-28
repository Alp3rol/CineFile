import 'package:dio/dio.dart';

/// Why a TMDb request failed, in the terms a user can act on.
enum TmdbFailure {
  /// TMDb could not be reached at all — no connectivity, a timeout, or the DNS
  /// interception this app's DoH resolver exists to work around. The most
  /// likely failure in practice, and the one that used to be indistinguishable
  /// from "your search matched nothing".
  network,

  /// TMDb rejected the credentials. Actionable: the key in Settings is wrong.
  invalidApiKey,

  /// Anything else — an unexpected status, a malformed payload.
  unknown,
}

/// A TMDb request failure carrying a reason rather than a message.
///
/// Every call site used to `throw Exception('TMDb <something> Hatası: ...')`.
/// That is untranslatable, and it encouraged callers to render the raw text —
/// so a DNS block reached the user as a sentence full of Dio internals. The
/// reason is what the UI switches on; [operation] and [detail] exist only for
/// logs.
class TmdbException implements Exception {
  const TmdbException(this.failure, {required this.operation, this.detail});

  final TmdbFailure failure;

  /// Which call failed, in English, for debugging output only.
  final String operation;

  /// The underlying error text, for debugging output only.
  final String? detail;

  factory TmdbException.from(Object error, {required String operation}) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      // TMDb answers an unusable key with 401, and 404 on /authentication-style
      // paths; only 401 is unambiguous enough to tell the user about.
      if (status == 401) {
        return TmdbException(TmdbFailure.invalidApiKey,
            operation: operation, detail: error.message);
      }
      // A response that arrived at all means the network worked, whatever else
      // went wrong with it.
      final failure = error.type == DioExceptionType.badResponse
          ? TmdbFailure.unknown
          : TmdbFailure.network;
      return TmdbException(failure, operation: operation, detail: error.message);
    }
    return TmdbException(TmdbFailure.unknown,
        operation: operation, detail: error.toString());
  }

  @override
  String toString() => 'TmdbException(${failure.name}) during $operation: $detail';
}
