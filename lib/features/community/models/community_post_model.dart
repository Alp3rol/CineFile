import 'package:cloud_firestore/cloud_firestore.dart';

// A community feed post. Three kinds today:
//   - 'movie': a snapshot of ONE diary entry the user chose to share, plus
//     their caption. The movie fields below are copied from the source log
//     at share time — NOT a live reference — so later edits to that diary
//     entry don't retroactively change an already-published post.
//   - 'diary_snapshot': a frozen copy of several diary entries the user
//     picked in one go ("Günlüğünü Paylaş"). `entries` is captured once at
//     share time and never updated afterward, by design: adding new movies
//     to the diary later must not alter a post that already went out.
//   - 'collection': unlike the two above, this is deliberately LIVE, not a
//     snapshot — `collectionRefId` points at a shared_collections/{id} doc
//     (see database_provider.dart's sharedCollectionProvider /
//     movie_repository.dart's _mirrorSharedCollection) that keeps updating
//     as the owner edits their collection. The post itself only carries the
//     caption and the reference; nothing collection-specific is embedded.
class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String type; // 'movie' | 'diary_snapshot'
  final String caption;
  final DateTime createdAt;
  final List<String> starredBy;
  final int commentCount;

  // 'movie' type only.
  final int? movieId;
  final bool? isTv;
  final String? movieTitle;
  final String? moviePosterPath;
  final int? releaseYear;
  final double? rating;
  final String? mood;
  final DateTime? watchDate;

  // 'diary_snapshot' type only. Each entry:
  // {movieId, isTv, movieTitle, moviePosterPath, rating, watchDate}
  final List<Map<String, dynamic>> entries;

  // 'collection' type only — see class doc comment above.
  final String? collectionRefId;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.type,
    required this.caption,
    required this.createdAt,
    required this.starredBy,
    required this.commentCount,
    this.movieId,
    this.isTv,
    this.movieTitle,
    this.moviePosterPath,
    this.releaseYear,
    this.rating,
    this.mood,
    this.watchDate,
    this.entries = const [],
    this.collectionRefId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'type': type,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'starredBy': starredBy,
      'commentCount': commentCount,
      'movieId': movieId,
      'isTv': isTv,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'releaseYear': releaseYear,
      'rating': rating,
      'mood': mood,
      'watchDate': watchDate != null ? Timestamp.fromDate(watchDate!) : null,
      'entries': entries
          .map((e) => {
                ...e,
                'watchDate': e['watchDate'] is DateTime ? Timestamp.fromDate(e['watchDate'] as DateTime) : e['watchDate'],
              })
          .toList(),
      'collectionRefId': collectionRefId,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map, String docId) {
    return CommunityPost(
      id: docId,
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? '',
      userAvatarUrl: map['userAvatarUrl'] as String? ?? '',
      type: map['type'] as String? ?? 'movie',
      caption: map['caption'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      starredBy: List<String>.from(map['starredBy'] ?? []),
      commentCount: map['commentCount'] as int? ?? 0,
      movieId: map['movieId'] as int?,
      isTv: map['isTv'] as bool?,
      movieTitle: map['movieTitle'] as String?,
      moviePosterPath: map['moviePosterPath'] as String?,
      releaseYear: map['releaseYear'] as int?,
      rating: (map['rating'] as num?)?.toDouble(),
      mood: map['mood'] as String?,
      watchDate: (map['watchDate'] as Timestamp?)?.toDate(),
      entries: (map['entries'] as List<dynamic>? ?? [])
          .map((e) {
            final entry = Map<String, dynamic>.from(e as Map);
            final ts = entry['watchDate'];
            if (ts is Timestamp) entry['watchDate'] = ts.toDate();
            return entry;
          })
          .toList(),
      collectionRefId: map['collectionRefId'] as String?,
    );
  }
}
