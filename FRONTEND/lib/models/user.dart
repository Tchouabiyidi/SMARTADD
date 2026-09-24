enum UserRole {
  advertiser,
  billboardOwner,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.advertiser:
        return 'Advertiser';
      case UserRole.billboardOwner:
        return 'Billboard Owner';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String toDbValue() {
    switch (this) {
      case UserRole.advertiser:
        return 'ADVERTISER';
      case UserRole.billboardOwner:
        return 'BILLBOARD_OWNER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase().replaceAll(' ', '_')) {
      case 'advertiser':
        return UserRole.advertiser;
      case 'billboard_owner':
      case 'billboardowner':
      case 'owner':
        return UserRole.billboardOwner;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.advertiser;
    }
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? token;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'advertiser'),
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.toDbValue(),
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
