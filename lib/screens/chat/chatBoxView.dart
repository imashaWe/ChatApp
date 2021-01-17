import 'package:flutter/material.dart';
import 'package:chatApp/models/chat/chatBox.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:chatApp/widget/profileImage.dart';

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
    _controller.addListener(_scrollListener);
    _chatBox.init(clId: widget.clId, reciver: widget.reciver);
    super.initState();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print('bottom');
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print('top');
    }
  }

  void _scrollToEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  void _send() async {
    String text = _text.text;
    if (text.isEmpty) return;
    _text.clear();
    await _chatBox.sendText(text);
    _scrollToEnd();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: ProfileImage(
              path: widget.imageUrl,
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: SizedBox(
                  height: double.infinity,
                  child: StreamBuilder<List<Message>>(
                    stream: _chatBox.snapsshots(),
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
                          if (!m.isMessage) {
                            return Bubble(
                              margin: BubbleEdges.only(top: 10),
                              alignment: Alignment.center,
                              color: Color.fromRGBO(212, 234, 244, 1.0),
                              child: Text(m.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11.0)),
                            );
                          }
                          final DateTime dateTime = m.time.toDate();
                          if (!m.isSend & !m.isRead) m.setAsRead();
                          return Bubble(
                              margin: m.isSend
                                  ? BubbleEdges.only(right: 10)
                                  : BubbleEdges.only(left: 10),
                              style: m.isSend ? styleMe : styleSomebody,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      m.text,
                                      style: TextStyle(fontSize: 16),
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
                                          size: 16,
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
                  ))),
          Padding(
              padding: EdgeInsets.only(top: 5),
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
                      filled: true,
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
                  ))),
        ],
      ),
    );
  }
}
