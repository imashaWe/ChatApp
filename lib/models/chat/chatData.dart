class ChatData {
  final String uid;
  final String name;
  final String imageUrl;
  final String subtitle;
  final String clId;
  final int unreadCount;
  ChatData(
      {this.uid,
      this.name,
      this.imageUrl,
      this.subtitle,
      this.clId,
      this.unreadCount});

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
        uid: json['uid'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        subtitle: json['subtitle'],
        clId: json['clId'],
        unreadCount: json['unreadCount']);
  }
}
