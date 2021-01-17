class UserData {
  final String uid;
  final String name;
  final String profile;
  final int logStatus;

  UserData({this.uid, this.name, this.profile, this.logStatus});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'],
      name: json['name'],
      profile: json['profile'],
      logStatus: json['logStatus'],
    );
  }
}
