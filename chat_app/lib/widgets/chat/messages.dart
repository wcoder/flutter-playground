import 'package:chat_app/widgets/chat/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return StreamBuilder(
          stream: Firestore.instance
              .collection("chat")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, streamSnapshot) {
            switch (streamSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                final messages = streamSnapshot.data.documents;
                return ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: 0,
                  ),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message['text'],
                      message['username'] ?? "",
                      message['userId'] == snapshot.data.uid,
                      key: ValueKey(message.documentID),
                    );
                  },
                );
              default:
                return Center(
                  child: Text('Nothing!'),
                );
            }
          },
        );
      },
    );
  }
}
