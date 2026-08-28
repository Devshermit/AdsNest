import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardMetrics> getMetrics(DateRangeFilter filter) async {
    final raw = await remoteDataSource.fetchMetrics(filter);
    return DashboardMetrics(
      totalSpend: (raw['total_spend'] as num).toDouble(),
      totalRevenue: (raw['total_revenue'] as num).toDouble(),
      roas: (raw['roas'] as num).toDouble(),
      totalConversions: raw['total_conversions'] as int,
      ctr: (raw['ctr'] as num).toDouble(),
      spendChangePercentage: (raw['spend_change'] as num).toDouble(),
      roasChangePercentage: (raw['roas_change'] as num).toDouble(),
    );
  }

  @override
  Future<List<PerformanceChartPoint>> getChartData(
    DateRangeFilter filter,
  ) async {
    final list = await remoteDataSource.fetchChartData(filter);
    return list
        .map(
          (e) => PerformanceChartPoint(
            label: e['label'],
            spend: (e['spend'] as num).toDouble(),
            revenue: (e['revenue'] as num).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<List<CampaignSummary>> getTopCampaigns(DateRangeFilter filter) async {
    final list = await remoteDataSource.fetchTopCampaigns(filter);
    return list
        .map(
          (e) => CampaignSummary(
            id: e['id'],
            name: e['name'],
            platform: e['platform'],
            spend: (e['spend'] as num).toDouble(),
            revenue: (e['revenue'] as num).toDouble(),
            roas: (e['roas'] as num).toDouble(),
            status: e['status'],
          ),
        )
        .toList();
  }
}
