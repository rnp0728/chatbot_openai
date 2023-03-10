import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  final String text;
  final bool isMe;

  final String myImageUrl =
      'https://tse2.mm.bing.net/th?id=OIP.E4Kcb0Cqmc-hWVSpmS8qjAHaI9&pid=Api&P=0';
  final String botImageUrl =
      'https://tse4.mm.bing.net/th?id=OIP.FJt-FH98RKamoDc2nntVngHaFj&pid=Api&P=0';

  Widget textResults(context) {
    return Expanded(
        child: Card(
          color: isMe ? Theme.of(context).cardColor : Colors.indigo[400],
      elevation: 5,
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            text,
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ),
        ),
      ),
    ));
  }

  Widget imageShow() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 80,
      height: 60,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                isMe ? myImageUrl : botImageUrl,
              ),
              fit: BoxFit.cover,
              alignment: Alignment.center),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50)),
      // child: ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isMe ? textResults(context) : imageShow(),
        isMe ? imageShow() : textResults(context) ,
      ],
    );
  }
}
