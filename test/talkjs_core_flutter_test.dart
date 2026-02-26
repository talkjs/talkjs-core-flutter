import 'package:flutter_test/flutter_test.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter_platform_interface.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTalkjsCoreFlutterPlatform
    with MockPlatformInterfaceMixin
    implements TalkjsCoreFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TalkjsCoreFlutterPlatform initialPlatform = TalkjsCoreFlutterPlatform.instance;

  test('$MethodChannelTalkjsCoreFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTalkjsCoreFlutter>());
  });

  test('getPlatformVersion', () async {
    TalkjsCoreFlutter talkjsCoreFlutterPlugin = TalkjsCoreFlutter();
    MockTalkjsCoreFlutterPlatform fakePlatform = MockTalkjsCoreFlutterPlatform();
    TalkjsCoreFlutterPlatform.instance = fakePlatform;

    expect(await talkjsCoreFlutterPlugin.getPlatformVersion(), '42');
  });
}
