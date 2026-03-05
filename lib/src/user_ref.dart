import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show CreateUserParams, SetUserParams, UserSnapshot;

final Finalizer<int> _userSubscriptionFinalizer = Finalizer((handle) async {
  await hostApi?.userSubscriptionDeleteHandle(handle);
});

class UserSubscription {
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
    userSubscriptionOnSnapshots.remove(_handle);

    return _api.userSubscriptionUnsubscribe(_handle);
  }

  UserSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

final Finalizer<int> _userOnlineSubscriptionFinalizer = Finalizer((
  handle,
) async {
  await hostApi?.userOnlineSubscriptionDeleteHandle(handle);
});

/// A subscription to the online status of a user
///
/// @remarks
/// Get a UserOnlineSubscription by calling [UserRef.subscribeOnline].
///
/// Remember to `.unsubscribe` the subscription once you are done with it.
///
/// @public
class UserOnlineSubscription {
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
    userOnlineSubscriptionOnSnapshots.remove(_handle);

    return _api.userOnlineSubscriptionUnsubscribe(_handle);
  }

  UserOnlineSubscription._({required CoreHostApi api, required int handle})
    : _api = api,
      _handle = handle;
}

final Finalizer<int> _userFinalizer = Finalizer((handle) async {
  await hostApi?.userDeleteHandle(handle);
});

/// References the user with a given user ID.
///
/// @remarks
/// Used in all Data API operations affecting that user, such as creating the user, fetching or updating user data, or adding a user to a conversation.
/// Created via [TalkSession.user].
///
/// @public
class UserRef {
  final CoreHostApi _api;
  final int _handle;

  /// The ID of the referenced user.
  ///
  /// @remarks
  /// Immutable: if you want to reference a different user, get a new UserRef instead.
  final String id;

  /// Fetches a snapshot of the user.
  ///
  /// @remarks
  /// This contains all of a user's public information.
  /// Fetching a user snapshot doesn't require any permissions. You can read the public information of any user.
  /// Private information, such as email addresses and phone numbers, aren't included in the response.
  ///
  /// @return A snapshot of the user's public attributes, or null if the user doesn't exist.
  Future<UserSnapshot?> get() {
    return _api.userGet(_handle);
  }

  /// Sets properties of this user. The user is created if a user with this ID doesn't already exist.
  ///
  /// @remarks
  /// `name` is required when creating a user. The function will throw if you don't provide a `name` and the user does not exist yet.
  Future<void> set(SetUserParams data) {
    return _api.userSet(_handle, data);
  }

  /// Creates a user with this ID, or does nothing if a user with this ID already exists.
  ///
  /// @remarks
  /// If the user already exists, this operation is still considered successful.
  Future<void> createIfNotExists(CreateUserParams data) {
    return _api.userCreateIfNotExists(_handle, data);
  }

  /// Deletes properties of this user.
  ///
  /// @param fields - The names of the properties to delete
  ///
  /// @remarks
  /// To delete a field in the `custom` property, pass it as `custom.FIELD_TO_DELETE`.
  /// To delete a field in the `pushTokens` property, pass it as `pushTokens.FIELD_TO_DELETE`.
  Future<void> deleteFields(List<String> fields) {
    return _api.userDeleteFields(_handle, fields);
  }

  /// Subscribe to this user's state.
  ///
  /// @remarks
  /// While the subscription is active, `onSnapshot` will be called when the user is created or the snapshot changes.
  ///
  /// Remember to call `.unsubscribe` on the subscription once you are done with it.
  ///
  /// @return A subscription to the user
  Future<UserSubscription> subscribe([
    void Function(UserSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.userSubscribe(_handle);

    userSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = UserSubscription._(api: _api, handle: handle);

    _userSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  /// Subscribe to this user and their online status.
  ///
  /// @remarks
  /// While the subscription is active, `onSnapshot` will be called when the user is created or the snapshot changes (including changes to the nested UserSnapshot).
  ///
  /// Remember to call `.unsubscribe` on the subscription once you are done with it.
  ///
  /// @return A subscription to the user's online status
  Future<UserOnlineSubscription> subscribeOnline([
    void Function(UserOnlineSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.userSubscribeOnline(_handle);

    userOnlineSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = UserOnlineSubscription._(api: _api, handle: handle);

    _userOnlineSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

  UserRef._({required CoreHostApi api, required int handle, required this.id})
    : _api = api,
      _handle = handle;
}

// Implementation detail
UserRef makeUserRef({
  required CoreHostApi api,
  required int handle,
  required String id,
  bool attachFinalizer = true,
}) {
  final ref = UserRef._(api: api, handle: handle, id: id);

  if (attachFinalizer) {
    _userFinalizer.attach(ref, handle);
  }

  return ref;
}
