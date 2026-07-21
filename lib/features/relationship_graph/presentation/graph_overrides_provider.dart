import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../domain/graph_models.dart';
import '../domain/graph_overrides.dart';

/// Doc id for the single global "hidden people" document (distinct from the
/// per-title `${tmdbId}_${isTv}` ids).
const String _kGlobalDocId = '__global__';

String _titleId(int tmdbId, bool isTv) => 'title:$tmdbId:$isTv';

/// Streams the current user's graph curation from
/// `users/{uid}/graph_overrides/*` (mirrors [allMovieSettingsProvider]).
/// Empty for guests — the graph itself is empty for them anyway.
final graphOverridesProvider = StreamProvider<GraphOverrides>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(GraphOverrides.empty);
  return ref
      .read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('graph_overrides')
      .snapshots()
      .map(_overridesFromSnapshot);
});

GraphOverrides _overridesFromSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
  final perTitle = <String, TitleOverride>{};
  final hidden = <String>{};
  for (final doc in snap.docs) {
    final data = doc.data();
    if (doc.id == _kGlobalDocId) {
      hidden.addAll(
          (data['hiddenPersonKeys'] as List<dynamic>? ?? const []).cast<String>());
      continue;
    }
    final movieId = data['movieId'] as int?;
    final isTv = data['isTv'] as bool?;
    if (movieId == null || isTv == null) continue;
    final added = (data['addedPeople'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CreditPerson.fromMap)
        .toList();
    final removed =
        (data['removedPersonKeys'] as List<dynamic>? ?? const []).cast<String>().toSet();
    perTitle[_titleId(movieId, isTv)] =
        TitleOverride(added: added, removedKeys: removed);
  }
  return GraphOverrides(perTitle: perTitle, hiddenKeys: hidden);
}

final graphOverridesControllerProvider =
    Provider<GraphOverridesController>((ref) => GraphOverridesController(ref));

/// Writes graph curation directly to Firestore (signed-in only, like the
/// movie_settings write path). No-ops for guests.
class GraphOverridesController {
  final Ref _ref;
  GraphOverridesController(this._ref);

  CollectionReference<Map<String, dynamic>>? _collection() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return null;
    return _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('graph_overrides');
  }

  Future<void> addPersonToTitle(int tmdbId, bool isTv, CreditPerson person) async {
    final col = _collection();
    if (col == null) return;
    await col.doc('${tmdbId}_$isTv').set({
      'movieId': tmdbId,
      'isTv': isTv,
      'addedPeople': FieldValue.arrayUnion([person.toMap()]),
      // If it was previously removed from this title, un-remove it.
      'removedPersonKeys': FieldValue.arrayRemove([personKey(person)]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removePersonFromTitle(int tmdbId, bool isTv, String key) async {
    final col = _collection();
    if (col == null) return;
    await col.doc('${tmdbId}_$isTv').set({
      'movieId': tmdbId,
      'isTv': isTv,
      'removedPersonKeys': FieldValue.arrayUnion([key]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> hidePerson(String key) async {
    final col = _collection();
    if (col == null) return;
    await col.doc(_kGlobalDocId).set({
      'hiddenPersonKeys': FieldValue.arrayUnion([key]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> unhidePerson(String key) async {
    final col = _collection();
    if (col == null) return;
    await col.doc(_kGlobalDocId).set({
      'hiddenPersonKeys': FieldValue.arrayRemove([key]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
