import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String clId;
  final String id;
  //final DateTime time;
  final Timestamp time;
  final bool isSend;
  final bool isRead;
  Message({this.text, this.clId, this.id, this.time, this.isSend, this.isRead});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        time: json['time'],
        clId: json['clId'],
        id: json['id'],
        isSend: json['isSend'],
        isRead: json['isRead']);
  }

  Future<void> setAsRead() async {
    final CollectionReference messageRef =
        FirebaseFirestore.instance.collection('message');
    await messageRef.doc(id).update({'isRead': true});
    print("Set As read");
  }
}
