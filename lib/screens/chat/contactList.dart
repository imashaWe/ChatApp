import 'package:chatApp/widget/curveAppBar.dart';
import 'package:chatApp/widget/profileImage.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/models/appUser/appUser.dart';
import 'chatBoxView.dart';

class ContactList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<ProfileData> contactList = [];
  @override
  void initState() {
    _loadConatact();
    super.initState();
  }

  void _sync() async {
    // await AppUser.contacts.sycnc();
    _loadConatact();
  }

  void _loadConatact() {
    AppUser.contacts.fetch().then((_) => setState(() => contactList = _));
  }

  void _onContactTap(ProfileData profile) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ChatBoxView(
        name: profile.name,
        imageUrl: profile.imageUrl,
        reciver: profile.uid,
        clId: profile.clId,
      );
    }));
    //Navigator.repla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: CurveAppBar(
          actions: [
            IconButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios),
            ),
            Text('Contacts',
                style: TextStyle(
                    //fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0)),
            IconButton(
              color: Colors.white,
              onPressed: _sync,
              icon: Icon(Icons.sync),
            )
          ],
          child: ListView.separated(
            itemCount: contactList.length,
            itemBuilder: (context, int i) {
              return ListTile(
                leading: ProfileImage(
                  url: contactList[i].imageUrl,
                ),
                title: Text(contactList[i].name),
                onTap: () => _onContactTap(contactList[i]),
              );
            },
            separatorBuilder: (context, int i) {
              return Divider(
                color: Colors.black,
                height: 20,
              );
            },
          ),
        ));
  }
}
