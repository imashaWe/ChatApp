import 'package:chatApp/services/appUser/profileData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'contacts.dart';

export "contacts.dart";
export 'profile.dart';
export 'profileData.dart';

class AppUser {
  static final User user = FirebaseAuth.instance.currentUser;
  static final Profile profile = Profile();
  static final Contacts contacts = Contacts();

  static Future<int> loginStatus() async {
    if (user == null) {
      return 0;
    } else {
      final ProfileData userProfile = await profile.get();
      if (userProfile.name == null) {
        return 1;
      } else {
        return 3;
      }
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
