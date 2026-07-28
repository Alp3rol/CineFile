import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

/// Web builds have no SQLite: `drift/web.dart` needs sql.js assets that this
/// app doesn't ship, so opening this connection throws.
///
/// That is fine *as long as nothing on web actually reaches it* — the web
/// build stores collections in the in-memory providers instead (see
/// WebMovieRepository), and everything else lives in Firestore. It is kept
/// rather than removed so `databaseProvider` still type-checks on web; any
/// code path that hits it is a bug, and the exception is the signal.
///
/// `logStatements` was previously left on here, which spammed the release
/// console with every query.
///
/// The store name keeps the old `filmdizi` project name for the same reason
/// the native path does — see connection_native.dart.
QueryExecutor createConnection() {
  return WebDatabase('filmdizi_journal');
}
