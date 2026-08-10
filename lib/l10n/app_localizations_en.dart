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
  String get swipeDiscoverTitle => 'Swipe & Discover';

  @override
  String get swipeDiscoverEntryHint =>
      'Add interesting titles straight to your watchlist';

  @override
  String get swipeDiscoverHint =>
      'Swipe right: add to Watchlist • Swipe left: pass';

  @override
  String get swipeInterested => 'Add to List';

  @override
  String get swipeNotInterested => 'Pass';

  @override
  String get swipeWatched => 'Watched';

  @override
  String get swipeAddedToWatchlist => 'Added to your Watchlist';

  @override
  String get swipePassed => 'Title passed';

  @override
  String get swipeWhy => 'Why?';

  @override
  String get swipeSkipReasonTitle => 'Why did you pass?';

  @override
  String get swipeSkipReasonHint =>
      'Optional, and helps improve your recommendations.';

  @override
  String get swipeSkipReasonGenre => 'This genre isn\'t for me';

  @override
  String get swipeSkipReasonTitleSpecific => 'This title didn\'t interest me';

  @override
  String get swipeSkipReasonNotNow => 'Not right now';

  @override
  String get swipeSkipReasonSaved =>
      'Your recommendations will reflect this choice';

  @override
  String get swipeUndo => 'Undo';

  @override
  String get swipeViewDetails => 'View Full Details';

  @override
  String swipeSeasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seasons',
      one: '1 Season',
    );
    return '$_temp0';
  }

  @override
  String get swipeSessionSummary => 'This Session';

  @override
  String get swipeSessionAdded => 'Added';

  @override
  String get swipeSessionPassed => 'Passed';

  @override
  String get swipeSessionWatched => 'Watched';

  @override
  String swipeSessionTasteHint(String genres) {
    return 'Your $genres choices will shape your next recommendations';
  }

  @override
  String get swipeSaveFailed => 'Couldn\'t save your choice. Please try again.';

  @override
  String get swipeDeckFinished => 'That\'s all for now!';

  @override
  String get swipeDeckFinishedHint =>
      'Fresh recommendations will be waiting here when they arrive.';

  @override
  String get swipeMoreOptions => 'More options';

  @override
  String get swipeResetTitle => 'Reset swipe preferences?';

  @override
  String get swipeResetMessage =>
      'Titles you passed may be recommended again. Your Watchlist and viewing history won\'t change.';

  @override
  String get swipeResetAction => 'Reset preferences';

  @override
  String get swipeResetDone => 'Your swipe preferences were reset';

  @override
  String swipeRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recommendations left',
      one: '1 recommendation left',
    );
    return '$_temp0';
  }

  @override
  String get swipeLoadMore => 'Get fresh recommendations';

  @override
  String get swipeRefreshFailed =>
      'Couldn\'t load fresh recommendations. Please try again.';

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
  String get detailWhereToWatch => 'Where to Watch';

  @override
  String get detailWatchCategoryFlatrate => 'Streaming';

  @override
  String get detailWatchCategoryFree => 'Free';

  @override
  String get detailWatchCategoryRent => 'Rent';

  @override
  String get detailWatchCategoryBuy => 'Buy';

  @override
  String get detailWatchProvidersJustWatchAttribution =>
      'Streaming availability provided by JustWatch.';

  @override
  String get settingsWatchRegionLabel => 'Streaming Region';

  @override
  String get settingsWatchRegionTitle => 'Choose Region';

  @override
  String settingsWatchRegionAutoWith(String region) {
    return 'Automatic ($region)';
  }

  @override
  String commonErrorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileBioHint => 'Tell us about yourself...';

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
  String get insightsInsufficientData => 'Not Enough Data';

  @override
  String get insightsSummaryTotalWatches => 'Total Watches';

  @override
  String get insightsSummaryUniqueTitles => 'Unique Titles';

  @override
  String get insightsSummaryTotalTime => 'Total Time';

  @override
  String get insightsSummaryAvgRating => 'Avg. Rating';

  @override
  String get insightsGenreChartTitle => 'Most-Watched Genres';

  @override
  String get insightsGenreOther => 'Other';

  @override
  String get insightsRatingChartTitle => 'Your Rating Distribution';

  @override
  String get insightsCriticProfile => 'Your Critic Profile';

  @override
  String get insightsTopDirectors => 'Most-Watched Directors';

  @override
  String get insightsTopActors => 'Most-Watched Actors';

  @override
  String get insightsNoRecords => 'No records found.';

  @override
  String get insightsTimeOfDayTitle => 'When Do You Watch?';

  @override
  String get insightsTimeMorning => 'Morning';

  @override
  String get insightsTimeNoon => 'Midday';

  @override
  String get insightsTimeEvening => 'Evening';

  @override
  String get insightsTimeNight => 'Night';

  @override
  String get insightsSeasonWinter => 'Winter';

  @override
  String get insightsSeasonSpring => 'Spring';

  @override
  String get insightsSeasonSummer => 'Summer';

  @override
  String get insightsSeasonAutumn => 'Autumn';

  @override
  String insightsMonthlyChartTitle(int year) {
    return 'Monthly Watches in $year';
  }

  @override
  String insightsWatchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count watches',
      one: '1 watch',
    );
    return '$_temp0';
  }

  @override
  String insightsGoldenDay(String day) {
    return 'Golden day: $day 🏆';
  }

  @override
  String get heatmapTitle => 'Watch Frequency This Year';

  @override
  String get heatmapFilterAll => 'All';

  @override
  String get heatmapFilterMovies => 'Films';

  @override
  String get heatmapFilterShows => 'Shows';

  @override
  String get heatmapLegendLess => 'Less';

  @override
  String get heatmapLegendMore => 'More';

  @override
  String get heatmapLegendMovie => 'Film';

  @override
  String get heatmapLegendShow => 'Show';

  @override
  String get heatmapLegendBoth => 'Both';

  @override
  String get heatmapActiveDays => 'Active Days';

  @override
  String get heatmapCurrentStreak => 'Current Streak';

  @override
  String get heatmapPeakHour => 'Peak Hour';

  @override
  String get heatmapNoRecordOnDay => '— nothing logged.';

  @override
  String get weeklyGoalSetTitle => 'Set Your Weekly Goal';

  @override
  String get weeklyGoalQuestion => 'How many titles a week are you aiming for?';

  @override
  String get weeklyGoalThisWeekPrefix => 'This week ';

  @override
  String get weeklyGoalReached => 'You hit this week\'s goal. Nice one! 🎉';

  @override
  String weeklyGoalRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more to reach your goal.',
      one: '1 more to reach your goal.',
    );
    return '$_temp0';
  }

  @override
  String get achievementsTitle => 'Badges & Achievements';

  @override
  String get achievementsNeedRecords =>
      'Add at least one watch record to your diary to start unlocking badges.';

  @override
  String get achievementsCurrentRank => 'CURRENT RANK';

  @override
  String get achievementsProgress => 'Collection Progress';

  @override
  String get achievementsUnlocked => 'Unlocked';

  @override
  String get achievementsNoneForFilter => 'No badges match this filter.';

  @override
  String achievementsAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String get achievementsRankNoviceSubtitle => 'Just getting started';

  @override
  String get achievementsRankTicketBuddy => 'Ticket Buddy 🎬';

  @override
  String get achievementsRankTicketBuddySubtitle => 'A regular now';

  @override
  String get achievementsRankConnoisseurSubtitle => 'A long cinematic memory';

  @override
  String get achievementsRankGuruSubtitle => 'A genuine authority';

  @override
  String get badgeMaxLevel => 'Max Level! 👑';

  @override
  String get badgeNextLevelProgress => 'Progress to Next Level';

  @override
  String get badgeUnlockProgress => 'Progress to Unlock';

  @override
  String get badgeShare => 'Share Achievement';

  @override
  String get badgeCategoryMilestone => 'Volume & Marathons';

  @override
  String get badgeCategoryTime => 'Time & Atmosphere';

  @override
  String get badgeCategoryDirectors => 'Directors & Auteurs';

  @override
  String get badgeCategoryGenres => 'Genres & Themes';

  @override
  String get badgeCategoryCritic => 'Critic & Diary';

  @override
  String get badgeCategorySeries => 'Shows & Seasons';

  @override
  String get badgeFirstWatchTitle => 'First Steps';

  @override
  String get badgeFirstWatchT1 => 'First Step';

  @override
  String get badgeFirstWatchT2 => 'Getting the Bug';

  @override
  String get badgeFirstWatchT3 => 'Keen Watcher';

  @override
  String get badgeSinefilTitle => 'Cinephile Series';

  @override
  String get badgeSinefilT1 => 'Cinephile';

  @override
  String get badgeSinefilT2 => 'Culture Vulture';

  @override
  String get badgeSinefilT3 => 'Screen Legend';

  @override
  String get badgeSinefilT4 => 'Cinema Guru';

  @override
  String get badgeStreakTitle => 'Streak Watcher';

  @override
  String get badgeStreakT1 => 'Short Marathon';

  @override
  String get badgeStreakT2 => 'Streak Watcher';

  @override
  String get badgeStreakT3 => 'On a Roll';

  @override
  String get badgeStreakT4 => 'Unstoppable';

  @override
  String get badgeNightOwlTitle => 'Night Owl Series';

  @override
  String get badgeNightOwlT1 => 'Night Owl';

  @override
  String get badgeNightOwlT2 => 'Night Watchman';

  @override
  String get badgeNightOwlT3 => 'Prince of Darkness';

  @override
  String get badgeEarlyBirdTitle => 'Early Bird Series';

  @override
  String get badgeEarlyBirdT1 => 'Sunrise Viewer';

  @override
  String get badgeEarlyBirdT2 => 'Early Bird';

  @override
  String get badgeEarlyBirdT3 => 'Dawn Watchman';

  @override
  String get badgeSundayTitle => 'Sunday Cinema';

  @override
  String get badgeSundayT1 => 'Sunday Treat';

  @override
  String get badgeSundayT2 => 'Sunday Cinema';

  @override
  String get badgeSundayT3 => 'Sunday Master';

  @override
  String get badgeWeekendTitle => 'Weekend Marathon';

  @override
  String get badgeWeekendT1 => 'Weekend Warm-Up';

  @override
  String get badgeWeekendT2 => 'Weekend Marathoner';

  @override
  String get badgeWeekendT3 => 'Weekend Monster';

  @override
  String get badgeWinterTitle => 'Blanket & a Film';

  @override
  String get badgeWinterT1 => 'Seasonal Viewer';

  @override
  String get badgeWinterT2 => 'Blanket & a Film';

  @override
  String get badgeWinterT3 => 'All-Season Cinephile';

  @override
  String get badgeTimeTravelerTitle => 'Time Traveller';

  @override
  String get badgeTimeTravelerT1 => 'Nostalgia Seeker';

  @override
  String get badgeTimeTravelerT2 => 'Time Traveller';

  @override
  String get badgeTimeTravelerT3 => 'Archivist of Classics';

  @override
  String get badgeNolanTitle => 'Nolanist Series';

  @override
  String get badgeNolanT1 => 'Nolan Curious';

  @override
  String get badgeNolanT2 => 'Time-Bending Nolanist';

  @override
  String get badgeNolanT3 => 'Dream Within a Dream';

  @override
  String get badgeTarantinoTitle => 'Tarantino Fan';

  @override
  String get badgeTarantinoT1 => 'Pulp Reader';

  @override
  String get badgeTarantinoT2 => 'Revenge Connoisseur';

  @override
  String get badgeTarantinoT3 => 'Cinematic Auteur';

  @override
  String get badgeSpielbergTitle => 'Spielberg Fan';

  @override
  String get badgeSpielbergT1 => 'Adventure Apprentice';

  @override
  String get badgeSpielbergT2 => 'Spielberg Fan';

  @override
  String get badgeSpielbergT3 => 'Blockbuster Legend';

  @override
  String get badgeScorseseTitle => 'Scorsese Devotee';

  @override
  String get badgeScorseseT1 => 'Mob & Crime Fan';

  @override
  String get badgeScorseseT2 => 'Scorsese Devotee';

  @override
  String get badgeScorseseT3 => 'Cinema Artist';

  @override
  String get badgeKubrickTitle => 'Kubrick Mastery';

  @override
  String get badgeKubrickT1 => 'Kubrick Apprentice';

  @override
  String get badgeKubrickT2 => 'Kubrick Mastery';

  @override
  String get badgeKubrickT3 => 'Visual Visionary';

  @override
  String get badgeWesternTitle => 'Wild West Series';

  @override
  String get badgeWesternT1 => 'Wild West Explorer';

  @override
  String get badgeWesternT2 => 'Cowboy & Sheriff';

  @override
  String get badgeWesternT3 => 'The Good, the Bad and the Legend';

  @override
  String get badgeScifiTitle => 'Sci-Fi Explorer';

  @override
  String get badgeScifiT1 => 'Space Traveller';

  @override
  String get badgeScifiT2 => 'Galaxy Explorer';

  @override
  String get badgeScifiT3 => 'Master of the Universe';

  @override
  String get badgeHorrorTitle => 'Horror & Thriller';

  @override
  String get badgeHorrorT1 => 'Fearless Viewer';

  @override
  String get badgeHorrorT2 => 'Thriller Master';

  @override
  String get badgeHorrorT3 => 'Lord of Nightmares';

  @override
  String get badgeDramaTitle => 'Drama Lover';

  @override
  String get badgeDramaT1 => 'Emotional Viewer';

  @override
  String get badgeDramaT2 => 'Drama Lover';

  @override
  String get badgeDramaT3 => 'Master of Feeling';

  @override
  String get badgeCrimeTitle => 'Crime & Mystery Agent';

  @override
  String get badgeCrimeT1 => 'Amateur Detective';

  @override
  String get badgeCrimeT2 => 'Crime & Mystery Agent';

  @override
  String get badgeCrimeT3 => 'Sherlock Level';

  @override
  String get badgeAnimationTitle => 'Animation & Daydreams';

  @override
  String get badgeAnimationT1 => 'Cartoon Fan';

  @override
  String get badgeAnimationT2 => 'Screen of Dreams';

  @override
  String get badgeAnimationT3 => 'Anime & Animation Master';

  @override
  String get badgeTurkishTitle => 'Turkish Cinema';

  @override
  String get badgeTurkishT1 => 'Friend of Turkish Cinema';

  @override
  String get badgeTurkishT2 => 'Yeşilçam Devotee';

  @override
  String get badgeTurkishT3 => 'Guardian of Turkish Cinema';

  @override
  String get badgeCriticTitle => 'Critic Series';

  @override
  String get badgeCriticT1 => 'Note Taker';

  @override
  String get badgeCriticT2 => 'Serious Critic';

  @override
  String get badgeCriticT3 => 'Columnist';

  @override
  String get badgeGenerousTitle => 'Generous Rater';

  @override
  String get badgeGenerousT1 => 'Full Marks Fan';

  @override
  String get badgeGenerousT2 => 'Generous Rater';

  @override
  String get badgeGenerousT3 => 'Masterpiece Hunter';

  @override
  String get badgeStrictTitle => 'Hard to Please';

  @override
  String get badgeStrictT1 => 'Harsh Critic';

  @override
  String get badgeStrictT2 => 'Hard to Please';

  @override
  String get badgeStrictT3 => 'Unforgiving Jury';

  @override
  String get badgeRewatchTitle => 'Loyal Viewer';

  @override
  String get badgeRewatchT1 => 'Rewatcher';

  @override
  String get badgeRewatchT2 => 'Loyal Viewer';

  @override
  String get badgeRewatchT3 => 'Serial Rewatcher';

  @override
  String get badgeTagMasterTitle => 'Tag Master';

  @override
  String get badgeTagMasterT1 => 'Tag Apprentice';

  @override
  String get badgeTagMasterT2 => 'Category Master';

  @override
  String get badgeTagMasterT3 => 'Tag Collector';

  @override
  String get badgeTvTitle => 'Binge Series';

  @override
  String get badgeTvT1 => 'Show Curious';

  @override
  String get badgeTvT2 => 'Binge Watcher';

  @override
  String get badgeTvT3 => 'Serial Addict';

  @override
  String get badgeSeasonTitle => 'Season Monster';

  @override
  String get badgeSeasonT1 => 'Season Finished';

  @override
  String get badgeSeasonT2 => 'Season Monster';

  @override
  String get badgeSeasonT3 => 'Marathon Master';

  @override
  String badgeDescLogEntries(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Add $n watch records to your diary.',
      one: 'Add 1 watch record to your diary.',
    );
    return '$_temp0';
  }

  @override
  String badgeDescWatchAtLeast(int n) {
    return 'Watch at least $n films or shows.';
  }

  @override
  String badgeDescStreak(int n) {
    return 'Log something $n days in a row.';
  }

  @override
  String badgeDescNightWatch(int n) {
    return 'Log $n watches between 00:00 and 05:00.';
  }

  @override
  String badgeDescEarlyWatch(int n) {
    return 'Log $n watches between 06:00 and 09:00.';
  }

  @override
  String badgeDescSunday(int n) {
    return 'Watch $n titles on Sundays.';
  }

  @override
  String badgeDescSingleDay(int n) {
    return 'Watch at least $n titles in a single day.';
  }

  @override
  String badgeDescWinter(int n) {
    return 'Watch $n titles during the winter months.';
  }

  @override
  String badgeDescRetro(int n) {
    return 'Watch $n films made before 1980.';
  }

  @override
  String badgeDescDirector(int n, String director) {
    return 'Watch $n $director films.';
  }

  @override
  String badgeDescWestern(int n) {
    return 'Watch $n Westerns.';
  }

  @override
  String badgeDescScifi(int n) {
    return 'Watch $n science-fiction titles.';
  }

  @override
  String badgeDescHorror(int n) {
    return 'Watch $n horror or thriller titles.';
  }

  @override
  String badgeDescDrama(int n) {
    return 'Watch $n dramas.';
  }

  @override
  String badgeDescCrime(int n) {
    return 'Watch $n crime or mystery titles.';
  }

  @override
  String badgeDescAnimation(int n) {
    return 'Watch $n animated titles.';
  }

  @override
  String badgeDescTurkish(int n) {
    return 'Watch $n Turkish productions.';
  }

  @override
  String badgeDescNotes(int n) {
    return 'Write personal notes on $n titles.';
  }

  @override
  String badgeDescPerfectScore(int n) {
    return 'Give $n titles a full 10/10.';
  }

  @override
  String badgeDescLowScore(int n) {
    return 'Rate $n titles below 5.0.';
  }

  @override
  String badgeDescRewatchNth(int n) {
    return 'Watch the same title for the ${n}th time.';
  }

  @override
  String badgeDescRewatchTimes(int n) {
    return 'Rewatch the same title $n times.';
  }

  @override
  String badgeDescRewatchRecords(int n) {
    return 'Log $n rewatches.';
  }

  @override
  String badgeDescTags(int n) {
    return 'Use $n different personal tags.';
  }

  @override
  String badgeDescEpisodes(int n) {
    return 'Watch $n episodes.';
  }

  @override
  String badgeDescSeasons(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Finish a whole season of $n shows.',
      one: 'Finish a whole season of 1 show.',
    );
    return '$_temp0';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hrs ago',
      one: '1 hr ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get communityTitle => 'Community Feed';

  @override
  String get communityFilterAll => 'All';

  @override
  String get communityFilterFollowing => 'Following';

  @override
  String get communityComposeHint => 'Share something...';

  @override
  String get communityFeedLoadFailed =>
      'Couldn\'t load the feed. Please try again.';

  @override
  String get communityEmptyTitle => 'No posts yet';

  @override
  String get communityEmptyHint => 'Use the box above to write the first one.';

  @override
  String get communityNotFollowingTitle => 'You aren\'t following anyone yet';

  @override
  String get communityNotFollowingHint => 'Find some people to follow';

  @override
  String get communityFollowingEmpty => 'Nobody you follow has posted yet';

  @override
  String get communitySignInToLike => 'Please sign in to like posts.';

  @override
  String communityPostMood(String mood) {
    return 'Mood: $mood';
  }

  @override
  String get communityPostLoadFailed => 'Couldn\'t load this post.';

  @override
  String get communityShowLabel => 'Show';

  @override
  String get userSearchTitle => 'Find People';

  @override
  String get userSearchHint => 'Search by username...';

  @override
  String get userSearchPrompt => 'Search for someone by their username.';

  @override
  String get userSearchNotFound => 'No Users Found';

  @override
  String get userSearchFailed =>
      'The search couldn\'t be completed. Please try again.';

  @override
  String get userUnknown => 'Unknown User';

  @override
  String get followFollow => 'Follow';

  @override
  String get followUnfollow => 'Unfollow';

  @override
  String get followFailed => 'Couldn\'t update that. Please try again.';

  @override
  String get cineTwinSeeMatch => 'See Your CineTwin Match';

  @override
  String get commentsTitle => 'Comments';

  @override
  String commentsTitleWithCount(int count) {
    return 'Comments ($count)';
  }

  @override
  String get commentsLoadFailed => 'Couldn\'t load the comments.';

  @override
  String get commentsEmpty => 'Be the first to comment.';

  @override
  String get commentsHint => 'Write a comment...';

  @override
  String get commentsSignInHint => 'Sign in to comment';

  @override
  String get commentsDeleteTitle => 'Delete Comment?';

  @override
  String get commentsDeleteConfirm =>
      'Are you sure you want to delete this comment?';

  @override
  String get shareOptionsTitle => 'What Do You Want to Share?';

  @override
  String get shareMovieTitle => 'Share a Title';

  @override
  String get shareMovieSubtitle => 'Share a single film or show you watched.';

  @override
  String get shareDiaryTitle => 'Share Your Diary';

  @override
  String get shareDiarySubtitle => 'Pick several records to share at once.';

  @override
  String get shareCollectionTitle => 'Share a Collection';

  @override
  String get shareCollectionSubtitle =>
      'Share a collection that stays in sync.';

  @override
  String get shareCollectionWebUnavailable =>
      'This isn\'t available on the web.';

  @override
  String get shareCollectionPickPrompt =>
      'Choose the collection you want to share.';

  @override
  String get shareCollectionNone => 'You don\'t have any collections yet.';

  @override
  String get shareMoviePickPrompt => 'Choose a film or show to share.';

  @override
  String get shareDiaryPickPrompt => 'Tick the records you want in this post.';

  @override
  String get shareNoRecords => 'You haven\'t logged anything yet.';

  @override
  String get shareContinue => 'Continue';

  @override
  String get shareSubmit => 'Share';

  @override
  String get shareComposeMovieHint => 'What did you make of it?';

  @override
  String get shareComposeDiaryHint => 'Say something about this diary...';

  @override
  String get shareComposeCollectionHint =>
      'Say something about this collection...';

  @override
  String get shareSignInRequired => 'Please sign in first.';

  @override
  String get shareSucceeded => 'Shared.';

  @override
  String get shareFailed => 'Couldn\'t share that. Please try again.';

  @override
  String get sharedCollectionTitle => 'Collection';

  @override
  String get sharedCollectionUnshared => 'This collection is no longer shared';

  @override
  String get sharedCollectionEmpty =>
      'There is nothing in this collection yet.';

  @override
  String get sharedCollectionLoadFailed => 'Couldn\'t load the collection.';

  @override
  String get publicDiaryEmpty => 'Nothing has been shared.';

  @override
  String userSearchNoMatch(String query) {
    return 'No users match \"$query\".';
  }

  @override
  String userFollowerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
    );
    return '$_temp0';
  }

  @override
  String communityDiaryEntriesLink(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles · see the diary',
      one: '1 title · see the diary',
    );
    return '$_temp0';
  }

  @override
  String shareEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records will be shared',
      one: '1 record will be shared',
    );
    return '$_temp0';
  }

  @override
  String get graphTitle => 'Connections';

  @override
  String get graphLoading => 'Analysing connections…';

  @override
  String get graphLoadFailed =>
      'Couldn\'t load the connections. Check your internet and try again.';

  @override
  String get graphEmptyTitle => 'Your graph is empty';

  @override
  String get graphEmptyBody =>
      'Add two titles that share an actor or director to your diary, and the hidden links between them start appearing here on their own.';

  @override
  String get graphNoPathFound => 'No connection found between those two.';

  @override
  String get graphPositionsReset =>
      'Node positions reset to the automatic layout.';

  @override
  String get graphProfileLookupFailed =>
      'Something went wrong looking up that profile.';

  @override
  String get graphClusterUnconnected => 'Unconnected';

  @override
  String get graphNodeMovie => 'Film';

  @override
  String get graphNodeShow => 'Show';

  @override
  String get graphNodeActor => 'Actor';

  @override
  String get graphNodeDirector => 'Director';

  @override
  String get graphNodeWriter => 'Writer';

  @override
  String get graphNodeProducer => 'Producer';

  @override
  String get graphNodeCompany => 'Studio';

  @override
  String get graphNodeGenre => 'Genre';

  @override
  String get graphFilterActors => 'Actors';

  @override
  String get graphFilterDirectors => 'Directors';

  @override
  String get graphDepthLeads => 'Leads';

  @override
  String get graphDepthFeatured => 'Featured';

  @override
  String get graphDepthFullCast => 'Full cast';

  @override
  String get graphCastDepth => 'Cast depth';

  @override
  String get graphSearch => 'Search';

  @override
  String get graphSearchHint => 'Search…';

  @override
  String get graphSearchInGraphHint => 'Search the graph…';

  @override
  String get graphFindConnection => 'Find a connection';

  @override
  String get graphResetPositions => 'Reset positions';

  @override
  String get graphFitToScreen => 'Fit to screen';

  @override
  String get graphAddPerson => 'Add Person';

  @override
  String get graphAddPersonHint => 'Actor or director name…';

  @override
  String get graphAddPersonRole => 'Role:';

  @override
  String get graphAddPersonSearchPrompt => 'Start typing to search.';

  @override
  String get graphHideFromGraph => 'Hide from Graph';

  @override
  String get graphOpenDetail => 'Open detail';

  @override
  String get graphOpenProfile => 'Open profile';

  @override
  String get graphWhyConnected => 'Why connected?';

  @override
  String get graphWhyConnectedTitle => 'Why Connected?';

  @override
  String get graphRemoveConnection => 'Remove this connection';

  @override
  String get graphDiscoverRecommendations => 'Discover (Recommendations)';

  @override
  String get graphInsightsTitle => 'Insights';

  @override
  String graphInsightMostCentral(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Most central: $name ($count titles)',
      one: 'Most central: $name (1 title)',
    );
    return '$_temp0';
  }

  @override
  String get pathFinderTitle => 'Find the Path';

  @override
  String get pathFinderHeader => 'Find a Bridge (Six Degrees)';

  @override
  String get pathFinderExplain =>
      'Finds the shortest chain of shared actors or directors between any two titles or people.';

  @override
  String get discoverRecommendationsFailed =>
      'Couldn\'t load the recommendations.';

  @override
  String get discoverSubtitle =>
      'What you\'ve watched, and what you shouldn\'t miss';

  @override
  String discoverWatchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles in your library',
      one: '1 title in your library',
    );
    return '$_temp0';
  }

  @override
  String get discoverAllWatched =>
      'You\'ve already watched every one of this actor\'s headline projects. Nicely done! 🎉';

  @override
  String get cineDnaTitle => 'CineDNA';

  @override
  String cineDnaAnchorSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Connects $count titles in your library.',
      one: 'Connects 1 title in your library.',
    );
    return '$_temp0';
  }

  @override
  String get cineDnaPersonaAuteurTitle => 'Director-Driven';

  @override
  String get cineDnaPersonaAuteurDescription =>
      'You follow your favourite directors\' filmographies all the way through.';

  @override
  String get cineDnaPersonaActorHunterTitle => 'Actor Follower';

  @override
  String get cineDnaPersonaActorHunterDescription =>
      'You find new titles by following the actors you love.';

  @override
  String get cineDnaPersonaFranchiseTitle => 'Universe Explorer';

  @override
  String get cineDnaPersonaFranchiseDescription =>
      'You finish sequels and cinematic universes to the last entry.';

  @override
  String get cineDnaPersonaCriticTitle => 'Selective Critic';

  @override
  String get cineDnaPersonaCriticDescription =>
      'Your average rating is high — only the best makes it into your library.';

  @override
  String get cineTwinTitle => 'CineTwin Match';

  @override
  String get cineTwinYou => 'You';

  @override
  String get cineTwinMatchLabel => 'MATCH';

  @override
  String get cineTwinNotEnoughData =>
      'There isn\'t enough watch data yet to work out a match.';

  @override
  String get cineTwinSharedTitles => 'Shared';

  @override
  String get cineTwinRatingGap => 'Rating Gap';

  @override
  String get cineTwinSharedRecommendation => 'Shared Pick';

  @override
  String get cineTwinShareCard => 'Share Match Card';

  @override
  String get cineTwinWhatToWatch => 'What Should You Watch Together Tonight?';

  @override
  String cineTwinCopied(int percentage) {
    return 'CineTwin match ($percentage%) copied to your clipboard.';
  }

  @override
  String get cineTwinBadgeSoulmatesTitle => 'Cinematic Soulmates';

  @override
  String get cineTwinBadgeSoulmatesDescription =>
      'Your taste and your ratings line up almost perfectly.';

  @override
  String get cineTwinBadgeBuddiesTitle => 'Ticket Buddies';

  @override
  String get cineTwinBadgeBuddiesDescription =>
      'A strong match — you\'d have great film nights together.';

  @override
  String get cineTwinBadgeGenreMatchTitle => 'Genre Siblings';

  @override
  String get cineTwinBadgeGenreMatchDescription =>
      'You enjoy the same kinds of titles.';

  @override
  String get cineTwinBadgeComplementsTitle => 'Opposite Tastes';

  @override
  String get cineTwinBadgeComplementsDescription =>
      'A nice balance — you\'d each broaden the other\'s watchlist.';

  @override
  String get cineTwinBadgeOppositesTitle => 'Different Worlds';

  @override
  String get cineTwinBadgeOppositesDescription =>
      'Your tastes differ a lot, or there isn\'t enough shared data yet.';

  @override
  String cineTwinReasonRated(String name, String rating) {
    return '$name rated this $rating';
  }

  @override
  String cineTwinReasonRatedHighly(String name) {
    return '$name rated this highly';
  }

  @override
  String graphClusterNamed(String name) {
    return '$name cluster';
  }

  @override
  String graphPathFound(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: 'Connected in $steps steps',
      one: 'Connected in 1 step',
    );
    return '$_temp0';
  }

  @override
  String graphSearchingProfile(String name) {
    return 'Looking up $name…';
  }

  @override
  String graphProfileNotFound(String name) {
    return 'No profile found for $name.';
  }

  @override
  String graphSummary(int titles, int people) {
    return '$titles titles · $people bridges';
  }

  @override
  String graphInsightBiggestCluster(String name) {
    return ' · biggest: $name';
  }

  @override
  String graphInsightStrongestPair(String a, String b, int weight) {
    return 'Strongest link: $a ↔ $b ($weight)';
  }

  @override
  String graphConnectedByPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linked by $count shared people',
      one: 'Linked by 1 shared person',
    );
    return '$_temp0';
  }

  @override
  String graphConnectsTitles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Connects $count titles',
      one: 'Connects 1 title',
    );
    return '$_temp0';
  }

  @override
  String graphSharedPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared people',
      one: '1 shared person',
    );
    return '$_temp0';
  }

  @override
  String graphPersonAdded(String name, String title) {
    return '$name was added to \"$title\".';
  }

  @override
  String graphAddPersonPrompt(String title) {
    return 'Search for someone to link to \"$title\".';
  }

  @override
  String graphExplainDirector(String person, String title) {
    return '$person directed $title.';
  }

  @override
  String graphExplainActor(String person, String title) {
    return '$person appears in the cast of $title.';
  }

  @override
  String get pathFinderStart => '1. Start (title or person)';

  @override
  String get pathFinderTarget => '2. Target (title or person)';

  @override
  String discoverEngineTitle(String name) {
    return '$name — Discovery';
  }

  @override
  String get discoverUnwatchedPopular => '⭐ Popular Titles You Haven\'t Seen';

  @override
  String get cineDnaBackbone => '👑 The Backbone of Your Library';

  @override
  String get cineDnaTotalTitles => '🎬 Total Titles';

  @override
  String get cineDnaConnectionNetwork => '🔗 Connection Network';

  @override
  String get cineDnaTopBridges => '🌉 Strongest Bridges';

  @override
  String cineDnaConnectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count connections',
      one: '1 connection',
    );
    return '$_temp0';
  }

  @override
  String get cineTwinSharedFavorites => '❤️ Titles You Both Love';

  @override
  String get cineTwinBigDisputes => '⚡ Where You Disagree Most';

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navDiary => 'Diary';

  @override
  String get navCommunity => 'Community';

  @override
  String get navGraph => 'Graph';

  @override
  String get homeGreetingMorning => 'Good morning, ☀️';

  @override
  String get homeGreetingDay => 'Hello, 👋';

  @override
  String get homeGreetingEvening => 'Good evening, 🌙';

  @override
  String get homeGreetingNight => 'Good night, 🌌';

  @override
  String get homeRecentlyAdded => 'Recently Added';

  @override
  String get homeNothingAdded =>
      'You haven\'t added anything to your library yet.';

  @override
  String get homeSeeAll => 'See All';

  @override
  String get homeHeroLastWatched => 'LAST WATCHED';

  @override
  String get homeHeroWhatToWatch => 'WHAT TO WATCH THIS WEEK?';

  @override
  String get homeHeroMovieBadge => 'FILM';

  @override
  String get homeHeroShowBadge => 'SHOW';

  @override
  String get homeHeroDetails => 'See Details';

  @override
  String get homeContinueWatching => 'CONTINUE WATCHING';

  @override
  String get homeContinue => 'Continue';

  @override
  String homeNextEpisode(int episode) {
    return 'Up next: episode $episode';
  }

  @override
  String homeNextEpisodeOf(int episode, int total) {
    return 'Up next: episode $episode of $total';
  }

  @override
  String get homeStatsHeader => 'SUMMARY & STATS';

  @override
  String get homeStatsTotalWatches => 'Total Watches';

  @override
  String get homeStatsTitlesUnit => 'titles';

  @override
  String get homeStatsAverageRating => 'Average Rating';

  @override
  String get homeStatsWeeklyGoal => 'Weekly Goal';

  @override
  String get homeStatsWeeklyGoalCaps => 'WEEKLY GOAL';

  @override
  String get homeStatsGoalDoneCaps => 'GOAL MET';

  @override
  String get homeStatsAddFirst => 'Add your first watch to get started.';

  @override
  String get homeStatsGoalReached => 'You hit this week\'s goal. Nice one! 🎉';

  @override
  String homeStatsGoalRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more this week to hit your goal.',
      one: '1 more this week to hit your goal.',
    );
    return '$_temp0';
  }

  @override
  String get activelyWatchingTitle => 'Currently Watching';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get homeAddOneEpisode => '+1 episode';

  @override
  String episodeOf(int episode, int total) {
    return 'Episode $episode of $total';
  }

  @override
  String episodeSingle(int episode) {
    return 'Episode $episode';
  }

  @override
  String get datePickerTitle => 'Pick a Date';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get tierLocked => 'Locked';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String badgeTierLevel(String symbol, String tier, int current, int max) {
    return '$symbol $tier (level $current/$max)';
  }

  @override
  String achievementsCategoryCount(String category, int count) {
    return '$category ($count)';
  }

  @override
  String get insightsEmptyBody =>
      'Add at least one watch record to your diary and your charts and statistics will start filling in.';

  @override
  String achievementsShowing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Showing $count achievements',
      one: 'Showing 1 achievement',
    );
    return '$_temp0';
  }

  @override
  String get badgeLockedLabel => '🔒 Locked';

  @override
  String badgeCurrentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String badgeNextTier(int remaining, String tier) {
    return '$remaining more ➔ reach \"$tier\"!';
  }

  @override
  String badgeCopied(String title) {
    return '\"$title\" copied to your clipboard — share it wherever you like.';
  }

  @override
  String heatmapYearTotal(int year, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count watches in $year',
      one: '1 watch in $year',
    );
    return '$_temp0';
  }

  @override
  String heatmapEpisodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get insightsBadgesTitle => '🏆 Achievements & Badges';

  @override
  String insightsBadgesEarned(int unlocked, int total) {
    return '$unlocked / $total earned';
  }

  @override
  String get insightsTopTagsTitle => '🏷️ Most-Used Tags';

  @override
  String insightsDistinctTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count distinct tags',
      one: '1 distinct tag',
    );
    return '$_temp0';
  }

  @override
  String insightsWatchesWithPercent(int count, String percent) {
    return '$count watches ($percent%)';
  }

  @override
  String get insightsSeasonalTitle => '📅 By Season';

  @override
  String get insightsSeasonWinterLong => '❄️ Winter (Dec–Feb)';

  @override
  String get insightsSeasonSpringLong => '🌱 Spring (Mar–May)';

  @override
  String get insightsSeasonSummerLong => '☀️ Summer (Jun–Aug)';

  @override
  String get insightsSeasonAutumnLong => '🍂 Autumn (Sep–Nov)';

  @override
  String get weeklyGoalTitle => '🎯 Weekly Watch Goal';

  @override
  String weeklyGoalProgress(int count, int goal) {
    return 'You have watched $count this week. (Goal: $goal)';
  }

  @override
  String weeklyGoalItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
    );
    return '$_temp0';
  }

  @override
  String get timeVisualizerTitle => '🍿 What Else Could You Have Done?';

  @override
  String get timeVisualizerFooter =>
      'Watching things is a great use of it though. 🎬';

  @override
  String timeCompareLotr(String n) {
    return 'You could have watched the Lord of the Rings Extended Trilogy back to back $n times!';
  }

  @override
  String timeCompareFlight(String n) {
    return 'That\'s $n return flights between London and New York!';
  }

  @override
  String timeCompareBreakingBad(String n) {
    return 'You could have marathoned all of Breaking Bad $n times over!';
  }

  @override
  String timeCompareWalk(String n) {
    return 'You could have walked the length of Great Britain $n times without stopping!';
  }

  @override
  String timeCompareBooks(String n) {
    return 'At eight hours a book, that\'s $n books finished!';
  }

  @override
  String timeCompareFood(String n) {
    return 'You could have eaten $n slices of pizza back to back. Enjoy!';
  }

  @override
  String timeCompareIss(String n) {
    return 'The ISS would have orbited Earth $n times in that time!';
  }

  @override
  String timeCompareLight(String n) {
    return 'Light would have travelled $n million kilometres through space!';
  }

  @override
  String timeCompareMinecraft(String n) {
    return 'You could have placed $n blocks in Minecraft without a break!';
  }

  @override
  String timeCompareCoffee(String n) {
    return 'You could have had $n cups of coffee with friends!';
  }

  @override
  String timeCompareMusic(String n) {
    return 'That\'s $n songs from your favourite playlist!';
  }

  @override
  String timeCompareMonopoly(String n) {
    return 'You could have played $n games of Monopoly that felt like they\'d never end!';
  }

  @override
  String timeCompareSleep(String n) {
    return 'That\'s $n full, undisturbed nights of sleep!';
  }

  @override
  String timeCompareHair(String n) {
    return 'Your hair would have grown $n millimetres in that time!';
  }

  @override
  String timeCompareCells(String n) {
    return 'Your body made $n million new cells while you sat there!';
  }

  @override
  String timeCompareOrbit(String n) {
    return 'Earth travelled $n thousand kilometres around the sun in that time!';
  }

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

  @override
  String get onboardingTitleWelcome => 'Welcome to CineFile';

  @override
  String get onboardingSubtitleWelcome =>
      'Get started by customizing your movie diary and preferences.';

  @override
  String get onboardingStepPreferences => '1. Preferences';

  @override
  String get onboardingStepFavorites => '2. Initial Favorites';

  @override
  String get onboardingStepTour => '3. Features & Privacy';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingFinish => 'Start Using CineFile';

  @override
  String get onboardingFavoritesSubtitle =>
      'Search and add a few titles you\'ve watched or love to your favorites.';

  @override
  String get onboardingFavoritesSearchHint => 'Search movie or TV show...';

  @override
  String get onboardingFeature1Title => 'Multi-Watch & Season Tracking';

  @override
  String get onboardingFeature1Desc =>
      'Record rewatches separately. Advance TV episodes with a single tap.';

  @override
  String get onboardingFeature2Title => 'Insights & Badges';

  @override
  String get onboardingFeature2Desc =>
      'Discover your GitHub-style heatmap, rating distribution, and top actors.';

  @override
  String get onboardingFeature3Title => 'Privacy First';

  @override
  String get onboardingFeature3Desc =>
      'Your diary is private by default. Export as JSON anytime or share with community optionally.';

  @override
  String get settingsRerunOnboarding => 'Run Onboarding Tour';

  @override
  String get journalAddFirstRecordCTA => 'Add Your First Record';

  @override
  String get journalClearFiltersCTA => 'Clear Filters';

  @override
  String get collectionAddMoviesCTA => 'Add Titles';

  @override
  String get communityFollowingEmptyHint =>
      'Users you follow haven\'t shared watch records yet. Discover new friends!';

  @override
  String get checklistTitle => 'Welcome! Getting Started Guide';

  @override
  String checklistProgress(int completed, int total) {
    return '$completed/$total Completed';
  }

  @override
  String get checklistStep1 => 'Set your watch region and language';

  @override
  String get checklistStep2 => 'Add your first watch record';

  @override
  String get checklistStep3 => 'Mark your first favorite title';

  @override
  String get checklistStep4 => 'Create a collection or follow a friend';

  @override
  String get quickActionTitle => 'Quick Actions';

  @override
  String get quickActionAddRecord => 'Add Watch Record';

  @override
  String get quickActionToggleFavorite => 'Toggle Favorite';

  @override
  String get quickActionViewDetail => 'View Details';

  @override
  String get errorOfflineTitle => 'You\'re Offline';

  @override
  String get errorOfflineSubtitle =>
      'Your watch records are saved safely on device. They will sync with community when online.';

  @override
  String get errorGenericTitle => 'Something Went Wrong';

  @override
  String get errorRetryCTA => 'Try Again';

  @override
  String get privacyCenterTitle => 'Privacy Center';

  @override
  String get privacyCenterSubtitle =>
      'Transparently see where your data is stored and managed.';

  @override
  String get privacyLocalSection => 'Local Data (On-Device)';

  @override
  String get privacyLocalDesc =>
      'Your diary, ratings and notes are stored locally in your SQLite database. Accessible offline.';

  @override
  String get privacyCloudSection => 'Cloud Sync';

  @override
  String get privacyCloudDesc =>
      'Favorites and profile settings sync securely across your devices via Firebase Firestore.';

  @override
  String get privacyPublicSection => 'Community & Privacy Model';

  @override
  String get privacyPublicDesc =>
      'All records are PRIVATE by default. Only posts you explicitly share are visible in community.';

  @override
  String get privacyExportCTA => 'Export My Data as JSON';

  @override
  String get wrappedTitle => 'CineFile Wrapped';

  @override
  String get wrappedIntro => 'Your Cinema Journey';

  @override
  String get wrappedTotalTime => 'Total Watch Time';

  @override
  String wrappedTotalHours(int hours) {
    return '$hours Hours';
  }

  @override
  String get wrappedTopGenres => 'Top Watched Genres';

  @override
  String get wrappedTopDirector => 'Favorite Director';

  @override
  String get wrappedTopActor => 'Favorite Actor';

  @override
  String get wrappedShareCTA => 'Share Summary Card';

  @override
  String get wrappedPostCommunity => 'Share with Community';

  @override
  String get wrappedCopiedToast => 'Summary text copied to clipboard!';

  @override
  String get insightsFilterAllYears => 'All Years';

  @override
  String get insightsFilterAllTypes => 'All Titles';

  @override
  String get insightsFilterMoviesOnly => 'Movies Only';

  @override
  String get insightsFilterTvOnly => 'TV Shows Only';

  @override
  String get privacyDeleteAccountCTA => 'Purge All My Data from Device';

  @override
  String get privacyDeleteConfirmTitle => 'Delete All Data';

  @override
  String get privacyDeleteConfirmDesc =>
      'All watch logs, notes, and local data on this device will be permanently wiped. This action cannot be undone.';
}
