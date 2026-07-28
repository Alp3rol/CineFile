import 'package:flutter/material.dart';

/// The app-wide navigator key, handed to [MaterialApp] in `main.dart` and used
/// by anything that has to navigate without a [BuildContext] — currently only
/// NotificationService, which routes a tapped release reminder to the relevant
/// detail screen from a background isolate callback.
///
/// It lives in its own file rather than in `main.dart` on purpose: `main.dart`
/// pulls in the Firebase *web* plugin packages, and those import
/// `dart:js_interop`, which does not exist on the Dart VM. Any file importing
/// `main.dart` therefore drags web-only libraries into every `flutter test`
/// compile that transitively reaches it — which is exactly what used to break
/// 17 test files at load time.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
