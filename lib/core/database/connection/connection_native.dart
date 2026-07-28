import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor createConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // The filename deliberately keeps the project's old `filmdizi` name even
    // though the Dart package is now `cinefile`. It is the path to a file that
    // already exists on every current install: renaming it would silently
    // point the app at a brand-new empty database, and the user's collections
    // and cached title metadata would look like they had vanished. Changing it
    // would need a migration step that moves the old file first — not worth it
    // for a name nobody sees.
    final file = File(p.join(dbFolder.path, 'filmdizi_journal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
