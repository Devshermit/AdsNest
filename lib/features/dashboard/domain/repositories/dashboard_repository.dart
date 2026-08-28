
import '../entities/dashboard_metrics.dart';

abstract class DashboardRepository {
  Future<DashboardMetrics> getMetrics(DateRangeFilter filter);
  Future<List<PerformanceChartPoint>> getChartData(DateRangeFilter filter);
  Future<List<CampaignSummary>> getTopCampaigns(DateRangeFilter filter);
}