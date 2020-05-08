import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String username;
  final String userimage;
  final bool isMe;
  final Key key;

  MessageBubble(this.message, this.username, this.userimage, this.isMe,
      {this.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color:
                      isMe ? Colors.grey[300] : Theme.of(context).accentColor,
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
                vertical: 16,
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
        ),
        if (userimage != null) Positioned(
          top: 0,
          left: isMe ? null : 120,
          right: isMe ? 120 : null,
          child: CircleAvatar(
            backgroundImage: NetworkImage(userimage),
          ),
        )
      ],
      overflow: Overflow.visible,
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
