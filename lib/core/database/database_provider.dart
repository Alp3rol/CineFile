import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/journal/models/diary_log_model.dart';
import 'app_database.dart';
import 'movie_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// TMDb movie IDs and TV show IDs come from separate counters, so a movie and
// a show can legitimately share the same numeric tmdbId. Every place that
// used to key by tmdbId alone now keys by this (tmdbId, isTv) pair instead —
// otherwise adding one silently overwrites/aliases the other (see
// tables.dart's Movies.primaryKey comment for the full story).
typedef MovieKey = ({int tmdbId, bool isTv});

// --- IN-MEMORY PROVIDERS FOR WEB COMPATIBILITY ---
// Since sql.js is not loaded on Flutter Web without hosting setup,
// we use in-memory Riverpod lists to simulate database operations on Web.
final webWatchRecordsProvider = StateProvider<List<WatchRecord>>((ref) => []);
final webMovieSettingsProvider = StateProvider<Map<MovieKey, UserMovieSetting>>((ref) => {});
final webMoviesProvider = StateProvider<Map<MovieKey, Movie>>((ref) => {});

// Stream provider to get watch records for a specific movie
final watchRecordsForMovieProvider = StreamProvider.family<List<WatchRecord>, MovieKey>((ref, key) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<WatchRecord>[]);
  }

  return ref.read(firestoreProvider)
      .collection('logs')
      .where('userId', isEqualTo: user.uid)
      .where('movieId', isEqualTo: key.tmdbId)
      .where('isTv', isEqualTo: key.isTv)
      .snapshots()
      .map((snapshot) {
        final logs = snapshot.docs.map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id)).toList();
        // Sort descending by watchDate
        logs.sort((a, b) => b.watchDate.compareTo(a.watchDate));
        return logs.map((log) => log.toWatchRecordWithMovie().record).toList();
      });
});

// Stream provider to get settings for a specific movie
final movieSettingsProvider = StreamProvider.family<UserMovieSetting?, MovieKey>((ref, key) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(null);
  }

  return ref.read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('movie_settings')
      .doc('${key.tmdbId}_${key.isTv}')
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data()!;
        return UserMovieSetting(
          tmdbId: key.tmdbId,
          isTv: key.isTv,
          isFavorite: data['isFavorite'] ?? false,
          isReWatchList: data['isReWatchList'] ?? false,
          personalRanking: data['personalRanking'] as int?,
          personalNotes: data['personalNotes'] as String?,
          personalTags: data['personalTags'] as String?,
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActivelyWatching: data['isActivelyWatching'] ?? false,
          lastWatchedEpisode: data['lastWatchedEpisode'] as int?,
        );
      });
});

// Model to represent a Watch Record joined with its Movie metadata and settings
class WatchRecordWithMovie {
  final WatchRecord record;
  final Movie movie;
  final UserMovieSetting? setting;
  WatchRecordWithMovie(this.record, this.movie, {this.setting});
}

// Stream provider to get watch records for any user with movie details
final watchRecordsForUserProvider = StreamProvider.family<List<WatchRecordWithMovie>, String>((ref, userId) {
  return ref.read(firestoreProvider)
      .collection('logs')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .asyncMap((snapshot) async {
        final logs = snapshot.docs.map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id)).toList();
        // Sort descending by watchDate
        logs.sort((a, b) => b.watchDate.compareTo(a.watchDate));
        
        final list = <WatchRecordWithMovie>[];
        for (final log in logs) {
          final key = (tmdbId: log.movieId, isTv: log.isTv);
          
          // Get settings from Firestore
          final settingsDoc = await ref.read(firestoreProvider)
              .collection('users')
              .doc(userId)
              .collection('movie_settings')
              .doc('${key.tmdbId}_${key.isTv}')
              .get();
              
          UserMovieSetting? setting;
          if (settingsDoc.exists) {
            final data = settingsDoc.data()!;
            setting = UserMovieSetting(
              tmdbId: key.tmdbId,
              isTv: key.isTv,
              isFavorite: data['isFavorite'] ?? false,
              isReWatchList: data['isReWatchList'] ?? false,
              personalRanking: data['personalRanking'] as int?,
              personalNotes: data['personalNotes'] as String?,
              personalTags: data['personalTags'] as String?,
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isActivelyWatching: data['isActivelyWatching'] ?? false,
              lastWatchedEpisode: data['lastWatchedEpisode'] as int?,
            );
          }
          
          final wRecord = log.toWatchRecordWithMovie();
          list.add(WatchRecordWithMovie(wRecord.record, wRecord.movie, setting: setting));
        }
        return list;
      });
});

