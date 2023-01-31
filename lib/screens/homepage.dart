import 'dart:convert';
import 'package:chatbot/widgets/textfieldwithbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../widgets/chatmessage.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    const ChatMessage(text: 'Ask me Anything....', isMe: false),
  ];
  String _chatBotResponse = '';
  bool _isTyping = false;
  static const apiKey = {Provide your API-KEY};

  @override
  void initState() {
    super.initState();
    _getMessagesFromDB();
  }

  Future<void> getGPT3Response(String input) async {
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": input,
        "max_tokens": 500,
        "temperature": 0,
      }),
    );

    final responseJson = jsonDecode(response.body);
    final responseText = responseJson['choices'][0]['text'];

    setState(() {
      _chatBotResponse = responseText;
      ChatMessage message = ChatMessage(
        text: _chatBotResponse.trim(),
        isMe: false,
      );
      _messages.insert(0, message);
      _isTyping = false;
    });
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'chatbot_db.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (id INTEGER PRIMARY KEY, text TEXT, isMe INTEGER)",
        );
      },
      version: 1,
    );
    await database.insert(
      'messages',
      {'text': responseText, 'isMe': 0},
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      isMe: true,
    );
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    Database database = await openDatabase(
      join(await getDatabasesPath(), 'chatbot_db.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (id INTEGER PRIMARY KEY, text TEXT, isMe INTEGER)",
        );
      },
      version: 1,
    );
    await database.insert(
      'messages',
      {'text': _controller.text, 'isMe': message.isMe ? 1 : 0},
    );
    _controller.clear();
    await getGPT3Response(message.text);
  }

  void _clearDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'chatbot_db.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (id INTEGER PRIMARY KEY, text TEXT, isMe INTEGER)",
        );
      },
      version: 1,
    );
    await database.execute('DELETE FROM messages');
    setState(() {
      _messages.clear();
    });
  }

  void _getMessagesFromDB() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'chatbot_db.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages (id INTEGER PRIMARY KEY, text TEXT, isMe INTEGER)",
        );
      },
      version: 1,
    );

    final List<Map<String, dynamic>> messages =
        await database.query('messages');

    setState(() {
      for (int i = messages.length - 1; i >= 0; i--) {
        var message = messages[i];
        _messages.add(ChatMessage(
          text: message['text'],
          isMe: message['isMe'] == 1,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBOT'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          InkWell(
            onTap: () {
              _clearDatabase();
            },
            child: Row(
              children: const [
                // Text('Clear CHAT',style: TextStyle(color: Colors.teal),),
                Icon(Icons.delete_sweep_outlined, color: Colors.red,size: 25,),
                SizedBox(width: 20,)
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                return _messages[index];
              },
            ),
          ),
          _isTyping
              ? const SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 30.0,
                )
              : Container(),
          TextFieldWithButton(
            controller: _controller,
            sendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
