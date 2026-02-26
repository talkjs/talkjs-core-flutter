import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/core.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/example/talkjs_core_flutter/Core.g.kt',
    kotlinOptions: KotlinOptions(),
    dartPackageName: 'talkjs_core_flutter',
  ),
)
class ApiUrlOptions {
  String realtimeWsApiUrl;
  String internalHttpApiUrl;
  String restApiHttpUrl;

  ApiUrlOptions({
    required this.realtimeWsApiUrl,
    required this.internalHttpApiUrl,
    required this.restApiHttpUrl,
  });
}

class TalkSessionOptions {
  /// Your app's unique TalkJS ID. Get it from the **Settings** page of the [dashboard](https://talkjs.com/dashboard).
  String appId;

  /// The `id` of the user you want to connect and act as. Any messages you send will be sent as this user.
  String userId;

  /// A token to authenticate the session with. Ignored if a TalkSession object already exists for this appId + userId.
  String? token;

  /// A callback that fetches a new token from your backend and returns it. If this callback throws an error, the session will terminate. Your callback should retry failed requests. Ignored if a TalkSession object already exists for this appId + userId.
  //val tokenFetcher: (suspend () -> String)? = null,

  /// @suppress
  /// If set to true, then `getTalkSession` will bypass the registry and create a new session
  /// This option is the only way to have two sessions for the same user with different auth tokens.
  ///
  /// IE it's an undocumented, secret escape hatch for that specific weird niche use case.
  /// It *is* designed to be used by customers, but it's undocumented so they'd only find out about it
  /// if they contacted live support and we told them about it.
  bool? forceCreateNew;

  /// @suppress
  String? signature;

  /// @suppress
  ApiUrlOptions? apiUrls;

  /// @suppress
  ///
  /// note: it makes little sense to have both `host` and `apiUrls`. I intend to
  /// remove `apiUrls` in the future in favour of just `host`.
  String? host;

  /// @suppress
  String? clientBuild;

  TalkSessionOptions({
    required this.appId,
    required this.userId,
    this.token,
    this.forceCreateNew,
    this.signature,
    this.apiUrls,
    this.host,
    this.clientBuild,
  });
}

class CreateUserParams {
  /// The user's name which is displayed on the TalkJS UI
  String name;

  /// Custom metadata you have set on the user.
  /// Default = no custom metadata
  Map<String, String>? custom;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  String? locale;

  /// An optional URL to a photo that is displayed as the user's avatar.
  /// Default = no photo
  String? photoUrl;

  /// TalkJS supports multiple sets of settings, called "roles". These allow you to change the behavior of TalkJS for different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  String? role;

  /// The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  String? welcomeMessage;

  /// An array of email addresses associated with the user.
  /// Default = no email addresses
  List<String>? email;

  /// An array of phone numbers associated with the user.
  /// Default = no phone numbers
  List<String>? phone;

  /// A Map of push registration tokens to use when notifying this user.
  ///
  /// Keys in the Map have the format `'provider:token_id'`, where `provider` is either
  /// `"fcm"` for Firebase Cloud Messaging or `"apns"` for Apple Push Notification Service
  ///
  /// Default = no push registration tokens
  ///
  /// (Value of the Map is always true)
  Map<String, bool>? pushTokens;

  CreateUserParams({
    required this.name,
    this.custom,
    this.locale,
    this.photoUrl,
    this.role,
    this.welcomeMessage,
    this.email,
    this.phone,
    this.pushTokens,
  });
}

class SetUserParams {
  /// The user's name which will be displayed on the TalkJS UI
  String? name;

  /// Custom metadata you have set on the user.
  /// This value acts as a patch. Remove specific properties by calling [UserRef.deleteFields]
  /// Default = no custom metadata
  Map<String, String?>? custom;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  String? locale;

  /// An optional URL to a photo which will be displayed as the user's avatar.
  /// Default = no photo
  String? photoUrl;

