import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show ReactionSnapshot;

final Finalizer<int> _reactionFinalizer = Finalizer((handle) async {
  await hostApi?.reactionDeleteHandle(handle);
});

/// References a specific emoji reaction on a message.
///
/// @remarks
/// Used in all Data API operations affecting that emoji reaction, such as adding or removing the reaction.
/// Created via [MessageRef.reaction].
///
/// @public
class ReactionRef {
  final CoreHostApi _api;
  final int _handle;

  /// Which emoji the reaction is using.
  ///
  /// @remarks
  /// Either a single Unicode emoji, or the name of a custom emoji with a colon at the start and end.
  /// This is not validated until you send a request to the server.
  /// Since custom emoji are configured in the frontend, there are no checks to make sure a custom emoji actually exists.
  ///
  /// Immutable: if you want to use a different emoji, get a new ReactionRef instead.
  ///
  /// @example Unicode emoji
  /// "👍"
  ///
  /// @example Custom emoji
  /// ":cat-roomba:"
  final String emoji;

  /// The ID of the message that this is a reaction to.
  ///
  /// @remarks
  /// Immutable: if you want to react to a different message, get a new ReactionRef instead.
  final String messageId;

  /// The ID of the conversation the message belongs to.
  ///
  /// @remarks
  /// Immutable: if you want to reference a message from a different conversation, get a new MessageRef from that conversation and call `.reaction` on that MessageRef.
  final String conversationId;

  /// Adds this emoji reaction onto the message, from the current user.
  ///
  /// @remarks
  /// The function will throw if the request is invalid, the message doesn't exist, there are already 50 different reactions on this message, or if you do not have permission to use emoji reactions on that message.
  Future<void> add() {
    return _api.reactionAdd(_handle);
  }

  /// Removes this emoji reaction from the message, from the current user.
  ///
  /// @remarks
  /// The function will throw if the request is invalid, the message doesn't exist, or you do not have permission to use emoji reactions on that message.
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
