import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifiaction {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // void init() async {
  //   final String token =
  //       await _firebaseMessaging.getToken().catchError((e) => {print(e)});
  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage: $message");
  //       // _showItemDialog(message);
  //     },
  //     //onBackgroundMessage: myBackgroundMessageHandler,
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message");
  //       // _navigateToItemDetail(message);
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume: $message");
  //       // _navigateToItemDetail(message);
  //     },
  //   );
  // }

  static Future<String> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
