import 'core.g.dart';
import 'api.dart';

export 'core.g.dart'
    show CreateParticipantParams, SetParticipantParams, ParticipantSnapshot;

final Finalizer<int> _participantFinalizer = Finalizer((handle) async {
  await hostApi?.participantDeleteHandle(handle);
});

/// References a given user's participation in a conversation.
///
/// @remarks
/// Used in all Data API operations affecting that participant, such as joining/leaving a conversation, or setting their access.
/// Created via [ConversationRef.participant].
///
/// @public
class ParticipantRef {
  final CoreHostApi _api;
  final int _handle;

  /// The ID of the user who is participating.
  ///
  /// @remarks
  /// Immutable: if you want to reference a different participant, get a new ParticipantRef instead.
  final String userId;

  /// The ID of the conversation the user is participating in.
  ///
  /// @remarks
  /// Immutable: if you want to reference the user in a different conversation, get a new ParticipantRef instead.
  final String conversationId;

  /// Fetches a snapshot of the participant.
  ///
  /// @remarks
  /// This contains all of the participant's public information.
  ///
  /// @return A snapshot of the participant's attributes, or null if the user is not a participant. The function will throw if you are not a participant and try to read information about someone else.
  Future<ParticipantSnapshot?> get() {
    return _api.participantGet(_handle);
  }

  /// Sets properties of this participant. If the user is not already a participant in the conversation, they will be added.
  ///
  /// @remarks
  /// When client-side conversation syncing is disabled, you must already be a participant and you cannot set anything except the `notify` property.
  /// Everything else requires client-side conversation syncing to be enabled, and will cause the function to throw.
  Future<void> set(SetParticipantParams data) {
    return _api.participantSet(_handle, data);
  }

  /// Edits properties of a pre-existing participant. If the user is not already a participant in the conversation, the function will throw.
  ///
  /// @remarks
  /// When client-side conversation syncing is disabled, you must already be a participant and you cannot set anything except the `notify` property.
  /// Everything else requires client-side conversation syncing to be enabled, and will cause the function to throw.
  Future<void> edit(SetParticipantParams data) {
    return _api.participantEdit(_handle, data);
  }

  /// Adds the user as a participant, or does nothing if they are already a participant.
  ///
  /// @remarks
  /// If the participant already exists, this operation is still considered successful.
  ///
  /// The function will throw if client-side conversation syncing is disabled and the user is not already a participant.
  Future<void> createIfNotExists(CreateParticipantParams data) {
    return _api.participantCreateIfNotExists(_handle, data);
  }

  /// Deletes properties of this participant.
  ///
  /// @param fields - The names of the properties to delete
  Future<void> deleteFields(List<String> fields) {
    return _api.participantDeleteFields(_handle, fields);
  }

  /// Removes the user as a participant, or does nothing if they are already not a participant.
  ///
  /// @remarks
  /// Deleting a nonexistent participant is treated as success.
  ///
  /// This function will throw if client-side conversation syncing is disabled.
  Future<void> delete() {
    return _api.participantDelete(_handle);
  }

  ParticipantRef._({
    required CoreHostApi api,
    required int handle,
    required this.userId,
    required this.conversationId,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
ParticipantRef makeParticipantRef({
  required CoreHostApi api,
  required int handle,
  required String userId,
  required String conversationId,
}) {
  final ref = ParticipantRef._(
    api: api,
    handle: handle,
    userId: userId,
    conversationId: conversationId,
  );

  _participantFinalizer.attach(ref, handle);

  return ref;
}
