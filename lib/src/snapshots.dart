import 'package:flutter/foundation.dart';

import 'entity_tree.dart';

// ignore: constant_identifier_names
enum ConversationAccess { Read, ReadWrite }

enum NotificationSettings { yes, no, mentionsOnly }

// ignore: constant_identifier_names
enum MessageType { UserMessage, SystemMessage }

enum MessageOrigin { web, rest, import, email }

/// A snapshot of a user's attributes at a given moment in time.
///
/// Users also have private information, such as email addresses and phone numbers, but these are only exposed on the [REST API](https://talkjs.com/docs/Reference/REST_API/Getting_Started/Introduction/)
class UserSnapshot {
  /// The unique ID that is used to identify the user in TalkJS
  final String id;

  /// The user's name, which is displayed on the TalkJS UI
  final String name;

  /// Custom metadata you have set on the user
  final Map<String, String> custom;

  /// TalkJS supports multiple sets of settings for users, called "roles". Roles allow you to change the behavior of TalkJS for different users.
  /// You have full control over which user gets which configuration.
  final String role;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// For more information, see: [localization](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  ///
  /// When `locale` is null, the app's default locale will be used
  final String? locale;

  /// An optional URL to a photo that is displayed as the user's avatar
  final String? photoUrl;

  /// The default message a person sees when starting a chat with this user
  final String? welcomeMessage;

  UserSnapshot.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      custom = Map<String, String>.from(json['custom'] as Map<String, dynamic>),
      role = json['role'] as String,
      locale = json['locale'] as String?,
      photoUrl = json['photoUrl'] as String?,
      welcomeMessage = json['welcomeMessage'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'custom': custom,
    'role': role,
    'locale': locale,
    'photoUrl': photoUrl,
    'welcomeMessage': welcomeMessage,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! UserSnapshot) {
      return false;
    }

    if (id != other.id) {
      return false;
    }

    if (name != other.name) {
      return false;
    }

    if (!mapEquals(custom, other.custom)) {
      return false;
    }

    if (role != other.role) {
      return false;
    }

    if (locale != other.locale) {
      return false;
    }

    if (photoUrl != other.photoUrl) {
      return false;
    }

    if (welcomeMessage != other.welcomeMessage) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    Object.hashAll(custom.keys),
    Object.hashAll(custom.values),
    role,
    locale,
    photoUrl,
    welcomeMessage,
  );
}

/// A summary of a single emoji reaction on a message.
///
/// @public
class ReactionSnapshot {
  /// Which emoji the users reacted with.
  ///
  /// @remarks
  /// Either a single Unicode emoji, or the name of a custom emoji with a colon at the start and end.
  /// Since custom emoji are defined in the frontend, they are not validated by the TalkJS server.
  /// The UI should ignore reactions that use unrecognised custom emoji.
  ///
  /// NOTE: In unicode, it is possible to have multiple emoji that look identical but are represented differently.
  /// For example, `"👍" != "👍️"` because the second emoji includes a [variation selector 16 codepoint](https://en.wikipedia.org/wiki/Variation_Selectors_(Unicode_block)).
  /// This codepoint forces the character to appear as an emoji.
  ///
  /// TalkJS normalises all emoji reactions to be "fully qualified" [according to this list](https://unicode.org/Public/emoji/16.0/emoji-test.txt).
  /// This prevents a message having multiple separate 👍 reactions.
  ///
  /// Be careful when processing the `emoji` property, as this normalisation might break equality checks:
  ///
  /// ```dart
  /// // Emoji has unnecessary variation selector 16
  /// final sent = '👍';
  ///
  /// // React with thumbs up,
  /// final reaction = await messageRef.reaction(sent);
  /// await reaction.add();
  ///
  /// // Fetch the reaction
  /// final snapshot = await messageRef.get();
  /// final received = snapshot!.reactions[0].emoji;
  ///
  /// // Fails because TalkJS removed the variation selector
  /// assert(sent == received);
  /// ```
  ///
  /// @example Unicode emoji
  /// "👍"
  ///
  /// @example Custom emoji
  /// ":cat-roomba:"
  final String emoji;

  /// The number of times this emoji has been added to the message.
  final int count;

