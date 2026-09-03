class Campaign {
  final String id;
  final String tenantId;
  final String campaignName;
  final String platform;
  final String status;
  final double dailyBudgetLimit;
  final DateTime? createdAt;

  const Campaign({
    required this.id,
    required this.tenantId,
    required this.campaignName,
    required this.platform,
    required this.status,
    required this.dailyBudgetLimit,
    this.createdAt,
  });

  bool get isActive => status == 'ACTIVE';

  // แปลงข้อมูลจาก Supabase JSON -> Campaign Object
  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] ?? '',
      tenantId: map['tenant_id'] ?? '',
      campaignName: map['campaign_name'] ?? 'ไม่มีชื่อแคมเปญ',
      platform: (map['platform'] ?? 'OTHER').toString().toUpperCase(),
      status: map['status'] ?? 'PAUSED',
      dailyBudgetLimit: (map['daily_budget_limit'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // แปลง Campaign Object -> JSON เพื่อส่งไป Supabase
  Map<String, dynamic> toMap() {
    return {
      'tenant_id': tenantId,
      'campaign_name': campaignName,
      'platform': platform,
      'status': status,
      'daily_budget_limit': dailyBudgetLimit,
    };
  }

  // ใช้สำหรับอัปเดต Object แบบ Immutable
  Campaign copyWith({
    String? id,
    String? tenantId,
    String? campaignName,
    String? platform,
    String? status,
    double? dailyBudgetLimit,
    DateTime? createdAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      campaignName: campaignName ?? this.campaignName,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      dailyBudgetLimit: dailyBudgetLimit ?? this.dailyBudgetLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
