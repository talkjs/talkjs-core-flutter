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

/// A subscription to a specific conversation.
///
/// @remarks
/// Get a ConversationSubscription by calling [ConversationRef.subscribe]
///
/// @public
class ConversationSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  /// Resolves when the subscription starts receiving updates from the server.
  //Completer<SubscriptionState> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  //Completer<SubscriptionState> terminated;

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
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

/// A subscription to the messages in a specific conversation.
///
/// @remarks
/// Get a MessageSubscription by calling [ConversationRef.subscribeMessages]
///
/// The subscription is 'windowed'. It includes all messages since a certain point in time.
/// By default, you subscribe to the 30 most recent messages, and any new messages that are sent after you subscribe.
///
/// You can expand this window by calling [MessageSubscription.loadMore], which extends the window further into the past.
///
/// Remember to `.unsubscribe` the subscription once you are done with it.
///
/// @public
class MessageSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  /// Resolves when the subscription starts receiving updates from the server.
  ///
  /// @remarks
  /// Wait for this promise if you want to perform some action as soon as the subscription is active.
  ///
  /// The promise rejects if the subscription is terminated before it connects.
  //Completer<SubscriptionState> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  //Completer<SubscriptionState> terminated;

  /// Expand the window to include older messages
  ///
  /// @remarks
  /// Calling `loadMore` multiple times in parallel will still only load one page of messages.
  ///
  /// @param count - The number of additional messages to load. Must be between 1 and 100
  Future<void> loadMore([int? count]) {
    return _api.messageSubscriptionLoadMore(_handle, count);
  }

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
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

/// A subscription to the participants in a specific conversation.
///
/// @remarks
/// Get a ParticipantSubscription by calling [ConversationRef.subscribeParticipants]
///
/// The subscription is 'windowed'. It includes everyone who joined since a certain point in time.
/// By default, you subscribe to the 10 most recent participants, and any participants who joined after you subscribe.
///
/// You can expand this window by calling [ParticipantSubscription.loadMore], which extends the window further into the past.
/// Do not call `.loadMore` in a loop until you have loaded all participants, unless you know that the maximum number of participants is small (under 100).
///
/// Remember to `.unsubscribe` the subscription once you are done with it.
///
/// @public
class ParticipantSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  /// Resolves when the subscription starts receiving updates from the server.
  ///
  /// @remarks
  /// Wait for this promise if you want to perform some action as soon as the subscription is active.
  ///
  /// The promise rejects if the subscription is terminated before it connects.
  //Completer<SubscriptionState> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  //Completer<SubscriptionState> terminated;

  /// Expand the window to include older participants
  ///
  /// @remarks
  /// Calling `loadMore` multiple times in parallel will still only load one page of participants.
  ///
  /// Avoid calling `.loadMore` in a loop until you have loaded all participants.
  /// If you do need to call loadMore in a loop, make sure you set a small upper bound (e.g. 100) on the number of participants, where the loop will exit.
  ///
  /// @param count - The number of additional participants to load. Must be between 1 and 50. Default 10.
  Future<void> loadMore([int? count]) {
    return _api.participantSubscriptionLoadMore(_handle, count);
  }

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
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

