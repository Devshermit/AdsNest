import 'package:equatable/equatable.dart';

enum DateRangeFilter { today, last7Days, last30Days, thisMonth }

class DashboardMetrics extends Equatable {
  final double totalSpend;
  final double totalRevenue;
  final double roas;
  final int totalConversions;
  final double ctr;
  final double spendChangePercentage;
  final double roasChangePercentage;

  const DashboardMetrics({
    required this.totalSpend,
    required this.totalRevenue,
    required this.roas,
    required this.totalConversions,
    required this.ctr,
    required this.spendChangePercentage,
    required this.roasChangePercentage,
  });

  @override
  List<Object?> get props => [
    totalSpend,
    totalRevenue,
    roas,
    totalConversions,
    ctr,
    spendChangePercentage,
    roasChangePercentage,
  ];
}

class PerformanceChartPoint extends Equatable {
  final String label; // เช่น 'Mon', 'Tue', '29 Aug'
  final double spend;
  final double revenue;

  const PerformanceChartPoint({
    required this.label,
    required this.spend,
    required this.revenue,
  });

  @override
  List<Object?> get props => [label, spend, revenue];
}

class CampaignSummary extends Equatable {
  final String id;
  final String name;
  final String platform; // 'Facebook', 'TikTok', 'Google'
  final double spend;
  final double revenue;
  final double roas;
  final String status; // 'ACTIVE', 'PAUSED'

  const CampaignSummary({
    required this.id,
    required this.name,
    required this.platform,
    required this.spend,
    required this.revenue,
    required this.roas,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, platform, spend, revenue, roas, status];
}
