import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

const FORGROUND = Colors.white;
const COLORS = [
  Colors.greenAccent,
  Colors.blueAccent,
  Colors.redAccent,
  Colors.yellowAccent,
  Colors.purpleAccent,
  Colors.limeAccent,
  Colors.orangeAccent,
];

class ProfileImage extends StatefulWidget {
  final String path;
  final double radius;
  ProfileImage({@required this.path, this.radius = 35});
  @override
  State<StatefulWidget> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final firebase_storage.FirebaseStorage _firebaseStorage =
      firebase_storage.FirebaseStorage.instance;

  String _url;
  bool _isProcceng = true;

  @override
  void initState() {
    initImage();
    super.initState();
  }

  void initImage() async {
    try {
      final url = await _firebaseStorage.ref(widget.path).getDownloadURL();
      setState(() => _url = url);
    } catch (e) {
      setState(() => _url = '');
    }
  }

  Color randomColor() {
    final Random random = Random();
    return COLORS[random.nextInt(7)];
  }

  @override
  Widget build(BuildContext context) {
    final color = randomColor();
    return _url == null
        ? CircleAvatar(
            backgroundColor: color,
            radius: widget.radius,
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(FORGROUND)),
          )
        : _url != ''
            ? CircleAvatar(
                radius: widget.radius,
                backgroundColor: color,
                backgroundImage: NetworkImage(_url),
              )
            : CircleAvatar(
                backgroundColor: color,
                foregroundColor: FORGROUND,
                radius: widget.radius,
                child: Icon(Icons.person));
  }
}
