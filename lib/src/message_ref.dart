import 'core.g.dart';
import 'api.dart';

export 'core.g.dart' show MessageSnapshot;

final Finalizer<int> _messageFinalizer = Finalizer((handle) async {
  await hostApi?.messageDeleteHandle(handle);
});

class MessageRef {
  final CoreHostApi _api;
  final int _handle;

  final String id;
  final String conversationId;

  Future<MessageSnapshot?> get() {
    return _api.messageGet(_handle);
  }

  Future<void> edit(String params) {
    return _api.messageEdit(_handle, params);
  }

  Future<void> deleteFields(List<String> fields) {
    return _api.messageDeleteFields(_handle, fields);
  }

  Future<void> delete() {
    return _api.messageDelete(_handle);
  }

  MessageRef._({
    required CoreHostApi api,
    required int handle,
    required this.id,
    required this.conversationId,
  }) : _api = api,
       _handle = handle;
}

// Implementation detail
MessageRef makeMessageRef({
  required CoreHostApi api,
  required int handle,
  required String id,
  required String conversationId,
}) {
  final ref = MessageRef._(
    api: api,
    handle: handle,
    id: id,
    conversationId: conversationId,
  );

  _messageFinalizer.attach(ref, handle);

  return ref;
}
