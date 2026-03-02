import 'core.g.dart';

CoreHostApi? hostApi;

Map<int, Function(UserSnapshot? snapshot)?> userSubscriptionOnSnapshots = {};
Map<int, Function(UserOnlineSnapshot? snapshot)?>
userOnlineSubscriptionOnSnapshots = {};
Map<int, Function(ConversationSnapshot? snapshot)?>
conversationSubscriptionOnSnapshots = {};

class CoreFlutterApiImplementation implements CoreFlutterApi {
  @override
  void newUserSnapshot(int handle, UserSnapshot? snapshot) {
    userSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void newUserOnlineSnapshot(int handle, UserOnlineSnapshot? snapshot) {
    userOnlineSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void newConversationSnapshot(int handle, ConversationSnapshot? snapshot) {
    conversationSubscriptionOnSnapshots[handle]?.call(snapshot);
  }
}
