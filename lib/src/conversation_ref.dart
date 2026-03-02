import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show CreateConversationParams, ConversationSnapshot;

final Finalizer<int> _conversationSubscriptionFinalizer = Finalizer((
  handle,
) async {
  await hostApi?.conversationSubscriptionDelete(handle);
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

final Finalizer<int> _conversationFinalizer = Finalizer((handle) async {
  await hostApi?.conversationDelete(handle);
});

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

  Future<ConversationSubscription> subscribe(
    void Function(ConversationSnapshot? snapshot)? onSnapshot,
  ) async {
    final handle = await _api.conversationSubscribe(_handle);

    conversationSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = ConversationSubscription._(api: _api, handle: handle);

    _conversationSubscriptionFinalizer.attach(subscription, handle);

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
