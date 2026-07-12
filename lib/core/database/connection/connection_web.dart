import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

QueryExecutor createConnection() {
  return WebDatabase('filmdizi_journal', logStatements: true);
}
