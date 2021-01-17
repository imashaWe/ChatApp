import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String text;
  final String clId;
  final String id;
  //final DateTime time;
  final Timestamp time;
  final bool isSend;
  final bool isRead;
  final bool isMessage;
  Message(
      {this.text,
      this.clId,
      this.id,
      this.time,
      this.isSend,
      this.isRead,
      this.isMessage});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        time: json['time'],
        clId: json['clId'],
        id: json['id'],
        isSend: json['isSend'],
        isRead: json['isRead'],
        isMessage: json['isMessage']);
  }

  Future<void> setAsRead() async {
    final CollectionReference messageRef =
        FirebaseFirestore.instance.collection('message');
    final CollectionReference chatListRef =
        FirebaseFirestore.instance.collection('chatList');
    await messageRef.doc(id).update({'isRead': true});
    return chatListRef.doc(clId).get().then((doc) {
      final int i = doc['ids'].indexOf(FirebaseAuth.instance.currentUser.uid);
      var users = doc['users'];
      users[i]['unreadCount']--;
      doc.reference.update({'users': users});
    });
  }
}
