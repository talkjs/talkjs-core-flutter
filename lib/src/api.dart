import 'core.g.dart';

CoreHostApi? hostApi;

Map<int, Function(UserSnapshot? snapshot)?> userSubscriptionOnSnapshots = {};
Map<int, Function(UserOnlineSnapshot? snapshot)?>
userOnlineSubscriptionOnSnapshots = {};
Map<int, Function(ConversationSnapshot? snapshot)?>
conversationSubscriptionOnSnapshots = {};
Map<int, Function(List<ConversationSnapshot> snapshot, bool loadedAll)?>
conversationListSubscriptionOnSnapshots = {};
Map<int, Function(List<MessageSnapshot>? snapshot, bool loadedAll)?>
messageSubscriptionOnSnapshots = {};
Map<int, Function(List<ParticipantSnapshot>? snapshot, bool loadedAll)?>
participantSubscriptionOnSnapshots = {};
Map<int, Function(TypingSnapshot? snapshot)?> typingSubscriptionOnSnapshots =
    {};

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

  @override
  void newConversationListSnapshot(
    int handle,
    List<ConversationSnapshot> snapshot,
    bool loadedAll,
  ) {
    conversationListSubscriptionOnSnapshots[handle]?.call(snapshot, loadedAll);
  }

  @override
  void newMessageSnapshot(
    int handle,
    List<MessageSnapshot>? snapshot,
    bool loadedAll,
  ) {
    messageSubscriptionOnSnapshots[handle]?.call(snapshot, loadedAll);
  }

  @override
  void newParticipantSnapshot(
    int handle,
    List<ParticipantSnapshot>? snapshot,
    bool loadedAll,
  ) {
    participantSubscriptionOnSnapshots[handle]?.call(snapshot, loadedAll);
  }

  @override
  void newTypingSnapshot(int handle, TypingSnapshot? snapshot) {
    typingSubscriptionOnSnapshots[handle]?.call(snapshot);
  }
}
