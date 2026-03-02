import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show ReactionSnapshot;

final Finalizer<int> _reactionFinalizer = Finalizer((handle) async {
  await hostApi?.reactionDeleteHandle(handle);
});

class ReactionRef {
  final CoreHostApi _api;
  final int _handle;

  final String emoji;
  final String messageId;
  final String conversationId;

  Future<void> add() {
    return _api.reactionAdd(_handle);
  }

  Future<void> remove() {
    return _api.reactionRemove(_handle);
  }

  ReactionRef._({
    required CoreHostApi api,
    required int handle,
    required this.emoji,
    required this.messageId,
    required this.conversationId,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
ReactionRef makeReactionRef({
  required CoreHostApi api,
  required int handle,
  required String emoji,
  required String messageId,
  required String conversationId,
}) {
  final ref = ReactionRef._(
    api: api,
    handle: handle,
    emoji: emoji,
    messageId: messageId,
    conversationId: conversationId,
  );

  _reactionFinalizer.attach(ref, handle);

  return ref;
}
