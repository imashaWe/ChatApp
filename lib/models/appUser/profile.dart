import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'profileData.dart';
import 'pushNotification.dart';

class Profile {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _firebaseStorage =
      firebase_storage.FirebaseStorage.instance;

  Future<ProfileData> get() async {
    QueryDocumentSnapshot userDoc = await getDoc();
    if (userDoc != null)
      return ProfileData.fromJson({
        'uid': userDoc['uid'],
        'name': userDoc['name'],
        'imageUrl': userDoc['imageUrl']
      });
    else
      return ProfileData.fromJson(
          {'uid': null, 'name': null, 'imageUrl': null});
  }

  Future<QueryDocumentSnapshot> getDoc() async {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    final CollectionReference userDocs = _firestore.collection('users');
    QuerySnapshot docs =
        await userDocs.where('uid', isEqualTo: uid).limit(1).get();
    if (docs.docs.isNotEmpty)
      return docs.docs.first;
    else
      return null;
  }

  Future<void> init({@required String ccode, @required String phone}) async {
    final String uid = FirebaseAuth.instance.currentUser.uid;

    final QueryDocumentSnapshot oldUser = await getDoc();
    if (oldUser != null) {
      return await oldUser.reference.update({
        'ccode': ccode,
        'phone': phone,
      });
    } else {
      final String token = await PushNotifiaction.getToken();
      final CollectionReference userDocs = _firestore.collection('users');

      return await userDocs.add({
        'uid': uid,
        'ccode': ccode,
        'phone': phone,
        'token': token,
        'name': null,
        'imageUrl': null
      });
    }
  }

  Future<void> update({String name, File image}) async {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    if (image != null) {
      try {
        firebase_storage.TaskSnapshot r =
            await _firebaseStorage.ref('profile/$uid/').putFile(image);
        DocumentSnapshot documentSnapshot = await getDoc();
        return await documentSnapshot.reference
            .update({'imageUrl': 'profile/$uid', 'name': name});
      } on firebase_core.FirebaseException catch (e) {
        throw e;
      }
    } else {
      DocumentSnapshot documentSnapshot = await getDoc();
      return await documentSnapshot.reference.update({'name': name});
    }
  }

  Future<void> setToken(String token) async {
    final String uid = FirebaseAuth.instance.currentUser.uid;

    QuerySnapshot _docs = await _firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    return await _docs.docs.first.reference.update({'token': token});
  }
}
