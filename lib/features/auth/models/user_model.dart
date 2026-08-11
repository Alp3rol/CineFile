// Public profile document (`users/{uid}`). Every field here is world-readable
// by any signed-in user — the Community feed, user search and profile screens
// all read other people's docs — so NOTHING private may live in this model.
//
// In particular there is deliberately no `email` field: it used to be stored
// here, which made every user's address readable by anyone (the collection is
// read-open so search/profiles work). The address is already in Firebase Auth
// where only its owner can see it, and nothing in the app ever displays
// somebody else's — the places that need a display-name fallback derive it
// from FirebaseAuth's own `User.email` for the *current* user only.
class UserModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final List<String> featuredMovieIds;
  final bool shareSwipeTasteForMatching;
  final List<int> publicSwipeTasteGenreIds;
  // Null identifies profiles created before account-scoped onboarding was
  // introduced. Those users must not be forced through onboarding again.
  final bool? onboardingCompleted;

  UserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.featuredMovieIds = const [],
    this.shareSwipeTasteForMatching = false,
    this.publicSwipeTasteGenreIds = const [],
    this.onboardingCompleted,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'],
      bio: map['bio'],
      followerCount: map['followerCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      featuredMovieIds: List<String>.from(map['featuredMovieIds'] ?? []),
      shareSwipeTasteForMatching: map['shareSwipeTasteForMatching'] == true,
      publicSwipeTasteGenreIds:
          (map['publicSwipeTasteGenreIds'] as List<dynamic>? ?? const [])
              .whereType<num>()
              .map((id) => id.toInt())
              .toList(growable: false),
      onboardingCompleted: map['onboardingCompleted'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'featuredMovieIds': featuredMovieIds,
      'shareSwipeTasteForMatching': shareSwipeTasteForMatching,
      'publicSwipeTasteGenreIds': publicSwipeTasteGenreIds,
    };
    if (onboardingCompleted != null) {
      map['onboardingCompleted'] = onboardingCompleted;
    }
    return map;
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? bio,
    int? followerCount,
    int? followingCount,
    List<String>? featuredMovieIds,
    bool? shareSwipeTasteForMatching,
    List<int>? publicSwipeTasteGenreIds,
    bool? onboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      featuredMovieIds: featuredMovieIds ?? this.featuredMovieIds,
      shareSwipeTasteForMatching:
          shareSwipeTasteForMatching ?? this.shareSwipeTasteForMatching,
      publicSwipeTasteGenreIds:
          publicSwipeTasteGenreIds ?? this.publicSwipeTasteGenreIds,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
