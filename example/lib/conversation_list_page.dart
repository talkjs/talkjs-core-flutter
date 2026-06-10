import 'dart:math';
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
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _subscription = _session?.subscribeConversations((snapshots, loadedAll) {
      setState(() => _conversations = snapshots);
    });
    _subscription?.connected.then((_) {
      if (mounted) {
        setState(() => _isConnected = true);
      }
    }, onError: (_) {});
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
      body: Column(
        children: [
          if (!_isConnected)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: min(constraints.maxWidth, constraints.maxHeight),
                      height: min(constraints.maxWidth, constraints.maxHeight),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView(
                children: _conversations.map((conversation) {
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
                    child: Text(conversation.subject ?? conversation.id),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
