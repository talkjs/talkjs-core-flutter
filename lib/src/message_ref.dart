import 'core.g.dart';
import 'api.dart';
import 'reaction_ref.dart';

export 'core.g.dart' show MessageSnapshot;

final Finalizer<int> _messageFinalizer = Finalizer((handle) async {
  await hostApi?.messageDeleteHandle(handle);
});

/// References the message with a given message ID.
///
/// @remarks
/// Used in all Data API operations affecting that message, such as fetching or editing the message attributes, or deleting the message.
/// Created via [ConversationRef.message] and [ConversationRef.send].
///
/// @public
class MessageRef {
  final CoreHostApi _api;
  final int _handle;

  /// The ID of the referenced message.
  ///
  /// @remarks
  /// Immutable: if you want to reference a different message, get a new MessageRef instead.
  final String id;

  /// The ID of the conversation that the referenced message belongs to.
  ///
  /// @remarks
  /// Immutable: if you want to reference a message from a different conversation, get a new MessageRef from that conversation.
  final String conversationId;

  /// Fetches a snapshot of the message.
  ///
  /// @return A snapshot of the message's attributes, or null if the message doesn't exist, the conversation doesn't exist, or you're not a participant in the conversation.
  Future<MessageSnapshot?> get() {
    return _api.messageGet(_handle);
  }

  /// Edits this message.
  ///
  /// @remarks
  /// The function will throw if the request is invalid, the message doesn't exist, or you do not have permission to edit that message.
  Future<void> edit(String params) {
    return _api.messageEdit(_handle, params);
  }

  /// Deletes properties of this message.
  ///
  /// @param fields - The names of the properties to delete
  ///
  /// @remarks
  /// To delete a field in the `custom` property, pass it as `custom.FIELD_TO_DELETE`.
  Future<void> deleteFields(List<String> fields) {
    return _api.messageDeleteFields(_handle, fields);
  }

  /// Deletes this message, or does nothing if the message does not exist.
  ///
  /// @remarks
  /// Deleting a nonexistent message is treated as success.
  ///
  /// This function will throw if you are not a participant in the conversation or if your role does not give you permission to delete this message.
  Future<void> delete() {
    return _api.messageDelete(_handle);
  }

  /// Get a reference to a specific emoji reaction on this message
  ///
  /// @remarks
  /// If you call `.reaction` with an invalid emoji, it will still succeed and you will still get a [ReactionRef].
  /// However, the TalkJS server will reject any calls that use an invalid emoji.
  ///
  /// In the future, this will also be used to fetch a full list of people who used that specific reaction on the message.
  ///
  /// @example Reacting to the message with a Unicode emoji
  /// ```dart
  /// final reaction = await messageRef.reaction("🚀");
  /// await reaction.add();
  /// ```
  ///
  /// @example Removing your custom emoji reaction from the message
  /// ```dart
  /// final reaction = await messageRef.reaction(":cat-roomba:");
  /// await reaction.remove();
  /// ```
  ///
  /// @param emoji - The emoji for the reaction you want to reference. a single Unicode emoji like "🚀" or a custom emoji like ":cat_roomba:". Custom emoji can be up to 50 characters long.
  /// @return A [ReactionRef] for the reaction with that emoji on this message.
  /// Throws If the emoji is not a string or is an empty string
  /// @public
  Future<ReactionRef> reaction(String emoji) async {
    final handle = await _api.messageReaction(_handle, emoji);

    return makeReactionRef(
      api: _api,
      handle: handle,
      emoji: emoji,
      messageId: id,
      conversationId: conversationId,
    );
  }

  MessageRef._({
    required CoreHostApi api,
    required int handle,
    required this.id,
    required this.conversationId,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
MessageRef makeMessageRef({
  required CoreHostApi api,
  required int handle,
  required String id,
  required String conversationId,
}) {
  final ref = MessageRef._(
    api: api,
    handle: handle,
    id: id,
    conversationId: conversationId,
  );

  _messageFinalizer.attach(ref, handle);

  return ref;
}
