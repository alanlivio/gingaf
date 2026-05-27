// lib/main.dart
import 'dart:io';
import 'ncl_document.dart';

void main(List<String> arguments) {
  print('NCL Document Headless CLI');
  if (arguments.isEmpty) {
    print('Usage: ncl-doc <file.ncl>');
    exit(1);
  }

  var file = File(arguments[0]);
  if (!file.existsSync()) {
    print('File not found: ${arguments[0]}');
    exit(1);
  }

  print('Validating and executing ${arguments[0]} in headless mode...');

  String content = file.readAsStringSync();
  var parser = NCLParser();

  var errors = parser.validate(content);
  if (errors.isNotEmpty) {
    print('Validation errors:');
    for (var err in errors) {
      print('  - $err');
    }
    exit(1);
  }

  print('Validation passed. Starting headless execution...');

  var document = NCLDocument(content);
  document.start(ticksPerSecond: 1000);
}
