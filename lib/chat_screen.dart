import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final firestoreMessagesReference = Firestore.instance
      .collection('chats')
      .document('main')
      .collection('messages');
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      // Chat list
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: firestoreMessagesReference.orderBy('createdAt').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Error checking
              if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return new ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new ListTile(
                        title: new Text(document['content']),
                        subtitle: new Text(document['authorId']),
                      );
                    }).toList(),
                  );
              }
            }),
      ),
      // Text Input
      Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(hintText: 'Write a message...'),
          )),
          RaisedButton(
            onPressed: () async {
              final messageContent = textEditingController.text;
              textEditingController.clear();
              await firestoreMessagesReference.document().setData({
                // TODO(kai): Get this UID from login
                'authorId': 'newFakeUid',
                'content': messageContent,
                'createdAt': DateTime.now()
              });
            },
            child: Text('Send'),
          )
        ],
      )
    ]);
  }
}
