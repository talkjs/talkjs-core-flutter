
import 'talkjs_core_flutter_platform_interface.dart';

class TalkjsCoreFlutter {
  Future<String?> getPlatformVersion() {
    return TalkjsCoreFlutterPlatform.instance.getPlatformVersion();
  }
}
