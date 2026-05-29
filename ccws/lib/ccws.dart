import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'router.dart';

const bool isWeb = bool.hasEnvironment('dart.library.js_util');
const RUNTIME = isWeb ? 'ginga-ccws(browser)' : 'ginga-ccws';
const CCWS_PORT = 44642;

final _logger = Logger(RUNTIME);

class CCWS {
  HttpServer? _server;
  bool _running = false;
  int get port => _server?.port ?? 0;
  bool get isRunning => _running;

  Handler get handler => Pipeline()
      .addMiddleware(logRequests(logger: (message, isError) {
        if (isError) {
          _logger.severe(message);
        } else {
          _logger.info(message);
        }
      }))
      .addHandler(CCWSRouter.getHandler());

  Future<void> start() async {
    if (isWeb) {
      _startWebImplementation();
    } else {
      await _startDesktopServer();
    }
    _running = true;
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    _running = false;
    _logger.info('$RUNTIME: Server stopped');
  }

  Future<void> _startDesktopServer() async {
    int currentPort = CCWS_PORT;
    const maxRetry = 100;

    for (int i = 0; i < maxRetry; i++) {
      try {
        _server =
            await io.serve(handler, InternetAddress.loopbackIPv4, currentPort);
        _logger.info(
            '$RUNTIME: Server running on http://${_server!.address.address}:${_server!.port}');
        return;
      } catch (e) {
        if (e is SocketException) {
          currentPort++;
          continue;
        }
        rethrow;
      }
    }
    _logger.severe(
        '$RUNTIME: Server failed to start after $maxRetry port attempts');
  }

  void _startWebImplementation() {
    _logger.info(
        '$RUNTIME: Mock Initialized (Use service-worker.js for fetch interception)');
  }
}

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('[${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  final ccws = CCWS();
  await ccws.start();
  _logger.info('CCWS Standalone active. Target Port: ${ccws.port}');
  _logger.info('Press Ctrl+C to terminate the service.');
}