  /// Whether the current user has reacted to the message with this emoji.
  final bool currentUserReacted;

  ReactionSnapshot.fromJson(Map<String, dynamic> json)
    : emoji = json['emoji'] as String,
      count = json['count'] as int,
      currentUserReacted = json['currentUserReacted'] as bool;

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'count': count,
    'currentUserReacted': currentUserReacted,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ReactionSnapshot) {
      return false;
    }

    if (emoji != other.emoji) {
      return false;
    }

    if (count != other.count) {
      return false;
    }

    if (currentUserReacted != other.currentUserReacted) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(emoji, count, currentUserReacted);
}

/// A snapshot of the typing indicators in a conversation at a given moment in time.
///
/// @remarks
/// Currently when there are 5 or less people typing in the conversation,
/// `many` will be `false` and `users` will contain the users who are currently typing in this conversation.
/// When more than 5 people are typing, `many` will be `true` and `users` will be `null`.
/// This limit may change in the future, which will not be considered a breaking change.
///
/// @example Converting a TypingSnapshot to text
/// ```dart
/// String formatTyping(TypingSnapshot snapshot) {
///   if (snapshot.many) {
///     return 'Several people are typing';
///   }
///
///   final names = snapshot.users!.map((user) => user.name).toList();
///
///   if (names.isEmpty) {
///     return '';
///   }
///
///   if (names.length == 1) {
///     return '${names[0]} is typing';
///   }
///
///   if (names.length == 2) {
///     return '${names.join(' and ')} are typing';
///   }
///
///   // Prefix last name with "and "
///   names.add('and ${names.removeLast()}');
///   return '${names.join(', ')} are typing';
/// }
/// ```
class TypingSnapshot {
  /// Check this to differentiate between few people are typing (`false`) and many people are typing (`true`).
  ///
  /// @remarks
  /// When `false`, you can see the list of users who are typing in the `users` property.
  final bool many;

  /// The users who are currently typing in this conversation.
  ///
  /// @remarks
  /// The list is in chronological order, starting with the users who have been typing the longest.
  /// The current user is never contained in the list, only other users.
  /// When the `many` property is `true`, this property is `null`.
  final List<UserSnapshot>? users;

