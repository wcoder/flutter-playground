import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String username;
  final bool isMe;
  final Key key;

  MessageBubble(this.message, this.username, this.isMe, {this.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: !isMe ? Radius.zero : Radius.circular(12),
                bottomRight: isMe ? Radius.zero : Radius.circular(12),
              )),
          width: 140,
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              _buildUserName(context),
              Text(
                message,
                style: TextStyle(
                    color: isMe
                        ? Colors.black
                        : Theme.of(context).accentTextTheme.title.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserName(BuildContext context) {
    return Text(
      username,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isMe
              ? Colors.black
              : Theme.of(context).accentTextTheme.title.color),
      textAlign: isMe ? TextAlign.end : TextAlign.start,
    );
  }
}
