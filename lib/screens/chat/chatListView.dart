import 'package:chatApp/models/chat/chatData.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/models/appUser/appUser.dart';
import 'chatBoxView.dart';
import 'contactList.dart';
import 'package:chatApp/models/appUser/profileData.dart';
import 'package:chatApp/models/chat/chatList.dart';

class ChatListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatList _chatList = ChatList();

  @override
  void initState() {
    super.initState();
  }

  void _onTapFloatingActionBtn() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ContactList();
    }));
  }

  void _onChatListItemTap(ChatData profile) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ChatBoxView(
        name: profile.name,
        imageUrl: profile.imageUrl,
        reciver: profile.uid,
        clId: profile.clId,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<List<ChatData>>(
          stream: _chatList.load(),
          builder:
              (BuildContext context, AsyncSnapshot<List<ChatData>> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Icon(Icons.error),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            if (snapshot.data.length == 0)
              return Center(
                child: Icon(Icons.error),
              );
            return ListView(
              children: snapshot.data.map((p) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(p.imageUrl),
                  ),
                  subtitle: Text(p.subtitle),
                  title: Text(p.name),
                  trailing: Visibility(
                      visible: p.unreadCount > 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        radius: 15,
                        child: Text(p.unreadCount.toString()),
                      )),
                  onTap: () => _onChatListItemTap(p),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _onTapFloatingActionBtn,
        child: Icon(Icons.add),
      ),
    );
  }
}
