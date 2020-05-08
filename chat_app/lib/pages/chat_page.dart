import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final chatCollectionRef = Firestore.instance
      .collection("chats/mivpJiPT4e0Voy3GTL6u/messages");

  @override
  Widget build(BuildContext context) {
    final messagesStream = chatCollectionRef.snapshots();

    return Scaffold(
      body: StreamBuilder(
        stream: messagesStream,
        builder: (context, streamSnapshot) {
          switch (streamSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              final messages = streamSnapshot.data.documents;
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => Container(
                  padding: EdgeInsets.all(8),
                  child: Text(messages[index]['text']),
                ),
              );
            default:
              return Center(
                child: Text('Nothing!'),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          chatCollectionRef.add({
            "text": "This was added by clicking the button!",
          });
        },
      ),
    );
  }
}