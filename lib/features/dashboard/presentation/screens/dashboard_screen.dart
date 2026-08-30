import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dashboard_metrics.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashboardFilterProvider);
    final asyncDashboardData = ref.watch(dashboardDataProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1121), // Deeper Dark Background
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'ภาพรวมแคมเปญของคุณ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildDateFilter(context, ref, filter),
          const SizedBox(width: 16),
        ],
      ),
      body: asyncDashboardData.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (data) {
          final metrics = data['metrics'] as Map<String, dynamic>;
          final campaigns = data['topCampaigns'] as List<Map<String, dynamic>>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Metric Cards Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    final cardWidth = isWide
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildPremiumMetricCard(
                          width: cardWidth,
                          title: 'ยอดใช้จ่ายโฆษณา',
                          value: currencyFormatter.format(
                            metrics['total_spend'],
                          ),
                          change: '+${metrics['spend_change']}%',
                          isPositive: false,
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF3B82F6), // Blue
                        ),
                        _buildPremiumMetricCard(
                          width: cardWidth,
                          title: 'ยอดขายรวม (Sales)',
                          value: currencyFormatter.format(
                            metrics['total_revenue'],
                          ),
                          change: '+12.4%',
                          isPositive: true,
                          icon: Icons.monetization_on_rounded,
                          color: const Color(0xFF10B981), // Emerald
                        ),
                        _buildPremiumMetricCard(
                          width: cardWidth,
                          title: 'ROAS เฉลี่ย',
                          value:
                              '${(metrics['roas'] as double).toStringAsFixed(2)}x',
                          change: '+${metrics['roas_change']}%',
                          isPositive: true,
                          icon: Icons.rocket_launch_rounded,
                          color: const Color(0xFFF59E0B), // Amber
                        ),
                        _buildPremiumMetricCard(
                          width: cardWidth,
                          title: 'Conversions',
                          value: NumberFormat('#,###')
                              .format(metrics['total_conversions']),
                          change: '+1.8%',
                          isPositive: true,
                          icon: Icons.shopping_bag_rounded,
                          color: const Color(0xFF8B5CF6), // Purple
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 2. Main Chart Placeholder (Elevates the look)
                _buildSectionHeader(
                  'แนวโน้มประสิทธิภาพ',
                  Icons.bar_chart_rounded,
                ),
                const SizedBox(height: 16),
                const DashboardChartWidget(),
                // Container(
                //   height: 250,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(
                //       color: Colors.white.withValues(alpha: 0.05),
                //     ),
                //   ),
                //   child: const Center(
                //     child: Text(
                //       'พื้นที่สำหรับแสดงกราฟ (เช่น fl_chart)',
                //       style: TextStyle(color: Colors.white38, fontSize: 14),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 32),

                // 3. Top Campaigns Table
                _buildSectionHeader('แคมเปญประสิทธิภาพสูง', Icons.star_rounded),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF162032),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                        color: Colors.black.withValues(alpha: (0.2)),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 32,
                        horizontalMargin: 24,
                        dividerThickness: 0.5,
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 60,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF1E293B),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'แคมเปญ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'แพลตฟอร์ม',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ยอดใช้จ่าย',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ยอดขาย',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ROAS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        rows: campaigns.map((c) {
                          return _buildPremiumCampaignRow(
                            c['name'],
                            c['platform'],
                            currencyFormatter.format(c['spend']),
                            currencyFormatter.format(c['revenue']),
                            '${(c['roas'] as double).toStringAsFixed(2)}x',
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildDateFilter(
    BuildContext context,
    WidgetRef ref,
    DateRangeFilter currentFilter,
  ) {
    String filterText = '7 วันล่าสุด';
    if (currentFilter == DateRangeFilter.today) filterText = 'วันนี้';
    if (currentFilter == DateRangeFilter.last30Days) {
      filterText = '30 วันล่าสุด';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: PopupMenuButton<DateRangeFilter>(
        initialValue: currentFilter,
        onSelected: (newFilter) =>
            ref.read(dashboardFilterProvider.notifier).state = newFilter,
        offset: const Offset(0, 40),
        color: const Color(0xFF1E293B),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              filterText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
          ],
        ),
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: DateRangeFilter.today,
            child: Text('วันนี้', style: TextStyle(color: Colors.white)),
          ),
          PopupMenuItem(
            value: DateRangeFilter.last7Days,
            child: Text('7 วันล่าสุด', style: TextStyle(color: Colors.white)),
          ),
          PopupMenuItem(
            value: DateRangeFilter.last30Days,
            child: Text('30 วันล่าสุด', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumMetricCard({
    required double width,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // แก้ไข: เพิ่ม Expanded และ TextOverflow ตรงนี้เพื่อป้องกันการล้น
              const Expanded(
                child: Text(
                  'เทียบกับช่วงก่อนหน้า',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildPremiumCampaignRow(
    String name,
    String platform,
    String spend,
    String revenue,
    String roas,
  ) {
    Color platformColor;
    switch (platform.toUpperCase()) {
      case 'TIKTOK':
        platformColor = const Color(0xFFE53935);
        break;
      case 'FACEBOOK':
        platformColor = const Color(0xFF1E88E5);
        break;
      case 'SHOPEE':
        platformColor = const Color(0xFFFF8F00);
        break;
      default:
        platformColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 180,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: platformColor.withValues(alpha: 0.1),
              border: Border.all(color: platformColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20), // Pill shape
            ),
            child: Text(
              platform,
              style: TextStyle(
                color: platformColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 90,
            child: Text(
              spend,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              softWrap: false,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 90,
            child: Text(
              revenue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              softWrap: false,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              roas,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:intl/intl.dart';

// import '../../domain/entities/dashboard_metrics.dart';

// // Simulated Provider for Mock Data
// final dashboardFilterProvider = StateProvider<DateRangeFilter>(
//   (ref) => DateRangeFilter.last7Days,
// );

// class DashboardScreen extends ConsumerWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currencyFormatter = NumberFormat.currency(
//       symbol: '฿',
//       decimalDigits: 0,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A), // Dark Slate
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF1E293B),
//         elevation: 0,
//         actions: [
//           // Filter Selector
//           PopupMenuButton<DateRangeFilter>(
//             initialValue: ref.watch(dashboardFilterProvider),
//             onSelected: (filter) =>
//                 ref.read(dashboardFilterProvider.notifier).state = filter,
//             icon: const Icon(Icons.calendar_today, color: Colors.white70),
//             itemBuilder: (context) => const [
//               PopupMenuItem(
//                 value: DateRangeFilter.today,
//                 child: Text('วันนี้'),
//               ),
//               PopupMenuItem(
//                 value: DateRangeFilter.last7Days,
//                 child: Text('7 วันล่าสุด'),
//               ),
//               PopupMenuItem(
//                 value: DateRangeFilter.last30Days,
//                 child: Text('30 วันล่าสุด'),
//               ),
//             ],
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       // 1. ป้องกัน Bottom Overflow ด้วย SingleChildScrollView
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Section
//             const Text(
//               'ภาพรวมโฆษณา (Overview)',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 2. ป้องกัน Right Overflow บน Cards ด้วย LayoutBuilder / Wrap
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final isWide = constraints.maxWidth > 800;
//                 return Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: [
//                     _buildMetricCard(
//                       width: isWide
//                           ? (constraints.maxWidth - 48) / 4
//                           : (constraints.maxWidth - 16) / 2,
//                       title: 'ยอดใช้จ่ายโฆษณา',
//                       value: currencyFormatter.format(145200),
//                       change: '+5.0%',
//                       isPositive: false,
//                       icon: Icons.account_balance_wallet,
//                       accentColor: Colors.blueAccent,
//                     ),
//                     _buildMetricCard(
//                       width: isWide
//                           ? (constraints.maxWidth - 48) / 4
//                           : (constraints.maxWidth - 16) / 2,
//                       title: 'ยอดขายรวม (Sales)',
//                       value: currencyFormatter.format(522720),
//                       change: '+12.4%',
//                       isPositive: true,
//                       icon: Icons.monetization_on,
//                       accentColor: Colors.greenAccent,
//                     ),
//                     _buildMetricCard(
//                       width: isWide
//                           ? (constraints.maxWidth - 48) / 4
//                           : (constraints.maxWidth - 16) / 2,
//                       title: 'ROAS เฉลี่ย',
//                       value: '3.60x',
//                       change: '+2.5%',
//                       isPositive: true,
//                       icon: Icons.trending_up,
//                       accentColor: Colors.amberAccent,
//                     ),
//                     _buildMetricCard(
//                       width: isWide
//                           ? (constraints.maxWidth - 48) / 4
//                           : (constraints.maxWidth - 16) / 2,
//                       title: 'จำนวน Conversions',
//                       value: '1,680',
//                       change: '+1.8%',
//                       isPositive: true,
//                       icon: Icons.shopping_cart,
//                       accentColor: Colors.purpleAccent,
//                     ),
//                   ],
//                 );
//               },
//             ),

//             const SizedBox(height: 24),

//             // Top Campaigns Section
//             const Text(
//               'แคมเปญประสิทธิภาพสูง (Top Campaigns)',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // 3. ป้องกัน Right Overflow ใน ตาราง ด้วย SingleChildScrollView แบบ Horizontal
//             Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1E293B),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: DataTable(
//                   columnSpacing: 28, // เพิ่มระยะห่างระหว่างคอลัมน์
//                   horizontalMargin: 16,
//                   headingRowColor: WidgetStateProperty.all(
//                     Colors.white.withValues(alpha: 0.05),
//                   ),
//                   columns: const [
//                     DataColumn(
//                       label: Text(
//                         'แคมเปญ',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     DataColumn(
//                       label: Text(
//                         'แพลตฟอร์ม',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     DataColumn(
//                       label: Text(
//                         'ยอดใช้จ่าย',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     DataColumn(
//                       label: Text(
//                         'ยอดขาย',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     DataColumn(
//                       label: Text(
//                         'ROAS',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                   rows: [
//                     _buildCampaignRow(
//                       'Mega Sale - TikTok Ads',
//                       'TIKTOK',
//                       '฿65,000',
//                       '฿260,000',
//                       '4.00x',
//                       Colors.pinkAccent,
//                     ),
//                     _buildCampaignRow(
//                       'Retargeting - FB Catalog',
//                       'FACEBOOK',
//                       '฿48,000',
//                       '฿168,000',
//                       '3.50x',
//                       Colors.blueAccent,
//                     ),
//                     _buildCampaignRow(
//                       'Payday - Shopee Ads',
//                       'SHOPEE',
//                       '฿32,200',
//                       '฿94,720',
//                       '2.94x',
//                       Colors.deepOrange,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Metric Card Helper Widget
//   Widget _buildMetricCard({
//     required double width,
//     required String title,
//     required String value,
//     required String change,
//     required bool isPositive,
//     required IconData icon,
//     required Color accentColor,
//   }) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E293B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // 4. หุ้มด้วย Expanded และ TextOverflow เพื่อป้องกันข้อความยาวจนล้นขวา
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Icon(icon, color: accentColor, size: 20),
//             ],
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 isPositive ? Icons.arrow_upward : Icons.arrow_downward,
//                 color: isPositive ? Colors.greenAccent : Colors.redAccent,
//                 size: 14,
//               ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   change,
//                   style: TextStyle(
//                     color: isPositive ? Colors.greenAccent : Colors.redAccent,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   DataRow _buildCampaignRow(
//     String name,
//     String platform,
//     String spend,
//     String revenue,
//     String roas,
//     Color platformColor,
//   ) {
//     return DataRow(
//       cells: [
//         DataCell(
//           SizedBox(
//             width: 180,
//             child: Text(
//               name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         DataCell(
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: platformColor.withValues(alpha: 0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               platform,
//               style: TextStyle(
//                 color: platformColor,
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         DataCell(
//           Text(
//             spend,
//             style: const TextStyle(color: Colors.white70),
//             softWrap: false,
//           ),
//         ),
//         DataCell(
//           SizedBox(
//             width: 95, // กำหนดพื้นที่ให้ยอดขายเพียงพอสำหรับตัวเลข 6 หลักขึ้นไป
//             child: Text(
//               revenue,
//               style: const TextStyle(color: Colors.white70),
//               softWrap: false, // ห้ามขึ้นบรรทัดใหม่
//             ),
//           ),
//         ),
//         DataCell(
//           Text(
//             roas,
//             style: const TextStyle(
//               color: Colors.greenAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
