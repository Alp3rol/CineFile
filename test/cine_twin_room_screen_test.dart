import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/community/presentation/cine_twin_room_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'support/localized_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('renders CineTwinRoomScreen when signed in', (tester) async {
    final mockUser = MockUser(uid: 'user-1', displayName: 'Alice');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
        child: const LocalizedTestApp(
          locale: Locale('tr'),
          home: CineTwinRoomScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CineTwin Odası'), findsNWidgets(2)); // in AppBar and banner card
    expect(find.text('Bir Arkadaş Seç'), findsWidgets);
  });
}
