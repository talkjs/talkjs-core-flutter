import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show CreateParticipantParams;

final Finalizer<int> _participantFinalizer = Finalizer((handle) async {
  await hostApi?.participantDeleteHandle(handle);
});

class ParticipantRef {
  final CoreHostApi _api;
  final int _handle;

  final String userId;
  final String conversationId;

  Future<ParticipantSnapshot?> get() {
    return _api.participantGet(_handle);
  }

  Future<void> set(SetParticipantParams data) {
    return _api.participantSet(_handle, data);
  }

  Future<void> edit(SetParticipantParams data) {
    return _api.participantEdit(_handle, data);
  }

  Future<void> createIfNotExists(CreateParticipantParams data) {
    return _api.participantCreateIfNotExists(_handle, data);
  }

  Future<void> deleteFields(List<String> fields) {
    return _api.participantDeleteFields(_handle, fields);
  }

  Future<void> delete() {
    return _api.participantDelete(_handle);
  }

  ParticipantRef._({
    required CoreHostApi api,
    required int handle,
    required this.userId,
    required this.conversationId,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
ParticipantRef makeParticipantRef({
  required CoreHostApi api,
  required int handle,
  required String userId,
  required String conversationId,
}) {
  final ref = ParticipantRef._(
    api: api,
    handle: handle,
    userId: userId,
    conversationId: conversationId,
  );

  _participantFinalizer.attach(ref, handle);

  return ref;
}
