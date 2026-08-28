import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';

// State Provider สำหรับเก็บตัวกรองช่วงเวลาปัจจุบัน
final selectedDateFilterProvider = StateProvider<DateRangeFilter>((ref) {
  return DateRangeFilter.last7Days;
});

// Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return DashboardRepositoryImpl(
    remoteDataSource: DashboardRemoteDataSourceImpl(supabase),
  );
});

// Provider ดึงข้อมูลทั้งหมดใน Dashboard แบบรวมศูนย์
final dashboardDataProvider = FutureProvider.autoDispose((ref) async {
  final filter = ref.watch(selectedDateFilterProvider);
  final repo = ref.watch(dashboardRepositoryProvider);

  final metrics = await repo.getMetrics(filter);
  final chartData = await repo.getChartData(filter);
  final campaigns = await repo.getTopCampaigns(filter);

  return (metrics: metrics, chartData: chartData, campaigns: campaigns);
});
