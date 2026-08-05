import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/backup_repository.dart';
import 'package:cinefile/core/database/backup_service.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _webBackupRepositoryProvider = Provider<WebBackupRepository>(
  WebBackupRepository.new,
);

void main() {
  test('rejects a backup larger than the limit before JSON parsing', () {
    final oversized =
        '{"version":2,"padding":"${'x' * BackupService.maxImportBytes}"}';

    expect(
      () => BackupService.decodeImportPayload(oversized),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('rejects a section with the wrong top-level type', () {
    expect(
      () => BackupService.decodeImportPayload('{"version":2,"movies":{}}'),
      throwsA(
        isA<BackupFormatException>().having(
          (error) => error.message,
          'message',
          contains('movies'),
        ),
      ),
    );
  });

  test('malformed fields fail before existing web state is replaced', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final existing = Movie(
      tmdbId: 1,
      title: 'Existing',
      isTv: false,
      createdAt: DateTime(2026, 8, 5),
    );
    container.read(webMoviesProvider.notifier).state = {
      (tmdbId: 1, isTv: false): existing,
    };

    await expectLater(
      container.read(_webBackupRepositoryProvider).importBackupData({
        'movies': [
          {'tmdbId': 'not-an-int', 'title': 'Broken'},
        ],
      }),
      throwsA(isA<BackupFormatException>()),
    );
    expect(container.read(webMoviesProvider).values.single, same(existing));
  });

  test(
    'partial backup restores present sections and preserves absent ones',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final existingList = CustomList(
        id: 7,
        name: 'Keep me',
        createdAt: DateTime(2026, 8, 5),
        isPublic: false,
      );
      container.read(webCustomListsProvider.notifier).state = {7: existingList};

      await container.read(_webBackupRepositoryProvider).importBackupData({
        'movies': [
          {
            'tmdbId': 27205,
            'title': 'Inception',
            'isTv': false,
            'createdAt': DateTime(2026, 8, 5).millisecondsSinceEpoch,
          },
          'safe-to-skip-scalar-entry',
        ],
      });

      expect(
        container.read(webMoviesProvider).values.single.title,
        'Inception',
      );
      expect(container.read(webCustomListsProvider)[7], same(existingList));
    },
  );
}
