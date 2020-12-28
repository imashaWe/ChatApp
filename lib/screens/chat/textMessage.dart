import 'package:chatApp/models/chat/chatBox.dart';
import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  final String message;
  final Timestamp time;
  final bool isMe;
  final bool isRead;

  TextMessage({this.message, this.time, this.isMe, this.isRead});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 20,
        child: Container(
          color: isMe ? Colors.green : Colors.grey,
          //width: 100,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(message),
              Text(
                '10:53 AM',
                textAlign: TextAlign.right,
              )
            ],
          ),
        ));
  }
}
