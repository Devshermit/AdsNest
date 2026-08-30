import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChartWidget extends StatelessWidget {
  const DashboardChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลจำลองแนวโน้มรายวัน (x: วันที่, y: จำนวนเงิน)
    final revenueSpots = const [
      FlSpot(0, 12000),
      FlSpot(1, 19000),
      FlSpot(2, 15000),
      FlSpot(3, 28000),
      FlSpot(4, 22000),
      FlSpot(5, 34000),
      FlSpot(6, 41000),
    ];

    final spendSpots = const [
      FlSpot(0, 4000),
      FlSpot(1, 5500),
      FlSpot(2, 5000),
      FlSpot(3, 8000),
      FlSpot(4, 7500),
      FlSpot(5, 11000),
      FlSpot(6, 12500),
    ];

    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // คำอธิบายเส้นกราฟ (Legend)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem('ยอดขาย (Revenue)', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _buildLegendItem('ยอดใช้จ่าย (Spend)', const Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 16),
          // ตัวกราฟ fl_chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'จ.',
                          'อ.',
                          'พ.',
                          'พฤ.',
                          'ศ.',
                          'ส.',
                          'อา.',
                        ];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 10000,
                      getTitlesWidget: (value, meta) {
                        String label = '';
                        if (value >= 1000) {
                          label = '${(value / 1000).toStringAsFixed(0)}k';
                        } else {
                          label = value.toStringAsFixed(0);
                        }
                        return Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 50000,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                    tooltipBorderRadius: BorderRadius.circular(8.0),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isRevenue = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isRevenue ? "Sales" : "Spend"}: ฿${spot.y.toInt()}',
                          TextStyle(
                            color: isRevenue
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // เส้นที่ 1: ยอดขาย (Sales / Revenue) - สีเขียว
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    ),
                  ),
                  // เส้นที่ 2: ยอดโฆษณา (Spend) - สีฟ้า
                  LineChartBarData(
                    spots: spendSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
