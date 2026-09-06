class AffiliateLinkModel {
  final String id;
  final String campaignId;
  final String affiliateId;
  final String shortCode;
  final String destinationUrl;
  final int clicksCount;
  final DateTime createdAt;

  // Extra joined fields (เพื่อนำมาแสดงใน UI)
  final String? campaignTitle;
  final String? affiliateName;

  AffiliateLinkModel({
    required this.id,
    required this.campaignId,
    required this.affiliateId,
    required this.shortCode,
    required this.destinationUrl,
    required this.clicksCount,
    required this.createdAt,
    this.campaignTitle,
    this.affiliateName,
  });

  factory AffiliateLinkModel.fromJson(Map<String, dynamic> json) {
    return AffiliateLinkModel(
      id: json['id'] as String,
      campaignId: json['campaign_id'] as String,
      affiliateId: json['affiliate_id'] as String,
      shortCode: json['short_code'] as String,
      destinationUrl: json['destination_url'] as String,
      clicksCount: json['clicks_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      campaignTitle: json['campaigns']?['title'] as String?,
      affiliateName: json['profiles']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'affiliate_id': affiliateId,
      'short_code': shortCode,
      'destination_url': destinationUrl,
    };
  }
}
