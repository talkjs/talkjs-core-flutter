import 'core.g.dart';
import 'api.dart';
import 'user_ref.dart';
import 'conversation_ref.dart';

export 'core.g.dart' show ApiUrlOptions, TalkSessionOptions;

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

final Finalizer<int> _sessionFinalizer = Finalizer((handle) async {
  await hostApi?.sessionDeleteHandle(handle);
});

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