  /// TalkJS supports multiple sets of settings, called "roles". These allow you to change the behaviour of TalkJS for
  /// different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  String? role;

  /// The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  String? welcomeMessage;

  /// An array of email addresses associated with the user.
  /// Default = no email addresses
  List<String>? email;

  /// An array of phone numbers associated with the user.
  /// Default = no phone numbers
  List<String>? phone;

  /// A Map of push registration tokens to use when notifying this user.
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
  Map<String, bool?>? pushTokens;

  SetUserParams({
    this.name,
    this.custom,
    this.locale,
    this.photoUrl,
    this.role,
    this.welcomeMessage,
    this.email,
    this.phone,
    this.pushTokens,
  });
}

class UserSnapshot {
  /// The unique ID that is used to identify the user in TalkJS
  String id;

  /// The user's name, which is displayed on the TalkJS UI
  String name;

  /// Custom metadata you have set on the user
  Map<String, String> custom;

  /// TalkJS supports multiple sets of settings for users, called "roles". Roles allow you to change the behavior of TalkJS for different users.
  /// You have full control over which user gets which configuration.
  String role;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// For more information, see: [localization](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  ///
  /// When `locale` is null, the app's default locale will be used
  String? locale;

  /// An optional URL to a photo that is displayed as the user's avatar
  String? photoUrl;

  /// The default message a person sees when starting a chat with this user
  String? welcomeMessage;

  UserSnapshot({
    required this.id,
    required this.name,
    required this.custom,
    required this.role,
    this.locale,
    this.photoUrl,
    this.welcomeMessage,
  });
}

class UserOnlineSnapshot {
  /// The user this snapshot relates to
  UserSnapshot user;

  /// Whether the user is connected right now
  ///
  /// @remarks
  /// Users are considered connected whenever they have an active websocket connection to the TalkJS servers.
  /// In practice, this means:
  ///
  /// People using the [JS Data API](https://talkjs.com/docs/Reference/JavaScript_Data_API/) are considered connected if they are subscribed to something, or if they sent a request in the last few seconds.
  /// Creating a `TalkSession` is not enough to appear connected.
  ///
  /// People using [Components](https://talkjs.com/docs/Reference/Components/), are considered connected if they have a UI open.
  ///
  /// People using the [JavaScript SDK](https://talkjs.com/docs/Reference/JavaScript_Chat_SDK/), [React SDK](https://talkjs.com/docs/Reference/React_SDK/Installation/), [React Native SDK](https://talkjs.com/docs/Reference/React_Native_SDK/Installation/), or [Flutter SDK](https://talkjs.com/docs/Reference/Flutter_SDK/Installation/) are considered connected whenever they have an active `Session` object.
  bool isConnected;

  UserOnlineSnapshot({required this.user, required this.isConnected});
}

@HostApi()
abstract class CoreHostApi {
  // Session
  int getTalkSession(TalkSessionOptions options);
  void sessionDelete(int handle);
  int sessionUser(int handle, String id);

  // User
  void userDelete(int handle);

  @async
  UserSnapshot? userGet(int handle);

  @async
  void userSet(int handle, SetUserParams data);

  @async
  void userCreateIfNotExists(int handle, CreateUserParams data);

  @async
  void userDeleteFields(int handle, List<String> fields);

  int userSubscribe(int handle);
  int userSubscribeOnline(int handle);

  // UserSubscription
  void userSubscriptionDelete(int handle);
  void userSubscriptionUnsubscribe(int handle);

  // UserOnlineSubscription
  void userOnlineSubscriptionDelete(int handle);
  void userOnlineSubscriptionUnsubscribe(int handle);
}

@FlutterApi()
abstract class CoreFlutterApi {
  void newUserSnapshot(int handle, UserSnapshot? snapshot);
  void newUserOnlineSnapshot(int handle, UserOnlineSnapshot? snapshot);
}
