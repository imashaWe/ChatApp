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
    await AppUser.contacts.sycnc();
    _loadConatact();
  }

  void _loadConatact() {
    AppUser.contacts.get().then((_) => setState(() => contactList = _));
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
          title: Text('Contacts'),
          actions: [
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: _sync,
            )
          ],
        ),
        body: Container(
          child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, int i) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contactList[i].imageUrl),
                  ),
                  title: Text(contactList[i].name),
                  onTap: () => _onContactTap(contactList[i]),
                );
              }),
        ));
  }
}
