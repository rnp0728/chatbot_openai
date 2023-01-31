import 'package:flutter/material.dart';

class TextFieldWithButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback sendMessage;
  const TextFieldWithButton({Key? key, required this.controller, required this.sendMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: controller,
                onSubmitted: (value) => sendMessage(),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Feel Free to Ask...',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.indigo,
                ),
                onPressed: () => sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
