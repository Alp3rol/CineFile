import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

/// Web implementation — see `firebase_web_registrar.dart` for why the import is
/// conditional.
///
/// Registration is idempotent in practice but not contractually, and it is
/// called from two places during startup (once eagerly in `main`, once inside
/// `firebaseInitProvider` in case the provider is re-created by a retry), so
/// a second call must never take the app down.
void registerFirebaseWebPlugins() {
  // Register independently: one plugin being registered already must not stop
  // the remaining plugins from becoming available.
  _register(() => SharedPreferencesPlugin.registerWith(webPluginRegistrar));
  _register(() => FirebaseCoreWeb.registerWith(webPluginRegistrar));
  _register(() => FirebaseAuthWeb.registerWith(webPluginRegistrar));
  _register(() => FirebaseFirestoreWeb.registerWith(webPluginRegistrar));
}

void _register(void Function() registration) {
  try {
    registration();
  } catch (_) {
    // Already registered — harmless.
  }
}
