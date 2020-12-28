import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
import 'chatList.dart';
import 'message.dart';
export 'message.dart';

class ChatBox {
  String _clId;
  String _reciver;

  final String _sender = FirebaseAuth.instance.currentUser.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatList _chatList = ChatList();

  void init({String clId, String reciver}) {
    this._clId = clId;
    this._reciver = reciver;
  }

  Future<void> sendText(String text) async {
    if (_clId == null) {
      _clId = await _chatList.create(_reciver);
    }
    CollectionReference _messageRef = _firestore.collection('message');

    return _messageRef.add({
      'clId': _clId,
      'sender': _sender,
      'reciver': _reciver,
      'text': text,
      'isRead': false,
      'sendTs': DateTime.now(),
    });
  }

  Message _toMessage(QueryDocumentSnapshot doc) {
    //print(doc.id);
    return Message.fromJson({
      'id': doc.id,
      'clId': doc['clId'],
      'text': doc['text'],
      'time': doc['sendTs'],
      'isRead': doc['isRead'],
      'isSend': doc['sender'] == _sender
    });
  }

  Stream<List<Message>> load() {
    final CollectionReference chatList = _firestore.collection('message');

    return chatList
        .where('clId', isEqualTo: _clId ?? '0')
        .orderBy('sendTs', descending: false)
        //.startAt()
        .snapshots()
        .asyncMap((data) {
      return data.docs.map((m) {
        return _toMessage(m);
      }).toList();
    });
  }
}
