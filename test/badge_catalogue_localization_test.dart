// The 28-badge catalogue is the largest block of copy in the app — 28 series
// titles, 86 tier titles and 26 parameterized descriptions. It is assembled in
// insightsProvider rather than a widget, so it resolves its language through
// the context-free lookup; this pins that it actually follows localeProvider
// and that no badge slipped through untranslated.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/insights/domain/achievement_models.dart';
import 'package:cinefile/features/insights/presentation/insights_provider.dart';
import 'package:cinefile/features/settings/presentation/settings_provider.dart';
import 'support/riverpod_async.dart';

WatchRecordWithMovie _record(int id) {
  return WatchRecordWithMovie(
    WatchRecord(
      id: id,
      movieId: id,
      isTv: false,
      watchDate: DateTime(2026, 1, id),
      rating: 8,
      watchNumber: 1,
      createdAt: DateTime.now(),
      episodeCount: 1,
      isPublic: false,
    ),
    Movie(tmdbId: id, title: 'Movie $id', isTv: false, createdAt: DateTime.now()),
  );
}

Future<List<AchievementBadge>> _badgesIn(Locale locale) async {
  final container = ProviderContainer(overrides: [
    allWatchRecordsProvider.overrideWith((ref) => Stream.value([_record(1), _record(2)])),
    allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
  ]);
  addTearDown(container.dispose);

  await container.read(localeProvider.notifier).setLocale(locale);
  await readAsync(container, allWatchRecordsProvider.future);
  await readAsync(container, allMovieSettingsProvider.future);

  return container.read(insightsProvider)!.achievementBadges;
}

void main() {
  // setLocale persists through AppSettingsStore, which reaches for a platform
  // channel. Without a binding that throws and gets logged on every call —
  // harmless, but it buries the actual test output.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every badge is localized, in both languages', () async {
    final tr = await _badgesIn(const Locale('tr'));
    final en = await _badgesIn(const Locale('en'));

    expect(tr, hasLength(28));
    expect(en, hasLength(28));

    // Same badges in the same order, keyed by their stable ids.
    expect(en.map((b) => b.id).toList(), tr.map((b) => b.id).toList());

    for (var i = 0; i < tr.length; i++) {
      expect(tr[i].title, isNotEmpty, reason: 'tr title for ${tr[i].id}');
      expect(en[i].title, isNotEmpty, reason: 'en title for ${en[i].id}');
      expect(tr[i].description, isNotEmpty, reason: 'tr description for ${tr[i].id}');
      expect(en[i].description, isNotEmpty, reason: 'en description for ${en[i].id}');
    }
  });

  test('badge copy actually differs between the two languages', () async {
    final tr = await _badgesIn(const Locale('tr'));
    final en = await _badgesIn(const Locale('en'));

    // A handful of series titles are deliberately identical across languages
    // (proper nouns like "Tarantino"), so this asserts on the whole set rather
    // than every entry: a badge left hardcoded would show up as a much larger
    // overlap than the few names that legitimately match.
    final identical = [
      for (var i = 0; i < tr.length; i++)
        if (tr[i].title == en[i].title) tr[i].id,
    ];
    expect(identical.length, lessThan(5), reason: 'untranslated titles: $identical');

    expect(tr.first.description, isNot(en.first.description));
  });

  test('descriptions carry their target number', () async {
    final en = await _badgesIn(const Locale('en'));
    final sinefil = en.firstWhere((b) => b.id == 'sinefil_series');

    // The number is data, interpolated into the message — not part of the
    // translated text.
    expect(sinefil.description, contains('10'));
  });
}
