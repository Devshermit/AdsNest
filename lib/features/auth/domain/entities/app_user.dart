class AppUser {
  final String id;
  final String email;
  final String? tenantId;
  final String role;
  final String fullName;
  final String? avatarUrl;
  final String? fcmToken;

  const AppUser({
    required this.id,
    required this.email,
    this.tenantId,
    required this.role,
    required this.fullName,
    this.avatarUrl,
    this.fcmToken,
  });

  // สร้าง AppUser จาก Map ที่ Query ได้จากตาราง profiles
  factory AppUser.fromProfileMap(Map<String, dynamic> map, String email) {
    return AppUser(
      id: map['id'],
      email: email,
      tenantId: map['tenant_id'],
      role: map['role'] ?? 'CLIENT_OWNER',
      fullName: map['full_name'] ?? 'ไม่มีชื่อ',
      avatarUrl: map['avatar_url'],
      fcmToken: map['fcm_token'],
    );
  }
}