import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatApp/services/appUser/appUser.dart';
import 'chatData.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

class ChatList {
  final String _sender = FirebaseAuth.instance.currentUser.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Contacts _contacts = AppUser.contacts;

  Future<String> create(String reciver, String text) async {
    final CollectionReference chatList = _firestore.collection('chatList');
    QuerySnapshot r = await chatList
        .where('ids', isEqualTo: [_sender, reciver])
        .limit(1)
        .get();
    if (r.docs.isNotEmpty) {
      return r.docs.first.id;
    } else {
      ProfileData senderProfile = await AppUser.profile.get();
      ProfileData reciverProfile = await _contacts.getProfile(reciver);

      var senderData = {
        'name': senderProfile.name,
        'imageUrl': senderProfile.imageUrl,
        'uid': senderProfile.uid,
        'unreadCount': 0
      };

      var reciverData = {
        'name': reciverProfile.name,
        'imageUrl': reciverProfile.imageUrl,
        'uid': reciverProfile.uid,
        'unreadCount': 0
      };

      DocumentReference r = await chatList.add({
        'ids': [_sender, reciver],
        'users': [senderData, reciverData],
        'lastUpdate': DateTime.now(),
        'subtitle': text,
      });
      return r.id;
    }
  }

  ChatData _getProfile(QueryDocumentSnapshot doc) {
    final int i = 1 - doc['ids'].indexOf(_sender);
    return ChatData.fromJson({
      'uid': doc['users'][i]['uid'],
      'name': doc['users'][i]['name'],
      'subtitle': doc['subtitle'],
      'lastUpdate': doc['lastUpdate'],
      'imageUrl': doc['users'][i]['imageUrl'],
      'clId': doc.id,
      'unreadCount': doc['users'][1 - i]['unreadCount']
    });
  }

  Stream<List<ChatData>> load() {
    final CollectionReference chatList = _firestore.collection('chatList');
    return chatList
        .where('ids', arrayContainsAny: [_sender])
        .orderBy('lastUpdate', descending: true)
        .snapshots()
        .asyncMap((chatList) {
          return chatList.docs.map((c) {
            return _getProfile(c);
          }).toList();
        });
  }

  Future<String> getClid(String uid) async {
    final CollectionReference _clRef = _firestore.collection('chatList');
    final QuerySnapshot _clDocs =
        await _clRef.where('ids', isEqualTo: [_sender, uid]).limit(1).get();
    if (_clDocs.docs.isNotEmpty)
      return _clDocs.docs.first.id;
    else
      return null;
  }
}
