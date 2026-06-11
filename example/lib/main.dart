import 'package:flutter/material.dart';
import 'package:talkjs_core_flutter/talkjs_core_flutter.dart';
import 'chat_box_page.dart';
import 'conversation_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalkJS Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TalkSession? _session;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final session = await getTalkSession(
      appId: 'YOUR_APP_ID',
      userId: 'YOUR_USER_ID',
    );
    setState(() => _session = session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TalkJS Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatBoxPage(
                      session: _session,
                      conversationId: 'YOUR_CONVERSATION_ID',
                    ),
                  ),
                );
              },
              child: const Text('ChatBox'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConversationListPage(session: _session),
                  ),
                );
              },
              child: const Text('ConversationList'),
            ),
          ],
        ),
      ),
    );
  }
}
