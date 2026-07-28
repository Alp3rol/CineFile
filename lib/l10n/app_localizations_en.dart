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

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsReleaseReminders => 'Release Reminders';

  @override
  String get settingsDynamicBackground => 'Dynamic Background';

  @override
  String get settingsNotificationPermissionDenied =>
      'Notification permission was denied. You can enable it in your system settings.';

  @override
  String get settingsDataSection => 'Data & Backup';

  @override
  String get settingsBackupTitle => 'Diary Backup';

  @override
  String get settingsBackupDescription =>
      'Back up your whole watch history, collections, favourites and notes as JSON, and restore it on any device. Restoring overwrites what is already there.';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsRestore => 'Restore';

  @override
  String get settingsCleanDuplicates => 'Clean Duplicate Records';

  @override
  String get settingsDataProvider => 'Data Provider';

  @override
  String get settingsTmdbAttribution =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get backupCopiedTitle => 'Backup Copied to Clipboard';

  @override
  String get backupCopiedMessage =>
      'Your backup data has been copied. Save it to a file or send it to another device to keep it safe.';

  @override
  String get backupRestoreTitle => 'Restore from Backup';

  @override
  String get backupRestoreWarning =>
      'Paste the JSON backup code you copied earlier into the field below. This will overwrite your collections AND your entire watch history on this account.';

  @override
  String get backupRestoreHint => 'Paste the JSON code here...';

  @override
  String get backupRestoreConfirm => 'Restore';

  @override
  String get backupRestoreSuccess => 'Your data was restored from the backup.';

  @override
  String backupExportError(String error) {
    return 'Could not create the backup file: $error';
  }

  @override
  String backupRestoreInvalid(String error) {
    return 'Invalid backup code format ($error)';
  }

  @override
  String get duplicateCleanupTitle => 'Clean Duplicate Records';

  @override
  String get duplicateCleanupConfirmTitle => 'Delete Duplicate Records';

  @override
  String get duplicateCleanupNone =>
      'No duplicates found. Your diary looks clean.';

  @override
  String duplicateCleanupConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Extra diary entries for $count titles will be deleted, keeping only the one reflecting the latest progress. This cannot be undone.',
      one:
          'Extra diary entries for 1 title will be deleted, keeping only the one reflecting the latest progress. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupIntro(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count titles have more than one entry on the same day. In each group the entry reflecting the latest progress is kept and the rest are deleted.',
      one:
          '1 title has more than one entry on the same day. In each group the entry reflecting the latest progress is kept and the rest are deleted.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupGroupSummary(String day, int total, int toDelete) {
    return '$day • $total entries, $toDelete to delete';
  }

  @override
  String duplicateCleanupCleaned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Duplicates cleaned for $count titles.',
      one: 'Duplicates cleaned for 1 title.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupPartial(int cleaned, int failed) {
    return '$cleaned cleaned, $failed failed.';
  }

  @override
  String duplicateCleanupAction(int count) {
    return 'Clean Selected ($count)';
  }

  @override
  String duplicateCleanupLoadError(String error) {
    return 'Could not load records: $error';
  }

  @override
  String get notificationChannelName => 'Release Reminders';

  @override
  String get notificationChannelDescription =>
      'Release-day reminders for the films and shows on your watchlist.';

  @override
  String get notificationReleaseTitle => 'Out Today! 🎬';

  @override
  String get notificationEpisodeTitle => 'New Episode! 🎬';

  @override
  String get notificationWatchlistFallbackTitle => 'A title on your watchlist';

  @override
  String get notificationShowFallbackTitle => 'A show you follow';

  @override
  String notificationReleaseBodyMovie(String title) {
    return '\"$title\" from your watchlist is out today.';
  }

  @override
  String notificationReleaseBodyShow(String title) {
    return 'A new episode of \"$title\" from your watchlist airs today.';
  }

  @override
  String get searchTitle => 'Discover';

  @override
  String get searchHint => 'Search films and shows...';

  @override
  String get searchNoResultsTitle => 'No Results';

  @override
  String get searchNoResultsHint => 'Try a different word.';

  @override
  String get searchStartTitle => 'Start Exploring';

  @override
  String get searchStartHint => 'Search across millions of titles.';

  @override
  String get searchErrorNetwork =>
      'Couldn\'t reach TMDb. Check your connection and try again.';

  @override
  String get searchErrorInvalidApiKey =>
      'Your TMDb API key isn\'t valid. You can check it in Settings.';

  @override
  String get searchErrorUnknown =>
      'The search couldn\'t be completed. Please try again.';

  @override
  String get discoverFilterAll => 'All';

  @override
  String get discoverFilterMovies => 'Films';

  @override
  String get discoverFilterShows => 'Shows';

  @override
  String get discoverCategoryTrend => 'Trending';

  @override
  String get discoverCategoryPopular => 'Popular';

  @override
  String get discoverCategoryTopRated => 'Top Rated';

  @override
  String get discoverWindowThisWeek => 'This Week';

  @override
  String get discoverWindowToday => 'Today';

  @override
  String get discoverGenreAll => 'All';

  @override
  String get discoverHeadingTrendToday => 'Trending Today';

  @override
  String get discoverHeadingTrendThisWeek => 'Trending This Week';

  @override
  String get discoverHeadingPopular => 'Popular Now';

  @override
  String get discoverHeadingTopRated => 'Top Rated';

  @override
  String get discoverFilterEmpty => 'Nothing in this category';

  @override
  String get searchTmdbAttribution => 'Data provided by TMDB.';

  @override
  String get recommendationsTitle => 'Picked For You';

  @override
  String get recommendationReasonPopular => 'Popular in the Community';

  @override
  String recommendationReasonGenre(String genre) {
    return 'For $genre Fans';
  }

  @override
  String recommendationReasonDirector(String director) {
    return 'Directed by $director';
  }

  @override
  String recommendationReasonActor(String actor) {
    return 'Starring $actor';
  }

  @override
  String get titleUnknown => 'Unknown Title';

  @override
  String get searchDemoModeBanner =>
      'No TMDb API key set, so you\'re in demo mode (try searching \"dune\", \"interstellar\", \"inception\" or \"dark\").';

  @override
  String get detailNotFound => 'Details for this title could not be found.';

  @override
  String get detailNoOverview => 'No overview available.';

  @override
  String get detailOverview => 'Overview';

  @override
  String get detailCast => 'Cast';

  @override
  String get detailDirector => 'Director';

  @override
  String get detailMyRating => 'My Rating';

  @override
  String get detailPlace => 'Where';

  @override
  String get detailAddToDiary => 'Add to Diary';

  @override
  String get detailAddToList => 'Add to List';

  @override
  String get detailShare => 'Share';

  @override
  String get detailAddToMyDiary => 'Add to My Diary';

  @override
  String get detailSetRank => 'Set Rank';

  @override
  String get detailTmdbAttribution => 'Data provided by TMDB.';

  @override
  String get directorUnknown => 'Unknown';

  @override
  String get detailFavoriteFailed =>
      'Couldn\'t update your favourites. Please try again.';

  @override
  String get detailWatchlistFailed =>
      'Couldn\'t update your watchlist. Please try again.';

  @override
  String get detailRecordDeleted => 'Watch record deleted.';

  @override
  String get detailRecordDeleteFailed =>
      'Couldn\'t delete that record. Please try again.';

  @override
  String get detailLoadFailed =>
      'Couldn\'t load the details. Please try again.';

  @override
  String get timelineTitle => 'My Watch History';

  @override
  String get timelineEmpty => 'You haven\'t watched this yet.';

  @override
  String get timelineLoadFailed => 'Couldn\'t load your watch history.';

  @override
  String timelineMood(String mood) {
    return 'Mood: $mood';
  }

  @override
  String get timelineDeleteTitle => 'Delete Record?';

  @override
  String get timelineDeleteConfirm =>
      'Permanently delete this watch record from your diary?';

  @override
  String get commonDiscard => 'Never mind';

  @override
  String get watchStatusCompleted => 'Completed';

  @override
  String watchStatusWatchingOf(int watched, int total) {
    return 'Watching ($watched/$total)';
  }

  @override
  String watchStatusWatchingEpisode(int episode) {
    return 'Watching (episode $episode)';
  }

  @override
  String get rankDialogTitle => 'Set Favourite Rank';

  @override
  String get rankDialogField => 'Rank Number';

  @override
  String get rankSaveFailed => 'Couldn\'t save that rank.';

  @override
  String get commonSave => 'Save';

  @override
  String get addRecordTitle => 'Add a Watch Record';

  @override
  String get addRecordSubmit => 'Add to Diary';

  @override
  String get addRecordSignInRequired => 'Please sign in first.';

  @override
  String get addRecordSaveFailed => 'Couldn\'t save the record.';

  @override
  String get addRecordMoodLabel => 'Viewing mood:';

  @override
  String get addRecordRatingLabel => 'Your rating:';

  @override
  String get addRecordPlaceLabel => 'Where did you watch it?';

  @override
  String get addRecordPlaceHint => 'e.g. Prince Charles Cinema, Home...';

  @override
  String get addRecordCompanionLabel => 'Who did you watch it with?';

  @override
  String get addRecordCompanionHint => 'e.g. On my own, Alex, My family...';

  @override
  String get addRecordNotesLabel => 'Your notes:';

  @override
  String get addRecordNotesHint =>
      'What did you make of it? Scenes that stuck with you...';

  @override
  String get addRecordTagsLabel => 'Custom tags (#tag):';

  @override
  String get addRecordTagsHint =>
      'e.g. #nostalgia, #inacinema, #alone (comma separated)...';

  @override
  String get addRecordVisibilityLabel => 'Show on my profile';

  @override
  String get addRecordVisibilityHint =>
      'When on, this record appears in the \"Recently Watched\" section of your profile for everyone.';

  @override
  String get addRecordContentSection => 'Content';

  @override
  String get placeHome => 'Home';

  @override
  String get placeCinema => 'Cinema';

  @override
  String get placeFriendsHouse => 'A friend\'s place';

  @override
  String get placeTravelling => 'Travelling';

  @override
  String get placeHotel => 'Hotel';

  @override
  String get placePlane => 'On a plane';

  @override
  String get placeGarden => 'Garden';

  @override
  String get placeCamping => 'Camping';

  @override
  String get placeWork => 'At work';

  @override
  String get companionAlone => 'On my own';

  @override
  String get companionFriends => 'With friends';

  @override
  String get companionFamily => 'With family';

  @override
  String get companionPartner => 'With my partner';

  @override
  String get companionSpouse => 'With my spouse';

  @override
  String get companionSibling => 'With my sibling';

  @override
  String get companionKids => 'With the kids';

  @override
  String get companionColleagues => 'With colleagues';

  @override
  String get episodeTrackingActive => 'Currently Watching';

  @override
  String get episodeTrackingWholeSeason => 'Finished the whole season';

  @override
  String get episodeTrackingSpecificCount => 'A specific number of episodes';

  @override
  String get episodeTrackingCountLabel => 'How many episodes did you watch?';

  @override
  String episodeLabel(int episode) {
    return 'Episode $episode';
  }

  @override
  String episodeLabelOf(int episode, int total) {
    return 'Episode $episode of $total';
  }

  @override
  String get episodeGuideTitle => 'Episode Guide';

  @override
  String get episodeGuideEmpty => 'No episodes found for this season.';

  @override
  String get episodeGuideLoadFailed =>
      'Couldn\'t load the episodes. Please try again.';

  @override
  String get episodeNoOverview => 'No episode summary available.';

  @override
  String get episodeMarkSeasonWatched => 'I Watched This Season';

  @override
  String get episodeMarkFailed => 'Couldn\'t mark that episode.';

  @override
  String get episodeAddShowPrompt => 'Add this show to your diary?';

  @override
  String get episodeAddShowExplain =>
      'Adding it puts the show in your \"Currently Watching\" list and counts towards your stats.';

  @override
  String get episodeFollowOnly => 'Just Follow';

  @override
  String get episodeConfirmWatchedTitle => 'Did you watch these episodes?';

  @override
  String get episodeUndoProgressTitle => 'Undo watch progress?';

  @override
  String get commonYes => 'Yes';

  @override
  String get offlineOverviewUnavailable =>
      'Offline: the overview couldn\'t be loaded.';

  @override
  String get offlineContentTitle => 'Offline Content';

  @override
  String get offlineFallbackOverview =>
      'A connection problem meant the details couldn\'t be fully loaded. You can still add this to your diary or lists.';

  @override
  String get journalTitle => 'My Diary';

  @override
  String get journalTabDiary => 'Diary';

  @override
  String get journalTabLists => 'Lists';

  @override
  String get journalTabInsights => 'Insights';

  @override
  String get journalSearchHint => 'Title, director, note, place...';

  @override
  String get journalFilterAll => 'All';

  @override
  String get journalFilterFavorites => 'Favourites';

  @override
  String get journalFilterCinema => 'At the cinema';

  @override
  String get journalFilterWithNotes => 'With notes';

  @override
  String get journalStatThisMonth => 'This Month';

  @override
  String get journalStatAvgRating => 'Avg. Rating';

  @override
  String get journalStatFavoriteGenre => 'Top Genre';

  @override
  String get journalStatTotalTime => 'Total Time';

  @override
  String get journalStatUndetermined => '—';

  @override
  String get journalEmptyTitle => 'No Records';

  @override
  String get journalEmptyFiltered =>
      'No diary entries match your search or filters.';

  @override
  String get journalEmptyNoRecords =>
      'Your diary is empty. Add watch records from the Discover tab.';

  @override
  String get journalLoadFailed =>
      'Couldn\'t load your diary. Please try again.';

  @override
  String get journalReorderFailed =>
      'Couldn\'t save the new order. Please try again.';

  @override
  String get journalColumnRank => 'Rank';

  @override
  String get journalColumnTitle => 'Title';

  @override
  String get journalColumnWatchDate => 'Watched On';

  @override
  String get journalColumnWatch => 'Watch';

  @override
  String get journalColumnWatchOrder => 'Watch No.';

  @override
  String get collectionsTitle => 'My Collections';

  @override
  String get collectionsEmptyTitle => 'No Collections Yet';

  @override
  String get collectionsCreate => 'Create a Collection';

  @override
  String get collectionsLoadFailed => 'Couldn\'t load your collections.';

  @override
  String get collectionAddTo => 'Add to Collection';

  @override
  String get collectionNewList => 'New List';

  @override
  String get collectionNoneYet => 'You have no collections.';

  @override
  String get collectionNoneYetHint =>
      'Tap \"+ New List\" in the top right to make one.';

  @override
  String get collectionUpdateFailed =>
      'Couldn\'t update the list. Please try again.';

  @override
  String get commonOk => 'OK';

  @override
  String get collectionEditTitle => 'Edit Collection';

  @override
  String get collectionCreateTitle => 'New Collection';

  @override
  String get collectionEditExplain =>
      'Update the name, description and marathon date of your collection.';

  @override
  String get collectionCreateExplain =>
      'Fill these in to track a film marathon or build a themed list.';

  @override
  String get collectionNameLabel => 'Collection Name';

  @override
  String get collectionNameHint => 'e.g. Marvel Marathon, Masterpieces...';

  @override
  String get collectionDescriptionLabel => 'Description (optional)';

  @override
  String get collectionDescriptionHint =>
      'A short description of this collection...';

  @override
  String get collectionTargetDateLabel => 'Marathon Target Date';

  @override
  String get collectionTargetDatePick => 'Pick a target date (optional)';

  @override
  String get commonCreate => 'Create';

  @override
  String get collectionEmptyTitle => 'This Collection Is Empty';

  @override
  String get collectionEmptyHint =>
      'Search from the Discover tab, or add titles to this collection from their detail pages.';

  @override
  String get collectionRemovedMovie => 'Removed from the collection.';

  @override
  String get collectionDeleteTitle => 'Delete Collection?';

  @override
  String get collectionShared => 'Shared with the community';

  @override
  String get collectionStopSharing => 'Stop Sharing';

  @override
  String get collectionStopSharingFailed =>
      'Couldn\'t stop sharing. Please try again.';

  @override
  String get collectionReorderFailed =>
      'Couldn\'t save the new order. Please try again.';

  @override
  String get marathonExpired => 'Time\'s Up! ⚠️';

  @override
  String marathonDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left to hit your target.',
      one: '1 day left to hit your target.',
    );
    return '$_temp0';
  }

  @override
  String get marathonCompleted => 'Marathon complete. Nice one! 🎉';

  @override
  String marathonRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles left.',
      one: '1 title left.',
    );
    return '$_temp0';
  }

  @override
  String recordMood(String mood) {
    return 'Mood: $mood';
  }

  @override
  String get recordWatchDate => 'Watched On';

  @override
  String get recordEpisodesWatched => 'Episodes Watched';

  @override
  String get recordEpisodeCount => 'Episode Count';

  @override
  String get recordEpisodeCountHint => 'How many episodes?';

  @override
  String get recordWatchPlace => 'Where';

  @override
  String get recordCompanions => 'With';

  @override
  String get recordVisibilityFailed => 'Couldn\'t update the sharing setting.';

  @override
  String get recordMyRank => 'My rank: ';

  @override
  String get recordRemoveRank => 'Remove Rank';

  @override
  String get recordMyNotes => 'My notes:';

  @override
  String get recordNoNotes => 'No notes were written for this record.';

  @override
  String get recordDeleteConfirmTitle => 'Are you sure?';

  @override
  String get recordDeleteConfirmBody => 'This watch record will be deleted.';

  @override
  String get recordDeleteFailed =>
      'Couldn\'t delete the record. Please try again.';

  @override
  String get recordDelete => 'Delete Record';

  @override
  String recordEpisodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String recordYearDirector(String year, String director) {
    return '$year • $director';
  }

  @override
  String get yearUnknown => 'Unknown Year';

  @override
  String get directorMissing => 'No Director';

  @override
  String watchNumber(int number) {
    return 'Watch #$number';
  }

  @override
  String journalMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int days) {
    return '${days}d';
  }

  @override
  String durationHours(int hours) {
    return '${hours}h';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String collectionTotalWatched(int total, int watched) {
    return '$total titles • $watched watched';
  }

  @override
  String collectionProgressPercent(int percent) {
    return '$percent% watched';
  }

  @override
  String get collectionsEmptyHint =>
      'Build your own lists (Best Nolan Films, Anime To Watch) to make the app yours.';

  @override
  String get collectionDeleteConfirm =>
      'Delete this collection? Its titles and your ordering will be removed. (The titles themselves stay in your library.)';

  @override
  String get marathonTitle => '🏁 Marathon Challenge';

  @override
  String journalTotalTimeSpent(int hours, int minutes) {
    return 'You have spent ${hours}h ${minutes}m watching the titles in this list.';
  }

  @override
  String addRecordSuccess(String title) {
    return '$title was added to your diary.';
  }

  @override
  String get rankDialogExplain =>
      'Enter a favourite rank for this title (e.g. 1, 2, 5). Leave it empty to remove it from the ranking.';

  @override
  String castSearching(String name) {
    return 'Looking up $name...';
  }

  @override
  String castNotFound(String name) {
    return 'No profile found for $name.';
  }

  @override
  String episodeNumbered(int episode) {
    return 'Episode $episode';
  }

  @override
  String get episodeUpNext => '▶ UP NEXT';

  @override
  String episodeMarkedWatched(int episode) {
    return 'Episode $episode marked as watched.';
  }

  @override
  String episodeMarkedUnwatched(int episode) {
    return 'Episode $episode marked as unwatched.';
  }

  @override
  String episodeBulkWatchConfirm(int from, int to) {
    return 'Marking this episode watched also marks every earlier one ($from - $to) as watched. Continue?';
  }

  @override
  String episodeBulkUnwatchConfirm(int from, int to) {
    return 'Marking this episode unwatched also marks every later one ($from - $to) as unwatched. Continue?';
  }

  @override
  String get tagNostalgia => '#nostalgia';

  @override
  String get tagAtTheCinema => '#inacinema';

  @override
  String get tagAlone => '#alone';

  @override
  String get tagAction => '#action';

  @override
  String get tagRomance => '#romance';

  @override
  String get tagThriller => '#thriller';

  @override
  String get tagComedy => '#comedy';

  @override
  String get tagDrama => '#drama';

  @override
  String get tagSciFi => '#scifi';

  @override
  String get tagHorror => '#horror';

  @override
  String get tagClassic => '#classic';

  @override
  String get tagNewDiscovery => '#newdiscovery';

  @override
  String notificationEpisodeBody(String show, int season, int episode) {
    return 'Season $season, episode $episode of \"$show\" airs today.';
  }
}
