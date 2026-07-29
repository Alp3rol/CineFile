// Fails if a Turkish string literal has crept back into a feature that has
// already been localized.
//
// Every localized slice was a one-time sweep; nothing stops the next screen
// from hardcoding its text again, and by the time anyone notices there is
// another sweep to do. This is the check that keeps that from happening.
//
// Run locally with:
//   dart run tool/check_localized.dart
//
// Detection is deliberately crude — a string literal containing a character
// that only appears in Turkish. It cannot catch a Turkish string that happens
// to be pure ASCII ("Ayarlar", "Tercihler"), so it is a backstop, not a proof.
// Reviewing the diff is still the real check.
import 'dart:io';

/// Features whose strings have been moved to ARB. Anything under these paths
/// must stay clean. Add a directory here the moment its slice lands.
const _localizedPaths = <String>[
  'lib/core/database',
  'lib/core/l10n',
  'lib/core/widgets',
  'lib/core/navigation',
  'lib/core/network',
  'lib/core/platform',
  'lib/core/services',
  'lib/core/theme',
  'lib/core/utils',
  'lib/features/auth',
  'lib/features/community',
  'lib/features/home',
  'lib/features/insights',
  'lib/features/journal',
  'lib/features/movie_detail',
  'lib/features/recommendations',
  'lib/features/relationship_graph',
  'lib/features/search',
  'lib/features/settings',
];

/// Single files that are localized but do not live under a swept directory.
const _localizedFiles = <String>[
  'lib/features/main_shell.dart',
];

/// Not yet swept. Listed rather than silently skipped so the remaining work is
/// visible, and so removing an entry is the deliberate act that turns the check
/// on for it.
const _notYetLocalized = <String>[
  // Unreachable: nothing constructs CalendarScreen. Translating a screen no
  // one can open would be wasted work — it should be wired back into the tabs
  // or deleted, and localized as part of whichever is chosen.
  'lib/features/calendar (dead screen)',
  // TmdbService's offline demo payload — user-visible, but only when no API
  // key is set.
  'lib/core/network/tmdb_service.dart (mock data)',
];

/// Characters that only occur in Turkish text, never in Dart identifiers,
/// asset paths or English copy.
final _turkishChars = RegExp(r'[çğıöşüÇĞİÖŞÜ]');

/// A single-quoted Dart string literal. Good enough for a heuristic; it does
/// not try to understand escaping or interpolation.
final _stringLiteral = RegExp(r"'[^']*'");

/// Every Dart file the check covers.
Iterable<File> _filesToCheck() sync* {
  for (final path in _localizedPaths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Generated code, and the ARB-backed lookups, are the one place Turkish
      // belongs.
      if (entity.path.endsWith('.g.dart')) continue;
      final normalized = entity.path.replaceAll(r'\', '/');
      if (normalized.contains('lib/l10n/')) continue;
      // TmdbService's offline demo payload is still Turkish; see
      // _notYetLocalized. Skipped whole-file rather than by line pattern,
      // since nothing else in it carries copy any more.
      if (normalized.endsWith('lib/core/network/tmdb_service.dart')) continue;
      yield entity;
    }
  }

  for (final path in _localizedFiles) {
    final file = File(path);
    if (file.existsSync()) yield file;
  }
}

/// Lines that legitimately contain Turkish and are not user-facing text.
bool _isExempt(String line) {
  final trimmed = line.trimLeft();
  // Comments, and debugPrint output which never reaches a user.
  if (trimmed.startsWith('//') || trimmed.startsWith('///') || trimmed.startsWith('*')) return true;
  if (trimmed.contains('debugPrint(')) return true;
  // Data-matching patterns: the Turkish-cinema badge sniffs titles for Turkish
  // characters, and the journal's cinema filter matches the word itself.
  if (trimmed.contains("RegExp(r'[ığüşöç]')")) return true;
  if (trimmed.contains("contains('sinema')")) return true;
  if (trimmed.contains("contains('türk')")) return true;
  if (trimmed.contains("contains('şener')")) return true;
  if (trimmed.contains("contains('çizgi')")) return true;
  // The legacy name→id table used to recover genre ids from rows written
  // before ids were stored. Data, and deliberately Turkish.
  if (trimmed.contains('TmdbGenre.') && trimmed.contains(': \'')) return true;
  // The Turkish dotted-i casing rule itself.
  if (trimmed.contains("replaceAll('i', 'İ')")) return true;
  // Languages are named in themselves in the picker, never translated.
  if (trimmed.contains("return 'Türkçe'")) return true;
  // TmdbService's offline demo payload, shown only with no API key set.
  if (trimmed.contains("'name': genreMap[id]")) return true;
  return false;
}

void main() {
  final offenders = <String>[];

  for (final file in _filesToCheck()) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_isExempt(line)) continue;

      for (final match in _stringLiteral.allMatches(line)) {
        final literal = match.group(0)!;
        if (_turkishChars.hasMatch(literal)) {
          offenders.add('${file.path}:${i + 1}  $literal');
        }
      }
    }
  }

  if (offenders.isEmpty) {
    stdout.writeln('No hardcoded Turkish found in localized features.');
    stdout.writeln('Still to sweep: ${_notYetLocalized.join(', ')}');
    return;
  }

  stderr.writeln('Hardcoded Turkish string literals in already-localized code:');
  for (final offender in offenders) {
    stderr.writeln('  $offender');
  }
  stderr.writeln('');
  stderr.writeln('Move these into lib/l10n/app_tr.arb (and app_en.arb) and read');
  stderr.writeln('them via AppLocalizations. If a line is data rather than copy,');
  stderr.writeln('add it to _isExempt in tool/check_localized.dart with a reason.');
  exitCode = 1;
}
