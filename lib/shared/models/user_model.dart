class UserModel {
  final String id;
  final String email;
  final String? avatar;
  final String? username;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.avatar,
    this.username,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'avatar': avatar,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? avatar,
    String? username,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