  TypingSnapshot.fromJson(Map<String, dynamic> json)
    : many = json['many'] as bool,
      users = (json['users'] as List<dynamic>?)
          ?.map((user) => UserSnapshot.fromJson(user as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => {
    'many': many,
    'users': users?.map((user) => user.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! TypingSnapshot) {
      return false;
    }

    if (many != other.many) {
      return false;
    }

    if (!listEquals(users, other.users)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode =>
      Object.hash(many, users == null ? null : Object.hashAll(users!));
}

/// A snapshot of a participant's attributes at a given moment in time.
class ParticipantSnapshot {
  /// The user who this Participant Snapshot is referring to
  final UserSnapshot user;

  /// The level of access this participant has in the conversation.
  final ConversationAccess access;

  /// When the participant will be notified about new messages in this conversation.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  final NotificationSettings notify;

  /// The date that this user joined the conversation, as a unix timestamp in milliseconds.
  final int joinedAt;

  ParticipantSnapshot.fromJson(Map<String, dynamic> json)
    : user = UserSnapshot.fromJson(json['user'] as Map<String, dynamic>),
      access = ConversationAccess.values.byName(json['access'] as String),
      notify = _notificationSettingsFromJson(json['notify']),
      joinedAt = json['joinedAt'] as int;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'access': access.name,
    'notify': notificationSettingsToJson(notify),
    'joinedAt': joinedAt,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ParticipantSnapshot) {
      return false;
    }

    if (user != other.user) {
      return false;
    }

    if (access != other.access) {
      return false;
    }

    if (notify != other.notify) {
      return false;
    }

    if (joinedAt != other.joinedAt) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(user, access, notify, joinedAt);
}

/// A snapshot of a user's online status at a given moment in time.
///
/// @remarks
/// Snapshots are immutable and we try to reuse them when possible. You should only re-render your UI when `oldSnapshot != newSnapshot`.
///
/// @public
class UserOnlineSnapshot {
  /// The user this snapshot relates to
  final UserSnapshot user;

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
  final bool isConnected;

  UserOnlineSnapshot.fromJson(Map<String, dynamic> json)
    : user = UserSnapshot.fromJson(json['user'] as Map<String, dynamic>),
      isConnected = json['isConnected'] as bool;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'isConnected': isConnected,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! UserOnlineSnapshot) {
      return false;
    }

    if (user != other.user) {
      return false;
    }

    if (isConnected != other.isConnected) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(user, isConnected);
}

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

  ReferencedMessageSnapshot.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      type = MessageType.values.byName(json['type'] as String),
      sender = json['sender'] == null
          ? null
          : UserSnapshot.fromJson(json['sender'] as Map<String, dynamic>),
      custom = Map<String, String>.from(json['custom'] as Map<String, dynamic>),
      createdAt = json['createdAt'] as int,
      editedAt = json['editedAt'] as int?,
      referencedMessageId = json['referencedMessageId'] as String?,
      origin = MessageOrigin.values.byName(json['origin'] as String),
      plaintext = json['plaintext'] as String,
      content = (json['content'] as List<dynamic>)
          .map(
            (block) => deserializeContentBlock(block as Map<String, dynamic>),
          )
          .toList(),
      reactions = (json['reactions'] as List<dynamic>)
          .map(
            (reaction) =>
                ReactionSnapshot.fromJson(reaction as Map<String, dynamic>),
          )
          .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'sender': sender?.toJson(),
    'custom': custom,
    'createdAt': createdAt,
    'editedAt': editedAt,
    'referencedMessageId': referencedMessageId,
    'origin': origin.name,
    'plaintext': plaintext,
    'content': content.map((block) => block.toJson()).toList(),
    'reactions': reactions.map((r) => r.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ReferencedMessageSnapshot) {
      return false;
    }

    if (id != other.id) {
      return false;
    }

    if (type != other.type) {
      return false;
    }

    if (sender != other.sender) {
      return false;
    }

    if (!mapEquals(custom, other.custom)) {
      return false;
    }

    if (createdAt != other.createdAt) {
      return false;
    }

    if (editedAt != other.editedAt) {
      return false;
    }

    if (referencedMessageId != other.referencedMessageId) {
      return false;
    }

    if (origin != other.origin) {
      return false;
    }

    if (plaintext != other.plaintext) {
      return false;
    }

    if (!listEquals(content, other.content)) {
      return false;
    }

    if (!listEquals(reactions, other.reactions)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    sender,
    Object.hashAll(custom.keys),
    Object.hashAll(custom.values),
    createdAt,
    editedAt,
    referencedMessageId,
    origin,
    plaintext,
    Object.hashAll(content),
    Object.hashAll(reactions),
  );
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

  MessageSnapshot.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      type = MessageType.values.byName(json['type'] as String),
      sender = json['sender'] == null
          ? null
          : UserSnapshot.fromJson(json['sender'] as Map<String, dynamic>),
      custom = Map<String, String>.from(json['custom'] as Map<String, dynamic>),
      createdAt = json['createdAt'] as int,
      editedAt = json['editedAt'] as int?,
      referencedMessage = json['referencedMessage'] == null
          ? null
          : ReferencedMessageSnapshot.fromJson(
              json['referencedMessage'] as Map<String, dynamic>,
            ),
      origin = MessageOrigin.values.byName(json['origin'] as String),
      plaintext = json['plaintext'] as String,
      content = (json['content'] as List<dynamic>)
          .map(
            (block) => deserializeContentBlock(block as Map<String, dynamic>),
          )
          .toList(),
      reactions = (json['reactions'] as List<dynamic>)
          .map(
            (reaction) =>
                ReactionSnapshot.fromJson(reaction as Map<String, dynamic>),
          )
          .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'sender': sender?.toJson(),
    'custom': custom,
    'createdAt': createdAt,
    'editedAt': editedAt,
    'referencedMessage': referencedMessage?.toJson(),
    'origin': origin.name,
    'plaintext': plaintext,
    'content': content.map((block) => block.toJson()).toList(),
    'reactions': reactions.map((r) => r.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! MessageSnapshot) {
      return false;
    }

    if (id != other.id) {
      return false;
    }

    if (type != other.type) {
      return false;
    }

    if (sender != other.sender) {
      return false;
    }

    if (!mapEquals(custom, other.custom)) {
      return false;
    }

    if (createdAt != other.createdAt) {
      return false;
    }

    if (editedAt != other.editedAt) {
      return false;
    }

    if (referencedMessage != other.referencedMessage) {
      return false;
    }

    if (origin != other.origin) {
      return false;
    }

    if (plaintext != other.plaintext) {
      return false;
    }

    if (!listEquals(content, other.content)) {
      return false;
    }

    if (!listEquals(reactions, other.reactions)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    sender,
    Object.hashAll(custom.keys),
    Object.hashAll(custom.values),
    createdAt,
    editedAt,
    referencedMessage,
    origin,
    plaintext,
    Object.hashAll(content),
    Object.hashAll(reactions),
  );
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

  ConversationSnapshot.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      subject = json['subject'] as String?,
      photoUrl = json['photoUrl'] as String?,
      welcomeMessages = (json['welcomeMessages'] as List<dynamic>)
          .map((message) => message as String)
          .toList(),
      custom = Map<String, String>.from(json['custom'] as Map<String, dynamic>),
      createdAt = json['createdAt'] as int,
      joinedAt = json['joinedAt'] as int,
      lastMessage = json['lastMessage'] == null
          ? null
          : MessageSnapshot.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      unreadMessageCount = json['unreadMessageCount'] as int,
      readUntil = json['readUntil'] as int,
      everyoneReadUntil = json['everyoneReadUntil'] as int,
      isUnread = json['isUnread'] as bool,
      access = ConversationAccess.values.byName(json['access'] as String),
      notify = _notificationSettingsFromJson(json['notify']),
      lastMessageAt = json['lastMessageAt'] as int?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'photoUrl': photoUrl,
    'welcomeMessages': welcomeMessages,
    'custom': custom,
    'createdAt': createdAt,
    'joinedAt': joinedAt,
    'lastMessage': lastMessage?.toJson(),
    'unreadMessageCount': unreadMessageCount,
    'readUntil': readUntil,
    'everyoneReadUntil': everyoneReadUntil,
    'isUnread': isUnread,
    'access': access.name,
    'notify': notificationSettingsToJson(notify),
    'lastMessageAt': lastMessageAt,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ConversationSnapshot) {
      return false;
    }

