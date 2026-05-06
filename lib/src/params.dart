import 'dart:convert';

import 'snapshots.dart';
import 'entity_tree.dart';

/// Parameters you can pass when creating a user.
class CreateUserParams {
  /// The user's name which is displayed on the TalkJS UI
  final String name;

  /// Custom metadata you have set on the user.
  /// Default = no custom metadata
  final Map<String, String>? custom;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  final String? locale;

  /// An optional URL to a photo that is displayed as the user's avatar.
  /// Default = no photo
  final String? photoUrl;

  /// TalkJS supports multiple sets of settings, called "roles". These allow you to change the behavior of TalkJS for different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  String? role;

  /// The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  final String? welcomeMessage;

  /// An array of email addresses associated with the user.
  /// Default = no email addresses
  final List<String>? email;

  /// An array of phone numbers associated with the user.
  /// Default = no phone numbers
  final List<String>? phone;

  /// A Map of push registration tokens to use when notifying this user.
  ///
  /// Keys in the Map have the format `'provider:token_id'`, where `provider` is either
  /// `"fcm"` for Firebase Cloud Messaging or `"apns"` for Apple Push Notification Service
  ///
  /// Default = no push registration tokens
  ///
  /// (Value of the Map is always true)
  final Map<String, bool>? pushTokens;

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

  Map<String, dynamic> toJson() => {
    'name': name,
    'custom': custom,
    'locale': locale,
    'photoUrl': photoUrl,
    'role': role,
    'welcomeMessage': welcomeMessage,
    'email': email,
    'phone': phone,
    'pushTokens': pushTokens,
  };
}

/// Parameters you can pass when updating a user.
///
/// Properties that are `null` will not be changed.
/// To clear / reset a property to the default, call [UserRef.deleteFields] instead.
class SetUserParams {
  /// The user's name which will be displayed on the TalkJS UI
  final String? name;

  /// Custom metadata you have set on the user.
  /// This value acts as a patch. Remove specific properties by calling [UserRef.deleteFields]
  /// Default = no custom metadata
  final Map<String, String?>? custom;

  /// An [IETF language tag](https://www.w3.org/International/articles/language-tags/)
  /// See the [localization documentation](https://talkjs.com/docs/Features/Language_Support/Localization.html)
  /// Default = the locale selected on the dashboard
  final String? locale;

  /// An optional URL to a photo which will be displayed as the user's avatar.
  /// Default = no photo
  final String? photoUrl;

  /// TalkJS supports multiple sets of settings, called "roles". These allow you to change the behaviour of TalkJS for
  /// different users.
  /// You have full control over which user gets which configuration.
  /// Default = the `default` role
  String? role;

  /// The default message a person sees when starting a chat with this user.
  /// Default = no welcome message
  final String? welcomeMessage;

  /// An array of email addresses associated with the user.
  /// Default = no email addresses
  final List<String>? email;

  /// An array of phone numbers associated with the user.
  /// Default = no phone numbers
  final List<String>? phone;

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
  final Map<String, bool?>? pushTokens;

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

  Map<String, dynamic> toJson() => {
    'name': name,
    'custom': custom,
    'locale': locale,
    'photoUrl': photoUrl,
    'role': role,
    'welcomeMessage': welcomeMessage,
    'email': email,
    'phone': phone,
    'pushTokens': pushTokens,
  };
}

/// Parameters you can pass when creating a conversation.
///
/// Properties that are `null` will be set to the default
class CreateConversationParams {
  /// The conversation subject to display in the chat header.
  /// Default = no subject, list participant names instead
  final String? subject;

  /// The URL for the conversation photo to display in the chat header.
  /// Default = no photo, show a placeholder image.
  final String? photoUrl;

  /// System messages which are sent at the beginning of a conversation.
  /// Default = no messages.
  final List<String>? welcomeMessages;

  /// Custom metadata you have set on the conversation.
  /// Default = no custom metadata
  final Map<String, String>? custom;

  /// Your access to the conversation.
  /// Default = `READ_WRITE` access.
  final ConversationAccess? access;

  /// Your notification settings.
  /// Default = `TRUE`
  final NotificationSettings? notify;

  const CreateConversationParams({
    this.subject,
    this.photoUrl,
    this.welcomeMessages,
    this.custom,
    this.access,
    this.notify,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'photoUrl': photoUrl,
    'welcomeMessages': welcomeMessages,
    'custom': custom,
    'access': access == null ? null : conversationAccessToJson(access!),
    'notify': notify == null ? null : notificationSettingsToJson(notify!),
  };
}

/// Parameters you can pass when updating a conversation.
///
/// Properties that are `null` will not be changed.
/// To clear / reset a property to the default, call [ConversationRef.deleteFields] instead.
class SetConversationParams {
  /// The conversation subject to display in the chat header.
  /// Default = no subject, list participant names instead.
  final String? subject;

  /// The URL for the conversation photo to display in the chat header.
  /// Default = no photo, show a placeholder image.
  final String? photoUrl;

  /// System messages which are sent at the beginning of a conversation.
  /// Default = no messages.
  final List<String>? welcomeMessages;

