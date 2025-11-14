import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'router.dart';

const bool isWeb = bool.hasEnvironment('dart.library.js_util');
const RUNTIME = isWeb ? 'gingaccws(browser)' : 'gingaccws';
const CCWS_PORT = 44642;

class CCWS {
  HttpServer? _server;
  bool _running = false;
  int get port => _server?.port ?? 0;
  bool get isRunning => _running;

  Handler get handler => Pipeline()
      .addMiddleware(logRequests())
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
    print('$RUNTIME: Server stopped');
  }

  Future<void> _startDesktopServer() async {
    int currentPort = CCWS_PORT;
    const maxRetry = 100;

    for (int i = 0; i < maxRetry; i++) {
      try {
        _server =
            await io.serve(handler, InternetAddress.loopbackIPv4, currentPort);
        print(
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
    print('$RUNTIME: Server failed to start after $maxRetry port attempts');
  }

  void _startWebImplementation() {
    print(
        '$RUNTIME: Mock Initialized (Use service-worker.js for fetch interception)');
  }
}

void main() async {
  final ccws = CCWS();
  await ccws.start();
  print('CCWS Standalone active. Target Port: ${ccws.port}');
  print('Press Ctrl+C to terminate the service.');
}
