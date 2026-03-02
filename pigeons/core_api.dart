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

enum ConversationAccess { read, readWrite }

enum NotificationSettings { yes, no, mentionsOnly }

class CreateConversationParams {
  /// The conversation subject to display in the chat header.
  /// Default = no subject, list participant names instead
  String? subject;

  /// The URL for the conversation photo to display in the chat header.
  /// Default = no photo, show a placeholder image.
  String? photoUrl;

  /// System messages which are sent at the beginning of a conversation.
  /// Default = no messages.
  List<String>? welcomeMessages;

  /// Custom metadata you have set on the conversation.
  /// Default = no custom metadata
  Map<String, String>? custom;

  /// Your access to the conversation.
  /// Default = `READ_WRITE` access.
  ConversationAccess? access;

  /// Your notification settings.
  /// Default = `TRUE`
  NotificationSettings? notify;

  CreateConversationParams({
    this.subject,
    this.photoUrl,
    this.welcomeMessages,
    this.custom,
    this.access,
    this.notify,
  });
}

class SetConversationParams {
  /// The conversation subject to display in the chat header.
  /// Default = no subject, list participant names instead.
  String? subject;

  /// The URL for the conversation photo to display in the chat header.
  /// Default = no photo, show a placeholder image.
  String? photoUrl;

  /// System messages which are sent at the beginning of a conversation.
  /// Default = no messages.
  List<String>? welcomeMessages;

  /// Custom metadata you have set on the conversation.
  /// This value acts as a patch. Remove specific properties by calling [ConversationRef.deleteFields]
  /// Default = no custom metadata
  Map<String, String?>? custom;

  /// Your access to the conversation.
  /// Default = `READ_WRITE` access.
  ConversationAccess? access;

  /// Your notification settings.
  /// Default = `TRUE`
  NotificationSettings? notify;

  SetConversationParams({
    this.subject,
    this.photoUrl,
    this.welcomeMessages,
    this.custom,
    this.access,
    this.notify,
  });
}

class ReactionSnapshot {
  /// Which emoji the users reacted with.
  String emoji;

  /// The number of times this emoji has been added to the message.
  int count;

  /// Whether the current user has reacted to the message with this emoji.
  bool currentUserReacted;

  ReactionSnapshot({
    required this.emoji,
    required this.count,
    required this.currentUserReacted,
  });
}

enum MessageType { userMessage, systemMessage }

enum MessageOrigin { web, rest, import, email }

class ReferencedMessageSnapshot {
  /// The unique ID that is used to identify the message in TalkJS
  String id;

  /// Referenced messages are always `USER_MESSAGE` because you cannot reply to a system message.
  MessageType type;

  /// A snapshot of the user who sent the message.
  /// The user's attributes may have been updated since they sent the message, in which case this snapshot contains the updated data.
  /// It is not a historical snapshot.
  ///
  /// @remarks
  /// Guaranteed to be set, unlike in MessageSnapshot, because you cannot reference a SystemMessage
  UserSnapshot? sender;

  /// Custom metadata you have set on the message
  Map<String, String> custom;

  /// Time at which the message was sent, as a unix timestamp in milliseconds
  int createdAt;

  /// Time at which the message was last edited, as a unix timestamp in milliseconds.
  /// `null` if the message has never been edited.
  int? editedAt;

  /// The ID of the message that this message is a reply to, or null if this message is not a reply.
  ///
  /// @remarks
  /// Since this is a snapshot of a referenced message, we do not automatically expand its referenced message.
  /// The ID of its referenced message is provided here instead.
  String? referencedMessageId;

  /// Where this message originated from:
  ///
  /// - `WEB` = Message sent via the UI or via `ConversationBuilder.sendMessage`
  ///
  /// - `REST` = Message sent via the REST API's "send message" endpoint
  ///
  /// - `IMPORT` = Message sent via the REST API's "import messages" endpoint
  ///
  /// - `EMAIL` = Message sent by replying to an email notification
  MessageOrigin origin;

  /// The contents of the message, as a plain text string without any formatting or attachments.
  /// Useful for showing in a conversation list or in notifications.
  String plaintext;

  /// The main body of the message, as a list of blocks that are rendered top-to-bottom.
  //List<ContentBlock> content;

