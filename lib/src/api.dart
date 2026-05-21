import 'dart:async';
import 'dart:convert';

import 'core.g.dart';
import 'snapshots.dart';

CoreHostApi? hostApi;

Map<int, Function(UserSnapshot? snapshot)?> userSubscriptionOnSnapshots = {};
Map<int, Function(UserOnlineSnapshot? snapshot)?>
userOnlineSubscriptionOnSnapshots = {};
Map<int, Function(ConversationSnapshot? snapshot)?>
conversationSubscriptionOnSnapshots = {};
Map<int, Function(List<ConversationSnapshot> snapshot, bool loadedAll)?>
conversationListSubscriptionOnSnapshots = {};
Map<int, Function(List<MessageSnapshot>? snapshot, bool loadedAll)?>
messageSubscriptionOnSnapshots = {};
Map<int, Function(List<ParticipantSnapshot>? snapshot, bool loadedAll)?>
participantSubscriptionOnSnapshots = {};
Map<int, Function(TypingSnapshot? snapshot)?> typingSubscriptionOnSnapshots =
    {};
Map<int, Function(Exception error)> sessionOnErrorExceptions = {};
Map<int, Completer<void>> userSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> userSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> userOnlineSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> userOnlineSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> conversationListSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> conversationListSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> conversationSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> conversationSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> messageSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> messageSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> participantSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> participantSubscriptionTerminatedCompleters = {};
Map<int, Completer<void>> typingSubscriptionConnectedCompleters = {};
Map<int, Completer<void>> typingSubscriptionTerminatedCompleters = {};

