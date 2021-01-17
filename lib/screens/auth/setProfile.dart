import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chatApp/models/appUser/appUser.dart';
import 'package:chatApp/widget/profileImage.dart';
import 'package:image_picker/image_picker.dart';

class SetProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  final Profile _profile = AppUser.profile;
  //final AppUser _appUser = AppUser();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _name = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  File _image;
  String _profileUrl;

  bool _isProcessing = false;

  @override
  void initState() {
    _profile.get().then((user) {
      setState(() {
        _name.text = user.name;
        _profileUrl = user.imageUrl;
      });
    });
    super.initState();
  }

  void _setImage(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  void _onSubmit() async {
    final String name = _name.text;
    _setProcess(true);

    if (name.isEmpty) return;
    try {
      await _profile.update(name: name, image: _image);
      Navigator.pushNamedAndRemoveUntil(context, '/chatList', (route) => false);
    } catch (e) {
      _setError("Something went wrong error!");
    }
  }

  void _setError(String error) {
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(
        error,
        //error.replaceAll('-', '\t'),
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 20),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _onTapImage() {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return Container(
        //color: Colors.grey,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () => _setImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Gallery'),
              onTap: () => _setImage(ImageSource.gallery),
            )
          ],
        ),
      );
    }, backgroundColor: Colors.white, elevation: 10);
  }

  void _setProcess(bool v) => setState(() => _isProcessing = v);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(50),
        child: ListView(
          padding: EdgeInsets.only(top: size.height * .2),
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(top: size.height * .06),
                child: Align(
                    child: GestureDetector(
                        child: _image == null && _profileUrl == null
                            ? CircleAvatar(
                                radius: 80,
                                child: Icon(
                                  Icons.person_add,
                                  size: 60,
                                ))
                            : _image != null
                                ? CircleAvatar(
                                    radius: 80,
                                    backgroundImage: FileImage(_image))
                                : ProfileImage(
                                    path: _profileUrl,
                                    radius: 80,
                                  ),
                        onTap: _onTapImage))),
            Container(
                padding: EdgeInsets.only(top: size.height * .06),
                child: TextField(
                  style: TextStyle(fontSize: 20),
                  controller: _name,
                  cursorColor: Colors.green,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person), hintText: 'Your Name'),
                )),
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: size.height * .1, horizontal: size.width * .2),
                child: _isProcessing
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).indicatorColor)))
                    : RaisedButton(
                        onPressed: _onSubmit,
                        child: Text(
                          'Finish',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