// Stream provider to get all watch records with movie details (current logged in user)
final allWatchRecordsProvider = StreamProvider<List<WatchRecordWithMovie>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<WatchRecordWithMovie>[]);
  }

  return ref.read(firestoreProvider)
      .collection('logs')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .asyncMap((snapshot) async {
        final logs = snapshot.docs.map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id)).toList();
        // Sort descending by watchDate
        logs.sort((a, b) => b.watchDate.compareTo(a.watchDate));
        
        final list = <WatchRecordWithMovie>[];
        for (final log in logs) {
          final key = (tmdbId: log.movieId, isTv: log.isTv);
          
          // Get settings from Firestore
          final settingsDoc = await ref.read(firestoreProvider)
              .collection('users')
              .doc(user.uid)
              .collection('movie_settings')
              .doc('${key.tmdbId}_${key.isTv}')
              .get();
              
          UserMovieSetting? setting;
          if (settingsDoc.exists) {
            final data = settingsDoc.data()!;
            setting = UserMovieSetting(
              tmdbId: key.tmdbId,
              isTv: key.isTv,
              isFavorite: data['isFavorite'] ?? false,
              isReWatchList: data['isReWatchList'] ?? false,
              personalRanking: data['personalRanking'] as int?,
              personalNotes: data['personalNotes'] as String?,
              personalTags: data['personalTags'] as String?,
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isActivelyWatching: data['isActivelyWatching'] ?? false,
              lastWatchedEpisode: data['lastWatchedEpisode'] as int?,
            );
          }
          
          final wRecord = log.toWatchRecordWithMovie();
          list.add(WatchRecordWithMovie(wRecord.record, wRecord.movie, setting: setting));
        }
        return list;
      });
});

// Stream provider to get all followed user IDs for the current user
final followedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<String>{});
  }

  return ref.read(firestoreProvider)
      .collection('follows')
      .where('followerId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()['followingId'] as String).toSet();
      });
});

// Stream provider to check if a specific user is followed by the current user
final isFollowingProvider = StreamProvider.family<bool, String>((ref, targetUserId) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(false);
  }

  return ref.read(firestoreProvider)
      .collection('follows')
      .doc('${user.uid}_$targetUserId')
      .snapshots()
      .map((doc) => doc.exists);
});

// Stream provider to get a set of favorite movie IDs
final favoriteMovieIdsProvider = StreamProvider<Set<MovieKey>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<MovieKey>{});
  }

  return ref.read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('movie_settings')
      .where('isFavorite', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final movieId = data['movieId'] as int? ?? 0;
          final isTv = data['isTv'] as bool? ?? false;
          return (tmdbId: movieId, isTv: isTv);
        }).toSet();
      });
});

// Stream provider for the most recently added movies (by Movie.createdAt),
// used by the Home screen's "Son Eklediklerim" section.
final recentlyAddedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  return watchRecordsAsync.when(
    loading: () => Stream.value(<Movie>[]),
    error: (err, stack) => Stream.value(<Movie>[]),
    data: (records) {
      final seenKeys = <MovieKey>{};
      final movies = <Movie>[];
      for (final r in records) {
        final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
        if (seenKeys.add(key)) {
          movies.add(r.movie);
        }
      }
      return Stream.value(movies.take(10).toList());
    },
  );
});

// Stream provider for movies that have been added to the library but have
// no WatchRecords entry yet, used by the Home screen's "Bu Hafta Ne
// İzlesem?" suggestion card.
final unwatchedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  return watchRecordsAsync.when(
    loading: () => Stream.value(<Movie>[]),
    error: (err, stack) => Stream.value(<Movie>[]),
    data: (records) {
      final watchedKeys = records.map((r) => (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv)).toSet();

      if (kIsWeb) {
        final movies = ref.watch(webMoviesProvider);
        return Stream.value(movies.values.where((m) => !watchedKeys.contains((tmdbId: m.tmdbId, isTv: m.isTv))).toList());
      }

      final db = ref.watch(databaseProvider);
      final query = db.select(db.movies).join([
        leftOuterJoin(
          db.watchRecords,
          db.watchRecords.movieId.equalsExp(db.movies.tmdbId) & db.watchRecords.isTv.equalsExp(db.movies.isTv),
        ),
      ])
        ..where(db.watchRecords.id.isNull());

      return query.watch().map((rows) {
        final list = rows.map((row) => row.readTable(db.movies)).toList();
        return list.where((m) => !watchedKeys.contains((tmdbId: m.tmdbId, isTv: m.isTv))).toList();
      });
    },
  );
});

