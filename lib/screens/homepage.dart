import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    ChatMessage(text: 'Hi', isMe: false),
  ];

  String _chatBotResponse = '';
  bool _isTyping = false;
  static const apiKey = '{API-KEY}';

  Future<void> getGPT3Response(String input) async {
    print(input);
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
      setState(() {
        _messages.insert(0, message);
        _isTyping = false;
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      isMe: true,
    );
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();
    getGPT3Response(message.text);
  }

  void insertNewData(String response) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      isMe: true,
    );
    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) {
                _sendMessage();
              },
              decoration: const InputDecoration.collapsed(
                  focusColor: Colors.greenAccent,
                  hintText: "Feel free to ask....."),
            ),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              color: Colors.indigo,
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('ChatBot'),
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                reverse: true,
                itemBuilder: (ctx, index) {
                  return _messages[index];
                },
              ),
            ),
            _isTyping ? const SpinKitThreeBounce(color: Colors.green,) : Container(),
            const Divider(
              height: 1.0,
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: _buildTextComposer(),
            )
          ],
        ));
  }
}
