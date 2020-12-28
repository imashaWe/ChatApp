import 'package:flutter/material.dart';
import 'package:chatApp/models/chat/chatBox.dart';
import 'package:intl/intl.dart';
//import 'package:intl/date_symbol_data_local.dart';
import 'package:bubble/bubble.dart';

class ChatBoxView extends StatefulWidget {
  final String name;
  final String imageUrl;
  String clId;
  final String reciver;

  ChatBoxView({this.reciver, this.name, this.imageUrl, this.clId});

  @override
  State<StatefulWidget> createState() => _ChatBoxViewState();
}

class _ChatBoxViewState extends State<ChatBoxView> {
  final ChatBox _chatBox = ChatBox();
  final TextEditingController _text = TextEditingController();
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    //_controller = ScrollController();
    _controller.addListener(_scrollListener);
    _chatBox.init(clId: widget.clId, reciver: widget.reciver);
    super.initState();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print('Birrom');
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print('top');
    }
  }

  void _send() async {
    String text = _text.text;
    if (text.isEmpty) return;
    await _chatBox.sendText(text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double px = 1 / pixelRatio;

    final BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );

    final BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(widget.name),
          // title: Row(
          //   children: [
          //     Flexible(
          //       child: CircleAvatar(
          //         radius: 20,
          //         backgroundImage: NetworkImage(widget.imageUrl),
          //       ),
          //     ),
          //     Flexible(
          //       child: Text(widget.name),
          //     )
          //   ],
          // ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: size.height * .01),
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * .16),
              child: ListTile(
                  title: TextField(
                    onSubmitted: (v) => _send(),
                    scrollPadding: EdgeInsets.all(20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: size.width * .001,
                          horizontal: size.height * .03),
                      hintText: 'Type a message',
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    controller: _text,
                  ),
                  trailing: GestureDetector(
                    child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        radius: 25,
                        child: Icon(Icons.send)),
                    onTap: _send,
                  )),
            )),
        body: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * .02, vertical: size.height * .02),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                    height: size.height * .7,
                    child: StreamBuilder<List<Message>>(
                      stream: _chatBox.load(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Message>> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Container();
                        }
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        if (snapshot.data.isEmpty)
                          return Center(
                            child: Icon(Icons.error),
                          );
                        return ListView(
                          controller: _controller,
                          children: snapshot.data.map((m) {
                            final DateTime dateTime = m.time.toDate();
                            if (!m.isSend & !m.isRead) m.setAsRead();
                            return Bubble(
                                style: m.isSend ? styleMe : styleSomebody,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        m.text,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Wrap(
                                      children: [
                                        Text(
                                          DateFormat('K:mm a').format(dateTime),
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        Visibility(
                                          visible: m.isSend & m.isRead,
                                          child: Icon(
                                            Icons.check,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ));
                          }).toList(),
                        );
                      },
                    )),
              ],
            ),
          ),
        ));
  }
}