class CoreFlutterApiImplementation implements CoreFlutterApi {
  @override
  void newUserSnapshot(int handle, String? snapshotJson) {
    UserSnapshot? snapshot;
    if (snapshotJson != null) {
      snapshot = UserSnapshot.fromJson(jsonDecode(snapshotJson));
    }

    userSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void newUserOnlineSnapshot(int handle, String? snapshotJson) {
    UserOnlineSnapshot? snapshot;
    if (snapshotJson != null) {
      snapshot = UserOnlineSnapshot.fromJson(jsonDecode(snapshotJson));
    }

    userOnlineSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void newConversationSnapshot(int handle, String? snapshotJson) {
    ConversationSnapshot? snapshot;
    if (snapshotJson != null) {
      snapshot = ConversationSnapshot.fromJson(jsonDecode(snapshotJson));
    }

    conversationSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void newConversationListSnapshot(
    int handle,
    String snapshotJson,
    bool loadedAll,
  ) {
    conversationListSubscriptionOnSnapshots[handle]?.call(
      (jsonDecode(snapshotJson) as List<dynamic>)
          .map(
            (conversation) => ConversationSnapshot.fromJson(
              conversation as Map<String, dynamic>,
            ),
          )
          .toList(),
      loadedAll,
    );
  }

  @override
  void newSessionError(int handle, String message) {
    sessionOnErrorExceptions[handle]?.call(Exception(message));
  }

  @override
  void newMessageSnapshot(int handle, String? snapshotJson, bool loadedAll) {
    List<MessageSnapshot>? snapshot;
    if (snapshotJson != null) {
      snapshot = (jsonDecode(snapshotJson) as List<dynamic>)
          .map(
            (message) =>
                MessageSnapshot.fromJson(message as Map<String, dynamic>),
          )
          .toList();
    }

    messageSubscriptionOnSnapshots[handle]?.call(snapshot, loadedAll);
  }

  @override
  void newParticipantSnapshot(
    int handle,
    String? snapshotJson,
    bool loadedAll,
  ) {
    List<ParticipantSnapshot>? snapshot;
    if (snapshotJson != null) {
      snapshot = (jsonDecode(snapshotJson) as List<dynamic>)
          .map(
            (participant) => ParticipantSnapshot.fromJson(
              participant as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    participantSubscriptionOnSnapshots[handle]?.call(snapshot, loadedAll);
  }

  @override
  void newTypingSnapshot(int handle, String? snapshotJson) {
    TypingSnapshot? snapshot;
    if (snapshotJson != null) {
      snapshot = TypingSnapshot.fromJson(jsonDecode(snapshotJson));
    }

    typingSubscriptionOnSnapshots[handle]?.call(snapshot);
  }

  @override
  void userSubscriptionConnectedResolve(int handle) {
    userSubscriptionConnectedCompleters[handle]?.complete();
    userSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void userSubscriptionConnectedReject(int handle, String error) {
    userSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    userSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void userSubscriptionTerminatedResolve(int handle) {
    userSubscriptionTerminatedCompleters[handle]?.complete();
    userSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void userSubscriptionTerminatedReject(int handle, String error) {
    userSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    userSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void userOnlineSubscriptionConnectedResolve(int handle) {
    userOnlineSubscriptionConnectedCompleters[handle]?.complete();
    userOnlineSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void userOnlineSubscriptionConnectedReject(int handle, String error) {
    userOnlineSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    userOnlineSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void userOnlineSubscriptionTerminatedResolve(int handle) {
    userOnlineSubscriptionTerminatedCompleters[handle]?.complete();
    userOnlineSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void userOnlineSubscriptionTerminatedReject(int handle, String error) {
    userOnlineSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    userOnlineSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void conversationListSubscriptionConnectedResolve(int handle) {
    conversationListSubscriptionConnectedCompleters[handle]?.complete();
    conversationListSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void conversationListSubscriptionConnectedReject(int handle, String error) {
    conversationListSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    conversationListSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void conversationListSubscriptionTerminatedResolve(int handle) {
    conversationListSubscriptionTerminatedCompleters[handle]?.complete();
    conversationListSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void conversationListSubscriptionTerminatedReject(int handle, String error) {
    conversationListSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    conversationListSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void conversationSubscriptionConnectedResolve(int handle) {
    conversationSubscriptionConnectedCompleters[handle]?.complete();
    conversationSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void conversationSubscriptionConnectedReject(int handle, String error) {
    conversationSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    conversationSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void conversationSubscriptionTerminatedResolve(int handle) {
    conversationSubscriptionTerminatedCompleters[handle]?.complete();
    conversationSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void conversationSubscriptionTerminatedReject(int handle, String error) {
    conversationSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    conversationSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void messageSubscriptionConnectedResolve(int handle) {
    messageSubscriptionConnectedCompleters[handle]?.complete();
    messageSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void messageSubscriptionConnectedReject(int handle, String error) {
    messageSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    messageSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void messageSubscriptionTerminatedResolve(int handle) {
    messageSubscriptionTerminatedCompleters[handle]?.complete();
    messageSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void messageSubscriptionTerminatedReject(int handle, String error) {
    messageSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    messageSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void participantSubscriptionConnectedResolve(int handle) {
    participantSubscriptionConnectedCompleters[handle]?.complete();
    participantSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void participantSubscriptionConnectedReject(int handle, String error) {
    participantSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    participantSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void participantSubscriptionTerminatedResolve(int handle) {
    participantSubscriptionTerminatedCompleters[handle]?.complete();
    participantSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void participantSubscriptionTerminatedReject(int handle, String error) {
    participantSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    participantSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void typingSubscriptionConnectedResolve(int handle) {
    typingSubscriptionConnectedCompleters[handle]?.complete();
    typingSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void typingSubscriptionConnectedReject(int handle, String error) {
    typingSubscriptionConnectedCompleters[handle]?.completeError(
      Exception(error),
    );
    typingSubscriptionConnectedCompleters.remove(handle);
  }

  @override
  void typingSubscriptionTerminatedResolve(int handle) {
    typingSubscriptionTerminatedCompleters[handle]?.complete();
    typingSubscriptionTerminatedCompleters.remove(handle);
  }

  @override
  void typingSubscriptionTerminatedReject(int handle, String error) {
    typingSubscriptionTerminatedCompleters[handle]?.completeError(
      Exception(error),
    );
    typingSubscriptionTerminatedCompleters.remove(handle);
  }
}
