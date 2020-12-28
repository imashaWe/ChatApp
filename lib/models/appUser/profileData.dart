class ProfileData {
  final String uid;
  final String name;
  final String imageUrl;
  final String clId;

  ProfileData({this.uid, this.name, this.imageUrl, this.clId});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      uid: json['uid'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      clId: json['clId'],
    );
  }
}
