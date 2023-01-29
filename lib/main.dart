import 'package:chatbot/screens/homepage.dart';
import 'package:flutter/material.dart';

void main() {

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI ChatBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // fontFamily: 'OpenSans',
        primaryColor: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}
