// Basic smoke test: verifies the app boots and shows its bottom navigation.
// The app now gates its main shell behind Firebase Auth (AuthGate) — a
// signed-out user sees the login screen instead, so this needs a mocked
// signed-in user to reach the bottom nav at all.
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/recommendations/presentation/recommendations_provider.dart';
import 'package:filmdizi/main.dart';

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
        ],
        child: const MyApp(),
      ),
    );
    // Not pumpAndSettle: network images with no real network in tests keep
    // retrying and never "settle". A couple of discrete pumps is enough for
    // the auth stream + Firestore user doc fetch to resolve and swap the
    // AuthGate's loading spinner for the real app.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
