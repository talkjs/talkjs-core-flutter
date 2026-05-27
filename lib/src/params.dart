import 'snapshots.dart';

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

