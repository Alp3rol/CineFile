// Basic smoke test: verifies the app boots and shows its bottom navigation.
// The app now gates its main shell behind Firebase Auth (AuthGate) — a
// signed-out user sees the login screen instead, so this needs a mocked
// signed-in user to reach the bottom nav at all.
import 'package:flutter/widgets.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/recommendations/presentation/recommendations_provider.dart';
import 'package:cinefile/main.dart';

void main() {
  testWidgets('App boots and shows bottom navigation tabs', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('test-uid').set({
      'id': 'test-uid',
      'email': 'test@test.com',
      'username': 'tester',
      // avatarUrl intentionally omitted (null) — a non-null value (even
      // empty string) makes UserProfileAvatarButton attempt a NetworkImage,
      // which has no real network to resolve against in tests.
    });

    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 retries a failed provider automatically (10 attempts,
        // 200ms→6.4s backoff). Any provider on the boot path that fails for
        // lack of a real network therefore leaves a retry Timer pending when
        // this test's short pumps finish, tripping flutter_test's "Timer is
        // still pending" teardown assertion. Retrying is the right behaviour
        // in the app and stays on there; it just has no place in a test.
        retry: (retryCount, error) => null,
        overrides: [
          firebaseAuthProvider
              .overrideWithValue(MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid', email: 'test@test.com'))),
          firestoreProvider.overrideWithValue(firestore),
          // HomeScreen's HomeRecommendationsList triggers a real TMDb fetch
          // via recommendationsProvider on first build. That request goes
          // through DioClient's custom connectionFactory (dio_client.dart),
          // which schedules Socket.connect timeout Timers a couple seconds
          // out — still pending when this test's short pumps finish below,
          // tripping flutter_test's "Timer is still pending" teardown
          // assertion. Short-circuiting the provider itself (rather than
          // just the network layer) avoids Dio/Socket timer scheduling
          // entirely instead of racing it.
          recommendationsProvider.overrideWith((ref) async => const []),
          // MyApp waits on Firebase.initializeApp before mounting AuthGate;
          // there is no real Firebase in a widget test, so report "ready"
          // immediately and let the mocked auth/firestore above stand in.
          firebaseInitProvider.overrideWith((ref) async {}),
        ],
        child: const MyApp(),
      ),
    );
    // Not pumpAndSettle: network images with no real network in tests keep
    // retrying and never "settle". Discrete pumps instead, enough for each
    // async gate in the boot path to resolve in turn: MaterialApp's
    // localizations, then firebaseInitProvider, then the auth stream and the
    // Firestore user-doc fetch behind AuthGate.
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.text('Ana Sayfa'), findsOneWidget);
    // Settings moved off the bottom nav (into the home header); the 5th tab is
    // now the İlişki Ağı ("Ağ") graph.
    expect(find.text('Ağ'), findsOneWidget);

    // Tear the tree down inside the test body. Disposing the ProviderScope
    // cancels the Drift query streams behind the local database providers, and
    // Drift closes those out on a zero-duration Timer — harmless, but if the
    // teardown flutter_test does after this body runs it, the timer is still
    // pending when the "no pending timers" invariant is checked. Unmounting
    // here leaves a pump to flush it.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