  /// Custom metadata you have set on the conversation.
  /// This value acts as a patch. Remove specific properties by calling [ConversationRef.deleteFields]
  /// Default = no custom metadata
  final Map<String, String?>? custom;

  /// Your access to the conversation.
  /// Default = `READ_WRITE` access.
  final ConversationAccess? access;

  /// Your notification settings.
  /// Default = `TRUE`
  final NotificationSettings? notify;

  const SetConversationParams({
    this.subject,
    this.photoUrl,
    this.welcomeMessages,
    this.custom,
    this.access,
    this.notify,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'photoUrl': photoUrl,
    'welcomeMessages': welcomeMessages,
    'custom': custom,
    'access': access == null ? null : conversationAccessToJson(access!),
    'notify': notify == null ? null : notificationSettingsToJson(notify!),
  };
}

/// Parameters you can pass when creating a participant (adding a user to a conversation).
class CreateParticipantParams {
  /// The level of access the participant should have in the conversation.
  /// Default = `READ_WRITE` access.
  final ConversationAccess? access;

  /// When the participant should be notified about new messages in this conversation.
  /// Default = `TRUE`.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  final NotificationSettings? notify;

  const CreateParticipantParams({this.access, this.notify});

  Map<String, dynamic> toJson() => {
    'access': access == null ? null : conversationAccessToJson(access!),
    'notify': notify == null ? null : notificationSettingsToJson(notify!),
  };
}

/// Parameters you can pass when updating a participant.
///
/// Properties that are `null` will not be changed.
/// To clear / reset a property to the default, call [ParticipantRef.deleteFields] instead.
class SetParticipantParams {
  /// The level of access the participant should have in the conversation.
  /// Default = `READ_WRITE` access.
  final ConversationAccess? access;

  /// When the participant should be notified about new messages in this conversation.
  /// Default = `TRUE`.
  ///
  /// `FALSE` means no notifications, `TRUE` means notifications for all messages, and `MENTIONS_ONLY` means that the user will only be notified when they are mentioned with an `@`.
  final NotificationSettings? notify;

  const SetParticipantParams({this.access, this.notify});

  Map<String, dynamic> toJson() => {
    'access': access == null ? null : conversationAccessToJson(access!),
    'notify': notify == null ? null : notificationSettingsToJson(notify!),
  };
}

/// Parameters you can pass when sending a message
class SendTextMessageParams {
  /// The text to send in the message.
  final String text;

  /// Custom metadata you have set on the user.
  /// Default = no custom metadata
  final Map<String, String>? custom;

  /// The message that you are replying to.
  /// Default = not a reply
  final String? referencedMessage;

  const SendTextMessageParams({
    required this.text,
    this.custom,
    this.referencedMessage,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'custom': custom,
    'referencedMessage': referencedMessage,
  };
}

/// Parameters you can pass to [ConversationRef.sendMessage].
///
/// @remarks
/// Properties that are `null` will be set to the default.
///
/// This is the more advanced method for editing a message, giving full control over the message content.
/// You can decide exactly how a text message should be formatted, edit an attachment, or even turn a text message into a location.
///
/// @public
class SendMessageParams {
  /// The most important part of the message, either some text, a file attachment, or a location.
  ///
  /// @remarks
  /// By default users do not have permission to send [LinkNode], [ActionLinkNode], or [ActionButtonNode], as they can be used to trick the recipient.
  final List<SendContentBlock> content;

  /// Custom metadata you have set on the user.
  /// Default = no custom metadata
  final Map<String, String>? custom;

  /// The message that you are replying to.
  /// Default = not a reply
  final String? referencedMessage;

  const SendMessageParams({
    required this.content,
    this.custom,
    this.referencedMessage,
  });

  Map<String, dynamic> toJson() => {
    'content': jsonDecode(serializeContent(content)),
    'custom': custom,
    'referencedMessage': referencedMessage,
  };
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
  final Map<String, String?>? custom;

  /// The new text to set as the message body
  final String? text;

  const EditTextMessageParams({this.custom, this.text});

  Map<String, dynamic> toJson() => {'custom': custom, 'text': text};
}

/// Parameters you can pass to [MessageRef.editMessage].
///
/// @remarks
/// Properties that are `null` will not be changed.
/// To clear / reset a property to the default, call [MessageRef.deleteFields] instead.
///
/// This is the more advanced method for editing a message. It gives you full control over the message content.
/// You can decide exactly how a text message should be formatted, edit an attachment, or even turn a text message into a location.
///
/// @public
class EditMessageParams {
  /// Custom metadata you have set on the message.
  /// This value acts as a patch. Remove specific properties by calling [MessageRef.deleteFields]
  /// Default = no custom metadata
  final Map<String, String?>? custom;

  /// The new content for the message.
  ///
  /// @remarks
  /// Any value provided here will overwrite the existing message content.
  ///
  /// By default users do not have permission to send [LinkNode], [ActionLinkNode], or [ActionButtonNode], as they can be used to trick the recipient.
  final List<SendContentBlock>? content;

  const EditMessageParams({this.custom, this.content});

  Map<String, dynamic> toJson() => {
    'custom': custom,
    'content': content == null ? null : jsonDecode(serializeContent(content!)),
  };
}
