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

  void _onTapSearch() {
    // TODO
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
        appBar: AppBar(
          title: Text(
            'Contacts',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: _onTapSearch,
            ),
            IconButton(
              color: Colors.white,
              onPressed: _sync,
              icon: Icon(Icons.sync),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(5),
          child: ListView.separated(
            itemCount: contactList.length,
            itemBuilder: (context, int i) {
              return ListTile(
                leading: ProfileImage(
                  path: contactList[i].imageUrl,
                ),
                title: Text(contactList[i].name),
                trailing: Icon(Icons.message),
                onTap: () => _onContactTap(contactList[i]),
              );
            },
            separatorBuilder: (context, int i) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              );
            },
          ),
        ));
  }
}
