class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImage;
  final bool fingerprintEnabled;
  final bool isVerified;
  final bool isBlocked;
  final DateTime? blockedAt;
  final String? blockedReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImage,
    required this.fingerprintEnabled,
    required this.isVerified,
    required this.isBlocked,
    this.blockedAt,
    this.blockedReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      fingerprintEnabled: json['fingerprint_enabled'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      blockedAt: json['blocked_at'] != null ? DateTime.parse(json['blocked_at']) : null,
      blockedReason: json['blocked_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_image': profileImage,
      'fingerprint_enabled': fingerprintEnabled,
      'is_verified': isVerified,
      'is_blocked': isBlocked,
      'blocked_at': blockedAt?.toIso8601String(),
      'blocked_reason': blockedReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? fingerprintEnabled,
    bool? isVerified,
    bool? isBlocked,
    DateTime? blockedAt,
    String? blockedReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedAt: blockedAt ?? this.blockedAt,
      blockedReason: blockedReason ?? this.blockedReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}

