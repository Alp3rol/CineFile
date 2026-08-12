import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Public reCAPTCHA Enterprise site key supplied to release web builds.
const String appCheckWebSiteKey = String.fromEnvironment(
  'APP_CHECK_WEB_SITE_KEY',
);

/// Activates App Check after Firebase initialization and before Auth/Firestore.
///
/// Local web builds without a site key remain usable while enforcement is off.
/// Production deploys reject a missing key in the workflow. Windows has no
/// supported default attestation provider and is intentionally left outside
/// the first enforcement rollout.
Future<void> activateAppCheck() async {
  if (kIsWeb) {
    if (appCheckWebSiteKey.isEmpty) return;
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaEnterpriseProvider(appCheckWebSiteKey),
    );
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kReleaseMode
            ? const AndroidPlayIntegrityProvider()
            : const AndroidDebugProvider(),
      );
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      await FirebaseAppCheck.instance.activate(
        providerApple: kReleaseMode
            ? const AppleAppAttestWithDeviceCheckFallbackProvider()
            : const AppleDebugProvider(),
      );
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return;
  }
}
