import 'dart:io';

void main(List<String> arguments) {
  var inputPath = 'coverage/lcov.info';
  var minimum = 50.0;
  var domainMinimum = 80.0;

  for (final argument in arguments) {
    if (argument.startsWith('--minimum=')) {
      minimum = double.parse(argument.substring('--minimum='.length));
    } else if (argument.startsWith('--domain-minimum=')) {
      domainMinimum = double.parse(
        argument.substring('--domain-minimum='.length),
      );
    } else {
      inputPath = argument;
    }
  }

  final input = File(inputPath);
  if (!input.existsSync()) {
    stderr.writeln('Coverage file not found: $inputPath');
    exitCode = 2;
    return;
  }

  var currentSource = '';
  var total = 0;
  var hit = 0;
  var domainTotal = 0;
  var domainHit = 0;

  for (final line in input.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      currentSource = line.substring(3).replaceAll('\\', '/');
      continue;
    }
    if (!line.startsWith('DA:')) continue;

    final separator = line.indexOf(',');
    if (separator < 0) continue;
    final count = int.parse(line.substring(separator + 1));
    total++;
    if (count > 0) hit++;
    if (currentSource.contains('/domain/')) {
      domainTotal++;
      if (count > 0) domainHit++;
    }
  }

  if (total == 0 || domainTotal == 0) {
    stderr.writeln('Coverage report contains no executable lines.');
    exitCode = 2;
    return;
  }

  final overallPercent = 100 * hit / total;
  final domainPercent = 100 * domainHit / domainTotal;
  stdout.writeln(
    'Overall coverage: $hit / $total '
    '(${overallPercent.toStringAsFixed(2)}%; minimum '
    '${minimum.toStringAsFixed(2)}%)',
  );
  stdout.writeln(
    'Domain coverage: $domainHit / $domainTotal '
    '(${domainPercent.toStringAsFixed(2)}%; minimum '
    '${domainMinimum.toStringAsFixed(2)}%)',
  );

  final failures = <String>[];
  if (overallPercent < minimum) {
    failures.add('overall coverage is below the minimum');
  }
  if (domainPercent < domainMinimum) {
    failures.add('domain coverage is below the minimum');
  }
  if (failures.isNotEmpty) {
    stderr.writeln('Coverage gate failed: ${failures.join('; ')}.');
    exitCode = 1;
  }
}
