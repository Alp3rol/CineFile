import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createConnection() {
  return WebDatabase('filmdizi_journal', logStatements: true);
}
