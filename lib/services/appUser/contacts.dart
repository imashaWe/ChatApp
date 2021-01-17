import 'package:chatApp/services/appUser/profileData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contacts {
  final String _uid = FirebaseAuth.instance.currentUser.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProfileData>> fetch() async {
    final CollectionReference _usersRef = _firestore.collection('users');
    final QuerySnapshot _usersDoc =
        await _usersRef.where('uid', isNotEqualTo: _uid).get();
    return _usersDoc.docs.map((doc) {
      return ProfileData.fromJson({
        'uid': doc['uid'],
        'name': doc['name'],
        'imageUrl': doc['imageUrl'],
        'clId': null
      });
    }).toList();
  }

  // Future<void> sycnc() async {
  //   final Permission permissionContact = Permission.contacts;

  //   if (await permissionContact.request().isGranted) {
  //     Iterable<Contact> contacts =
  //         await ContactsService.getContacts(withThumbnails: false);

  //     final CollectionReference userRef = _firestore.collection('users');
  //     final CollectionReference contactsRef = _firestore.collection('contacts');
  //     final CollectionReference chatListRef = _firestore.collection('chatList');
  //     final WriteBatch batch = _firestore.batch();
  //     for (var c in contacts) {
  //       QuerySnapshot r = await userRef
  //           .where('phone',
  //               isEqualTo: int.parse(c.phones.first.value).toString())
  //           .limit(1)
  //           .get();

  //       if (r.docs.isNotEmpty) {
  //         String clId = null;
  //         final QueryDocumentSnapshot user = r.docs.first;

  //         final QuerySnapshot chatListDoc = await chatListRef
  //             .where('ids', isEqualTo: [user['uid'], _uid]).get();
  //         if (chatListDoc.docs.isNotEmpty) clId = chatListDoc.docs.first.id;
  //         print(chatListDoc.docs.length);
  //         final QuerySnapshot contactDoc = await contactsRef
  //             .where('uid', isEqualTo: user['uid'])
  //             .where('owner', isEqualTo: _uid)
  //             .get();

  //         if (contactDoc.docs.isNotEmpty) {
  //           batch.update(contactDoc.docs.first.reference, {
  //             'name': c.displayName,
  //             'imageUrl': user['imageUrl'],
  //             'phone': user['phone'],
  //             'clId': clId
  //           });
  //         } else {
  //           batch.set(contactsRef.doc(), {
  //             'owner': _uid,
  //             'name': c.displayName,
  //             'imageUrl': user['imageUrl'],
  //             'uid': user['uid'],
  //             'phone': user['phone'],
  //             'clId': clId
  //           });
  //         }
  //       }
  //       return batch.commit();
  //     }
  //   } else {
  //     final PermissionStatus r = await permissionContact.request();
  //     if (r.isGranted) {
  //       sycnc();
  //     } else {
  //       throw 'Permisson denied';
  //     }
  //   }
  // }

  // Future<List<ProfileData>> get() async {
  //   final CollectionReference contactsRef = _firestore.collection('users');
  //   final QuerySnapshot contacts = await contactsRef.get();

  //   if (contacts.docs.isNotEmpty)
  //     return contacts.docs
  //         .map((e) => ProfileData.fromJson({
  //               'uid': e['uid'],
  //               'name': e['name'],
  //               'imageUrl': e['imageUrl'],
  //               'clId': e['clId']
  //             }))
  //         .toList();
  //   else
  //     return [];
  // }

  Future<ProfileData> getProfile(String uid) async {
    final CollectionReference usersRef = _firestore.collection('users');
    final QuerySnapshot users =
        await usersRef.where('uid', isEqualTo: uid).limit(1).get();
    var e = users.docs.first;
    return ProfileData.fromJson({
      'uid': e['uid'],
      'name': e['name'],
      'imageUrl': e['imageUrl'],
      'clId': null
    });
  }
}
