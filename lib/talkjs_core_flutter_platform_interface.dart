import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'talkjs_core_flutter_method_channel.dart';

abstract class TalkjsCoreFlutterPlatform extends PlatformInterface {
  /// Constructs a TalkjsCoreFlutterPlatform.
  TalkjsCoreFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static TalkjsCoreFlutterPlatform _instance = MethodChannelTalkjsCoreFlutter();

  /// The default instance of [TalkjsCoreFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelTalkjsCoreFlutter].
  static TalkjsCoreFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TalkjsCoreFlutterPlatform] when
  /// they register themselves.
  static set instance(TalkjsCoreFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
