import 'core.g.dart';
import 'api.dart';
import 'participant_ref.dart';
import 'message_ref.dart';

export 'core.g.dart'
    show CreateConversationParams, SetConversationParams, ConversationSnapshot;

final Finalizer<int> _conversationSubscriptionFinalizer = Finalizer((
  handle,
) async {
  await hostApi?.conversationSubscriptionDeleteHandle(handle);
});

class ConversationSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

  Future<void> unsubscribe() {
    conversationSubscriptionOnSnapshots.remove(_handle);

    return _api.conversationSubscriptionUnsubscribe(_handle);
  }

  ConversationSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

final Finalizer<int> _messageSubscriptionFinalizer = Finalizer((handle) async {
  await hostApi?.messageSubscriptionDeleteHandle(handle);
});

class MessageSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

  Future<void> loadMore([int? count]) {
    return _api.messageSubscriptionLoadMore(_handle, count);
  }

  Future<void> unsubscribe() {
    messageSubscriptionOnSnapshots.remove(_handle);

    return _api.messageSubscriptionUnsubscribe(_handle);
  }

  MessageSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

final Finalizer<int> _participantSubscriptionFinalizer = Finalizer((
  handle,
) async {
  await hostApi?.participantSubscriptionDeleteHandle(handle);
});

class ParticipantSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

  Future<void> loadMore([int? count]) {
    return _api.participantSubscriptionLoadMore(_handle, count);
  }

  Future<void> unsubscribe() {
    participantSubscriptionOnSnapshots.remove(_handle);

    return _api.participantSubscriptionUnsubscribe(_handle);
  }

  ParticipantSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

final Finalizer<int> _conversationFinalizer = Finalizer((handle) async {
  await hostApi?.conversationDeleteHandle(handle);
});

final Finalizer<int> _typingSubscriptionFinalizer = Finalizer((handle) async {
  await hostApi?.typingSubscriptionDeleteHandle(handle);
});

class TypingSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

  Future<void> unsubscribe() {
    typingSubscriptionOnSnapshots.remove(_handle);

    return _api.typingSubscriptionUnsubscribe(_handle);
  }

  TypingSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

class ConversationRef {
  final CoreHostApi _api;
  final int _handle;

  final String id;

  Future<ConversationSnapshot?> get() {
    return _api.conversationGet(_handle);
  }

  Future<void> set(SetConversationParams data) {
    return _api.conversationSet(_handle, data);
  }

  Future<void> createIfNotExists(CreateConversationParams data) {
    return _api.conversationCreateIfNotExists(_handle, data);
  }

  Future<void> deleteFields(List<String> fields) {
    return _api.conversationDeleteFields(_handle, fields);
  }

  Future<void> markAsRead() {
    return _api.conversationMarkAsRead(_handle);
  }

  Future<void> markAsUnread() {
    return _api.conversationMarkAsUnread(_handle);
  }

  Future<void> markAsTyping() {
    return _api.conversationMarkAsTyping(_handle);
  }

  Future<ParticipantRef> participant(String user) async {
    final handle = await _api.conversationParticipant(_handle, user);

    return makeParticipantRef(
      api: _api,
      handle: handle,
      userId: user,
      conversationId: id,
    );
  }

  Future<MessageRef> message(String messageId) async {
    final handle = await _api.conversationMessage(_handle, messageId);

    return makeMessageRef(
      api: _api,
      handle: handle,
      id: messageId,
      conversationId: id,
    );
  }

  Future<MessageRef> send(String params) async {
    final refParams = await _api.conversationSend(_handle, params);

    return makeMessageRef(
      api: _api,
      handle: refParams.handle,
      id: refParams.id,
      conversationId: refParams.conversationId,
    );
  }

  Future<ConversationSubscription> subscribe([
    void Function(ConversationSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribe(_handle);

    conversationSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = ConversationSubscription._(api: _api, handle: handle);

    _conversationSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  Future<MessageSubscription> subscribeMessages([
    void Function(List<MessageSnapshot>? snapshot, bool loadedAll)? onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribeMessages(_handle);

    messageSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = MessageSubscription._(api: _api, handle: handle);

    _messageSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  Future<ParticipantSubscription> subscribeParticipants([
    void Function(List<ParticipantSnapshot>? snapshot, bool loadedAll)?
    onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribeParticipants(_handle);

    participantSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = ParticipantSubscription._(api: _api, handle: handle);

    _participantSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  Future<TypingSubscription> subscribeTyping([
    void Function(TypingSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribeTyping(_handle);

    typingSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = TypingSubscription._(api: _api, handle: handle);

    _typingSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  ConversationRef._({
    required CoreHostApi api,
    required int handle,
    required this.id,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
ConversationRef makeConversationRef({
  required CoreHostApi api,
  required int handle,
  required String id,
}) {
  final ref = ConversationRef._(api: api, handle: handle, id: id);

  _conversationFinalizer.attach(ref, handle);

  return ref;
}
