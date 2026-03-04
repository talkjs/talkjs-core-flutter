import 'package:flutter/material.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter.dart';
import 'chat_box_page.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key, required this.session});

  final TalkSession? session;

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  TalkSession? _session;
  List<ConversationSnapshot> _conversations = [];
  ConversationListSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _session
        ?.subscribeConversations((snapshots, loadedAll) {
          setState(() => _conversations = snapshots);
        })
        .then((sub) => _subscription = sub);
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ConversationList'),
      ),
      body: ListView(
        children: _conversations.map((conversation) {
          final label = conversation.subject ?? conversation.id;
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatBoxPage(
                    session: _session,
                    conversationId: conversation.id,
                  ),
                ),
              );
            },
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }
}
