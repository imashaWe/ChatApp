import 'package:chatApp/models/chat/chatData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatBoxView.dart';
import 'contactList.dart';
import 'package:chatApp/models/chat/chatList.dart';
import 'package:chatApp/widget/profileImage.dart';
import 'package:chatApp/widget/curveAppBar.dart';

enum AppBarAction { Profile }

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

  String _toTimeString(DateTime dateTime) {
    final int numDays = DateTime.parse(
            DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .difference(DateTime.parse(DateFormat("yyyy-MM-dd").format(dateTime)))
        .inDays;
    print(numDays);
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
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _onTapFloatingActionBtn,
        child: Icon(Icons.add),
      ),
      body: CurveAppBar(
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
                print(p.imageUrl);
                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ProfileImage(
                    url: p.imageUrl,
                  ),
                  subtitle: Text(p.subtitle),
                  title: Text(
                    p.name,
                    style: TextStyle(fontSize: 20),
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
        actions: [
          Container(
            child: Row(
              children: <Widget>[
                Text('Chat',
                    style: TextStyle(
                        //fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Text('App',
                    style: TextStyle(
                        //fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),
          PopupMenuButton<AppBarAction>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (v) {
              Navigator.pushNamed(context, '/profile');
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<AppBarAction>>[
              const PopupMenuItem(
                value: AppBarAction.Profile,
                child: Text('Profile'),
              ),
              // const PopupMenuItem(
              //   value: AppBarAction.Update,
              //   child: Text('update'),
              // )
            ],
          )
        ],
      ),
    );
  }
}
