class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final int followerCount;
  final int followingCount;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'],
      followerCount: map['followerCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'followerCount': followerCount,
      'followingCount': followingCount,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    int? followerCount,
    int? followingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
