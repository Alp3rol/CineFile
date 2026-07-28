import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/journal/models/diary_log_model.dart';
import 'movie_repository.dart';

/// Whole-account JSON backup and restore, behind Settings → "Veri Yönetimi &
/// Yedekleme".
///
/// A user's data lives in two places, and a backup has to span both:
///
///  * **Firestore** — watch records (`logs`) and per-title settings
///    (`users/{uid}/movie_settings`). This is where everything a signed-in
///    user actually creates ends up; the diary sheet writes there directly.
///  * **Local (Drift on native, in-memory on web)** — custom collections and
///    the cached title metadata they reference.
///
/// Previously this only read the local side, which for a signed-in user meant
/// the exported file contained collections and *no watch history at all* —
/// while the UI promised "tüm izleme geçmişiniz". The Drift `watch_records` /
/// `user_movie_settings` tables are never written on the signed-in path, so
/// they were always empty. Restoring such a file put rows into tables nothing
/// reads, so it silently appeared to do nothing.
///
/// `ref` stays `dynamic` (not `WidgetRef`) because tests call this with a bare
/// `ProviderContainer`, which also exposes a compatible `.read()`.
class BackupService {
  BackupService._();

  /// Bumped from 1 to 2 when the cloud sections (`logs`, `movie_settings`)
  /// were added. Version 1 files still restore — they simply carry no cloud
  /// data, which [importData] treats as "leave the cloud side alone" rather
  /// than "wipe it".
  static const int currentVersion = 2;

  static Future<Map<String, dynamic>> exportData(dynamic ref) async {
    final data = await ref.read(movieRepositoryProvider).exportBackupData()
        as Map<String, dynamic>;
    data['version'] = currentVersion;

    // currentUser, not authStateProvider: the latter is a StreamProvider whose
    // value is still null until its first emission, so a backup triggered
    // right after launch would silently skip the cloud half.
    final user = (ref.read(firebaseAuthProvider) as FirebaseAuth).currentUser;
    if (user == null) return data;

    final firestore = ref.read(firestoreProvider) as FirebaseFirestore;

    final logsSnapshot =
        await firestore.collection('logs').where('userId', isEqualTo: user.uid).get();
    data['logs'] = logsSnapshot.docs.map((doc) {
      final log = DiaryLogModel.fromMap(doc.data(), doc.id);
      return _logToJson(log);
    }).toList();

    final settingsSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .get();
    data['movie_settings'] = settingsSnapshot.docs.map((doc) {
      final d = doc.data();
      return {
        ...d,
        // Timestamps aren't JSON-encodable; normalise to ISO-8601 strings,
        // which _settingsFromJson turns back into Timestamps on restore.
        'updatedAt': _isoOrNull(d['updatedAt']),
        'lastEpisodeProgressAt': _isoOrNull(d['lastEpisodeProgressAt']),
      };
    }).toList();

    return data;
  }

  static Future<void> importData(dynamic ref, Map<String, dynamic> json) async {
    // Local side first: collections and cached title metadata.
    await ref.read(movieRepositoryProvider).importBackupData(json);

    // currentUser, not authStateProvider: the latter is a StreamProvider whose
    // value is still null until its first emission, so a backup triggered
    // right after launch would silently skip the cloud half.
    final user = (ref.read(firebaseAuthProvider) as FirebaseAuth).currentUser;
    if (user == null) return;

    final logs = json['logs'] as List<dynamic>?;
    final settings = json['movie_settings'] as List<dynamic>?;
    // A v1 file has neither section. Deleting the user's cloud history
    // because an old backup didn't contain it would be the worst possible
    // reading of "restore", so treat absent as "don't touch".
    if (logs == null && settings == null) return;

    final firestore = ref.read(firestoreProvider) as FirebaseFirestore;

    if (logs != null) {
      final existing =
          await firestore.collection('logs').where('userId', isEqualTo: user.uid).get();
      await _commitInChunks(firestore, [
        for (final doc in existing.docs) (ref: doc.reference, data: null),
        for (final entry in logs.whereType<Map<String, dynamic>>())
          // New document ids on purpose: the backup may have been taken from a
          // different account, and reusing its ids would collide with, or
          // silently overwrite, logs that belong to someone else.
          (
            ref: firestore.collection('logs').doc(),
            data: _logFromJson(entry, user.uid),
          ),
      ]);
    }

    if (settings != null) {
      final settingsCol =
          firestore.collection('users').doc(user.uid).collection('movie_settings');

      // Settings ids are deterministic ("{tmdbId}_{isTv}"), so unlike logs the
      // incoming documents overlap the existing ones. Overwrite those in place
      // and delete only what the backup doesn't mention — issuing a delete and
      // a set for the same document id in one batch would depend on
      // within-batch ordering to land on the right final state.
      final incoming = <String, Map<String, dynamic>>{};
      for (final entry in settings.whereType<Map<String, dynamic>>()) {
        final id = _settingsDocId(entry);
        if (id != null) incoming[id] = _settingsFromJson(entry);
      }

      final existing = await settingsCol.get();
      await _commitInChunks(firestore, [
        for (final doc in existing.docs)
          if (!incoming.containsKey(doc.id)) (ref: doc.reference, data: null),
        for (final entry in incoming.entries)
          (ref: settingsCol.doc(entry.key), data: entry.value),
      ]);
    }
  }

  // --- helpers ---

  /// Firestore rejects a batch with more than 500 writes, and a restore can
  /// easily exceed that (delete + recreate of a few hundred logs), so the
  /// operations are committed in chunks rather than as one batch.
  static Future<void> _commitInChunks(
    FirebaseFirestore firestore,
    List<({DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic>? data})> ops,
  ) async {
    const chunkSize = 400;
    for (var i = 0; i < ops.length; i += chunkSize) {
      final batch = firestore.batch();
      for (final op in ops.skip(i).take(chunkSize)) {
        if (op.data == null) {
          batch.delete(op.ref);
        } else {
          batch.set(op.ref, op.data!);
        }
      }
      await batch.commit();
    }
  }

  static String? _isoOrNull(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    return null;
  }

  static Timestamp _timestampFrom(Object? value, {DateTime? fallback}) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    return Timestamp.fromDate(parsed ?? fallback ?? DateTime.now());
  }

  static Map<String, dynamic> _logToJson(DiaryLogModel log) {
    final map = log.toMap();
    return {
      ...map,
      'watchDate': log.watchDate.toIso8601String(),
      'createdAt': log.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _logFromJson(Map<String, dynamic> entry, String uid) {
    return {
      ...entry,
      // The restoring account owns the restored rows, whoever the file came
      // from — otherwise firestore.rules rejects the write outright.
      'userId': uid,
      'watchDate': _timestampFrom(entry['watchDate']),
      'createdAt': _timestampFrom(entry['createdAt']),
      // Social state belongs to the original posting, not to a restored copy.
      'starredBy': <String>[],
      'commentCount': 0,
      'isPublic': entry['isPublic'] == true,
    }..remove('id');
  }

  static String? _settingsDocId(Map<String, dynamic> entry) {
    final movieId = entry['movieId'];
    if (movieId is! num) return null;
    final isTv = entry['isTv'] == true;
    return '${movieId.toInt()}_$isTv';
  }

  static Map<String, dynamic> _settingsFromJson(Map<String, dynamic> entry) {
    return {
      ...entry,
      'updatedAt': _timestampFrom(entry['updatedAt']),
      if (entry['lastEpisodeProgressAt'] != null)
        'lastEpisodeProgressAt': _timestampFrom(entry['lastEpisodeProgressAt']),
    };
  }
}
