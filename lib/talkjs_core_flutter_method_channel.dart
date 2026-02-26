import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'talkjs_core_flutter_platform_interface.dart';

/// An implementation of [TalkjsCoreFlutterPlatform] that uses method channels.
class MethodChannelTalkjsCoreFlutter extends TalkjsCoreFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('talkjs_core_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
