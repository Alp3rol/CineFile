/// Registers the Firebase web plugins with Flutter's web plugin registrar.
///
/// Flutter Web's automatic plugin registration doesn't reliably run before the
/// first Firebase call in this app's startup order, which surfaced as Pigeon
/// channel errors on the deployed build — so the three plugins are registered
/// explicitly instead (see git history around the `fix: Register Firebase*Web`
/// commits).
///
/// The real implementation is web-only and imports `dart:js_interop`, which
/// doesn't exist on the Dart VM. Importing it unconditionally from `main.dart`
/// broke `flutter test` for every file that transitively reached `main.dart`,
/// so the import is conditional: native builds and the VM test runner get the
/// no-op stub below, web builds get `firebase_web_registrar_web.dart`.
library;

export 'firebase_web_registrar_stub.dart'
    if (dart.library.js_interop) 'firebase_web_registrar_web.dart';
