// lib/main.dart
import 'dart:io';

import 'package:logging/logging.dart';

import 'ncl_document.dart';

final _logger = Logger('ncl_doc_cli');

void main(List<String> arguments) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('[${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  _logger.info('NCL Document Headless CLI');
  if (arguments.isEmpty) {
    _logger.info('Usage: dart ncl_doc/lib/main.dart <file.ncl>');
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

  _logger.info('Validating and executing ${arguments[0]} in headless mode...');

  String content = file.readAsStringSync();
  var parser = NCLParser();

  var errors = parser.validate(content);
  if (errors.isNotEmpty) {
    _logger.severe('Validation errors:');
    for (var err in errors) {
      _logger.severe('  - $err');
    }
    exit(1);
  }

  _logger.info('Validation passed. Starting headless execution...');

  var document = NCLDocument.fromXML(content);
  document.start(ticksPerSecond: 1000);
}