// A TV show the user is currently tracking episode-by-episode (see
// UserMovieSettings.isActivelyWatching), used by the Home/Journal "Aktif
// İzlediklerin" quick-add sections.
class ActivelyWatchingShow {
  final Movie movie;
  final UserMovieSetting setting;
  ActivelyWatchingShow(this.movie, this.setting);
}

final activelyWatchingProvider = StreamProvider<List<ActivelyWatchingShow>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<ActivelyWatchingShow>[]);
  }

  return ref.read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('movie_settings')
      .where('isActivelyWatching', isEqualTo: true)
      .snapshots()
      .asyncMap((snapshot) async {
        final list = <ActivelyWatchingShow>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final movieId = data['movieId'] as int? ?? 0;
          final isTv = data['isTv'] as bool? ?? false;
          
          final logSnapshot = await ref.read(firestoreProvider)
              .collection('logs')
              .where('userId', isEqualTo: user.uid)
              .where('movieId', isEqualTo: movieId)
              .where('isTv', isEqualTo: isTv)
              .limit(1)
              .get();
              
          if (logSnapshot.docs.isNotEmpty) {
            final log = DiaryLogModel.fromMap(logSnapshot.docs.first.data(), logSnapshot.docs.first.id);
            final watchWithMovie = log.toWatchRecordWithMovie();
            
            final setting = UserMovieSetting(
              tmdbId: movieId,
              isTv: isTv,
              isFavorite: data['isFavorite'] ?? false,
              isReWatchList: data['isReWatchList'] ?? false,
              personalRanking: data['personalRanking'] as int?,
              personalNotes: data['personalNotes'] as String?,
              personalTags: data['personalTags'] as String?,
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isActivelyWatching: true,
              lastWatchedEpisode: data['lastWatchedEpisode'] as int?,
            );
            
            list.add(ActivelyWatchingShow(watchWithMovie.movie, setting));
          }
        }
        return list;
      });
});

// --- CUSTOM LISTS PROVIDERS AND ACTIONS ---

// Web in-memory lists state
final webCustomListsProvider = StateProvider<Map<int, CustomList>>((ref) => {});
final webCustomListMoviesProvider = StateProvider<List<CustomListMovie>>((ref) => []);

// Stream provider to get all custom lists
final customListsProvider = StreamProvider<List<CustomList>>((ref) {
  if (kIsWeb) {
    final map = ref.watch(webCustomListsProvider);
    final sorted = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(sorted);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.customLists)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
});

class CustomListMovieWithMovie {
  final CustomListMovie relation;
  final Movie movie;
  CustomListMovieWithMovie(this.relation, this.movie);
}

// Stream provider to get movies in a specific list, ordered by rankingOrder or addedAt
final moviesInCustomListProvider = StreamProvider.family<List<CustomListMovieWithMovie>, int>((ref, listId) {
  if (kIsWeb) {
    final list = ref.watch(webCustomListMoviesProvider);
    final movies = ref.watch(webMoviesProvider);
    
    final filtered = list.where((r) => r.listId == listId).map((r) {
      final movie = movies[(tmdbId: r.movieId, isTv: r.isTv)] ?? Movie(
        tmdbId: r.movieId,
        title: 'Bilinmeyen Film',
        isTv: r.isTv,
        createdAt: DateTime.now(),
      );
      return CustomListMovieWithMovie(r, movie);
    }).toList();
    
    // Sort: if rankingOrder is not null, sort by it, otherwise sort by addedAt descending
    filtered.sort((a, b) {
      final rA = a.relation.rankingOrder;
      final rB = b.relation.rankingOrder;
      if (rA != null && rB != null) {
        return rA.compareTo(rB);
      } else if (rA != null) {
        return -1;
      } else if (rB != null) {
        return 1;
      } else {
        return b.relation.addedAt.compareTo(a.relation.addedAt);
      }
    });
    return Stream.value(filtered);
  }

  final db = ref.watch(databaseProvider);
  final query = db.select(db.customListMovies).join([
    leftOuterJoin(
      db.movies,
      db.movies.tmdbId.equalsExp(db.customListMovies.movieId) &
          db.movies.isTv.equalsExp(db.customListMovies.isTv),
    ),
  ])..where(db.customListMovies.listId.equals(listId));

  // Order: first by rankingOrder (ascending), then addedAt (descending)
  query.orderBy([
    OrderingTerm.asc(db.customListMovies.rankingOrder),
    OrderingTerm.desc(db.customListMovies.addedAt),
  ]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return CustomListMovieWithMovie(
        row.readTable(db.customListMovies),
        row.readTable(db.movies),
      );
    }).toList();
  });
});

