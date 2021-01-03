import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class ProfileImage extends StatefulWidget {
  final String url;
  final double radius;
  ProfileImage({@required this.url, this.radius = 35});
  @override
  State<StatefulWidget> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final firebase_storage.FirebaseStorage _firebaseStorage =
      firebase_storage.FirebaseStorage.instance;

  String url;

  @override
  void initState() {
    _firebaseStorage
        .ref(widget.url)
        .getDownloadURL()
        .then((r) => setState(() => url = r))
        .catchError((e) => setState(() => url = null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return url != null
        ? CircleAvatar(
            radius: widget.radius,
            backgroundImage: NetworkImage(url),
          )
        : CircleAvatar(
            radius: widget.radius,
            child: Icon(Icons.person),
          );
  }
}
