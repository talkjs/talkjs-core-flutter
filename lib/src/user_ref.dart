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

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

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

class UserOnlineSubscription {
  final CoreHostApi _api;
  final int _handle;

  // I have no idea on how to port state
  //SubscriptionState state;

  //Completer<SubscriptionState> connected;

  //Completer<SubscriptionState> terminated;

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

class UserRef {
  final CoreHostApi _api;
  final int _handle;

  final String id;

  Future<UserSnapshot?> get() {
    return _api.userGet(_handle);
  }

  Future<void> set(SetUserParams data) {
    return _api.userSet(_handle, data);
  }

  Future<void> createIfNotExists(CreateUserParams data) {
    return _api.userCreateIfNotExists(_handle, data);
  }

  Future<void> deleteFields(List<String> fields) {
    return _api.userDeleteFields(_handle, fields);
  }

  Future<UserSubscription> subscribe([
    void Function(UserSnapshot? snapshot)? onSnapshot,
  ]) async {
    final handle = await _api.userSubscribe(_handle);

    userSubscriptionOnSnapshots[handle] = onSnapshot;

    final subscription = UserSubscription._(api: _api, handle: handle);

    _userSubscriptionFinalizer.attach(subscription, handle);

    return subscription;
  }

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
