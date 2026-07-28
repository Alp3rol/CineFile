import '../../../l10n/app_localizations.dart';

/// Why a sign-in, sign-up or profile update did not succeed.
///
/// [AuthController] used to return the message itself — a Turkish string, and
/// for anything unrecognised, `e.toString()` or Firebase's own English
/// `e.message`. That put untranslated (and sometimes raw exception) text in
/// front of the user. The controller now names the *reason*; turning it into
/// words is the UI's job, so it happens in the user's language.
enum AuthFailure {
  usernameEmpty,
  usernameTaken,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  invalidCredentials,
  accountCreationFailed,
  notSignedIn,
  userDataMissing,

  /// Anything not worth its own case — a network drop, a Firestore permission
  /// error, an unrecognised Firebase code. The underlying error is logged via
  /// `debugPrint` at the throw site rather than shown, so it stays diagnosable
  /// without leaking stack text into the UI.
  unknown,
}

extension AuthFailureMessage on AuthFailure {
  String message(AppLocalizations l10n) {
    return switch (this) {
      AuthFailure.usernameEmpty => l10n.authErrorUsernameEmpty,
      AuthFailure.usernameTaken => l10n.authErrorUsernameTaken,
      AuthFailure.emailAlreadyInUse => l10n.authErrorEmailInUse,
      AuthFailure.weakPassword => l10n.authErrorWeakPassword,
      AuthFailure.invalidEmail => l10n.authErrorInvalidEmail,
      AuthFailure.invalidCredentials => l10n.authErrorInvalidCredentials,
      AuthFailure.accountCreationFailed => l10n.authErrorAccountCreationFailed,
      AuthFailure.notSignedIn => l10n.authErrorNotSignedIn,
      AuthFailure.userDataMissing => l10n.authErrorUserDataMissing,
      AuthFailure.unknown => l10n.authErrorUnknown,
    };
  }
}
