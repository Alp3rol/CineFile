import 'dart:convert';
import 'dart:io';

/// Summarizes a `flutter test --file-reporter json:<path>` event stream.
///
/// Suite durations include loading, setup, tests, and teardown. Suites run in
/// parallel, so these values identify slow files but must not be added together
/// to calculate the total test wall time.
void main(List<String> arguments) {
  final inputPath = arguments.isEmpty
      ? 'build/test-timings.json'
      : arguments.first;
  final input = File(inputPath);
  if (!input.existsSync()) {
    stderr.writeln('Timing event file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final suitePaths = <int, String>{};
  final testSuites = <int, int>{};
  final suiteStarts = <int, int>{};
  final suiteEnds = <int, int>{};
  var totalMilliseconds = 0;

  for (final line in input.readAsLinesSync()) {
    final event = jsonDecode(line) as Map<String, dynamic>;
    final type = event['type'];
    if (type == 'suite') {
      final suite = event['suite'] as Map<String, dynamic>;
      suitePaths[suite['id'] as int] = suite['path'] as String;
    } else if (type == 'testStart') {
      final test = event['test'] as Map<String, dynamic>;
      final testId = test['id'] as int;
      final suiteId = test['suiteID'] as int;
      final time = event['time'] as int;
      testSuites[testId] = suiteId;
      suiteStarts.update(
        suiteId,
        (current) => time < current ? time : current,
        ifAbsent: () => time,
      );
    } else if (type == 'testDone') {
      final suiteId = testSuites[event['testID'] as int];
      if (suiteId != null) {
        final time = event['time'] as int;
        suiteEnds.update(
          suiteId,
          (current) => time > current ? time : current,
          ifAbsent: () => time,
        );
      }
    } else if (type == 'done') {
      totalMilliseconds = event['time'] as int;
    }
  }

  final timings = <({String file, int milliseconds})>[];
  for (final entry in suitePaths.entries) {
    final start = suiteStarts[entry.key];
    final end = suiteEnds[entry.key];
    if (start == null || end == null) continue;
    timings.add((
      file: entry.value.replaceAll('\\', '/').split('/').last,
      milliseconds: end - start,
    ));
  }
  timings.sort((a, b) => b.milliseconds.compareTo(a.milliseconds));

  stdout.writeln('# Flutter test timing report');
  stdout.writeln();
  stdout.writeln(
    'Total wall time: ${(totalMilliseconds / 1000).toStringAsFixed(2)} s',
  );
  stdout.writeln();
  stdout.writeln('| Slowest test file | Suite span |');
  stdout.writeln('|---|---:|');
  for (final timing in timings.take(15)) {
    stdout.writeln(
      '| `${timing.file}` | '
      '${(timing.milliseconds / 1000).toStringAsFixed(2)} s |',
    );
  }
}
