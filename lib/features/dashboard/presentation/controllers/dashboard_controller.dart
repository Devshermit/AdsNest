// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';

// import '../../../../core/providers/core_providers.dart';
// import '../../data/datasources/dashboard_remote_datasource.dart';
// import '../../data/repositories/dashboard_repository_impl.dart';
// import '../../domain/entities/dashboard_metrics.dart';
// import '../../domain/repositories/dashboard_repository.dart';

// // State Provider สำหรับเก็บตัวกรองช่วงเวลาปัจจุบัน
// final selectedDateFilterProvider = StateProvider<DateRangeFilter>((ref) {
//   return DateRangeFilter.last7Days;
// });

// // Repository Provider
// final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
//   final supabase = ref.watch(supabaseClientProvider);
//   return DashboardRepositoryImpl(
//     remoteDataSource: DashboardRemoteDataSourceImpl(supabase),
//   );
// });

// // Provider ดึงข้อมูลทั้งหมดใน Dashboard แบบรวมศูนย์
// final dashboardDataProvider = FutureProvider.autoDispose((ref) async {
//   final filter = ref.watch(selectedDateFilterProvider);
//   final repo = ref.watch(dashboardRepositoryProvider);

//   final metrics = await repo.getMetrics(filter);
//   final chartData = await repo.getChartData(filter);
//   final campaigns = await repo.getTopCampaigns(filter);

//   return (metrics: metrics, chartData: chartData, campaigns: campaigns);
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../domain/entities/dashboard_metrics.dart';

// 1. Provider สำหรับเก็บสถานะ Date Filter (ค่าเริ่มต้นเป็น 7 วันล่าสุด)
final dashboardFilterProvider = StateProvider<DateRangeFilter>((ref) {
  return DateRangeFilter.last7Days;
});

// 2. Provider สำหรับดึง Data Source
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSourceImpl(Supabase.instance.client);
});

// 3. Main Data Provider ที่จะคอย re-fetch ข้อมูลใหม่เมื่อ filter เปลี่ยน
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final filter = ref.watch(dashboardFilterProvider);
  final dataSource = ref.watch(dashboardRemoteDataSourceProvider);

  // ดึงข้อมูลทั้ง 3 ส่วนพร้อมกันแบบ Parallel เพื่อความเร็ว
  final results = await Future.wait([
    dataSource.fetchMetrics(filter),
    dataSource.fetchChartData(filter),
    dataSource.fetchTopCampaigns(filter),
  ]);

  return {
    'metrics': results[0] as Map<String, dynamic>,
    'chartData': results[1] as List<Map<String, dynamic>>,
    'topCampaigns': results[2] as List<Map<String, dynamic>>,
  };
});
