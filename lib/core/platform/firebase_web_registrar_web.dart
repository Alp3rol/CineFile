import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';

/// Web implementation — see `firebase_web_registrar.dart` for why the import is
/// conditional.
///
/// Registration is idempotent in practice but not contractually, and it is
/// called from two places during startup (once eagerly in `main`, once inside
/// `firebaseInitProvider` in case the provider is re-created by a retry), so
/// a second call must never take the app down.
void registerFirebaseWebPlugins() {
  try {
    FirebaseCoreWeb.registerWith(webPluginRegistrar);
    FirebaseAuthWeb.registerWith(webPluginRegistrar);
    FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  } catch (_) {
    // Already registered — harmless.
  }
}
