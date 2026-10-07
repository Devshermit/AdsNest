enum UserRole { superAdmin, agencyStaff, clientOwner, affiliate }

class AppUser {
  final String id;
  final String? tenantId;
  final String
  role; // 'SUPER_ADMIN', 'AGENCY_STAFF', 'CLIENT_OWNER', 'AFFILIATE'
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    this.tenantId,
    required this.role,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String?,
      role: json['role'] as String? ?? 'CLIENT_OWNER',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'role': role,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
