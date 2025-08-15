class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImage;
  final bool fingerprintEnabled;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImage,
    this.fingerprintEnabled = false,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      fingerprintEnabled: json['fingerprint_enabled'] ?? false,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }
  
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0].toUpperCase()}${lastName![0].toUpperCase()}';
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else {
      return username[0].toUpperCase();
    }
  }
  
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? fingerprintEnabled,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

