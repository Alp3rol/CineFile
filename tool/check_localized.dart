// Fails if a hardcoded user-facing string has crept back into a feature that
// has already been localized.
//
// Every localized slice was a one-time sweep; nothing stops the next screen
// from hardcoding its text again, and by the time anyone notices there is
// another sweep to do. This is the check that keeps that from happening.
//
// Run locally with:
//   dart run tool/check_localized.dart
//
// Detection used to be "a string literal containing a character that only
// appears in Turkish". That missed every Turkish word which happens to be pure
// ASCII — and it did, in practice: "Biyografi", "Kaydet", "Tamam" and "Profil"
// all sat in already-swept files for months without the check noticing.
//
// So the rule is now about position rather than spelling: a literal appearing
// where the framework expects user-facing text (a `Text(...)` child, a
// `hintText:`, a `labelText:`) is an offender regardless of language, because
// localized code reads those from AppLocalizations. That is language-agnostic
// and catches the ASCII cases the old heuristic could not.
//
// It still is not a proof — `Text(someHelper())` slips through — but it now
// fails on the shape the mistake actually takes.
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

/// A string literal sitting in a slot the framework renders to the user.
///
/// Covers `Text('...')` (including `const Text`), and the `hintText:`,
/// `labelText:`, `helperText:`, `errorText:` and `semanticLabel:` arguments.
/// Deliberately does NOT try to parse Dart — it matches the shape these
/// mistakes actually take.
final _userFacingLiteral = RegExp(
  r"(?:\bText\(\s*|\b(?:hintText|labelText|helperText|errorText|semanticLabel)\s*:\s*)"
  r"('[^']*')",
);

/// Literals that are not copy even though they sit in a text slot: emoji and
/// symbols, punctuation-only separators, and interpolations that are entirely
/// made of values (`'@$username'`, `'$a ↔ $b'`).
bool _isNotCopy(String literal) {
  final inner = literal.substring(1, literal.length - 1);
  if (inner.trim().isEmpty) return true;

  // Strip interpolations, then see whether any letters are left. `'/10'`,
  // `'@$username'` and `'${cat.label} ($n)'` all reduce to punctuation.
  final withoutInterpolation = inner
      .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
      .replaceAll(RegExp(r'\$\w+'), '');
  return !RegExp(r'\p{L}{2,}', unicode: true).hasMatch(withoutInterpolation);
}

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

/// Lines that are not user-facing copy despite matching.
///
/// Much shorter than it used to be: the old detector matched any literal
/// containing a Turkish character anywhere in the file, so every
/// Turkish-language *data* pattern (the genre name→id table, the cinema
/// filter's `contains('sinema')`, the dotted-i casing rule) had to be listed
/// here. Matching only literals in text slots excludes all of those by
/// construction.
bool _isExempt(String line) {
  final trimmed = line.trimLeft();
  // Comments — including ones that quote a `Text('...')` example.
  if (trimmed.startsWith('//') || trimmed.startsWith('*')) return true;
  // Diagnostics never reach a user.
  if (trimmed.contains('debugPrint(')) return true;
  // The language picker names each language in itself, never translated.
  if (trimmed.contains("return 'Türkçe'")) return true;
  return false;
}

void main() {
  final offenders = <String>[];

  for (final file in _filesToCheck()) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_isExempt(line)) continue;

      for (final match in _userFacingLiteral.allMatches(line)) {
        final literal = match.group(1)!;
        if (_isNotCopy(literal)) continue;
        offenders.add('${file.path}:${i + 1}  $literal');
      }
    }
  }

  if (offenders.isEmpty) {
    stdout.writeln('No hardcoded user-facing text found in localized features.');
    stdout.writeln('Still to sweep: ${_notYetLocalized.join(', ')}');
    return;
  }

  stderr.writeln('Literals in user-facing slots inside already-localized code:');
  for (final offender in offenders) {
    stderr.writeln('  $offender');
  }
  stderr.writeln('');
  stderr.writeln('Move these into lib/l10n/app_tr.arb (and app_en.arb) and read');
  stderr.writeln('them via AppLocalizations. If a line is data rather than copy,');
  stderr.writeln('add it to _isExempt in tool/check_localized.dart with a reason.');
  exitCode = 1;
}
