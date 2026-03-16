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

class ReferencedMessageSnapshotJson {
  String id;
  MessageType type;
  UserSnapshot? sender;
  Map<String, String> custom;
  int createdAt;
  int? editedAt;
  String? referencedMessageId;
  MessageOrigin origin;
  String plaintext;
  String contentJson;
  List<ReactionSnapshot> reactions;

  ReferencedMessageSnapshotJson({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessageId,
    required this.origin,
    required this.plaintext,
    required this.contentJson,
    required this.reactions,
  });
}

class MessageSnapshotJson {
  String id;
  MessageType type;
  UserSnapshot? sender;
  Map<String, String> custom;
  int createdAt;
  int? editedAt;
  ReferencedMessageSnapshotJson? referencedMessage;
  MessageOrigin origin;
  String plaintext;
  String contentJson;
  List<ReactionSnapshot> reactions;

  MessageSnapshotJson({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessage,
    required this.origin,
    required this.plaintext,
    required this.contentJson,
    required this.reactions,
  });
}

class MessageRefParams {
  int handle;
  String id;
  String conversationId;

  MessageRefParams({
    required this.handle,
    required this.id,
    required this.conversationId,
  });
}

/// Parameters you can pass when sending a message
class SendTextMessageParams {
  /// The text to send in the message.
  String text;

  /// Custom metadata you have set on the user.
  /// Default = no custom metadata
  Map<String, String>? custom;

  /// The message that you are replying to.
  /// Default = not a reply
  String? referencedMessage;

  SendTextMessageParams({
    required this.text,
    this.custom,
    this.referencedMessage,
  });
}

/// Parameters you can pass when editing a message.
///
/// @remarks
/// Properties that are `null` will not be changed.
/// To clear / reset a property to the default, call [MessageRef.deleteFields] instead.
///
class EditTextMessageParams {
  /// Custom metadata you have set on the user.
  /// This value acts as a patch. Remove specific properties by calling [MessageRef.deleteFields]
  /// Default = no custom metadata
  Map<String, String?>? custom;

  /// The new text to set as the message body
  String? text;

  EditTextMessageParams({this.custom, this.text});
}

class SendMessageParamsJson {
  String contentJson;
  Map<String, String>? custom;
  String? referencedMessage;

  SendMessageParamsJson({
    required this.contentJson,
    this.custom,
    this.referencedMessage,
  });
}

class EditMessageParamsJson {
  Map<String, String?>? custom;
  String? contentJson;

  EditMessageParamsJson({this.custom, this.contentJson});
}

class ConversationSnapshotJson {
  String id;
  String? subject;
  String? photoUrl;
  List<String> welcomeMessages;
  Map<String, String> custom;
  int createdAt;
  int joinedAt;
  MessageSnapshotJson? lastMessage;
  int unreadMessageCount;
  int readUntil;
  int everyoneReadUntil;
  bool isUnread;
  ConversationAccess access;
  NotificationSettings notify;
  int? lastMessageAt;

