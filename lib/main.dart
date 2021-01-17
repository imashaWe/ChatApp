import 'package:chatApp/models/appUser/appUser.dart';
import 'package:chatApp/screens/auth/setProfile.dart';
import 'package:chatApp/screens/chat/chatListView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/screens/auth/OtpVerify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      routes: {
        '/home': (context) => CheckLogin(),
        '/chatList': (context) => ChatListView(),
        '/profile': (context) => SetProfile(),
      },
      theme: ThemeData(
        primaryColor: Color(0xFF21BFBD),
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),

        textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
            bodyText1: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.normal),
            button: TextStyle(color: Colors.white, fontSize: 18)),
        buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFF21BFBD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              // side: BorderSide(color: Colors.greenAccent)
            )),

        //inputDecorationTheme: InputDecorationTheme()
      ),
      home: CheckLogin(),
    );
  }
}

class CheckLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CheckLoinState();
}

class _CheckLoinState extends State<CheckLogin> {
  @override
  void initState() {
    AppUser.loginStatus().then((s) {
      switch (s) {
        case 0:
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) {
            return OtpVerify();
          }), (route) => false);
          break;
        case 1:
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) {
            return SetProfile();
          }), (route) => false);
          break;
        default:
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) {
            return ChatListView();
          }), (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Image.asset('assets/images/logo.png'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).indicatorColor),
            )
          ],
        ),
      ),
    );
  }
}
