import 'package:flutter/material.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({
    super.key,
    required this.session,
    required this.conversationId,
  });

  final TalkSession? session;
  final String conversationId;

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  TalkSession? _session;
  ConversationRef? _ref;
  List<MessageSnapshot> _messages = [];
  MessageSubscription? _subscription;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _session?.conversation(widget.conversationId).then((ref) {
      _ref = ref;
      ref
          .subscribeMessages((messages, _) {
            setState(() => _messages = messages ?? []);
          })
          .then((sub) => _subscription = sub);
    });
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ChatBox'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _messages
                  .map((message) => Text(message.plaintext))
                  .toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = _textController.text;
                  if (text.isEmpty) return;
                  _ref?.send(text);
                  _textController.clear();
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
