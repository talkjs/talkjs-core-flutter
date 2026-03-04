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
      TalkSessionOptions(
        appId: 't8Serdim',
        userId: '654321',
        apiUrls: ApiUrlOptions(
          realtimeWsApiUrl: "ws://192.168.122.6:4000/public_api/v1",
          internalHttpApiUrl: "http://192.168.122.6:4000/api/v0",
          restApiHttpUrl: "http://192.168.122.6:4000/public_api/v1",
        ),
        token: null,
      ),
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
                      conversationId: 'conv_9',
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
