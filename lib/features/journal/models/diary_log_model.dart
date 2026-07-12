import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

class DiaryLogModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  
  // Movie details
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final String? movieBackdropPath;
  final int? releaseYear;
  final int? runtime;
  final String? genres;
  final String? director;
  final String? actors;
  final String? overview;
  final bool isTv;
  final int? totalEpisodes;

  // Log details
  final DateTime watchDate;
  final String? watchPlace;
  final String? watchCompanion;
  final double rating;
  final String mood;
  final String? notes;
  final int watchNumber;
  final String? tags;
  final int episodeCount;
  final DateTime createdAt;

  // Social
  final List<String> starredBy;
  final int commentCount;
  final bool isPublic;

  DiaryLogModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    this.movieBackdropPath,
    this.releaseYear,
    this.runtime,
    this.genres,
    this.director,
    this.actors,
    this.overview,
    required this.isTv,
    this.totalEpisodes,
    required this.watchDate,
    this.watchPlace,
    this.watchCompanion,
    required this.rating,
    required this.mood,
    this.notes,
    required this.watchNumber,
    this.tags,
    required this.episodeCount,
    required this.createdAt,
    required this.starredBy,
    required this.commentCount,
    required this.isPublic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'movieBackdropPath': movieBackdropPath,
      'movieReleaseYear': releaseYear,
      'movieRuntime': runtime,
      'movieGenres': genres,
      'movieDirector': director,
      'movieActors': actors,
      'movieOverview': overview,
      'isTv': isTv,
      'movieTotalEpisodes': totalEpisodes,
      'watchDate': Timestamp.fromDate(watchDate),
      'watchPlace': watchPlace,
      'watchCompanion': watchCompanion,
      'rating': rating,
      'mood': mood,
      'notes': notes,
      'watchNumber': watchNumber,
      'tags': tags,
      'episodeCount': episodeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'starredBy': starredBy,
      'commentCount': commentCount,
      'isPublic': isPublic,
    };
  }

  factory DiaryLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return DiaryLogModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? '',
      userAvatarUrl: map['userAvatarUrl'] as String? ?? '',
      movieId: map['movieId'] as int? ?? 0,
      movieTitle: map['movieTitle'] as String? ?? '',
      moviePosterPath: map['moviePosterPath'] as String?,
      movieBackdropPath: map['movieBackdropPath'] as String?,
      releaseYear: (map['movieReleaseYear'] ?? map['releaseYear']) as int?,
      runtime: (map['movieRuntime'] ?? map['runtime']) as int?,
      genres: (map['movieGenres'] ?? map['genres']) as String?,
      director: (map['movieDirector'] ?? map['director']) as String?,
      actors: (map['movieActors'] ?? map['actors']) as String?,
      overview: (map['movieOverview'] ?? map['overview']) as String?,
      isTv: map['isTv'] as bool? ?? false,
      totalEpisodes: (map['movieTotalEpisodes'] ?? map['totalEpisodes']) as int?,
      watchDate: (map['watchDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      watchPlace: map['watchPlace'] as String?,
      watchCompanion: map['watchCompanion'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      mood: map['mood'] as String? ?? '🍿',
      notes: map['notes'] as String?,
      watchNumber: map['watchNumber'] as int? ?? 1,
      tags: map['tags'] as String?,
      episodeCount: map['episodeCount'] as int? ?? 1,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      starredBy: List<String>.from(map['starredBy'] ?? []),
      commentCount: map['commentCount'] as int? ?? 0,
      isPublic: map['isPublic'] as bool? ?? false,
    );
  }

  WatchRecordWithMovie toWatchRecordWithMovie() {
    final record = WatchRecord(
      id: id.hashCode, // Convert String ID to int ID for UI compatibility
      movieId: movieId,
      isTv: isTv,
      watchDate: watchDate,
      watchPlace: watchPlace,
      watchCompanion: watchCompanion,
      rating: rating,
      mood: mood,
      notes: notes,
      watchNumber: watchNumber,
      tags: tags,
      createdAt: createdAt,
      episodeCount: episodeCount,
      isPublic: isPublic,
    );

    final movie = Movie(
      tmdbId: movieId,
      title: movieTitle,
      originalTitle: movieTitle,
      posterPath: moviePosterPath,
      backdropPath: movieBackdropPath,
      releaseYear: releaseYear,
      runtime: runtime,
      genres: genres,
      director: director,
      actors: actors,
      overview: overview,
      isTv: isTv,
      createdAt: createdAt,
      totalEpisodes: totalEpisodes,
    );

    return WatchRecordWithMovie(record, movie);
  }
}