// Stream provider to find which lists a movie belongs to
final listsForMovieProvider = StreamProvider.family<Set<int>, MovieKey>((ref, key) {
  if (kIsWeb) {
    final list = ref.watch(webCustomListMoviesProvider);
    return Stream.value(
        list.where((r) => r.movieId == key.tmdbId && r.isTv == key.isTv).map((r) => r.listId).toSet());
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.customListMovies)
        ..where((t) => t.movieId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
      .watch()
      .map((list) => list.map((e) => e.listId).toSet());
});

// --- CUSTOM LIST ACTIONS ---
//
// These delegate to movieRepositoryProvider (see movie_repository.dart),
// which picks the native (Drift/SQLite) or web (in-memory) implementation.
// Kept as free functions so existing call sites don't need to change.

Future<void> createCustomList(WidgetRef ref, String name, String? description, {DateTime? targetDate}) =>
    ref.read(movieRepositoryProvider).createCustomList(name, description, targetDate: targetDate);

Future<void> updateCustomList(
  WidgetRef ref,
  int id,
  String name,
  String? description, {
  DateTime? targetDate,
  bool clearTargetDate = false,
}) =>
    ref.read(movieRepositoryProvider).updateCustomList(
          id,
          name,
          description,
          targetDate: targetDate,
          clearTargetDate: clearTargetDate,
        );

Future<void> deleteCustomList(WidgetRef ref, int id) =>
    ref.read(movieRepositoryProvider).deleteCustomList(id);

Future<void> addMovieToCustomList(WidgetRef ref, int listId, Movie movieData) =>
    ref.read(movieRepositoryProvider).addMovieToCustomList(listId, movieData);

Future<void> removeMovieFromCustomList(WidgetRef ref, int listId, int tmdbId, bool isTv) =>
    ref.read(movieRepositoryProvider).removeMovieFromCustomList(listId, tmdbId, isTv);

Future<void> reorderCustomListMovies(WidgetRef ref, int listId, Map<MovieKey, int> rankings) =>
    ref.read(movieRepositoryProvider).reorderCustomListMovies(listId, rankings);

// --- WATCH RECORD ACTIONS ---

Future<void> deleteWatchRecord(WidgetRef ref, WatchRecord record) async {
  final recordId = record.id;
  final authState = ref.read(authStateProvider);
  final user = authState.value;

  if (user != null) {
    final query = await ref.read(firestoreProvider)
        .collection('logs')
        .where('userId', isEqualTo: user.uid)
        .where('movieId', isEqualTo: record.movieId)
        .where('isTv', isEqualTo: record.isTv)
        .get();

    bool deleted = false;
    for (final doc in query.docs) {
      final data = doc.data();
      final docWatchDate = (data['watchDate'] as Timestamp?)?.toDate();
      
      final isHashCodeMatch = doc.id.hashCode == recordId;
      final isExactMatch = docWatchDate != null && 
          docWatchDate.isAtSameMomentAs(record.watchDate) &&
          data['watchNumber'] == record.watchNumber &&
          data['episodeCount'] == record.episodeCount;
          
      if (isHashCodeMatch || isExactMatch) {
        await doc.reference.delete();
        deleted = true;
        break;
      }
    }
    
    if (!deleted) {
      throw Exception('Firestore üzerinde silinecek eşleşen kayıt bulunamadı. (Sorgulanan film ID: ${record.movieId}, Log sayısı: ${query.docs.length})');
    }

    // Recalculate movie settings progress for this user & movie/show in Firestore
    final remainingQuery = await ref.read(firestoreProvider)
        .collection('logs')
        .where('userId', isEqualTo: user.uid)
        .where('movieId', isEqualTo: record.movieId)
        .where('isTv', isEqualTo: record.isTv)
        .get();

    final settingsRef = ref.read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${record.movieId}_${record.isTv}');

    if (remainingQuery.docs.isEmpty) {
      await settingsRef.set({
        'isActivelyWatching': false,
        'lastWatchedEpisode': null,
      }, SetOptions(merge: true));
    } else {
      final remainingLogs = remainingQuery.docs.map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id)).toList();
      remainingLogs.sort((a, b) => b.watchDate.compareTo(a.watchDate));
      
      final latestLog = remainingLogs.first;
      final latestWatchNumber = latestLog.watchNumber;
      
      final currentEpisodeProgress = remainingLogs
          .where((log) => log.watchNumber == latestWatchNumber)
          .fold<int>(0, (acc, log) => acc + log.episodeCount);
          
      final totalEpisodes = latestLog.totalEpisodes;
      final newIsActivelyWatching = totalEpisodes == null || currentEpisodeProgress < totalEpisodes;

      await settingsRef.set({
        'isActivelyWatching': newIsActivelyWatching,
        'lastWatchedEpisode': currentEpisodeProgress,
      }, SetOptions(merge: true));
    }
    return;
  }

  if (kIsWeb) {
    final notifier = ref.read(webWatchRecordsProvider.notifier);
    final currentList = ref.read(webWatchRecordsProvider);
    notifier.state = currentList.where((r) => r.id != recordId).toList();
    return;
  }
  
  final db = ref.read(databaseProvider);
  await (db.delete(db.watchRecords)..where((t) => t.id.equals(recordId))).go();

  // Recalculate Drift settings progress
  final remainingRecords = await (db.select(db.watchRecords)
    ..where((t) => t.movieId.equals(record.movieId) & t.isTv.equals(record.isTv))
    ..orderBy([(t) => OrderingTerm.desc(t.watchDate)]))
    .get();

  final settingsQuery = db.select(db.userMovieSettings)
    ..where((t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv));
  final existingSetting = await settingsQuery.getSingleOrNull();

  if (existingSetting != null) {
    if (remainingRecords.isEmpty) {
      await db.into(db.userMovieSettings).insertOnConflictUpdate(
        existingSetting.copyWith(
          isActivelyWatching: false,
          lastWatchedEpisode: const Value(null),
        ),
      );
    } else {
      final latestRecord = remainingRecords.first;
      final latestWatchNumber = latestRecord.watchNumber;
      
      final currentEpisodeProgress = remainingRecords
          .where((r) => r.watchNumber == latestWatchNumber)
          .fold<int>(0, (acc, r) => acc + r.episodeCount);

      final movieQuery = db.select(db.movies)
        ..where((t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv));
      final movie = await movieQuery.getSingleOrNull();
      final totalEpisodes = movie?.totalEpisodes;
      
      final newIsActivelyWatching = totalEpisodes == null || currentEpisodeProgress < totalEpisodes;

      await db.into(db.userMovieSettings).insertOnConflictUpdate(
        existingSetting.copyWith(
          isActivelyWatching: newIsActivelyWatching,
          lastWatchedEpisode: Value(currentEpisodeProgress),
        ),
      );
    }
  }
}

