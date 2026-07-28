// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CineFile';

  @override
  String get firebaseInitErrorTitle => 'Starting Connection';

  @override
  String get firebaseInitErrorMessage =>
      'Connecting to Firebase services. Please try again.';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageTitle => 'Choose Language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get genreAction => 'Action';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreAnimation => 'Animation';

  @override
  String get genreComedy => 'Comedy';

  @override
  String get genreCrime => 'Crime';

  @override
  String get genreDocumentary => 'Documentary';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreFamily => 'Family';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreHistory => 'History';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreMusic => 'Music';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreScienceFiction => 'Science Fiction';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreWar => 'War';

  @override
  String get genreWestern => 'Western';

  @override
  String get genreActionAdventure => 'Action & Adventure';

  @override
  String get genreKids => 'Kids';

  @override
  String get genreNews => 'News';

  @override
  String get genreReality => 'Reality';

  @override
  String get genreSciFiFantasy => 'Sci-Fi & Fantasy';

  @override
  String get genreSoap => 'Soap';

  @override
  String get genreTalk => 'Talk';

  @override
  String get genreWarPolitics => 'War & Politics';

  @override
  String get genreUnknown => 'Unknown';

  @override
  String get authErrorUsernameEmpty => 'Username cannot be empty.';

  @override
  String get authErrorAccountCreationFailed =>
      'Could not create the account. Please try again.';

  @override
  String get authErrorUsernameTaken => 'That username is already taken.';

  @override
  String get authErrorEmailInUse => 'That email address is already in use.';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get authErrorInvalidEmail => 'That email address is not valid.';

  @override
  String get authErrorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authErrorNotSignedIn => 'No signed-in user was found.';

  @override
  String get authErrorUserDataMissing =>
      'Your profile data could not be found.';

  @override
  String get authErrorUnknown => 'Something went wrong.';

  @override
  String get authGateErrorTitle => 'Authentication Error';

  @override
  String get authGateErrorMessage =>
      'Your session could not be read. Please try again.';

  @override
  String get authTagline => 'Join the community, share your diary.';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authEmailRequired => 'Please enter your email address.';

  @override
  String get authEmailInvalid => 'Please enter a valid email address.';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authPasswordRequired => 'Please enter your password.';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters.';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernameRequired => 'Please enter a username.';

  @override
  String get authUsernameTooShort => 'Username must be at least 3 characters.';

  @override
  String get authUsernameNoSpaces => 'Username cannot contain spaces.';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get authHasAccountPrompt => 'Already have an account? ';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authRegisterSuccess => 'You\'re all set. You can sign in now.';

  @override
  String get authSignInRequired => 'Please sign in.';

  @override
  String get authUserNotFound => 'User not found.';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profilePresetAvatars => 'Preset Avatars';

  @override
  String get profileUsernameHint => 'Enter a username';

  @override
  String get profileShowcaseTitle =>
      'Profile Showcase (Up to 5 Featured Titles)';

  @override
  String get profileShowcaseEdit => 'Edit Showcase';

  @override
  String get profileShowcasePickTitle => 'Choose Featured Titles';

  @override
  String get profileShowcaseNone => 'No featured titles yet.';

  @override
  String get profileShowcaseLimit => 'You can feature at most 5 titles.';

  @override
  String profileShowcaseSelected(int count) {
    return 'Choose Featured Titles ($count/5)';
  }

  @override
  String profileShowcasePickCount(int count) {
    return 'Pick up to 5 favourites ($count/5)';
  }

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get profileNoWatchRecords => 'You haven\'t logged anything yet.';

  @override
  String get profileRecentWatches => 'Recently Watched';

  @override
  String get profileNoRecentWatches => 'No watch records yet.';

  @override
  String get profileBadgesTitle => 'Badges Earned';

  @override
  String get profileBadgesEmpty =>
      'No badges yet. They unlock as you keep watching — tap to see them all.';

  @override
  String profileBadgesSeeAll(int unlocked, int total) {
    return 'See All ($unlocked/$total)';
  }

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileRankNovice => 'Rookie Cinephile 🍿';

  @override
  String get profileRankTicketBuddy => 'Ticket Buddy 🎬';

  @override
  String get profileRankConnoisseur => 'Culture Connoisseur 🏛️';

  @override
  String get profileRankGuru => 'Cinema Guru 👑';
}
