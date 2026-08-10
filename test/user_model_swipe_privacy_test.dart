import 'package:cinefile/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('swipe taste sharing is private by default', () {
    final user = UserModel.fromMap({'username': 'alice'}, 'user-1');

    expect(user.shareSwipeTasteForMatching, isFalse);
    expect(user.publicSwipeTasteGenreIds, isEmpty);
  });

  test('reads and writes only the public aggregate genre summary', () {
    final user = UserModel.fromMap({
      'username': 'alice',
      'shareSwipeTasteForMatching': true,
      'publicSwipeTasteGenreIds': [878, 18, 35],
    }, 'user-1');

    expect(user.shareSwipeTasteForMatching, isTrue);
    expect(user.publicSwipeTasteGenreIds, [878, 18, 35]);
    expect(user.toMap()['publicSwipeTasteGenreIds'], [878, 18, 35]);
    expect(user.toMap(), isNot(contains('swipeDecision')));
  });
}