/// A subscription to the typing status in a specific conversation
///
/// @remarks
/// Get a TypingSubscription by calling [ConversationRef.subscribeTyping].
///
/// When there are "many" people typing, the next update you receive will be once enough people stop typing.
/// Until then, your [TypingSnapshot] is still valid and does not need to changed, so `onSnapshot` will not be called.
///
/// @public
class TypingSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  /// Resolves when the subscription starts receiving updates from the server.
  ///
  /// @remarks
  /// Wait for this promise if you want to perform some action as soon as the subscription is active.
  ///
  /// The promise rejects if the subscription is terminated before it connects.
  //Completer<SubscriptionState> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  //Completer<SubscriptionState> terminated;

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
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

  /// The ID of the referenced conversation.
  ///
  /// Immutable: if you want to reference a different conversation, get a new `ConversationRef` instead.
  final String id;

  /// Fetches a snapshot of the conversation.
  ///
  /// @remarks
  /// This contains all of the information related to the conversation and the current user's participation in the conversation.
  ///
  /// @return A snapshot of the current user's view of the conversation, or `null` if the current user is not a participant (including if the conversation doesn't exist)
  Future<ConversationSnapshot?> get() {
    return _api.conversationGet(_handle);
  }

  /// Sets properties of this conversation and your participation in it.
  ///
  /// @remarks
  /// The conversation is created if a conversation with this ID doesn't already exist.
  /// You are added as a participant if you are not already a participant in the conversation.
  /// When client-side conversation syncing is disabled, you may only set your `notify` property, when you are already a participant.
  /// Everything else requires client-side conversation syncing to be enabled, and will cause the function to throw.
  ///
  /// @param params Parameters you pass when updating a conversation
  Future<void> set(SetConversationParams data) {
    return _api.conversationSet(_handle, data);
  }

  /// Creates this conversation if it does not already exist.
  ///
  /// @remarks
  /// Adds you as a participant in this conversation, if you are not already a participant.
  ///
  /// If the conversation already exists or you are already a participant, this operation is still considered successful.
  /// The promise rejects if you are not already a participant and client-side conversation syncing is disabled.
  Future<void> createIfNotExists(CreateConversationParams data) {
    return _api.conversationCreateIfNotExists(_handle, data);
  }

  /// Deletes properties of this conversation.
  ///
  /// @param fields - The names of the properties to delete
  ///
  /// @remarks
  /// To delete a field in the `custom` property, pass it as `custom.FIELD_TO_DELETE`.
  Future<void> deleteFields(List<String> fields) {
    return _api.conversationDeleteFields(_handle, fields);
  }

  /// Marks the conversation as read.
  ///
  /// @remarks
  /// The promise rejects if you are not a participant in the conversation.
  Future<void> markAsRead() {
    return _api.conversationMarkAsRead(_handle);
  }

  /// Marks the conversation as unread.
  ///
  /// @remarks
  /// The promise rejects if you are not a participant in the conversation.
  Future<void> markAsUnread() {
    return _api.conversationMarkAsUnread(_handle);
  }

  /// Marks the current user as typing in this conversation for 10 seconds.
  ///
  /// @remarks
  /// This means that other users will see a typing indicator in the UI, from the current user.
  ///
  /// The user will automatically stop typing after 10 seconds. You cannot manually mark a user as "not typing".
  /// Users are also considered "not typing" when they send a message, even if that message was sent from a different tab or using the REST API.
  ///
  /// To keep the typing indicator visible for longer, call this function again to reset the 10s timer.
  Future<void> markAsTyping() {
    return _api.conversationMarkAsTyping(_handle);
  }

  /// Get a reference to a participant in this conversation
  ///
  /// @param user the user's ID
  /// @return A reference to the given participant
  Future<ParticipantRef> participant(String user) async {
    final handle = await _api.conversationParticipant(_handle, user);

    return makeParticipantRef(
      api: _api,
      handle: handle,
      userId: user,
      conversationId: id,
    );
  }

  /// Get a reference to a message in this conversation
  ///
  /// @param id the message ID
  /// @return A reference to the message with the given ID
  Future<MessageRef> message(String messageId) async {
    final handle = await _api.conversationMessage(_handle, messageId);

    return makeMessageRef(
      api: _api,
      handle: handle,
      id: messageId,
      conversationId: id,
    );
  }

  /// Sends a message in the conversation
  ///
  /// @return A reference to the newly created message. The promise rejects if you are not a participant with write access in this conversation.
  Future<MessageRef> send(String params) async {
    final refParams = await _api.conversationSend(_handle, params);

    return makeMessageRef(
      api: _api,
      handle: refParams.handle,
      id: refParams.id,
      conversationId: refParams.conversationId,
    );
  }

  /// Subscribes to the conversation.
  ///
  /// @remarks
  /// Whenever `Subscription.state.type` is "active" and something about the conversation changes, `onSnapshot` will fire and `Subscription.state.latestSnapshot` will be updated.
  /// This includes changes to nested data. As an extreme example, `onSnapshot` would be called if `snapshot.lastMessage.referencedMessage.sender.name` changes.
  ///
  /// The snapshot is null if you are not a participant in the conversation (including when the conversation doesn't exist)
  Future<ConversationSubscription> subscribe([
    void Function(ConversationSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribe(_handle);

    conversationSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = ConversationSubscription._(api: _api, handle: handle);

    _conversationSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  /// Subscribes to the messages in the conversation.
  ///
  /// @remarks
  /// Initially, you will be subscribed to the 10 most recent messages and any new messages.
  /// Call `loadMore` to load additional older messages.
  ///
  /// Whenever a message is edited, a new message is received, or you load more messages, `onSnapshot` will fire and `Subscription.latestSnapshot` will be updated.
  /// `loadedAll` is true when the snapshot contains all the messages in the conversation.
  ///
  /// The snapshot is `null` if you are not a participant in the conversation (including when the conversation doesn't exist)
  ///
  /// @param onSnapshot function called when the list of messages is updated
  /// @return A subscription to messages.
  Future<MessageSubscription> subscribeMessages([
    void Function(List<MessageSnapshot>? snapshot, bool loadedAll)? onSnapshot,
  ]) async {
    final handle = await _api.conversationSubscribeMessages(_handle);

    messageSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = MessageSubscription._(api: _api, handle: handle);

    _messageSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  /// Subscribes to the participants in the conversation.
  ///
  /// @remarks
  /// While the subscription is active, `onSnapshot` will be called whenever the participant snapshots change.
  /// This includes when someone joins or leaves, when their participant attributes are edited, and when you load more participants.
  /// It also includes when nested data changes, such as when `snapshot[0].user.name` changes.
  /// `loadedAll` is true when `snapshot` contains all the participants in the conversation, and false if you could load more.
  ///
  /// The `snapshot` list is ordered chronologically with the participants who joined most recently at the start.
  /// When someone joins the conversation, they will be added to the start of the list.
  ///
  /// The snapshot is null if you are not a participant in the conversation (including when the conversation doesn't exist)
  ///
  /// Initially, you will be subscribed to the 10 participants who joined most recently, and any new participants.
  /// Call `loadMore` to load additional older participants. This will trigger `onSnapshot`.
  ///
  /// Remember to call `.unsubscribe` on the subscription once you are done with it.
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

  /// Subscribes to the typing status of the conversation.
  ///
  /// @remarks
  /// Whenever `Subscription.state.type` is "active" and the typing status changes, `onSnapshot` will fire and `Subscription.state.latestSnapshot` will be updated.
  /// This includes changes to nested data, such as when a user who is typing changes their name.
  ///
  /// The snapshot is null if you are not a participant in the conversation (including when the conversation doesn't exist)
  ///
  /// Note that if there are "many" people typing and another person starts to type, `onSnapshot` will not be called.
  /// This is because your existing [ManyTypingSnapshot] is still valid and did not change when the new person started to type.
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
