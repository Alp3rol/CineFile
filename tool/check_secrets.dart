// Fails when a tracked source file contains a credential-shaped value.
//
// This is deliberately repository-specific: Firebase web API keys are public
// identifiers and are expected in firebase_options.dart, while TMDb keys,
// private keys and provider access tokens must never be committed.
//
// Run locally with:
//   dart tool/check_secrets.dart
import 'dart:convert';
import 'dart:io';

final _credentialPatterns = <({String label, RegExp pattern})>[
  (
    label: 'private key',
    pattern: RegExp(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
  ),
  (
    label: 'GitHub token',
    pattern: RegExp(
      r'\b(?:gh[psour]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b',
    ),
  ),
  (label: 'AWS access key', pattern: RegExp(r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b')),
  (label: 'Slack token', pattern: RegExp(r'\bxox[baprs]-[A-Za-z0-9-]{20,}\b')),
  (
    label: 'Stripe live secret',
    pattern: RegExp(r'\bsk_live_[A-Za-z0-9]{20,}\b'),
  ),
  (
    label: 'TMDb API key',
    pattern: RegExp(
      r'''(?:TMDB_API_KEY|defaultTmdbApiKey)\s*[:=]\s*['"]([0-9a-fA-F]{32})['"]''',
    ),
  ),
  (
    label: 'credential assignment',
    pattern: RegExp(
      r'''(?:secret|access[_-]?token|auth[_-]?token|private[_-]?key|password|passwd)\s*[:=]\s*['"](?!\$\{|<|test\b|example\b|placeholder\b|redacted\b)([A-Za-z0-9_./+=-]{20,})['"]''',
      caseSensitive: false,
    ),
  ),
];

const _excludedPaths = <String>{
  // Historical audit excerpts describe the old leak and are not executable.
  'docs/architecture/AUDIT.md',
  // The scanner necessarily contains its signatures and synthetic fixtures.
  'tool/check_secrets.dart',
};

const _binaryExtensions = <String>{
  '.ico',
  '.jpeg',
  '.jpg',
  '.keystore',
  '.pdf',
  '.png',
  '.webp',
  '.zip',
};

void main(List<String> arguments) {
  if (arguments.contains('--self-test')) {
    _selfTest();
    return;
  }

  final trackedFiles = _trackedFiles();
  final findings = <String>[];

  for (final path in trackedFiles) {
    if (_excludedPaths.contains(path) || _isBinary(path)) continue;
    final file = File(path);
    if (!file.existsSync()) continue;

    String contents;
    try {
      contents = file.readAsStringSync();
    } on FileSystemException {
      continue;
    }

    final lines = const LineSplitter().convert(contents);
    for (var index = 0; index < lines.length; index++) {
      for (final rule in _credentialPatterns) {
        if (rule.pattern.hasMatch(lines[index])) {
          findings.add('$path:${index + 1}: ${rule.label}');
        }
      }
    }
  }

  if (findings.isNotEmpty) {
    stderr.writeln('Credential-shaped values found in tracked files:');
    for (final finding in findings) {
      stderr.writeln('  $finding');
    }
    stderr.writeln('Remove the value and rotate it if it was ever valid.');
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Secret scan OK: ${trackedFiles.length} tracked files checked.',
  );
}

List<String> _trackedFiles() {
  final result = Process.runSync('git', const ['ls-files', '-z']);
  if (result.exitCode != 0) {
    stderr.writeln('Could not list tracked files: ${result.stderr}');
    exit(1);
  }
  return (result.stdout as String)
      .split('\u0000')
      .where((path) => path.isNotEmpty)
      .toList(growable: false);
}

bool _isBinary(String path) {
  final normalized = path.toLowerCase();
  return _binaryExtensions.any(normalized.endsWith);
}

void _selfTest() {
  final shouldMatch = <String>[
    '-----BEGIN PRIVATE KEY-----',
    'token = "ghp_abcdefghijklmnopqrstuvwxyz1234567890"',
    'aws = "AKIAABCDEFGHIJKLMNOP"',
    ['slack = "xoxb-', '1234567890-abcdefghijklmnop"'].join(),
    'TMDB_API_KEY="0123456789abcdef0123456789abcdef"',
    'password: "this-is-a-real-looking-password"',
  ];
  final shouldNotMatch = <String>[
    "apiKey: 'AIzaSyPublicFirebaseWebIdentifier'",
    "TMDB_API_KEY: 'test'",
    'token = "\${{ secrets.GITHUB_TOKEN }}"',
    'password: "<password>"',
  ];

  for (final value in shouldMatch) {
    if (!_credentialPatterns.any((rule) => rule.pattern.hasMatch(value))) {
      stderr.writeln('Secret scanner self-test missed: $value');
      exitCode = 1;
      return;
    }
  }
  for (final value in shouldNotMatch) {
    if (_credentialPatterns.any((rule) => rule.pattern.hasMatch(value))) {
      stderr.writeln('Secret scanner self-test falsely matched: $value');
      exitCode = 1;
      return;
    }
  }
  stdout.writeln('Secret scanner self-test passed.');
}
