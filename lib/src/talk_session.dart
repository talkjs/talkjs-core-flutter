import 'core.g.dart';
import 'api.dart';
import 'user_ref.dart';
import 'conversation_ref.dart';

export 'core.g.dart' show ApiUrlOptions, TalkSessionOptions;

final Finalizer<int> _conversationListSubscriptionFinalizer = Finalizer((
  handle,
) async {
  await hostApi?.conversationListSubscriptionDeleteHandle(handle);
});

class ConversationListSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

  Future<void> loadMore([int? count]) {
    return _api.conversationListSubscriptionLoadMore(_handle, count);
  }

  Future<void> unsubscribe() {
    conversationListSubscriptionOnSnapshots.remove(_handle);

    return _api.conversationListSubscriptionUnsubscribe(_handle);
  }

  ConversationListSubscription._({
    required CoreHostApi api,
    required int handle,
  }) : _api = api,
       _handle = handle;
}

final Finalizer<int> _sessionFinalizer = Finalizer((handle) async {
  await hostApi?.sessionDeleteHandle(handle);
});

class TalkSession {
  final CoreHostApi _api;
  final int _handle;

  final UserRef currentUser;

  Future<UserRef> user(String id) async {
    final handle = await _api.sessionUser(_handle, id);

    return makeUserRef(api: _api, handle: handle, id: id);
  }

  Future<ConversationRef> conversation(String id) async {
    final handle = await _api.sessionConversation(_handle, id);

    return makeConversationRef(api: _api, handle: handle, id: id);
  }

  Future<ConversationListSubscription> subscribeConversations([
    void Function(List<ConversationSnapshot> snapshot, bool loadedAll)?
    onSnapshot,
  ]) async {
    final handle = await _api.sessionSubscribeConversations(_handle);

    conversationListSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = ConversationListSubscription._(
      api: _api,
      handle: handle,
    );

    _conversationListSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  TalkSession._({
    required CoreHostApi api,
    required int handle,
    required String userId,
  }) : _api = api,
       _handle = handle,
       currentUser = makeUserRef(
         api: api,
         handle: handle,
         id: userId,
         attachFinalizer: false,
       );
}

Future<TalkSession> getTalkSession(TalkSessionOptions options) async {
  if (hostApi == null) {
    hostApi = CoreHostApi();
    CoreFlutterApi.setUp(CoreFlutterApiImplementation());
  }

  final handle = await hostApi!.getTalkSession(options);
  final session = TalkSession._(
    api: hostApi!,
    handle: handle,
    userId: options.userId,
  );

  _sessionFinalizer.attach(session, handle);

  return session;
}
