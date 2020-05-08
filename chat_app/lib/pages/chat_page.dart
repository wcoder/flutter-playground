import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final chatCollectionRef = Firestore.instance
      .collection("chats/mivpJiPT4e0Voy3GTL6u/messages");

  @override
  Widget build(BuildContext context) {
    final messagesStream = chatCollectionRef.snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        actions: <Widget>[
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text("Logout"),
                    ],
                  ),
                ),
                value: "logout",
              )
            ],
            onChanged: (value) {
              switch (value) {
                case "logout":
                  FirebaseAuth.instance.signOut();
                break;
              }
            },
          ),
        ],
      ),
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