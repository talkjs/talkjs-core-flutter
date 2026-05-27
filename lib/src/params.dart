import 'snapshots.dart';

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
    'access': access?.name,
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
    'access': access?.name,
    'notify': notify == null ? null : notificationSettingsToJson(notify!),
  };
}

