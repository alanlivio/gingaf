import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import 'ncl_document.dart';

final _logger = Logger('ncl_doc_cli');

void main(List<String> arguments) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln(
      '[${record.loggerName}] ${record.level.name}: ${record.message}',
    );
  });

  if (arguments.isEmpty) {
    _logger.info(
      'Usage: dart ncl_doc/lib/cli.dart <file.ncl> [ticksPerSecond (default: 1)]',
    );
    exit(1);
  }

  if (!arguments[0].toLowerCase().endsWith('.ncl')) {
    _logger.severe('Error: Only .ncl files are supported.');
    exit(1);
  }

  var file = File(arguments[0]);
  if (!file.existsSync()) {
    _logger.severe('File not found: ${arguments[0]}');
    exit(1);
  }

  _logger.info('Executing ${arguments[0]} in headless mode...');

  String content = file.readAsStringSync();

  int ticksPerSecond = 1;
  if (arguments.length > 1) {
    ticksPerSecond = int.tryParse(arguments[1]) ?? 1;
  }

  var document = NCLDocument.fromXML(content);
  document.start();

  StreamSubscription<ProcessSignal>? sigintSub;
  sigintSub = ProcessSignal.sigint.watch().listen((ProcessSignal signal) {
    _logger.info('Captured Ctrl+C. Stopping document...');
    document.stop();
    sigintSub?.cancel();
  });

  _logger.info('Starting execution at $ticksPerSecond ticks per second...');
  document.tickIndefinitely(ticksPerSecond: ticksPerSecond);
}