Future<void> updateWatchRecord(
  WidgetRef ref,
  WatchRecord record, {
  DateTime? watchDate,
  int? episodeCount,
}) async {
  final recordId = record.id;
  final authState = ref.read(authStateProvider);
  final user = authState.value;

  if (user != null) {
    final query = await ref.read(firestoreProvider)
        .collection('logs')
        .where('userId', isEqualTo: user.uid)
        .where('movieId', isEqualTo: record.movieId)
        .where('isTv', isEqualTo: record.isTv)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final docWatchDate = (data['watchDate'] as Timestamp?)?.toDate();
      
      final isHashCodeMatch = doc.id.hashCode == recordId;
      final isExactMatch = docWatchDate != null && 
          docWatchDate.isAtSameMomentAs(record.watchDate) &&
          data['watchNumber'] == record.watchNumber &&
          data['episodeCount'] == record.episodeCount;

      if (isHashCodeMatch || isExactMatch) {
        final updates = <String, dynamic>{};
        if (watchDate != null) {
          updates['watchDate'] = Timestamp.fromDate(watchDate);
        }
        if (episodeCount != null) {
          updates['episodeCount'] = episodeCount;
        }

        if (updates.isNotEmpty) {
          await doc.reference.update(updates);
        }
        break;
      }
    }
    return;
  }

  if (kIsWeb) {
    final notifier = ref.read(webWatchRecordsProvider.notifier);
    final currentList = ref.read(webWatchRecordsProvider);
    notifier.state = currentList.map((r) {
      if (r.id == recordId) {
        return WatchRecord(
          id: r.id,
          movieId: r.movieId,
          isTv: r.isTv,
          watchDate: watchDate ?? r.watchDate,
          watchPlace: r.watchPlace,
          watchCompanion: r.watchCompanion,
          rating: r.rating,
          mood: r.mood,
          notes: r.notes,
          watchNumber: r.watchNumber,
          tags: r.tags,
          createdAt: r.createdAt,
          episodeCount: episodeCount ?? r.episodeCount,
        );
      }
      return r;
    }).toList();
    return;
  }

  final db = ref.read(databaseProvider);
  await (db.update(db.watchRecords)..where((t) => t.id.equals(recordId))).write(
    WatchRecordsCompanion(
      watchDate: watchDate != null ? Value(watchDate) : const Value.absent(),
      episodeCount: episodeCount != null ? Value(episodeCount) : const Value.absent(),
    ),
  );
}
