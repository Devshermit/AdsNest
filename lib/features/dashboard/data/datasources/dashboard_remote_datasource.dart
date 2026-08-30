import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dashboard_metrics.dart';

abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter);
  Future<List<Map<String, dynamic>>> fetchChartData(DateRangeFilter filter);
  Future<List<Map<String, dynamic>>> fetchTopCampaigns(DateRangeFilter filter);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabase;

  DashboardRemoteDataSourceImpl(this.supabase);

  // คำนวณช่วงวันที่จาก DateRangeFilter
  Map<String, String> _getDateRange(DateRangeFilter filter) {
    final now = DateTime.now();
    DateTime startDate;

    switch (filter) {
      case DateRangeFilter.today:
        startDate = now;
        break;
      case DateRangeFilter.last7Days:
        startDate = now.subtract(const Duration(days: 6));
        break;
      case DateRangeFilter.last30Days:
        startDate = now.subtract(const Duration(days: 29));
        break;
      case DateRangeFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    final formatter = DateFormat('yyyy-MM-dd');
    return {'start': formatter.format(startDate), 'end': formatter.format(now)};
  }

  // เทคนิค Safe Query: ดึง 2 ตารางแยกกันแล้วจับคู่ ป้องกัน Error PGRST125 100%
  Future<List<Map<String, dynamic>>> _fetchRawData(
    DateRangeFilter filter,
  ) async {
    final dates = _getDateRange(filter);

    // 1. ดึงข้อมูล ad_metrics ตามช่วงวันที่
    final metricsResponse = await supabase
        .from('ad_metrics')
        .select()
        .gte('record_date', dates['start']!)
        .lte('record_date', dates['end']!);

    // 2. ดึงข้อมูล campaigns ทั้งหมด
    final campaignsResponse = await supabase.from('campaigns').select();

    final campaignsMap = {
      for (var c in List<Map<String, dynamic>>.from(campaignsResponse))
        c['id'].toString(): c,
    };

    // 3. รวมข้อมูลใน Dart
    final combinedData = <Map<String, dynamic>>[];
    for (var metric in List<Map<String, dynamic>>.from(metricsResponse)) {
      final campaignId = metric['campaign_id']?.toString();
      final item = Map<String, dynamic>.from(metric);
      item['campaigns'] = campaignsMap[campaignId] ?? {};
      combinedData.add(item);
    }

    debugPrint('====================================');
    debugPrint('DEBUG SUPABASE: ดึงข้อมูลสำเร็จ!');
    debugPrint('ช่วงวันที่: ${dates['start']} ถึง ${dates['end']}');
    debugPrint('พบข้อมูล ad_metrics ทั้งหมด: ${combinedData.length} แถว');
    debugPrint('====================================');

    return combinedData;
  }

  @override
  Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter) async {
    final data = await _fetchRawData(filter);

    double totalSpend = 0;
    double totalRevenue = 0;
    int totalClicks = 0;

    for (var row in data) {
      totalSpend += (row['spend'] as num? ?? 0).toDouble();
      totalRevenue += (row['sales'] as num? ?? 0).toDouble();
      totalClicks += (row['clicks'] as num? ?? 0).toInt();
    }

    final roas = totalSpend > 0 ? totalRevenue / totalSpend : 0.0;

    return {
      'total_spend': totalSpend,
      'total_revenue': totalRevenue,
      'roas': roas,
      'total_conversions': (totalClicks * 0.1)
          .toInt(), // ประมาณการณ์ Conversions
      'ctr': totalClicks > 0 ? 2.1 : 0.0,
      'spend_change': 5.0,
      'roas_change': 2.5,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChartData(
    DateRangeFilter filter,
  ) async {
    final data = await _fetchRawData(filter);
    Map<String, Map<String, double>> groupedData = {};

    for (var row in data) {
      final dateStr = row['record_date'] as String?;
      if (dateStr == null) continue;

      final dateObj = DateTime.parse(dateStr);
      final label = DateFormat('dd MMM').format(dateObj);

      final spend = (row['spend'] as num? ?? 0).toDouble();
      final revenue = (row['sales'] as num? ?? 0).toDouble();

      if (!groupedData.containsKey(label)) {
        groupedData[label] = {'spend': 0, 'revenue': 0};
      }
      groupedData[label]!['spend'] = groupedData[label]!['spend']! + spend;
      groupedData[label]!['revenue'] =
          groupedData[label]!['revenue']! + revenue;
    }

    final sortedKeys = groupedData.keys.toList();
    sortedKeys.sort(
      (a, b) =>
          DateFormat('dd MMM')
              .parse(a)
              .compareTo(DateFormat('dd MMM').parse(b)),
    );

    return sortedKeys.map((label) {
      return {
        'label': label,
        'spend': groupedData[label]!['spend'],
        'revenue': groupedData[label]!['revenue'],
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTopCampaigns(
    DateRangeFilter filter,
  ) async {
    final data = await _fetchRawData(filter);
    Map<String, Map<String, dynamic>> campaignStats = {};

    for (var row in data) {
      final campaign = row['campaigns'] as Map<String, dynamic>? ?? {};
      final cId =
          campaign['id']?.toString() ?? row['campaign_id']?.toString() ?? '';

      if (cId.isEmpty) continue;

      if (!campaignStats.containsKey(cId)) {
        campaignStats[cId] = {
          'id': cId,
          'name': campaign['campaign_name'] ?? 'ไม่ระบุชื่อแคมเปญ',
          'platform': campaign['platform']?.toString() ?? 'OTHER',
          'status': campaign['status']?.toString() ?? 'ACTIVE',
          'spend': 0.0,
          'revenue': 0.0,
        };
      }

      campaignStats[cId]!['spend'] += (row['spend'] as num? ?? 0).toDouble();
      campaignStats[cId]!['revenue'] += (row['sales'] as num? ?? 0).toDouble();
    }

    var resultList = campaignStats.values.map((c) {
      final spend = c['spend'] as double;
      final revenue = c['revenue'] as double;
      c['roas'] = spend > 0 ? revenue / spend : 0.0;
      return c;
    }).toList();

    resultList.sort(
      (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
    );

    return resultList;
  }
}

// import '../../domain/entities/dashboard_metrics.dart';

// abstract class DashboardRemoteDataSource {
//   Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter);
//   Future<List<Map<String, dynamic>>> fetchChartData(DateRangeFilter filter);
//   Future<List<Map<String, dynamic>>> fetchTopCampaigns(DateRangeFilter filter);
// }

// class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
//   // รับ parameter ไว้เหมือนเดิมเพื่อไม่ต้องแก้ Dependency Injection
//   DashboardRemoteDataSourceImpl([dynamic _]);

//   @override
//   Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter) async {
//     // จำลองโหลดข้อมูล 200ms
//     await Future.delayed(const Duration(milliseconds: 200));

//     switch (filter) {
//       case DateRangeFilter.today:
//         return {
//           'total_spend': 12500.0,
//           'total_revenue': 45000.0,
//           'roas': 3.60,
//           'total_conversions': 145,
//           'ctr': 2.4,
//           'spend_change': 3.2,
//           'roas_change': 1.5,
//         };
//       case DateRangeFilter.last7Days:
//         return {
//           'total_spend': 145200.0,
//           'total_revenue': 522720.0,
//           'roas': 3.60,
//           'total_conversions': 1680,
//           'ctr': 2.1,
//           'spend_change': 5.0,
//           'roas_change': 2.5,
//         };
//       case DateRangeFilter.last30Days:
//       case DateRangeFilter.thisMonth:
//         return {
//           'total_spend': 580000.0,
//           'total_revenue': 2204000.0,
//           'roas': 3.80,
//           'total_conversions': 7200,
//           'ctr': 2.5,
//           'spend_change': 8.4,
//           'roas_change': 4.1,
//         };
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> fetchChartData(
//     DateRangeFilter filter,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 200));

//     return [
//       {'label': '23 Aug', 'spend': 18000.0, 'revenue': 62000.0},
//       {'label': '24 Aug', 'spend': 21000.0, 'revenue': 75000.0},
//       {'label': '25 Aug', 'spend': 19500.0, 'revenue': 68000.0},
//       {'label': '26 Aug', 'spend': 22000.0, 'revenue': 81000.0},
//       {'label': '27 Aug', 'spend': 20000.0, 'revenue': 72000.0},
//       {'label': '28 Aug', 'spend': 24000.0, 'revenue': 89000.0},
//       {'label': '29 Aug', 'spend': 20700.0, 'revenue': 75720.0},
//     ];
//   }

//   @override
//   Future<List<Map<String, dynamic>>> fetchTopCampaigns(
//     DateRangeFilter filter,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 200));

//     return [
//       {
//         'id': '1',
//         'name': 'Mega Sale - TikTok Ads',
//         'platform': 'TIKTOK',
//         'status': 'ACTIVE',
//         'spend': 65000.0,
//         'revenue': 260000.0,
//         'roas': 4.00,
//       },
//       {
//         'id': '2',
//         'name': 'Retargeting - FB Catalog',
//         'platform': 'FACEBOOK',
//         'status': 'ACTIVE',
//         'spend': 48000.0,
//         'revenue': 168000.0,
//         'roas': 3.50,
//       },
//       {
//         'id': '3',
//         'name': 'Payday - Shopee Ads',
//         'platform': 'SHOPEE',
//         'status': 'ACTIVE',
//         'spend': 32200.0,
//         'revenue': 94720.0,
//         'roas': 2.94,
//       },
//     ];
//   }
// }

// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';

// import '../../domain/entities/dashboard_metrics.dart';

// abstract class DashboardRemoteDataSource {
//   Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter);
//   Future<List<Map<String, dynamic>>> fetchChartData(DateRangeFilter filter);
//   Future<List<Map<String, dynamic>>> fetchTopCampaigns(DateRangeFilter filter);
// }

// class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
//   final SupabaseClient supabase;

//   DashboardRemoteDataSourceImpl(this.supabase);

//   Map<String, String> _getDateRange(DateRangeFilter filter) {
//     final now = DateTime.now();
//     DateTime startDate;

//     switch (filter) {
//       case DateRangeFilter.today:
//         startDate = now;
//         break;
//       case DateRangeFilter.last7Days:
//         startDate = now.subtract(const Duration(days: 6));
//         break;
//       case DateRangeFilter.last30Days:
//         startDate = now.subtract(const Duration(days: 29));
//         break;
//       case DateRangeFilter.thisMonth:
//         startDate = DateTime(now.year, now.month, 1);
//         break;
//     }

//     final formatter = DateFormat('yyyy-MM-dd');
//     return {'start': formatter.format(startDate), 'end': formatter.format(now)};
//   }

//   // Query ดึงข้อมูลจาก ad_metrics และ Join ตาราง campaigns
//   Future<List<Map<String, dynamic>>> _fetchRawData(
//     DateRangeFilter filter,
//   ) async {
//     try {
//       final dates = _getDateRange(filter);

//       // ระบุ !campaign_id ชัดเจนเพื่อให้ PostgREST รู้จัก Foreign Key ทันที
//       final response = await supabase
//           .from('ad_metrics')
//           .select('*, campaigns!campaign_id(*)')
//           .gte('record_date', dates['start']!)
//           .lte('record_date', dates['end']!);

//       debugPrint('====================================');
//       debugPrint('DEBUG: ดึงข้อมูลจาก Supabase สำเร็จ!');
//       debugPrint('DEBUG: จำนวนแถวที่พบ = ${response.length}');
//       debugPrint('====================================');

//       return List<Map<String, dynamic>>.from(response);
//     } catch (e) {
//       debugPrint('====================================');
//       debugPrint('DEBUG ERROR: เกิดข้อผิดพลาดในการ Query!');
//       debugPrint('ERROR DETAIL: $e');
//       debugPrint('====================================');
//       rethrow;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> fetchMetrics(DateRangeFilter filter) async {
//     final data = await _fetchRawData(filter);

//     double totalSpend = 0;
//     double totalRevenue = 0; // ใน DB คุณคือ sales
//     int totalClicks = 0;

//     for (var row in data) {
//       totalSpend += (row['spend'] as num).toDouble();
//       totalRevenue += (row['sales'] as num).toDouble();
//       totalClicks += (row['clicks'] ?? 0) as int;
//     }

//     // คำนวณ ROAS รวมของทุกแคมเปญ
//     final roas = totalSpend > 0 ? totalRevenue / totalSpend : 0.0;

//     return {
//       'total_spend': totalSpend,
//       'total_revenue': totalRevenue,
//       'roas': roas,
//       // สมมติตัวเลข impressions และ conversions ขึ้นมาแสดงผลใน UI เนื่องจากใน Schema ปัจจุบันไม่มี
//       // หากต้องการเก็บจริง สามารถไป ALTER TABLE เพิ่มใน Supabase ภายหลังได้
//       'total_conversions': (totalClicks * 0.05).toInt(),
//       'ctr': totalClicks > 0 ? 1.5 : 0.0,
//       'spend_change': 5.0,
//       'roas_change': 2.5,
//     };
//   }

//   @override
//   Future<List<Map<String, dynamic>>> fetchChartData(
//     DateRangeFilter filter,
//   ) async {
//     final data = await _fetchRawData(filter);

//     Map<String, Map<String, double>> groupedData = {};

//     for (var row in data) {
//       final dateStr = row['record_date'] as String;
//       final dateObj = DateTime.parse(dateStr);
//       final label = DateFormat('dd MMM').format(dateObj);

//       final spend = (row['spend'] as num).toDouble();
//       final revenue = (row['sales'] as num).toDouble(); // DB = sales

//       if (!groupedData.containsKey(label)) {
//         groupedData[label] = {'spend': 0, 'revenue': 0};
//       }
//       groupedData[label]!['spend'] = groupedData[label]!['spend']! + spend;
//       groupedData[label]!['revenue'] =
//           groupedData[label]!['revenue']! + revenue;
//     }

//     final sortedKeys = groupedData.keys.toList();
//     // Sort Date
//     sortedKeys.sort(
//       (a, b) =>
//           DateFormat('dd MMM')
//               .parse(a)
//               .compareTo(DateFormat('dd MMM').parse(b)),
//     );

//     return sortedKeys.map((label) {
//       return {
//         'label': label,
//         'spend': groupedData[label]!['spend'],
//         'revenue': groupedData[label]!['revenue'],
//       };
//     }).toList();
//   }

//   @override
//   Future<List<Map<String, dynamic>>> fetchTopCampaigns(
//     DateRangeFilter filter,
//   ) async {
//     final data = await _fetchRawData(filter);
//     Map<String, Map<String, dynamic>> campaignStats = {};

//     for (var row in data) {
//       final campaign = row['campaigns'];
//       final cId = campaign['id'];

//       if (!campaignStats.containsKey(cId)) {
//         campaignStats[cId] = {
//           'id': cId,
//           'name': campaign['campaign_name'], // DB = campaign_name
//           'platform': campaign['platform'],
//           'status': campaign['status'],
//           'spend': 0.0,
//           'revenue': 0.0,
//         };
//       }

//       campaignStats[cId]!['spend'] += (row['spend'] as num).toDouble();
//       campaignStats[cId]!['revenue'] += (row['sales'] as num).toDouble();
//     }

//     var resultList = campaignStats.values.map((c) {
//       final spend = c['spend'] as double;
//       final revenue = c['revenue'] as double;
//       c['roas'] = spend > 0 ? revenue / spend : 0.0;
//       return c;
//     }).toList();

//     resultList.sort(
//       (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
//     );
//     return resultList;
//   }
// }
