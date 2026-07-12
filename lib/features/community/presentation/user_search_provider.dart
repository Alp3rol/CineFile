import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';

final userSearchQueryProvider = StateProvider<String>((ref) => '');

// Firestore has no case-insensitive/substring search, only single-field range
// queries (which are auto-indexed, unlike composite equality+orderBy queries).
// This does a case-insensitive prefix match against the `usernameLower`
// field written alongside `username` at sign-up (see AuthController.signUp),
// rather than `username` itself - a search for "sukoo" must find "Suko35".
final userSearchResultsProvider = StreamProvider<List<UserModel>>((ref) {
  final query = ref.watch(userSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) {
    return Stream.value(const <UserModel>[]);
  }

  final currentUserId = ref.watch(authStateProvider).value?.uid;
  // U+F8FF sorts after virtually any real-world character, so bounding the
  // range with it turns "starts at `query`" into "starts with `query`".
  // Spelled out via fromCharCode rather than a literal glyph so it stays
  // unambiguous in source (it's a Private Use Area code point with no
  // visible rendering in most editors/terminals).
  final prefixEnd = query + String.fromCharCode(0xF8FF);

  return ref
      .read(firestoreProvider)
      .collection('users')
      .orderBy('usernameLower')
      .startAt([query])
      .endAt([prefixEnd])
      .limit(20)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .where((user) => user.id != currentUserId)
            .toList();
      });
});