  /// All the emoji reactions that have been added to this message.
  List<ReactionSnapshot> reactions;

  ReferencedMessageSnapshot({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessageId,
    required this.origin,
    required this.plaintext,
    required this.reactions,
  });
}

class MessageSnapshot {
  /// The unique ID that is used to identify the message in TalkJS
  String id;

  /// Whether this message was "from a user" or a general system message without a specific sender.
  ///
  /// The `sender` property is always present for `USER_MESSAGE` messages and never present for `SYSTEM_MESSAGE` messages.
  MessageType type;

  /// A snapshot of the user who sent the message, or null if it is a system message.
  /// The user's attributes may have been updated since they sent the message, in which case this snapshot contains the updated data.
  /// It is not a historical snapshot.
  UserSnapshot? sender;

  /// Custom metadata you have set on the message
  Map<String, String> custom;

  /// Time at which the message was sent, as a unix timestamp in milliseconds.
  int createdAt;

  /// Time at which the message was last edited, as a unix timestamp in milliseconds.
  /// `null` if the message has never been edited.
  int? editedAt;

  /// A snapshot of the message that this message is aa reply to, or `null` if this message is not a reply.
  ///
  /// Only UserMessages can reference other messages.
  /// The referenced message snapshot does not have a `referencedMessage` field.
  /// Instead, it has `referencedMessageId`.
  /// This prevents TalkJS fetching an unlimited number of messages in a long chain of replies.
  ReferencedMessageSnapshot? referencedMessage;

  /// Where this message origiranted from:
  ///
  /// - `WEB` = Message sent via the UI or via `ConversationBuilder.sendMessage`
  /// - `REST` = Message sent via the REST API's "send message" endpoint
  /// - `IMPORT` = Message sent via the REST API's "import messages" endpoint
  /// - `EMAIL` = Message sent by replying to an email notification
  MessageOrigin origin;

  /// The contents of the message, as a plain text string without any formatting or attachments.
  /// Useful for showing in a conversation list or in notifications.
  String plaintext;

  /// The main body of the message, as a list of blocks that are rendered top-to-bottom.
  //List<ContentBlock> content;

  /// All the emoji reactions that have been added to this message.
  ///
  /// @remarks
  /// There can be up to 50 different reactions on each message.
  List<ReactionSnapshot> reactions;

  MessageSnapshot({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessage,
    required this.origin,
    required this.plaintext,
    required this.reactions,
  });
}

class ConversationSnapshot {
  /// The ID of the conversation
  String id;

  /// Contains the conversation subject, or `null` if the conversation does not have a subject specified.
  String? subject;

  /// Contains the URL of a photo to represent the topic of the conversation or `null` if the conversation does not have a photo specified.
  String? photoUrl;

  /// One or more welcome messages that will be rendered at the start of this conversation as system messages.
  ///
  /// @remarks
  /// Welcome messages are rendered in the UI as messages, but they are not real messages.
  /// This means they do not appear when you list messages using the REST API or JS/Kotlin Data API, and you cannot reply or react to them.
  List<String> welcomeMessages;

  /// Custom metadata you have set on the conversation
  Map<String, String> custom;

  /// The date that the conversation was created, as a unix timestamp in milliseconds.
  int createdAt;

  /// The date that the current user joined the conversation, as a unix timestamp in milliseconds.
  int joinedAt;

  /// The last message sent in this conversation, or `null` if not messages have been sent.
  MessageSnapshot? lastMessage;

  /// The number of messages in this conversation that the current user hasn't read.
  int unreadMessageCount;

  /// The most recent date that the current user read the conversation.
  ///
  /// @remarks
  /// This value is updated whenever you read a message in a chat UI, open an email notification, or mark the conversation as read using an API like [ConversationRef.markAsRead].
  ///
  /// Any messages sent after this timestamp are unread messages.
  int readUntil;

  /// Everyone in the conversation has read any messages sent on or before this date.
  ///
  /// @remarks
  /// This is the minimum of all the participants' `readUntil` values.
  /// Any messages sent on or before this timestamp should show a "read" indicator in the UI.
  ///
  /// This value will rarely change in very large conversations.
  /// If just one person stops checking their messages, `everyoneReadUntil` will never update.
  int everyoneReadUntil;

