class User {
  final String id;
  final String firebaseUid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.firebaseUid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Add validation for required fields
    if (json['id'] == null) throw Exception('User id is required');
    if (json['displayName'] == null) throw Exception('User displayName is required');
    
    return User(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String? ?? '',  // Provide default if null
      displayName: json['displayName'] as String,
      email: json['email'] as String? ?? '',  // Provide default if null
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? firebaseUid,
    String? displayName,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}