  ConversationSnapshotJson({
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

class TypingSnapshot {
  /// Check this to differentiate between few people are typing (`false`) and many people are typing (`true`).
  ///
  /// @remarks
  /// When `false`, you can see the list of users who are typing in the `users` property.
  bool many;

  /// The users who are currently typing in this conversation.
  ///
  /// @remarks
  /// The list is in chronological order, starting with the users who have been typing the longest.
  /// The current user is never contained in the list, only other users.
  /// When the `many` property is `true`, this property is `null`.
  List<UserSnapshot>? users;

  TypingSnapshot({required this.many, this.users});
}

class GenericFileMetadata {
  /// The name of the file including extension.
  String filename;

  GenericFileMetadata({required this.filename});
}

class ImageFileMetadata {
  /// The name of the file including extension.
  String filename;

  /// The width of the image in pixels, if known.
  int? width;

  /// The height of the image in pixels, if known.
  int? height;

  ImageFileMetadata({required this.filename, this.width, this.height});
}

class VideoFileMetadata {
  /// The name of the file including extension.
  String filename;

  /// The width of the video in pixels, if known.
  int? width;

  /// The height of the video in pixels, if known.
  int? height;

  /// The duration of the video in seconds, if known.
  double? duration;

  VideoFileMetadata({
    required this.filename,
    this.width,
    this.height,
    this.duration,
  });
}

class AudioFileMetadata {
  /// The name of the file including extension.
  String filename;

  /// The duration of the audio file in seconds, if known.
  double? duration;

  AudioFileMetadata({required this.filename, this.duration});
}

class VoiceRecordingFileMetadata {
  /// The name of the file including extension.
  String filename;

  /// The duration of the recording in seconds, if known.
  double? duration;

  VoiceRecordingFileMetadata({required this.filename, this.duration});
}

@HostApi()
abstract class CoreHostApi {
  // Session
  int getTalkSession(TalkSessionOptions options);
  void sessionDeleteHandle(int handle);
  int sessionUser(int handle, String id);
  int sessionConversation(int handle, String id);
  int sessionSubscribeConversations(int handle);
  int sessionOnError(int handle);

  @async
  String sessionUploadFile(
    int handle,
    Uint8List data,
    GenericFileMetadata metadata,
  );

  @async
  String sessionUploadImage(
    int handle,
    Uint8List data,
    ImageFileMetadata metadata,
  );

  @async
  String sessionUploadVideo(
    int handle,
    Uint8List data,
    VideoFileMetadata metadata,
  );

  @async
  String sessionUploadAudio(
    int handle,
    Uint8List data,
    AudioFileMetadata metadata,
  );

  @async
  String sessionUploadVoice(
    int handle,
    Uint8List data,
    VoiceRecordingFileMetadata metadata,
  );

  // ConversationListSubscription
  void conversationListSubscriptionDeleteHandle(int handle);

  @async
  void conversationListSubscriptionLoadMore(int handle, int? count);

  void conversationListSubscriptionUnsubscribe(int handle);

  // ErrorSubscription
  void sessionOnErrorDeleteHandle(int handle);
  void sessionOnErrorUnsubscribe(int handle);

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
  ConversationSnapshotJson? conversationGet(int handle);

  @async
  void conversationSet(int handle, SetConversationParams data);

  @async
  void conversationCreateIfNotExists(int handle, CreateConversationParams data);

  @async
  void conversationDeleteFields(int handle, List<String> fields);

  @async
  void conversationMarkAsRead(int handle);

  @async
  void conversationMarkAsUnread(int handle);

  @async
  void conversationMarkAsTyping(int handle);

  int conversationParticipant(int handle, String user);
  int conversationMessage(int handle, String messageId);

  @async
  MessageRefParams conversationSend(int handle, String params);

  @async
  MessageRefParams conversationSendText(
    int handle,
    SendTextMessageParams params,
  );

  @async
  MessageRefParams conversationSendMessage(
    int handle,
    SendMessageParamsJson params,
  );

  int conversationSubscribe(int handle);
  int conversationSubscribeMessages(int handle);
  int conversationSubscribeParticipants(int handle);
  int conversationSubscribeTyping(int handle);

  // ConversationSubscription
  void conversationSubscriptionDeleteHandle(int handle);
  void conversationSubscriptionUnsubscribe(int handle);

  // MessageSubscription
  void messageSubscriptionDeleteHandle(int handle);

  @async
  void messageSubscriptionLoadMore(int handle, int? count);

  void messageSubscriptionUnsubscribe(int handle);

  // ParticipantSubscription
  void participantSubscriptionDeleteHandle(int handle);

  @async
  void participantSubscriptionLoadMore(int handle, int? count);

  void participantSubscriptionUnsubscribe(int handle);

  // TypingSubscription
  void typingSubscriptionDeleteHandle(int handle);
  void typingSubscriptionUnsubscribe(int handle);

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
  MessageSnapshotJson? messageGet(int handle);

  @async
  void messageEdit(int handle, String params);

  @async
  void messageEditText(int handle, EditTextMessageParams params);

  @async
  void messageEditMessage(int handle, EditMessageParamsJson params);

  @async
  void messageDeleteFields(int handle, List<String> fields);

  @async
  void messageDelete(int handle);

  int messageReaction(int handle, String emoji);

  // Reaction
  void reactionDeleteHandle(int handle);

  @async
  void reactionAdd(int handle);

  @async
  void reactionRemove(int handle);

  // Test endpoints
  String testContentSerialization(String contentJson);
}

@FlutterApi()
abstract class CoreFlutterApi {
  void newUserSnapshot(int handle, UserSnapshot? snapshot);
  void newUserOnlineSnapshot(int handle, UserOnlineSnapshot? snapshot);
  void newConversationSnapshot(int handle, ConversationSnapshotJson? snapshot);
  void newConversationListSnapshot(
    int handle,
    List<ConversationSnapshotJson> snapshot,
    bool loadedAll,
  );
  void newSessionError(int handle, String message);
  void newMessageSnapshot(
    int handle,
    List<MessageSnapshotJson>? snapshot,
    bool loadedAll,
  );
  void newParticipantSnapshot(
    int handle,
    List<ParticipantSnapshot>? snapshot,
    bool loadedAll,
  );
  void newTypingSnapshot(int handle, TypingSnapshot? snapshot);
  void userSubscriptionConnectedResolve(int handle);
  void userSubscriptionConnectedReject(int handle, String error);
  void userSubscriptionTerminatedResolve(int handle);
  void userSubscriptionTerminatedReject(int handle, String error);
  void userOnlineSubscriptionConnectedResolve(int handle);
  void userOnlineSubscriptionConnectedReject(int handle, String error);
  void userOnlineSubscriptionTerminatedResolve(int handle);
  void userOnlineSubscriptionTerminatedReject(int handle, String error);
  void conversationListSubscriptionConnectedResolve(int handle);
  void conversationListSubscriptionConnectedReject(int handle, String error);
  void conversationListSubscriptionTerminatedResolve(int handle);
  void conversationListSubscriptionTerminatedReject(int handle, String error);
  void conversationSubscriptionConnectedResolve(int handle);
  void conversationSubscriptionConnectedReject(int handle, String error);
  void conversationSubscriptionTerminatedResolve(int handle);
  void conversationSubscriptionTerminatedReject(int handle, String error);
  void messageSubscriptionConnectedResolve(int handle);
  void messageSubscriptionConnectedReject(int handle, String error);
  void messageSubscriptionTerminatedResolve(int handle);
  void messageSubscriptionTerminatedReject(int handle, String error);
  void participantSubscriptionConnectedResolve(int handle);
  void participantSubscriptionConnectedReject(int handle, String error);
  void participantSubscriptionTerminatedResolve(int handle);
  void participantSubscriptionTerminatedReject(int handle, String error);
  void typingSubscriptionConnectedResolve(int handle);
  void typingSubscriptionConnectedReject(int handle, String error);
  void typingSubscriptionTerminatedResolve(int handle);
  void typingSubscriptionTerminatedReject(int handle, String error);
}
