import 'core.g.dart';
import 'entity_tree.dart';

/// A snapshot of a message that another message is replying to.
///
/// @remarks
/// Unlike [MessageSnapshot], this type does not expand the referenced message further.
/// Instead of a nested [MessageSnapshot], it only contains the [referencedMessageId],
/// preventing TalkJS from fetching an unlimited number of messages in a long chain of replies.
///
/// @public
class ReferencedMessageSnapshot {
  /// The unique ID that is used to identify the message in TalkJS
  final String id;

  /// Referenced messages are always `USER_MESSAGE` because you cannot reply to a system message.
  final MessageType type;

  /// A snapshot of the user who sent the message.
  /// The user's attributes may have been updated since they sent the message, in which case this snapshot contains the updated data.
  /// It is not a historical snapshot.
  ///
  /// @remarks
  /// Guaranteed to be set, unlike in MessageSnapshot, because you cannot reference a SystemMessage
  final UserSnapshot? sender;

  /// Custom metadata you have set on the message
  final Map<String, String> custom;

  /// Time at which the message was sent, as a unix timestamp in milliseconds
  final int createdAt;

  /// Time at which the message was last edited, as a unix timestamp in milliseconds.
  /// `null` if the message has never been edited.
  final int? editedAt;

  /// The ID of the message that this message is a reply to, or null if this message is not a reply.
  ///
  /// @remarks
  /// Since this is a snapshot of a referenced message, we do not automatically expand its referenced message.
  /// The ID of its referenced message is provided here instead.
  final String? referencedMessageId;

  /// Where this message originated from:
  ///
  /// - `WEB` = Message sent via the UI or via `ConversationBuilder.sendMessage`
  ///
  /// - `REST` = Message sent via the REST API's "send message" endpoint
  ///
  /// - `IMPORT` = Message sent via the REST API's "import messages" endpoint
  ///
  /// - `EMAIL` = Message sent by replying to an email notification
  final MessageOrigin origin;

  /// The contents of the message, as a plain text string without any formatting or attachments.
  /// Useful for showing in a conversation list or in notifications.
  final String plaintext;

  /// The main body of the message, as a list of blocks that are rendered top-to-bottom.
  final List<ContentBlock> content;

  /// All the emoji reactions that have been added to this message.
  final List<ReactionSnapshot> reactions;

  const ReferencedMessageSnapshot._({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessageId,
    required this.origin,
    required this.plaintext,
    required this.content,
    required this.reactions,
  });
}

/// A snapshot of a message in a conversation.
///
/// @remarks
/// A snapshot is a frozen view of the message's attributes at the time it was fetched.
/// If the message is edited after the snapshot is taken, the snapshot will not automatically update.
///
/// @public
class MessageSnapshot {
  /// The unique ID that is used to identify the message in TalkJS
  final String id;

  /// Whether this message was "from a user" or a general system message without a specific sender.
  ///
  /// The `sender` property is always present for `USER_MESSAGE` messages and never present for `SYSTEM_MESSAGE` messages.
  final MessageType type;

  /// A snapshot of the user who sent the message, or null if it is a system message.
  /// The user's attributes may have been updated since they sent the message, in which case this snapshot contains the updated data.
  /// It is not a historical snapshot.
  final UserSnapshot? sender;

  /// Custom metadata you have set on the message
  final Map<String, String> custom;

  /// Time at which the message was sent, as a unix timestamp in milliseconds.
  final int createdAt;

  /// Time at which the message was last edited, as a unix timestamp in milliseconds.
  /// `null` if the message has never been edited.
  final int? editedAt;

  /// A snapshot of the message that this message is a reply to, or `null` if this message is not a reply.
  ///
  /// Only UserMessages can reference other messages.
  /// The referenced message snapshot does not have a `referencedMessage` field.
  /// Instead, it has `referencedMessageId`.
  /// This prevents TalkJS fetching an unlimited number of messages in a long chain of replies.
  final ReferencedMessageSnapshot? referencedMessage;

  /// Where this message originated from:
  ///
  /// - `WEB` = Message sent via the UI or via `ConversationBuilder.sendMessage`
  /// - `REST` = Message sent via the REST API's "send message" endpoint
  /// - `IMPORT` = Message sent via the REST API's "import messages" endpoint
  /// - `EMAIL` = Message sent by replying to an email notification
  final MessageOrigin origin;

  /// The contents of the message, as a plain text string without any formatting or attachments.
  /// Useful for showing in a conversation list or in notifications.
  final String plaintext;

  /// The main body of the message, as a list of blocks that are rendered top-to-bottom.
  final List<ContentBlock> content;

  /// All the emoji reactions that have been added to this message.
  ///
  /// @remarks
  /// There can be up to 50 different reactions on each message.
  final List<ReactionSnapshot> reactions;