  /// Whether the conversation should be considered unread.
  ///
  /// This can be true even when `unreadMessageCount` is zero, if the user has manually marked the conversation as unread.
  bool isUnread;

  /// The current user's permission level in this conversation.
  ConversationAccess access;

  /// The current user's notification settings for this conversation.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  NotificationSettings notify;

  /// @suppress
  /// For back-compat
  int? lastMessageAt;

  ConversationSnapshot({
    required this.id,
    this.subject,
    this.photoUrl,
    required this.welcomeMessages,
    required this.custom,
    required this.createdAt,
    required this.joinedAt,
    this.lastMessage,
    required this.unreadMessageCount,
    required this.readUntil,
    required this.everyoneReadUntil,
    required this.isUnread,
    required this.access,
    required this.notify,
    this.lastMessageAt,
  });
}

class SetParticipantParams {
  /// The level of access the participant should have in the conversation.
  /// Default = `READ_WRITE` access.
  ConversationAccess? access;

  /// When the participant should be notified about new messages in this conversation.
  /// Default = `TRUE`.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  NotificationSettings? notify;

  SetParticipantParams({this.access, this.notify});
}

class CreateParticipantParams {
  /// The level of access the participant should have in the conversation.
  /// Default = `READ_WRITE` access.
  ConversationAccess? access;

  /// When the participant should be notified about new messages in this conversation.
  /// Default = `TRUE`.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  NotificationSettings? notify;

  CreateParticipantParams({this.access, this.notify});
}

class ParticipantSnapshot {
  /// The user who this Participant Snapshot is referring to
  UserSnapshot user;

  /// The level of access this participant has in the conversation.
  ConversationAccess access;

  /// When the participant will be notified about new messages in this conversation.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  NotificationSettings notify;

  /// The date that this user joined the conversation, as a unix timestamp in milliseconds.
  int joinedAt;

  ParticipantSnapshot({
    required this.user,
    required this.access,
    required this.notify,
    required this.joinedAt,
  });
}

@HostApi()
abstract class CoreHostApi {
  // Session
  int getTalkSession(TalkSessionOptions options);
  void sessionDeleteHandle(int handle);
  int sessionUser(int handle, String id);
  int sessionConversation(int handle, String id);

  // User
  void userDeleteHandle(int handle);

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
  void userSubscriptionDeleteHandle(int handle);
  void userSubscriptionUnsubscribe(int handle);

  // UserOnlineSubscription
  void userOnlineSubscriptionDeleteHandle(int handle);
  void userOnlineSubscriptionUnsubscribe(int handle);

  // Conversation
  void conversationDeleteHandle(int handle);

  @async
  ConversationSnapshot? conversationGet(int handle);

  @async
  void conversationSet(int handle, SetConversationParams data);

  @async
  void conversationCreateIfNotExists(int handle, CreateConversationParams data);

  @async
  void conversationDeleteFields(int handle, List<String> fields);

  int conversationParticipant(int handle, String user);
  int conversationMessage(int handle, String messageId);

  int conversationSubscribe(int handle);

  // ConversationSubscription
  void conversationSubscriptionDeleteHandle(int handle);
  void conversationSubscriptionUnsubscribe(int handle);

  // Participant
  void participantDeleteHandle(int handle);

  @async
  ParticipantSnapshot? participantGet(int handle);

  @async
  void participantSet(int handle, SetParticipantParams data);

  @async
  void participantEdit(int handle, SetParticipantParams data);

  @async
  void participantCreateIfNotExists(int handle, CreateParticipantParams data);

  @async
  void participantDeleteFields(int handle, List<String> fields);

  @async
  void participantDelete(int handle);

  // Message
  void messageDeleteHandle(int handle);

  @async
  MessageSnapshot? messageGet(int handle);

  @async
  void messageEdit(int handle, String params);

  @async
  void messageDeleteFields(int handle, List<String> fields);

  @async
  void messageDelete(int handle);
}

@FlutterApi()
abstract class CoreFlutterApi {
  void newUserSnapshot(int handle, UserSnapshot? snapshot);
  void newUserOnlineSnapshot(int handle, UserOnlineSnapshot? snapshot);
  void newConversationSnapshot(int handle, ConversationSnapshot? snapshot);
}
