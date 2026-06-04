import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/main_av.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player/video_player.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform
    with MockPlatformInterfaceMixin {
  final StreamController<VideoEvent> events = StreamController<VideoEvent>.broadcast();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    return 1;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<Duration> getPosition(int textureId) async {
    return Duration.zero;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return events.stream;
  }

  @override
  Widget buildView(int textureId) {
    return Container();
  }
}

void main() {
  late FakeVideoPlayerPlatform fakePlatform;

  setUp(() {
    fakePlatform = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakePlatform;
  });

  testWidgets('MainAVController and MainAVWidget init, start, stop tests', (WidgetTester tester) async {
    final controller = MainAVController()..setMainAvUri('background.mp4');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainAVWidget(controller: controller),
        ),
      ),
    );

    expect(find.text('Loading Background AV: background.mp4'), findsOneWidget);

    fakePlatform.events.add(VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(seconds: 10),
      size: const Size(100, 100),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayer), findsOneWidget);
    expect(find.text('Loading Background AV: background.mp4'), findsNothing);

    controller.stop();
    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayer), findsNothing);

    controller.play();
    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayer), findsOneWidget);
  });
}
