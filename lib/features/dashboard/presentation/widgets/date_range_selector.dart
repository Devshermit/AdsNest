import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../controllers/dashboard_controller.dart';

class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  String _getLabel(DateRangeFilter filter) {
    switch (filter) {
      case DateRangeFilter.today:
        return 'วันนี้';
      case DateRangeFilter.last7Days:
        return '7 วันล่าสุด';
      case DateRangeFilter.last30Days:
        return '30 วันล่าสุด';
      case DateRangeFilter.thisMonth:
        return 'เดือนนี้';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(dashboardFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateRangeFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getLabel(filter)),
              selected: isSelected,
              onSelected: (_) {
                ref.read(dashboardFilterProvider.notifier).state = filter;
              },
              selectedColor: AppColors.primaryRed,
              backgroundColor: AppColors.surfaceDark,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.textWhite : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: const BorderSide(color: AppColors.borderGrey),
            ),
          );
        }).toList(),
      ),
    );
  }
}
