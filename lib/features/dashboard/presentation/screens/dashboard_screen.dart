import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/metric_card.dart';
import '../widgets/performance_chart_widget.dart';
import '../widgets/top_campaigns_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardDataProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          final m = data.metrics;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DateRangeSelector(),
                const SizedBox(height: 20),

                // Responsive Metric Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isTablet ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isTablet ? 1.3 : 1.1,
                  children: [
                    MetricCard(
                      title: 'ยอดใช้จ่ายทั้งหมด',
                      value: AppFormatters.formatCurrency(m.totalSpend),
                      changePercentage: m.spendChangePercentage,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    MetricCard(
                      title: 'รายได้รวม (Revenue)',
                      value: AppFormatters.formatCurrency(m.totalRevenue),
                      changePercentage: 15.2,
                      icon: Icons.monetization_on_outlined,
                    ),
                    MetricCard(
                      title: 'ROAS เฉลี่ย',
                      value: AppFormatters.formatRoas(m.roas),
                      changePercentage: m.roasChangePercentage,
                      icon: Icons.auto_graph_outlined,
                    ),
                    MetricCard(
                      title: 'ยอดการแปลง (Conversions)',
                      value: '${m.totalConversions} รายการ',
                      changePercentage: 5.4,
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart & Top Campaigns Layout
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: PerformanceChartWidget(points: data.chartData),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TopCampaignsWidget(campaigns: data.campaigns),
                      ),
                    ],
                  )
                else ...[
                  PerformanceChartWidget(points: data.chartData),
                  const SizedBox(height: 20),
                  TopCampaignsWidget(campaigns: data.campaigns),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
        error: (err, stack) => Center(
          child: Text(
            'เกิดข้อผิดพลาด: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
