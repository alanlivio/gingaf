import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncl_app/ncl_app.dart';
import 'package:ncl_doc/ncl_document.dart';

void main() {
  testWidgets('AVWidget rendering and simulation tests', (WidgetTester tester) async {
    bool stopped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AVWidget(
            uri: 'video.mp4',
            onVideoStopped: () {
              stopped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('AVWidget: video.mp4'), findsOneWidget);
    expect(stopped, isFalse);

    await tester.tap(find.text('Simulate End'));
    await tester.pump();

    expect(stopped, isTrue);
  });

  testWidgets('BaseWidgetState visual attributes mapping tests', (WidgetTester tester) async {
    final media = Media(
      id: 'm1',
      rawAttributes: {
        'id': 'm1',
        'src': 'video.mp4',
        'left': '10',
        'top': '20',
        'width': '150',
        'height': '250',
        'bgColor': 'blue',
        'focusBorderColor': 'red',
        'selBorderColor': 'green',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AVWidget(
                uri: 'video.mp4',
                media: media,
              ),
            ],
          ),
        ),
      ),
    );

    final Positioned positioned = tester.widget(find.byType(Positioned));
    expect(positioned.left, 10.0);
    expect(positioned.top, 20.0);
    expect(positioned.width, 150.0);
    expect(positioned.height, 250.0);

    final state = tester.state<AVWidgetState>(find.byType(AVWidget));
    expect(state.bgColor, Colors.blue);
    expect(state.focusBorderColor, Colors.red);
    expect(state.selBorderColor, Colors.green);
  });
}
