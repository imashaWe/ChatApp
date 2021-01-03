import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
import 'chatList.dart';
import 'message.dart';
export 'message.dart';

class ChatBox {
  String _clId;
  String _reciver;
  int _limit = 0;
  final String _sender = FirebaseAuth.instance.currentUser.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatList _chatList = ChatList();
  final StreamController<List<Message>> _chatStreamController =
      StreamController<List<Message>>();

  void init({String clId, String reciver}) async {
    this._clId = clId;
    this._reciver = reciver;
    if (_clId == null) {
      this._clId = await _chatList.getClid(_reciver);
    }

    loadMore();
  }

  Future<void> sendText(String text) async {
    if (_clId == null) {
      _clId = await _chatList.create(_reciver);
    }
    final CollectionReference _messageRef = _firestore.collection('message');
    final CollectionReference _chatListRef = _firestore.collection('chatList');
    _messageRef.add({
      'clId': _clId,
      'sender': _sender,
      'reciver': _reciver,
      'text': text,
      'isRead': false,
      'sendTs': DateTime.now(),
    });
    return _chatListRef.doc(_clId).get().then((doc) {
      final int i = doc['ids'].indexOf(_reciver);
      var users = doc['users'];
      users[i]['unreadCount']++;
      doc.reference.update(
          {'users': users, 'subtitle': text, 'lastUpdate': DateTime.now()});
    });
  }

  List<Message> _toMessages(QuerySnapshot data) {
    List<Message> messages = [];
    if (data.docs.isNotEmpty) {
      DateTime dateTime = data.docs.first['sendTs'].toDate();
      int numDays = _countDays(DateTime.now(), dateTime);
      String text;
      switch (numDays) {
        case 0:
          text = 'TODAY';
          break;
        case 1:
          text = 'YESTERDAY';
          break;
        default:
          text = DateFormat('MMMM d,yyyy').format(dateTime);
      }

      messages.add(Message.fromJson({'text': text, 'isMessage': false}));

      for (var doc in data.docs) {
        final DateTime msgDatetime = doc['sendTs'].toDate();
        numDays = _countDays(dateTime, msgDatetime);

        if (numDays != 0) {
          numDays = _countDays(DateTime.now(), msgDatetime);
          String text;
          switch (numDays) {
            case 0:
              text = 'TODAY';
              break;
            case 1:
              text = 'YESTERDAY';
              break;
            default:
              text = DateFormat('MMMM d,yyyy').format(msgDatetime);
          }
          messages.add(Message.fromJson({'text': text, 'isMessage': false}));
        }
        messages.add(Message.fromJson({
          'id': doc.id,
          'clId': doc['clId'],
          'text': doc['text'],
          'time': doc['sendTs'],
          'isRead': doc['isRead'],
          'isMessage': true,
          'isSend': doc['sender'] == _sender
        }));
        dateTime = msgDatetime;
      }
    }
    return messages;
  }

  int _countDays(DateTime first, DateTime second) {
    final DateTime firstInDate =
        DateTime.parse(DateFormat("yyyy-MM-dd").format(first));
    final DateTime secondInDate =
        DateTime.parse(DateFormat("yyyy-MM-dd").format(second));
    return firstInDate.difference(secondInDate).inDays;
  }

  void loadMore() {
    final CollectionReference chatList = _firestore.collection('message');
    chatList
        .where('clId', isEqualTo: _clId ?? '0')
        .orderBy('sendTs', descending: false)
        //.limit(_limit)
        //.startAt()
        .snapshots()
        .asyncMap((data) {
      return _toMessages(data);
    }).listen((r) {
      if (r.isNotEmpty) _chatStreamController.add(r);
    });
  }

  Stream<List<Message>> snapsshots() {
    return _chatStreamController.stream;
  }
}
