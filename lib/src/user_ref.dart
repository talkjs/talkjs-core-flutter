import 'dart:async';
import 'dart:convert';

import 'core.g.dart';
import 'api.dart';
import 'snapshots.dart';

final Finalizer<int> _userSubscriptionFinalizer = Finalizer((handle) async {
  await hostApi?.userSubscriptionDeleteHandle(handle);
});

class UserSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  /// Resolves when the subscription starts receiving updates from the server.
  final Future<void> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  final Future<void> terminated;

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
  Future<void> unsubscribe() {
    userSubscriptionOnSnapshots.remove(_handle);

    return _api.userSubscriptionUnsubscribe(_handle);
  }

  UserSubscription._({
    required CoreHostApi api,
    required int handle,
    required this.connected,
    required this.terminated,
  }) : _api = api,
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
  final Future<void> connected;

  /// Resolves when the subscription permanently stops receiving updates from the server.
  ///
  /// @remarks
  /// This is either because you unsubscribed or because the subscription encountered an unrecoverable error.
  final Future<void> terminated;

  /// Unsubscribe from this resource and stop receiving updates.
  ///
  /// @remarks
  /// If the subscription is already in the [UnsubscribedState] or [ErrorState], this is a no-op.
  Future<void> unsubscribe() {
    userOnlineSubscriptionOnSnapshots.remove(_handle);

    return _api.userOnlineSubscriptionUnsubscribe(_handle);
  }

  UserOnlineSubscription._({
    required CoreHostApi api,
    required int handle,
    required this.connected,
    required this.terminated,
  }) : _api = api,
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
  Future<UserSnapshot?> get() async {
    final json = await _api.userGet(_handle);
    if (json == null) {
      return null;
    }

    return UserSnapshot.fromJson(jsonDecode(json));
  }

  /// Sets properties of this user. The user is created if a user with this ID doesn't already exist.
  ///
  /// @param name - The user's name which will be displayed on the TalkJS UI
  /// @param custom - Custom metadata you have set on the user.
  /// This value acts as a patch. Remove specific properties by calling [UserRef.deleteFields]
  /// Default = no custom metadata
  /// @param locale - An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  /// @param photoUrl - An optional URL to a photo which will be displayed as the user's avatar.
  /// Default = no photo
  /// @param role - TalkJS supports multiple sets of settings, called "roles". These allow you to change the behaviour of TalkJS for
  /// different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  /// @param welcomeMessage - The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  /// @param email - An array of email addresses associated with the user.
  /// Default = no email addresses
  /// @param phone - An array of phone numbers associated with the user.
  /// Default = no phone numbers
  /// @param pushTokens - A Map of push registration tokens to use when notifying this user.
  ///
  /// Keys in the Map have the format `'provider:token_id'`, where `provider` is either
  /// `"fcm"` for Firebase Cloud Messaging or `"apns"` for Apple Push Notification Service
  ///
  /// The value for each key must be `true` to register the device for push notifications.
  /// To unregister that device call [UserRef.deleteFields]
  ///
  /// Calling [UserRef.deleteFields] with the string `pushTokens` unregisters all the previously registered devices.
  ///
  /// Default = no push tokens
  ///
  /// @remarks
  /// Properties that are `null` will not be changed.
  /// To clear / reset a property to the default, call [UserRef.deleteFields] instead.
  ///
  /// `name` is required when creating a user. The promise will reject if you don't provide a `name` and the user does not exist yet.
  Future<void> set({
    String? name,
    Map<String, String?>? custom,
    String? locale,
    String? photoUrl,
    String? role,
    String? welcomeMessage,
    List<String>? email,
    List<String>? phone,
    Map<String, bool?>? pushTokens,
  }) {
    return _api.userSet(
      _handle,
      name,
      custom,
      locale,
      photoUrl,
      role,
      welcomeMessage,
      email,
      phone,
      pushTokens,
    );
  }

  /// Creates a user with this ID, or does nothing if a user with this ID already exists.
  ///
  /// @param name - The user's name which is displayed on the TalkJS UI
  /// @param custom - Custom metadata you have set on the user.
  /// Default = no custom metadata
  /// @param locale - An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  /// @param photoUrl - An optional URL to a photo that is displayed as the user's avatar.
  /// Default = no photo
  /// @param role - TalkJS supports multiple sets of settings, called "roles". These allow you to change the behavior of TalkJS for different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  /// @param welcomeMessage - The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  /// @param email - An array of email addresses associated with the user.
  /// Default = no email addresses
  /// @param phone - An array of phone numbers associated with the user.
  /// Default = no phone numbers
  /// @param pushTokens - A Map of push registration tokens to use when notifying this user.
  ///
  /// Keys in the Map have the format `'provider:token_id'`, where `provider` is either
  /// `"fcm"` for Firebase Cloud Messaging or `"apns"` for Apple Push Notification Service
  ///
  /// Default = no push registration tokens
  ///
  /// (Value of the Map is always true)
  ///
  /// @remarks
  /// If the user already exists, this operation is still considered successful.
  Future<void> createIfNotExists({
    required String name,
    Map<String, String>? custom,
    String? locale,
    String? photoUrl,
    String? role,
    String? welcomeMessage,
    List<String>? email,
    List<String>? phone,
    Map<String, bool>? pushTokens,
  }) {
    return _api.userCreateIfNotExists(
      _handle,
      name,
      custom,
      locale,
      photoUrl,
      role,
      welcomeMessage,
      email,
      phone,
      pushTokens,
    );
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
  UserSubscription subscribe([
    void Function(UserSnapshot? snapshot)? onSnapshot,
  ]) {
    final subscriptionHandle = nextId;
    nextId += 1;

    _api.userSubscribe(_handle, subscriptionHandle);

    userSubscriptionOnSnapshots[subscriptionHandle] = onSnapshot;

    final connectedCompleter = Completer<void>();
    final terminatedCompleter = Completer<void>();
    userSubscriptionConnectedCompleters[subscriptionHandle] =
        connectedCompleter;
    userSubscriptionTerminatedCompleters[subscriptionHandle] =
        terminatedCompleter;

    final subscription = UserSubscription._(
      api: _api,
      handle: subscriptionHandle,
      connected: connectedCompleter.future,
      terminated: terminatedCompleter.future,
    );

    _userSubscriptionFinalizer.attach(subscription, subscriptionHandle);

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
  UserOnlineSubscription subscribeOnline([
    void Function(UserOnlineSnapshot? snapshot)? onSnapshot,
  ]) {
    final subscriptionHandle = nextId;
    nextId += 1;

    _api.userSubscribeOnline(_handle, subscriptionHandle);

    userOnlineSubscriptionOnSnapshots[subscriptionHandle] = onSnapshot;

    final connectedCompleter = Completer<void>();
    final terminatedCompleter = Completer<void>();
    userOnlineSubscriptionConnectedCompleters[subscriptionHandle] =
        connectedCompleter;
    userOnlineSubscriptionTerminatedCompleters[subscriptionHandle] =
        terminatedCompleter;

    final subscription = UserOnlineSubscription._(
      api: _api,
      handle: subscriptionHandle,
      connected: connectedCompleter.future,
      terminated: terminatedCompleter.future,
    );

    _userOnlineSubscriptionFinalizer.attach(subscription, subscriptionHandle);

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