    if (id != other.id) {
      return false;
    }

    if (subject != other.subject) {
      return false;
    }

    if (photoUrl != other.photoUrl) {
      return false;
    }

    if (!listEquals(welcomeMessages, other.welcomeMessages)) {
      return false;
    }

    if (!mapEquals(custom, other.custom)) {
      return false;
    }

    if (createdAt != other.createdAt) {
      return false;
    }

    if (joinedAt != other.joinedAt) {
      return false;
    }

    if (lastMessage != other.lastMessage) {
      return false;
    }

    if (unreadMessageCount != other.unreadMessageCount) {
      return false;
    }

    if (readUntil != other.readUntil) {
      return false;
    }

    if (everyoneReadUntil != other.everyoneReadUntil) {
      return false;
    }

    if (isUnread != other.isUnread) {
      return false;
    }

    if (access != other.access) {
      return false;
    }

    if (notify != other.notify) {
      return false;
    }

    if (lastMessageAt != other.lastMessageAt) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    subject,
    photoUrl,
    Object.hashAll(welcomeMessages),
    Object.hashAll(custom.keys),
    Object.hashAll(custom.values),
    createdAt,
    joinedAt,
    lastMessage,
    unreadMessageCount,
    readUntil,
    everyoneReadUntil,
    isUnread,
    access,
    notify,
    lastMessageAt,
  );
}

// Implementation details

NotificationSettings _notificationSettingsFromJson(dynamic value) =>
    switch (value) {
      true => NotificationSettings.yes,
      false => NotificationSettings.no,
      'mentionsOnly' => NotificationSettings.mentionsOnly,
      _ => throw Exception('Failed to deserialize NotificationSettings'),
    };

dynamic notificationSettingsToJson(NotificationSettings notify) =>
    switch (notify) {
      NotificationSettings.yes => true,
      NotificationSettings.no => false,
      NotificationSettings.mentionsOnly => 'mentionsOnly',
    };
