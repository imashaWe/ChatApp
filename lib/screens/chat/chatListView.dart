import 'package:chatApp/services/chat/chatData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatBoxView.dart';
import 'contactList.dart';
import 'package:chatApp/services/chat/chatList.dart';
import 'package:chatApp/widget/profileImage.dart';
import 'package:chatApp/services/appUser/appUser.dart';

enum AppBarAction { Profile, SignOut }

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

  void _onTapSearch() {
    // TODO
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

  String _toTimeString(DateTime dateTime) {
    final int numDays = DateTime.parse(
            DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .difference(DateTime.parse(DateFormat("yyyy-MM-dd").format(dateTime)))
        .inDays;
    switch (numDays) {
      case 0:
        return DateFormat("K:mm a").format(dateTime);
      case 1:
        return 'Yesterday';
      default:
        return DateFormat("MM/dd/yy").format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _onTapFloatingActionBtn,
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text(
            'ChatApp',
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
            PopupMenuButton<AppBarAction>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (v) async {
                if (v == AppBarAction.Profile) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  await AppUser.logout();
                  Navigator.pushNamed(context, '/home');
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AppBarAction>>[
                const PopupMenuItem(
                  value: AppBarAction.Profile,
                  child: Text('Account settings'),
                ),
                const PopupMenuItem(
                  value: AppBarAction.SignOut,
                  child: Text('Sign out'),
                )
              ],
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(5),
          child: StreamBuilder<List<ChatData>>(
            stream: _chatList.load(),
            builder:
                (BuildContext context, AsyncSnapshot<List<ChatData>> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline),
                      Text("Something went wrong")
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              if (snapshot.data.length == 0)
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline),
                      Text("No active chatroom")
                    ],
                  ),
                );
              return ListView(
                children: snapshot.data.map((p) {
                  return ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ProfileImage(
                      path: p.imageUrl,
                    ),
                    subtitle: Text(p.subtitle),
                    title: Text(
                      p.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_toTimeString(p.lastUpdate)),
                        Visibility(
                            visible: p.unreadCount > 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              radius: 15,
                              child: Text(p.unreadCount.toString()),
                            ))
                      ],
                    ),
                    onTap: () => _onChatListItemTap(p),
                  );
                }).toList(),
              );
            },
          ),
        ));
  }
}
