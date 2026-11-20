// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:vlc_remote/core/services/vlc_service.dart';

void main() {
  test('VlcService parses status.xml correctly', () {
    final vlcService = VlcService(baseUrl: 'http://127.0.0.1:8080');

    const sampleXml = '''
<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
<root>
  <state>playing</state>
  <time>45</time>
  <length>180</length>
  <volume>256</volume>
  <fullscreen>0</fullscreen>
  <information>
    <category name="meta">
      <info name="filename">test_video.mp4</info>
      <info name="title">Test Video Title</info>
    </category>
  </information>
</root>
''';

    final state = vlcService.parseStatusXml(sampleXml);

    expect(state.isPlaying, true);
    expect(state.currentPosition, 45);
    expect(state.totalDuration, 180);
    expect(state.currentFileName, 'test_video.mp4');
    expect(state.volume, 1.0);
    expect(state.isFullscreen, false);
  });
}