  const MessageSnapshot._({
    required this.id,
    required this.type,
    this.sender,
    required this.custom,
    required this.createdAt,
    this.editedAt,
    this.referencedMessage,
    required this.origin,
    required this.plaintext,
    required this.content,
    required this.reactions,
  });
}

/// A snapshot of a conversation and the current user's participation in it.
///
/// @remarks
/// A snapshot is a frozen view of the conversation's attributes at the time it was fetched.
/// If the conversation is updated after the snapshot is taken, the snapshot will not automatically update.
///
/// @public
class ConversationSnapshot {
  /// The ID of the conversation
  final String id;

  /// Contains the conversation subject, or `null` if the conversation does not have a subject specified.
  final String? subject;

  /// Contains the URL of a photo to represent the topic of the conversation or `null` if the conversation does not have a photo specified.
  final String? photoUrl;

  /// One or more welcome messages that will be rendered at the start of this conversation as system messages.
  ///
  /// @remarks
  /// Welcome messages are rendered in the UI as messages, but they are not real messages.
  /// This means they do not appear when you list messages using the REST API or JS/Kotlin Data API, and you cannot reply or react to them.
  final List<String> welcomeMessages;

  /// Custom metadata you have set on the conversation
  final Map<String, String> custom;

  /// The date that the conversation was created, as a unix timestamp in milliseconds.
  final int createdAt;

  /// The date that the current user joined the conversation, as a unix timestamp in milliseconds.
  final int joinedAt;

  /// The last message sent in this conversation, or `null` if not messages have been sent.
  final MessageSnapshot? lastMessage;

  /// The number of messages in this conversation that the current user hasn't read.
  final int unreadMessageCount;

  /// The most recent date that the current user read the conversation.
  ///
  /// @remarks
  /// This value is updated whenever you read a message in a chat UI, open an email notification, or mark the conversation as read using an API like [ConversationRef.markAsRead].
  ///
  /// Any messages sent after this timestamp are unread messages.
  final int readUntil;

  /// Everyone in the conversation has read any messages sent on or before this date.
  ///
  /// @remarks
  /// This is the minimum of all the participants' `readUntil` values.
  /// Any messages sent on or before this timestamp should show a "read" indicator in the UI.
  ///
  /// This value will rarely change in very large conversations.
  /// If just one person stops checking their messages, `everyoneReadUntil` will never update.
  final int everyoneReadUntil;

  /// Whether the conversation should be considered unread.
  ///
  /// This can be true even when `unreadMessageCount` is zero, if the user has manually marked the conversation as unread.
  final bool isUnread;

  /// The current user's permission level in this conversation.
  final ConversationAccess access;

  /// The current user's notification settings for this conversation.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  final NotificationSettings notify;

  /// @suppress
  /// For back-compat
  final int? lastMessageAt;

  const ConversationSnapshot._({
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

// Implementation details

ReferencedMessageSnapshot referencedMessageSnapshotFromJson(
  ReferencedMessageSnapshotJson json,
) {
  return ReferencedMessageSnapshot._(
    id: json.id,
    type: json.type,
    sender: json.sender,
    custom: json.custom,
    createdAt: json.createdAt,
    editedAt: json.editedAt,
    referencedMessageId: json.referencedMessageId,
    origin: json.origin,
    plaintext: json.plaintext,
    content: deserializeContent(json.contentJson),
    reactions: json.reactions,
  );
}

MessageSnapshot messageSnapshotFromJson(MessageSnapshotJson json) {
  return MessageSnapshot._(
    id: json.id,
    type: json.type,
    sender: json.sender,
    custom: json.custom,
    createdAt: json.createdAt,
    editedAt: json.editedAt,
    referencedMessage: json.referencedMessage == null
        ? null
        : referencedMessageSnapshotFromJson(json.referencedMessage!),
    origin: json.origin,
    plaintext: json.plaintext,
    content: deserializeContent(json.contentJson),
    reactions: json.reactions,
  );
}

ConversationSnapshot conversationSnapshotFromJson(
  ConversationSnapshotJson json,
) {
  return ConversationSnapshot._(
    id: json.id,
    subject: json.subject,
    photoUrl: json.photoUrl,
    welcomeMessages: json.welcomeMessages,
    custom: json.custom,
    createdAt: json.createdAt,
    joinedAt: json.joinedAt,
    lastMessage: json.lastMessage == null
        ? null
        : messageSnapshotFromJson(json.lastMessage!),
    unreadMessageCount: json.unreadMessageCount,
    readUntil: json.readUntil,
    everyoneReadUntil: json.everyoneReadUntil,
    isUnread: json.isUnread,
    access: json.access,
    notify: json.notify,
    lastMessageAt: json.lastMessageAt,
  );
}
