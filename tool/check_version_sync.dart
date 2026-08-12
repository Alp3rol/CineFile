// Keeps the package version and the version users see in Settings aligned.
//
// Run locally with:
//   dart run tool/check_version_sync.dart
import 'dart:io';

void main() {
  final pubspec = File('pubspec.yaml');
  final footer = File(
    'lib/features/settings/presentation/widgets/settings_credits_footer.dart',
  );

  if (!pubspec.existsSync() || !footer.existsSync()) {
    stderr.writeln('Run this check from the repository root.');
    exitCode = 1;
    return;
  }

  final packageMatch = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  final displayMatch = RegExp(
    r"const String kDisplayedAppVersion = '([^']+)';",
  ).firstMatch(footer.readAsStringSync());

  if (packageMatch == null) {
    stderr.writeln(
      'pubspec.yaml must contain a version in major.minor.patch+build format.',
    );
    exitCode = 1;
    return;
  }
  if (displayMatch == null) {
    stderr.writeln('Could not find kDisplayedAppVersion in Settings.');
    exitCode = 1;
    return;
  }

  final packageVersion = packageMatch.group(1)!;
  final buildNumber = packageMatch.group(2)!;
  final displayedVersion = displayMatch.group(1)!;

  if (packageVersion != displayedVersion) {
    stderr.writeln(
      'Version mismatch: pubspec is $packageVersion+$buildNumber, '
      'but Settings shows $displayedVersion.',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('Version sync OK: $packageVersion+$buildNumber');
}
