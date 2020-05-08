import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("chat").orderBy("createdAt", descending: true).snapshots(),
        builder: (context, streamSnapshot) {
          switch (streamSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              final messages = streamSnapshot.data.documents;
              return ListView.builder(
                reverse: true,
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
      );
  }
}