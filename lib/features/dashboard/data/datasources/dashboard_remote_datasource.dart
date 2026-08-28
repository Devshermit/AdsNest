import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/dashboard_metrics.dart';

abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter);
  Future<List<Map<String, dynamic>>> fetchChartData(DateRangeFilter filter);
  Future<List<Map<String, dynamic>>> fetchTopCampaigns(DateRangeFilter filter);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabase;

  DashboardRemoteDataSourceImpl(this.supabase);

  @override
  Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter) async {
    // จำลอง Response หรือเชื่อมต่อ Supabase RPC/Tables
    await Future.delayed(const Duration(milliseconds: 300));
    final multiplier = filter == DateRangeFilter.today
        ? 0.2
        : (filter == DateRangeFilter.last7Days ? 0.7 : 1.0);

    return {
      'total_spend': 145200.0 * multiplier,
      'total_revenue': 522720.0 * multiplier,
      'roas': 3.60,
      'total_conversions': (1240 * multiplier).round(),
      'ctr': 2.85,
      'spend_change': 12.5,
      'roas_change': 8.4,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChartData(
    DateRangeFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'label': 'จ.', 'spend': 12000.0, 'revenue': 42000.0},
      {'label': 'อ.', 'spend': 15000.0, 'revenue': 58000.0},
      {'label': 'พ.', 'spend': 18000.0, 'revenue': 61000.0},
      {'label': 'พฤ.', 'spend': 14000.0, 'revenue': 49000.0},
      {'label': 'ศ.', 'spend': 22000.0, 'revenue': 88000.0},
      {'label': 'ส.', 'spend': 28000.0, 'revenue': 105000.0},
      {'label': 'อา.', 'spend': 25000.0, 'revenue': 94000.0},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTopCampaigns(
    DateRangeFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'c1',
        'name': 'Mega Sale - TikTok Ads',
        'platform': 'TikTok',
        'spend': 45000.0,
        'revenue': 202500.0,
        'roas': 4.50,
        'status': 'ACTIVE',
      },
      {
        'id': 'c2',
        'name': 'Retargeting - FB Catalog',
        'platform': 'Facebook',
        'spend': 38000.0,
        'revenue': 144400.0,
        'roas': 3.80,
        'status': 'ACTIVE',
      },
      {
        'id': 'c3',
        'name': 'Google Search - Brand Keywords',
        'platform': 'Google',
        'spend': 22000.0,
        'revenue': 77000.0,
        'roas': 3.50,
        'status': 'PAUSED',
      },
    ];
  }
}
